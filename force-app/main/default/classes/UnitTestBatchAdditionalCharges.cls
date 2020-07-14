@isTest
public class UnitTestBatchAdditionalCharges {
static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity'});
    static User testRunningUser = [SELECT Id,Username,Email FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];

    static{
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;
        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1',c,'Yogiyo_Account');
        Account acc2 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'Yogiyo_Account');
        Account acc3 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'Yogiyo_Account');
        BatchOpportunityTarif_MigrationText__c cs = new BatchOpportunityTarif_MigrationText__c(name='FilterText',Value__c='Migration');
        
        insert new List<SObject>{acc1,acc2,acc3,cs};


        Opportunity opp1 = new Opportunity(CurrencyIsoCode='KRW',Setup_Fee_AU__c=155,Start_Date_uk__c=Date.newInstance(2014, 12, 21),name='BatchTestOpp1', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc1.id,CloseDate=Date.newInstance(2014, 12, 21), StageName='Prospecting', TarrifName_AU__c='testTarif1',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration');
        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c,'Setup Fee','Yogiyo_List_Product_Group');
        insert new List<SObject>{opp1,lpg,lpg1};
        System.debug('opp1: '+opp1);
        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c,'Ipad 4 Gen. 16GB',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 1',lpg1.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 2',lpg1.id,'Yogiyo_List_Product_Price',1,true,50,1,false,20);  
        insert new List<sObject>{lpp,lpp1,lpp2};
        List<Opportunity_Quote__c> oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(opp1, 1,'Yogiyo_Opportunity_Quote','Draft','test data',100.45,100.45,'','',0);
        insert oppQuoteList;
        System.debug('oppQuoteList: '+oppQuoteList);
        List<Opportunity_Quote_Line_Item__c> oqp=UnitTestDataFactory.createOpportunityQuoteLineItems(oppQuoteList[0],lpp.id,lpg.id,4,true,'Yogiyo_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        System.debug('oqp: '+oqp);
        insert oqp;
       }
    @isTest static void test_method_one() {
                
        Test.startTest();
        System.runAs(testRunningUser){
            BatchAdditionalCharges batch = new BatchAdditionalCharges();
            Database.executeBatch(batch,500);
        }
        Test.stopTest();
        System.assertEquals(([select id from Additional_Charges__c]).size(),4);       

    }
}