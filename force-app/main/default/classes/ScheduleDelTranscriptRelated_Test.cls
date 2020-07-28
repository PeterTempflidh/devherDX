@isTest
public without sharing class ScheduleDelTranscriptRelated_Test {
    @isTest
    public static void UnitTestScheduleDelTranscriptRelated_Batch_remove1() {
        
        LiveChatVisitor vis = new LiveChatVisitor();
        insert vis;

        LiveChatTranscript ltr = new LiveChatTranscript(LiveChatVisitorId = vis.Id);
        insert ltr;
        
        ConversationContextEntry ctr = new ConversationContextEntry(ParentId = ltr.Id);
        insert ctr;

        Test.setCreatedDate(ctr.Id, System.now().addDays(-45));
        Test.startTest();
            system.assertEquals(1, [SELECT COUNT() FROM ConversationContextEntry]);
            new ScheduleDelTranscriptRelated_Batch().execute(null);
        Test.stopTest();

        system.assertEquals(0, [SELECT COUNT() FROM ConversationContextEntry]);
    }

    @isTest
    public static void UnitTestScheduleDelTranscriptRelated_Batch_remove2() {
        
        LiveChatVisitor vis = new LiveChatVisitor();
        insert vis;

        LiveChatTranscript ltr = new LiveChatTranscript(LiveChatVisitorId = vis.Id);
        insert ltr;
        
        ConversationContextEntry ctr = new ConversationContextEntry(ParentId = ltr.Id);
        insert ctr;

        LiveChatTranscriptEvent lcte = new LiveChatTranscriptEvent(LiveChatTranscriptId = ltr.Id, Type = 'ChatRequest', Time = System.now());
        insert lcte;

        Test.setCreatedDate(ctr.Id, System.now().addDays(-45));
        Test.setCreatedDate(lcte.Id, System.now().addDays(-200));
        Test.startTest();
        system.assertEquals(1, [SELECT COUNT() FROM ConversationContextEntry]);
        system.assertEquals(1, [SELECT COUNT() FROM LiveChatTranscriptEvent]);
            new ScheduleDelTranscriptRelated_Batch().execute(null);
        Test.stopTest();

        system.assertEquals(0, [SELECT COUNT() FROM ConversationContextEntry]);
        system.assertEquals(0, [SELECT COUNT() FROM LiveChatTranscriptEvent]);
    }

    @isTest
    public static void UnitTestScheduleDelTranscriptRelated_Batch_keep() {

        LiveChatVisitor vis = new LiveChatVisitor();
        insert vis;

        LiveChatTranscript ltr = new LiveChatTranscript(LiveChatVisitorId = vis.Id);
        insert ltr;
        
        ConversationContextEntry ctr = new ConversationContextEntry(ParentId = ltr.Id);
        insert ctr;

        LiveChatTranscriptEvent lcte = new LiveChatTranscriptEvent(LiveChatTranscriptId = ltr.Id, Type = 'ChatRequest', Time = System.now());
        insert lcte;

        Test.setCreatedDate(ctr.Id, System.now().addDays(-15));
        Test.setCreatedDate(lcte.Id, System.now().addDays(-130));
        Test.startTest();
            system.assertEquals(1, [SELECT COUNT() FROM ConversationContextEntry]);
            system.assertEquals(1, [SELECT COUNT() FROM LiveChatTranscriptEvent]);
            new ScheduleDelTranscriptRelated_Batch().execute(null);
        Test.stopTest();

        system.assertEquals(1, [SELECT COUNT() FROM ConversationContextEntry]);
        system.assertEquals(1, [SELECT COUNT() FROM LiveChatTranscriptEvent]);
    }

    @isTest
    public static void UnitTestScheduleDelTranscriptRelated_logError() {

        LiveChatVisitor vis = new LiveChatVisitor();
        insert vis;

        LiveChatTranscript ltr = new LiveChatTranscript(LiveChatVisitorId = vis.Id);
        insert ltr;

		Database.DeleteResult[] dr = Database.delete(new LiveChatTranscript[]{ltr}, false);
		ScheduleDelTranscriptRelated_Batch.logError(dr, 'LiveChatTranscript');
	}

}
