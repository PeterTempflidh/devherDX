@isTest
private class UnitTestBatchAttachQuoteOnOpp{

    static {
        UnitTestDataFactory.getRecordtypeValues();
        Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity','Opportunity_Quote','Account'});
        Country__c c = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;
        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1',c,'Yogiyo_Account');
        insert acc1;
        Opportunity opp1 = new Opportunity(Setup_Fee_AU__c=150,Start_Date_uk__c=Date.newInstance(2014, 12, 05),name='BatchTestOpp6', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc1.id,CloseDate=Date.today(), StageName='Closed Won', TarrifName_AU__c='testTarif2',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration');


        insert opp1;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp1.id, status__c = 'Draft');
        newQuote.recordtypeid = LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity_Quote');
        newQuote.status__c = 'Accepted';
        insert newQuote;
    }
    
    
     @isTest static void test_method_two() {
        Test.startTest();

            BatchAttachOppQuoteOnOpp btc = new BatchAttachOppQuoteOnOpp('Yogiyo_Opportunity_Quote');
            Database.executeBatch(btc);

        Test.stopTest();
        
    }
    
    
    
    
    
 }