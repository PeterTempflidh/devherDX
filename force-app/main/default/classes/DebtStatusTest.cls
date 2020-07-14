/**
 * Created by w.novoa on 30.04.20.
 */
@IsTest
public with sharing class DebtStatusTest {
    @testSetup
    static void testSetup() {

        UnitTestDataFactory.getRecordtypeValues();
        country__c country  = UnitTestDataFactory.createCountry('AR', 'Argentina', 'ARS');
        insert country;
        Company__c company = UnitTestDataFactory.createCompany('PedidosYA', 'PY', country);
        insert company;
        Business_Config__c business = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'Canceled', Id_Country__c = country.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'PY_Account', Type__c = 'Process');
        insert business;
        Account account = UnitTestDataFactory.createAccount('TestAccount', country, 'PY_Account');
        insert account;

        Platform_Performance__c platformPerformance = new Platform_Performance__c();
        platformPerformance.Account__c = account.id;
        platformPerformance.Backend_ID__c = '12';
        platformPerformance.Contract_Number_SAP__c = '10';

        insert platformPerformance;
    }
    @IsTest
    static void updateplatformdebtPositive() {
        insert new Logging__c(SetupOwnerId=UserInfo.getOrganizationId());
        String jsonUpdate= '{"countryName":"Argentina","recordTypeName":"PY_Account","debtInformation":[{"numberPendingInvoices":1,"debtValue":1111111,"contractSAP":"10"},{"numberPendingInvoices":123,"debtValue":null,"contractSAP":11}]}';
        RestRequest request = new RestRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        request.requestUri =baseUrl +'/services/apexrest/DebtStatusRestService/';

        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(jsonUpdate);
        RestContext.request = request;
        test.startTest();
        DebtStatusRestHelper.ResponseWrapper response= DebtStatusRestService.doPost();
        test.stopTest();
        System.assertEquals('SUCCESS',response.status);
        Platform_Performance__c platform = [select id,Debt_Value__c,Number_Pending_Invoices__c
                                            from Platform_Performance__c limit 1 ];

        System.assertEquals(1111111,platform.Debt_Value__c);
        System.assertEquals(1,platform.Number_Pending_Invoices__c);

    }

    @IsTest
    static void updateplatformdebtNegatiive() {
        insert new Logging__c(SetupOwnerId=UserInfo.getOrganizationId());
        String jsonUpdate= '{"countryName":"Argentina","recordTypeName":"PY_Account","debtInformation":[{"numberPendingInvoices":1234,"debtValue":1111111,"contractSAP":"10"},{"numberPendingInvoices":123,"debtValue":null,"contractSAP":11}]}';
        RestRequest request = new RestRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        request.requestUri =baseUrl +'/services/apexrest/DebtStatusRestService/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(jsonUpdate);
        RestContext.request = request;
        test.startTest();
        DebtStatusRestHelper.ResponseWrapper response= DebtStatusRestService.doPost();
        test.stopTest();
        System.assertEquals('FAIL',response.status);

    }
}