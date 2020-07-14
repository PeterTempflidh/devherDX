@isTest
public class Opportunity_SelectorTest {

    @testSetup static void setup() {

        UnitTestDataFactory.getRecordtypeValues();
        Country__c pyCountry = UnitTestDataFactory.createCountry('AR', 'Argentina', 'ARS');
        insert pyCountry;

        Company__c pyCompany = UnitTestDataFactory.createCompany('Pedidosya', 'PY', pyCountry);
        insert pyCompany;

        Account pyAcc = UnitTestDataFactory.createAccount('test',pyCountry,'PY_Account');
        insert pyAcc;

        Opportunity pyOpp = UnitTestDataFactory.createOpportunity('test',pyAcc,'PY_Opportunity', Date.today());
        insert pyOpp;

        Opportunity_Quote__c  pyQuote = new Opportunity_Quote__c();
        pyQuote.Id_Account__c = pyAcc.Id;
        pyQuote.Id_Opportunity__c = pyOpp.Id;
        insert pyQuote;

    }

    private static testMethod void testAllQueries() {

        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        List<Id> oppIdList = new List<Id>();

        for(Opportunity opp : Opportunity_Selector.getAll()) {
            oppIdSet.add(opp.Id);
            oppIdList.add(opp.id);
        }

        for(Opportunity opp : Opportunity_Selector.getAllWithChildren()) {
            for(Opportunity_Quote__c oq : opp.Opportunity_Quotes__r) {
                quoteIdSet.add(oq.Id);
            }
        }

        for(Opportunity opp : [Select AccountId From Opportunity Where Id IN: oppIdSet]) {
            accIdSet.add(opp.AccountId);
        }

        Opportunity_Selector.getFromOppIdSet (oppIdSet);
        Opportunity_Selector.getQuotesMap (quoteIdSet);
        Opportunity_Selector.getSelected (oppIdList);
        Opportunity_Selector.getOpportunityClosed (oppIdSet);
        Opportunity_Selector.getOpportunityByIdStage (oppIdSet,'Closed');
        Opportunity_Selector.getOpportunityById (oppIdList[0]);
        Opportunity_Selector.getOpportunityAgainstAccounts (accIdSet);
        Opportunity_Selector.fetchOQLIProductName (oppIdList[0]);

    }
}