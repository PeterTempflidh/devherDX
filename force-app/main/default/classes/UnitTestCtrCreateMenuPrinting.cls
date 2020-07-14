@isTest
private class UnitTestCtrCreateMenuPrinting {
private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Case','Opportunity_Quote__c','Opportunity_Quote_Line_Item__c'});
private static List<Account> accList;   
private static List_Product_Price__c lpp;
    static{
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
       
        List<InterestedOppClosedLost__c> intOppClosedSetting =new List<InterestedOppClosedLost__c>(); 
        intOppClosedSetting.add(new InterestedOppClosedLost__c(name='Interested',Values__c='Not enough capacity'));
        insert intOppClosedSetting;
        UnitTestDataFactory.getRecordtypeValues();
    
    
 
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert testCountry;
        
        company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'HH', testCountry);
            insert com;
         accList= UnitTestDataFactory.createAccounts(1,testCountry,'UK_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'UK_Opportunity',Date.today());
        insert oppList;
         Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Draft');
         newQuote.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity_Quote');
        insert newQuote;
        Tarif__c t = UnitTestDataFactory.createTarif(com,testCountry,'Menu Printing','UK_Tarif',false);
        insert t;
        
        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','UK_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Menu Printing','UK_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        lpp = UnitTestDataFactory.createProduct(com,testCountry,'Menu Printing with website',lpg.id,'UK_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Menu Printing without website',lpg1.id,'UK_List_Product_Price',1,true,100,1,false,20); 
        lpp1.product_type__c='Menu Printing';
        lpp.product_type__c='Menu Printing';
        insert new List<sobject>{lpp1,lpp};
        
        
    }
    
     @isTest static void test_menuprinting_positive() {
        Map<Id,string>mpProducts = CtrCreateMenuPrinting.getMenuPrintingProducts('United Kingdom');
        Map<String,string> size =CtrCreateMenuPrinting.getSizes();
        Map<String,string> wts =CtrCreateMenuPrinting.getWeights();
        Map<String,string> copy=CtrCreateMenuPrinting.getNumberOfCopies();
        Map<String,string> deposit=CtrCreateMenuPrinting.getDepositMethods();
        string lppid = lpp.id;
        String prod='test;A4;100g;10k;200;direct debit;100;test;100.00;'+lppid;
        List<string> prodLst = new List<string>();
        prodLst.add(prod);
        
        List<opportunity_Quote_Line_Item__c> oqli=CtrCreateMenuPrinting.saveMenuPrinting(prodLst,'United Kingdom',accList[0].id);
        
     
     }
     
     }