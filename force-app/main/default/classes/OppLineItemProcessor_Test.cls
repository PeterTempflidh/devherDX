/**
* @author Peter Kalina
* @date 14.05.2019
*
* @description Test class for Apex Class (ClsOppLineItemProcessor, ClsOppLineItemHandler)
*/
@IsTest
private class OppLineItemProcessor_Test {
	
    /*******************************************************************************************************
    * @description test if Start Date was going to be changed in Opportunity;
    */
    @IsTest
    public static void updateOpportunityStartDate_Test(){
        UnitTestDataFactory.getRecordtypeValues();
        Map<String, String> mapCountryCurrency = LibBusinessConfig.recordCurrencyMap();
        
        Country__c cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
        insert cd;
        
        Account acco = UnitTestDataFactory.createAccount('TEST', cd, 'CD_Account');
        acco.Type = 'Branch - main';
        insert acco;
        
        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', (Date.today() + 4));
        oppt.Business_Type__c = 'New Business';
        insert oppt;
        
        List<Opportunity_Line_Item__c> listOppLI = new List<Opportunity_Line_Item__c>();
        for(Integer i = 0; i < 3; i++){
            listOppLI.add(new Opportunity_Line_Item__c(
                    Name = 'Test_Opportunity_Line_Item_' + i,
                    Id_Opportunity__c = oppt.Id,
                	Line_Item_Type__c = 'Service',
                    Start_Date__c = Date.Today() + i + 1,
                    RecordtypeId = UnitTestDataFactory.mapRecordtypes.get('CD_Opportunity_Line_Item').Id,
                    CurrencyIsoCode = mapCountryCurrency.get(oppt.Record_Country__c)
                )
            );
        }
		
        Test.startTest();
        insert listOppLI;
        listOppLI[0].Start_Date__c = Date.Today() - 1;
		update listOppLI;
        List<Opportunity> oppt2 = new List<Opportunity>([Select ID, Start_Date_uk__c, Name, Level__c From Opportunity where ID =: oppt.ID]);
        Test.stopTest();
        
        System.assertEquals(oppt2[0].Start_Date_uk__c, (Date.Today() - 1));
    }

    /*******************************************************************************************************
    * @description Test class for the mutliple commission then populate the earliest commission on Oppty Start date
    */
    @IsTest
    public static void updateOpptyStartDateWithEarliestCommissionDate(){
        UnitTestDataFactory.getRecordtypeValues();
        Map<String, String> mapCountryCurrency = LibBusinessConfig.recordCurrencyMap();

        Country__c cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
        insert cd;

        Account acco = UnitTestDataFactory.createAccount('TEST', cd, 'CD_Account');
        acco.Type = 'Branch - main';
        insert acco;

        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', (Date.today() + 4));
        oppt.Business_Type__c = 'New Business';
        insert oppt;

        List<Opportunity_Line_Item__c> listOppLI = new List<Opportunity_Line_Item__c>();
        for(Integer i = 0; i < 1; i++){
            listOppLI.add(new Opportunity_Line_Item__c(
                    Name = 'Test_Opportunity_Line_Item_' + i,
                    Id_Opportunity__c = oppt.Id,
                    Line_Item_Type__c = 'Service',
                    Sub_type__c = 'Commission Fee',
                    Start_Date__c = Date.Today() + i + 1,
                    RecordtypeId = UnitTestDataFactory.mapRecordtypes.get('CD_Opportunity_Line_Item').Id,
                    CurrencyIsoCode = mapCountryCurrency.get(oppt.Record_Country__c)
            )
            );
        }
        List<Opportunity_Line_Item__c> listOppLINew = new List<Opportunity_Line_Item__c>();
        for(Integer i = 0; i < 1; i++){
            listOppLI.add(new Opportunity_Line_Item__c(
                    Name = 'Test_Opportunity_Line_Item_' + i,
                    Id_Opportunity__c = oppt.Id,
                    Line_Item_Type__c = 'Service',
                    Sub_type__c = 'Commission Fee',
                    Start_Date__c = Date.Today() - 5,
                    RecordtypeId = UnitTestDataFactory.mapRecordtypes.get('CD_Opportunity_Line_Item').Id,
                    CurrencyIsoCode = mapCountryCurrency.get(oppt.Record_Country__c)
            )
            );
        }
        insert listOppLI;
        Test.startTest();
        insert listOppLINew;
        listOppLI[0].Start_Date__c = Date.Today() - 5;
        update listOppLI;
        List<Opportunity> oppt2 = new List<Opportunity>([Select ID, Start_Date_uk__c, Name, Level__c From Opportunity where ID =: oppt.ID]);
        Test.stopTest();

        System.assertEquals(oppt2[0].Start_Date_uk__c, (Date.Today() - 5));
    }
}