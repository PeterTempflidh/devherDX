// NOTE: most probably is deprecated - @CreatedBy m.zeuli
@isTest
private class UnitTestCtrPreChatForm {

    static{
        UnitTestDataFactory.getRecordtypeValues();
        List<LiveAgent__c> laSettings=new List<LiveAgent__c>(); 
        laSettings.add(new LiveAgent__c(name='test',Brand__c='test',BrandImage__c='test',Language__c='en',Problem__c='test1,test2'   ));
        
        insert laSettings;
    
    }
    static testmethod void UnitTest1(){
         ApexPages.currentPage().getParameters().put('endpoint','&button_id=test&session_id');

        Test.startTest();

        ctrPreChatForm ctrl = new ctrPreChatForm();
        List<string> pickVal =ctrl.getProblems();
        Test.stopTest();
    }

}