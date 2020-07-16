@isTest
public with sharing class UnitTestScheduleDeleteChatTranscript {
    @isTest
    public static void UnitTestScheduleDeleteChatTranscriptRelated_remove1() {
        
        LiveChatVisitor vis = new LiveChatVisitor();
        insert vis;

        LiveChatTranscript ltr = new LiveChatTranscript(LiveChatVisitorId = vis.Id);
        insert ltr;
        
        ConversationContextEntry ctr = new ConversationContextEntry(ParentId = ltr.Id);
        insert ctr;

        Test.setCreatedDate(ctr.Id, System.now().addDays(-45));
        Test.startTest();
            system.assertEquals(1, [SELECT COUNT() FROM ConversationContextEntry]);
            new ScheduleDeleteChatTranscriptRelated().execute(null);
        Test.stopTest();

        system.assertEquals(0, [SELECT COUNT() FROM ConversationContextEntry]);
    }

    @isTest
    public static void UnitTestScheduleDeleteChatTranscriptRelated_remove2() {
        
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
            new ScheduleDeleteChatTranscriptRelated().execute(null);
        Test.stopTest();

        system.assertEquals(0, [SELECT COUNT() FROM ConversationContextEntry]);
        system.assertEquals(0, [SELECT COUNT() FROM LiveChatTranscriptEvent]);
    }

    @isTest
    public static void UnitTestScheduleDeleteChatTranscriptRelated_keep() {

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
            new ScheduleDeleteChatTranscriptRelated().execute(null);
        Test.stopTest();

        system.assertEquals(1, [SELECT COUNT() FROM ConversationContextEntry]);
        system.assertEquals(1, [SELECT COUNT() FROM LiveChatTranscriptEvent]);
    }

}
