/**
 * Created by marco.zeuli on 17/5/2018.
 */
@IsTest
private class UnitTestCtrViewInvoicePDF {

    public class AWSS3Mock implements HttpCalloutMock {

        Boolean success;
        String resBody;

        public AWSS3Mock(Boolean success, String resBody) {
            this.success = success;
            this.resBody = resBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            if (success) {
                res.setStatusCode(200);
            } else {
                res.setStatusCode(404);
            }

            res.setBody(resBody);

            return res;
        }
    }

    @TestSetup static void setup() {

        UnitTestDataFactory.getRecordtypeValues();

        Country__c c = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        insert c;

        Account acc = UnitTestDataFactory.createAccount('test', c, 'DE_Account');
        insert acc;

        Platform_Performance__c p = new Platform_Performance__c(
                Platform__c = 'PizzaDE',
                Backend_ID__c = '1234',
                Account__c = acc.Id
        );
        insert p;

        Invoice__c inv = new Invoice__c(
                Invoice_Number__c = '987654321',
                Date__c = Date.today(),
                Account__c = acc.Id,
                Platform__c = 'PizzaDE'
        );
        insert inv;

        Integration_Config__c conf = new Integration_Config__c(
                Name = 'AWS_S3_PDE_Invoices',
                Endpoint__c = 'https://whatever.com',
                Timeout__c = 5000,
                ClientId__c = 'amazingId',
                ClientSecret__c = 'amazingSecret'
        );
        insert conf;
    }

    @IsTest static void CtrViewInvoicePDFInstantiateCorrectly() {
        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];

        PageReference pref = Page.ViewInvoicePDF;
        pref.getParameters().put('id', inv.Id);

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(inv);
        CtrViewInvoicePDF ctr = new CtrViewInvoicePDF(stdCtr);

        Test.stopTest();
    }

    @IsTest static void getInvoicePDFReturnsResponseWrapperInErrorIfInvoiceDoesNotExist() {

        CtrViewInvoicePDF.ResponseWrapper res;

        Test.startTest();

        res = CtrViewInvoicePDF.getInvoicePDF('1234');

        Test.stopTest();

        System.assert(!res.success);
        System.assert(String.isNotBlank(res.data));
    }

    @IsTest static void getInvoicePDFReturnsCorrectly() {
        final String responseBody = 'amazing pdf file!';
        final String responseBodyBase64 = EncodingUtil.base64Encode(Blob.valueOf(responseBody));

        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];

        CtrViewInvoicePDF.ResponseWrapper res;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AWSS3Mock(true, responseBody));

        res = CtrViewInvoicePDF.getInvoicePDF(inv.Id);

        Test.stopTest();

        System.assert(res.success);
        System.assertEquals(responseBodyBase64, res.data);
    }

    @IsTest static void getInvoicePDFReturnsResponseWrapperInErrorIfRequestFailed() {
        final String responseBody = 'error occurred';
        Invoice__c inv = [SELECT Id FROM Invoice__c LIMIT 1];
        CtrViewInvoicePDF.ResponseWrapper res;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AWSS3Mock(false, responseBody));

        res = CtrViewInvoicePDF.getInvoicePDF(inv.Id);

        Test.stopTest();

        System.assert(!res.success);
        System.assert(String.isNotBlank(res.data));
    }
}