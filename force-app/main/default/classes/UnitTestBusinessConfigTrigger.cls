@isTest
private class UnitTestBusinessConfigTrigger {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c testCountry = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert testCountry;

		List<Business_Config__c> configs = new List<Business_Config__c>();

		configs.add( new Business_Config__c(
		                 Business_Rule_Name__c = 'Select options',
		                 Business_Rule_Value__c = 'Account Clone Flyer,Account Clone Owner Change',
		                 Id_country__c = testCountry.Id,
		                 Is_Active__c = true,
		                 Parent__c = true,
		                 Process_Name__c = 'Account Clone Select Options',
		                 Record_Type_Id__c = 'Yogiyo_Account',
		                 Type__c = 'Process'
		             ));

		configs.add( new Business_Config__c(
		                 Business_Rule_Name__c = 'Copy fields',
		                 Business_Rule_Value__c = 'RecordTypeId,CurrencyIsoCode,Name,Restaurant_Name__c,BillingStreet,Menu_Typing_By_User__c,BillingPostalCode,Menu_Typing_Date_Start__c,BillingCity,Menu_Typing_Progress_Status__c,BillingState,Final_Check_Date__c,BillingCountry,Billing_Dong__c,Billing_GunGu__c,Billing_Subdistrict__c,Record_Country__c',
		                 Id_country__c = testCountry.Id,
		                 Is_Active__c = true,
		                 Parent__c = true,
		                 Process_Name__c = 'Account Clone Flyer',
		                 Record_Type_Id__c = 'Yogiyo_Account',
		                 Type__c = 'Process'
		             ));

		insert configs;
	}

	@isTest static void moamIsRetrievedFromCache() {
		Test.startTest();

		// load the cache
		Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;

		Test.stopTest();

		System.assert(Cache.Org.getPartition(LibBusinessConfig.MOAM_ORG_CACHE_PARTITION).contains(LibBusinessConfig.MOAM_ORG_CACHE_KEY));
	}

	@isTest static void moamIsRemovedFromCacheAfterInsert() {
		Country__c c = [Select Id from Country__c limit 1];

		Test.startTest();
		// load the cache
		Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;

		insert new Business_Config__c(
		    Business_Rule_Name__c = 'Select options',
		    Business_Rule_Value__c = 'Account Clone Flyer,Account Clone Owner Change',
		    Id_country__c = c.Id,
		    Is_Active__c = true,
		    Parent__c = true,
		    Process_Name__c = 'Account Clone Select Options 2',
		    Record_Type_Id__c = 'Yogiyo_Account',
		    Type__c = 'Process'
		);

		Test.stopTest();

		System.assert(!Cache.Org.getPartition(LibBusinessConfig.MOAM_ORG_CACHE_PARTITION).contains(LibBusinessConfig.MOAM_ORG_CACHE_KEY));
	}

	@isTest static void moamIsRemovedFromCacheAfterUpdate() {
		Business_Config__c bc = [Select Business_Rule_Value__c From Business_Config__c limit 1];

		Test.startTest();

		// load the cache
		Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;

		bc.Business_Rule_Value__c = 'new text';
		update bc;

		Test.stopTest();

		System.assert(!Cache.Org.getPartition(LibBusinessConfig.MOAM_ORG_CACHE_PARTITION).contains(LibBusinessConfig.MOAM_ORG_CACHE_KEY));
	}

	@isTest static void moamIsRemovedFromCacheAfterDelete() {
		Business_Config__c bc = [Select Business_Rule_Value__c From Business_Config__c limit 1];

		Test.startTest();

		// load the cache
		Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;

		delete bc;

		Test.stopTest();

		System.assert(!Cache.Org.getPartition(LibBusinessConfig.MOAM_ORG_CACHE_PARTITION).contains(LibBusinessConfig.MOAM_ORG_CACHE_KEY));
	}

}