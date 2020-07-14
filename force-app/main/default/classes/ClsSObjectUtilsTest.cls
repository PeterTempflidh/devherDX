/**
* @author Mantas Jurkunas
* @date 25.01.2019
*
* @description Test class for testing ClsObjectUtils methods
* @see ClsSObjectUtils
*/

@IsTest
public with sharing class ClsSObjectUtilsTest {

    @TestSetup
    private static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        Database.insert(bh);
        Company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
        insert com;

        List<Business_Config__c> rules = new List<Business_Config__c>();

        rules.add(
                new Business_Config__c(
                        Record_Type_Id__c = 'Talabat_Account',
                        Id_Country__c = bh.Id,
                        Is_Active__c = true,
                        Parent__c = true,
                        Type__c = 'Process',
                        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
                        Business_Rule_Name__c = 'parentAccountType',
                        Business_Rule_Value__c = 'Brand'
                )
        );

        rules.add(
                new Business_Config__c(
                        Record_Type_Id__c = 'Talabat_Account',
                        Id_Country__c = bh.Id,
                        Is_Active__c = true,
                        Parent__c = true,
                        Type__c = 'Process',
                        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
                        Business_Rule_Name__c = 'childAccountType',
                        Business_Rule_Value__c = 'Branch'
                )
        );

        rules.add(
                new Business_Config__c(
                        Record_Type_Id__c = 'Talabat_Account',
                        Id_Country__c = bh.Id,
                        Is_Active__c = true,
                        Parent__c = false,
                        Type__c = 'Process',
                        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
                        Business_Rule_Name__c = 'validContractStatuses',
                        Business_Rule_Value__c = 'Draft'
                )
        );

        rules.add(
                new Business_Config__c(
                        Record_Type_Id__c = 'Talabat_Account',
                        Id_Country__c = bh.Id,
                        Is_Active__c = true,
                        Parent__c = false,
                        Type__c = 'Process',
                        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
                        Business_Rule_Name__c = 'contractActivationStatus',
                        Business_Rule_Value__c = 'Activated'
                )
        );
        Database.insert(rules);
        List<Account> accounts = UnitTestDataFactory.createAccounts(1, bh, 'Talabat_Account');
        Database.insert(accounts);
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Talabat_Opportunity', Date.today());
        Database.insert(opportunities);
        List<Opportunity_Quote__c> oppQuotes = UnitTestDataFactory.createOpportunityQuotes(opportunities.get(0), 3, 'Talabat_Opportunity_Quote', 'Accepted', 'test', 100, 100, 'Test', 'Test', 10);
        Database.insert(oppQuotes);

    }

    /*******************************************************************************************************
    * @description test if approval process is being updated;
    */
    @IsTest
    public static void test_updateApprovalProcesses() {

        //change from talabat opportunity to PY as this approval process is not longer used by Talabat.

        Country__c bo = UnitTestDataFactory.createCountry('BO', 'Bolivia', 'BOB');
        Database.insert(bo);
        Company__c com = UnitTestDataFactory.createCompany('PedidosYa Bolivia', 'PY', bo);
        insert com;

        List<Account> accounts = UnitTestDataFactory.createAccounts(1, bo, 'PY_Account');
        Database.insert(accounts);
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'PY_Opportunity', Date.today());
        Database.insert(opportunities);
        List<Opportunity_Quote__c> oppQuotes = UnitTestDataFactory.createOpportunityQuotes(opportunities.get(0), 3, 'PY_Opportunity_Quote', 'Accepted', 'test', 100, 100, 'Test', 'Test', 10);
        Database.insert(oppQuotes);
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();


        ProcessDefinition currentApproval= ClsProcessDefinitionSelector.getApprovalProcessDefinition('Global - Approval Process');

        for(Opportunity_Quote__c oppQuote: oppQuotes) {
            Approval.ProcessSubmitRequest req1 =
                    new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(oppQuote.Id);

            // Submit on behalf of a specific submitter
            req1.setSubmitterId(UserInfo.getUserId());

            req1.setProcessDefinitionNameOrId(currentApproval.DeveloperName);
            req1.setSkipEntryCriteria(true);

            approvalRequests.add(req1);
        }

        List<Approval.ProcessResult> results = Approval.process(approvalRequests);

        for(Approval.ProcessResult result: results) {
            System.assert(result.isSuccess());
        }

        Test.startTest();
            ClsSObjectUtils.updateApprovalProcesses(new Map<Id, Opportunity_Quote__c>(oppQuotes).keySet(), 'Removed');
        Test.stopTest();

        List<ProcessInstanceWorkitem> workItems = ProcessInstanceWorkItemSelector.findActiveWorkItemsByTargetIds(new Map<Id, Opportunity_Quote__c>(oppQuotes).keySet());

        System.assert(workItems == null || workItems.isEmpty());
    }

    /**
     * @description Test if changed values are filtered correctly
     */
    @IsTest
    public static void filterChangedValues_test() {

        Country__c kr = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        Database.insert(kr);

        List<Account> accounts = UnitTestDataFactory.createAccounts(4, kr, 'Talabat_Account');
        insert accounts;
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        List<Account> accountCopies = accounts.deepClone(true);
        for (Account accountCopy: accountCopies) {
            accountCopy.Name = 'CopyOfAccount';
            accountCopy.Backend_ID__c = '1234';
            accountCopy.First_Payment_Date__c = Date.newInstance(1992, 05, 14);
            accountCopy.Total_Revenue__c = 200;
            accountCopy.Avg_Commission_of_Cont_Franchise_Branch__c = 20;
            accountCopy.Box_Available__c = true;
            accountCopy.Branches_In_Franchise_HQ__c = 25;
        }

        List<Account> filteredAccounts = ClsSObjectUtils.filterFieldValues(accountCopies, accountMap, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{'CopyOfAccount'},
                'First_Payment_Date__c' => new Set<Object> { Date.newInstance(1992, 05, 14), Date.newInstance(1992, 05, 15) }
        }, true);
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accountCopies, accountMap, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{'CopyOfAcc'},
                'First_Payment_Date__c' => new Set<Object> { Date.newInstance(1992, 05, 15) }
        });
        System.assertEquals(0, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accountCopies, accountMap, new Map<String, Set<Object>>{
                'Name' => new Set<Object>()
        });
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accountCopies, accountMap, new Map<String, Set<Object>>{
                'Name' => new Set<Object>(),
                'First_Payment_Date__c' => new Set<Object>(),
                'Total_Revenue__c' => new Set<Object>()
        }, true);
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accountCopies, accountMap, new Map<String, Set<Object>>{
                'Id' => new Set<Object>()
        });
        System.assertEquals(0, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accountCopies, accountMap, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{'CopyOfAccount'}, 'Backend_Id__c' => new Set<Object>{ '1234'}
        });
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accountCopies, accountMap, new Map<String, Set<Object>>{
                'Total_Revenue__c' => new Set<Object>{ Decimal.valueOf(25), Decimal.valueOf(200), Decimal.valueOf(10) },
                'Backend_Id__c' => new Set<Object>{ '1234'},
                'Avg_Commission_of_Cont_Franchise_Branch__c' => new Set<Object>{ Decimal.valueOf(20), Decimal.valueOf(200), Decimal.valueOf(10)},
                'Box_Available__c' => new Set<Object>{ true },
                'Branches_In_Franchise_HQ__c' => new Set<Object>{ Decimal.valueOf(28), Decimal.valueOf(25), Decimal.valueOf(10) }
        }, true);
        System.assertEquals(4, filteredAccounts.size());

    }

    /**
     * @description Test if changed values are filtered correctly
     */
    @IsTest
    public static void filterFieldValues_test() {

        Country__c kr = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        Database.insert(kr);

        List<Account> accounts = UnitTestDataFactory.createAccounts(4, kr, 'Talabat_Account');
        for (Account accountCopy: accounts) {
            accountCopy.Name = 'CopyOfAccount';
            accountCopy.Backend_ID__c = '1234';
        }

        insert accounts;

        accounts[0].Shared_Menu__r = accounts[1];

        List<Account> filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAccount' }
        });
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAcc' }
        });
        System.assertEquals(0, filteredAccounts.size());

        try {
            filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                    'Name' => null
            });
        } catch(ClsSObjectUtils.SObjectUtilsException e ) {}
        System.assertNotEquals(4, filteredAccounts.size());

        try {
            filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                    'Name' => null, 'Backend_Id__c' => null
            });
        } catch(ClsSObjectUtils.SObjectUtilsException e ) {}
        System.assertNotEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAccount' }, 'Backend_Id__c' => new Set<Object>{ '1234' }
        });
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAccount' }, 'Backend_Id__c' => new Set<Object>{ '12345' }
        }, true);
        System.assertEquals(0, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAccount' }, 'Backend_Id__c' => new Set<Object>{ '12345', '1234' }
        }, true);
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAccount' }, 'Shared_Menu__r.Backend_ID__c' => new Set<Object>{ '1234' }
        }, true);
        System.assertEquals(1, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
        'Name' => new Set<Object>{ 'CopyOfAccount' }, 'Shared_Menu__r.Backend_ID__c' => new Set<Object>{ null }
        }, true);
        System.assertEquals(3, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAccount' }, 'Backend_ID__c' => new Set<Object>()
        }, true);
        System.assertEquals(4, filteredAccounts.size());

        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Name' => new Set<Object>{ 'CopyOfAccount' }, 'Shared_Menu__r.Backend_ID__c' => new Set<Object>()
        }, true);
        System.assertEquals(1, filteredAccounts.size());
        filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, new Map<String, Set<Object>>{
                'Shared_Menu__r.Backend_ID__c' => new Set<Object>()
        });
        System.assertEquals(1, filteredAccounts.size());

    }
}
