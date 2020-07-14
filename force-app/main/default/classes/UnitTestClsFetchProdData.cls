@isTest
private class UnitTestClsFetchProdData {


     @isTest
      static void fetchDataTest1(){
      
      ClsFetchProdData cfp=new ClsFetchProdData('test','test');
      cfp.fetchData();
      List<jsonparser> lp = cfp.fetch('account__c');
     
     }



}