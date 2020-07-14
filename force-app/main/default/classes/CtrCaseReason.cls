public class CtrCaseReason {
    public String caseRecId{get;set;}
    public string json3to2 {get;set;}
    public string json2to1 {get;set;}
    public string json1toType {get;set;}
  
    public CtrCaseReason(ApexPages.StandardController controller) {
        Case c = (case)controller.getRecord();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType pType = objGlobalMap.get('Case');
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        Schema.SObjectField caseType =objFieldMap.get('Type');
        Schema.SObjectField caseReason1 =objFieldMap.get('Case_Reason_Level_1__c');
        Schema.SObjectField caseReason2 =objFieldMap.get('Case_Reason_Level_2__c');
        Schema.SObjectField caseReason3 =objFieldMap.get('Case_Reason_Level_3__c');
      


        caseRecId=String.valueof(c.recordtypeid).substring(0,15);
        Map<String,String> Level3ToLevel2 = LibBitSet.getDependentOptionsImpl(caseReason3,caseReason2);
        Map<String,String>Level2ToLevel1  = LibBitSet.getDependentOptionsImpl(caseReason2,caseReason1);      
        Map<String,String>Level1toType = LibBitSet.getDependentOptionsImpl(caseReason1,caseType);
      
        json3to2=JSON.serialize(Level3ToLevel2);
        json2to1=JSON.serialize(Level2ToLevel1);
        json1toType=JSON.serialize(Level1ToType);
        json1toType=JSON.serialize(Level1ToType);


    }

  }