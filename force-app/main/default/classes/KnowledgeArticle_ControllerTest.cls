/**
 * Created by p.bansal on 02-Jan-20.
 * Description: Class contains logic of setting capacity through a custom LWC 
 */
@IsTest
public with sharing class KnowledgeArticle_ControllerTest {
    @TestSetup
    static void TestSetup(){
        List<Knowledge__kav> knowArticleswithDataCategory = new List<Knowledge__kav>();
        List<Knowledge__DataCategorySelection> articlesCategorizations = new List<Knowledge__DataCategorySelection>();
   
        //Insert Articles
        for(Integer i = 0;i<10; i++){
            Knowledge__kav rec = new Knowledge__kav();
            rec.Title= 'Test Title '+i;
            rec.UrlName = 'TestURLName'+i;
            rec.Article_Detail__c = i+') Test Article Detail';
            knowArticleswithDataCategory.add(rec); 
        }
            insert knowArticleswithDataCategory;
        Set<Id> articlesIdSet = new Set<Id>();
        for(Knowledge__kav rec: knowArticleswithDataCategory){
            articlesIdSet.add(rec.Id);
        }

        //Assign Data Categories to articles and publish
        for(Knowledgearticleversion artcl : [SELECT Id,Title,PublishStatus,Language,IsVisibleInPkb,
                                            KnowledgeArticleId FROM Knowledgearticleversion
                                            WHERE id IN: articlesIdSet]) {
            Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
            dataCategory.ParentId = artcl.Id;
            dataCategory.DataCategoryGroupName = 'Case_Reasons';
            dataCategory.DataCategoryName = 'Connection_issues';
            articlesCategorizations.add(dataCategory);
            KbManagement.PublishingService.publishArticle(artcl.KnowledgeArticleId, true); 
        }

        insert articlesCategorizations;

        //Insert articles without Data Category
        List<Knowledge__kav> knowArticleswithoutDataCategory = new List<Knowledge__kav>();
        Set<Id> articlesIdsWithOutDC = new Set<Id>();
        FOR(Integer i = 11; i<=20; i++ ){
            Knowledge__kav rec = new Knowledge__kav();
            rec.Title= 'Test Title '+i;
            rec.UrlName = 'TestURLName'+i;
            rec.Article_Detail__c = i+') Test Article Detail';
            knowArticleswithoutDataCategory.add(rec); 
        }
        insert knowArticleswithoutDataCategory;
        FOR(Knowledge__kav rec: knowArticleswithoutDataCategory){
            articlesIdsWithOutDC.add(rec.Id);
        }
        //Publish articles without Data Category
        for(Knowledgearticleversion artcl : [SELECT Id,Title,PublishStatus,Language,IsVisibleInPkb,
                                            KnowledgeArticleId FROM Knowledgearticleversion
                                            WHERE id IN: articlesIdsWithOutDC]) {           
            KbManagement.PublishingService.publishArticle(artcl.KnowledgeArticleId, true);
        }

      
        //Insert Chat Records 
        //1. Insert Business Configs
        UnitTestDataFactory.getRecordtypeValues();
        Country__c hk = UnitTestDataFactory.createCountry('FP', 'Hong Kong', 'HKD');
        insert hk;

        List<Business_Config__c> configs = new List<Business_Config__c>();

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FP_Inbound_Case').getRecordTypeId();
        configs.add(
            new Business_Config__c(
                Process_Name__c = 'ChatToCase',
                Business_Rule_Name__c = 'Platform',
                Business_Rule_Value__c = 'Foodpanda',
                Id_Country__c = hk.id,
                Is_Active__c = true,
                Record_Type_Id__c = 'Foodpanda',
                Type__c = 'Process',
                Parent__c = true
            ));
            String businessRuleValue = '[  {    "CaseField": "RecordTypeId",    "Value": "' + recordTypeId + '"  },  { "CaseField": "OwnerId","ChatField": "OwnerId" },{"CaseField": "Origin","Value": "Chat"},{"CaseField": "Status","Value": "New"}, {    "ChatField": "Platform__c",    "CaseField": "Platform__c"  },  {    "ChatField": "Order_Number__c",    "CaseField": "Order_Number__c"  },'; 
            businessRuleValue+= '{    "ChatField": "My_Problem__c",    "CaseField": "Description"  },  {    "ChatField": "My_Problem__c",    "CaseField": "Subject"  },' ;
            businessRuleValue+='{    "ChatField": "Case_Reason_Level_1__c",    "CaseField": "Case_Reason_Level_1__c"  }, {    "ChatField": "Case_Reason_Level_2__c",    "CaseField": "Case_Reason_Level_2__c"  }, {    "ChatField": "Case_Reason_Level_3__c",    "CaseField": "Case_Reason_Level_3__c"  }, {    "ChatField": "Type__c",    "CaseField": "Type"  }]';
        configs.add(
            new Business_Config__c(
                Process_Name__c = 'ChatToCase',
                Business_Rule_Name__c = 'FieldsMap',
                Business_Rule_Value__c = businessRuleValue,  
                Id_Country__c = hk.id,
                Is_Active__c = true,
                Record_Type_Id__c = 'Foodpanda',
                Type__c = 'Process',
                Parent__c = true
            )
        );

        insert configs;
        //2. Insert LiveChatVisitor
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        //3.i) Insert LiveChatTranscript with CLRs
        List<LiveChatTranscript> chatRecordList = new List<LiveChatTranscript>();
        LiveChatTranscript liveChatTranscriptrecord = new LiveChatTranscript(
                Platform__c = 'Foodpanda',
                Order_Number__c = '1234567890001',
                Email__c = 'test@deliveryhero.com',
                User_Name__c = 'test name',
                My_Problem__c = 'Kunde - Anderes Problem',
                Body='Hello',
                LiveChatVisitorId=visitor.id,
                Case_Reason_Level_1__c = 'Technical Inquiry',
                Case_Reason_Level_2__c = 'Printer',
                Case_Reason_Level_3__c = 'Connection Issues',
                ownerId=userinfo.getUserId()
        );
        chatRecordList.add(liveChatTranscriptrecord);
         //3.i) Insert LiveChatTranscript without CLRs
        liveChatTranscriptrecord = new LiveChatTranscript(
            Platform__c = 'Foodpanda',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
            My_Problem__c = 'Kunde - Anderes Problem',
            Body='Hello',
            LiveChatVisitorId=visitor.id,  
            Country__c = 'Hong Kong' ,        
            ownerId=userinfo.getUserId()
        );
        chatRecordList.add(liveChatTranscriptrecord);
        
        insert chatRecordList;
        //4. Update the Owner on Chat as Case creation on Chat Update via Trigger
        List<LiveChatTranscript> updateOwnerOnchat = new List<LiveChatTranscript>();
        Set<Id> chatRecordIds = new Set<Id>();
        FOR(LiveChatTranscript lrec: chatRecordList){
            lrec.OwnerId = userinfo.getUserId();
            updateOwnerOnchat.add(lrec);
            chatRecordIds.add(lrec.Id);
        }
        update updateOwnerOnchat;

        //Update CLR on LiveChatTranscript Case which does not have CLRs
        Id caseId = [Select Id,CaseId FROM LiveChatTranscript WHERE Case_Reason_Level_3__c=:'' LIMIT 1].CaseId;
        system.assertEquals(TRUE, caseId!=null);
        Case updateCLRsonCase = new Case(Id=caseId,Type='Partner',
                                         Case_Reason_Level_1__c = 'Technical Inquiry',
                                         Case_Reason_Level_2__c = 'Printer',
                                         Case_Reason_Level_3__c = 'Connection Issues' );
        update updateCLRsonCase;
    }
    
    @IsTest
    static void testMethodGetAllMatchingArticlesWithoutSearch(){
        LiveChatTranscript chatRecord = [SELECT Id,Case_Reason_Level_3__c,CaseId FROM  
                                         LiveChatTranscript 
                                         WHERE Case_Reason_Level_3__c =:'Connection Issues' LIMIT 1];
        system.assertEquals(TRUE, chatRecord.CaseId!=null)   ;
        system.assertEquals(TRUE, chatRecord!=null)   ;
        Test.startTest();
         String articlesString = KnowledgeArticle_Controller.getAllMatchingArticles(chatRecord.Id, '',false);
        system.assertEquals(TRUE, articlesString!= System.Label.No_Result);
        Test.stopTest();                             
    }
    @IsTest
    static void testMethodGetAllMatchingArticlesWithSearch(){
        LiveChatTranscript chatRecord = [SELECT Id,Case_Reason_Level_3__c,CaseId FROM  
                                         LiveChatTranscript 
                                         WHERE Case_Reason_Level_3__c =:'Connection Issues' LIMIT 1];
        system.assertEquals(TRUE, chatRecord.CaseId!=null)   ;
        system.assertEquals(TRUE, chatRecord!=null)   ;
        Test.startTest();
        String articlesString =KnowledgeArticle_Controller.getAllMatchingArticles(chatRecord.Id, 'Test',true);
        system.assertEquals(TRUE, articlesString!= System.Label.No_Result);
        Test.stopTest();                             
    }
}
