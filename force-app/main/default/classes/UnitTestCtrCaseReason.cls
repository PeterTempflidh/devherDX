@isTest
private class UnitTestCtrCaseReason {
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
  
    static testMethod void caseReasontest() {
        UnitTestDataFactory.getRecordtypeValues();
        Case theCase = new Case(
                           Type = 'Partner',
                           Subject = 'test restaurant', 
                           RecordTypeId = mapRecordtypes.get('AT_Inbound_Case').id , 
                           Status = 'New');
           
        insert theCase;



    
    
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(theCase);
        CtrCaseReason ctr = new CtrCaseReason(stdCtr);
    }
    
}