/**
 * Created by marco.zeuli on 17/5/2018.
 */

public with sharing class CtrViewInvoicePDF {
    private static final String PLATFORM_PIZZADE = 'PizzaDE';
    private static final String PLATFORM_LIEFEHELDDE = 'LieferheldDE';

    static final Map<String, String> platformToApiSettings = new Map<String, String>{
            PLATFORM_PIZZADE => 'AWS_S3_PDE_Invoices',
            PLATFORM_LIEFEHELDDE => 'AWS_S3_LIH_Invoices'
    };

    public CtrViewInvoicePDF(ApexPages.StandardController stdCtr) {
    }

    /**
     * Given an Invoice's id, retrieves from S3 bucket the PDF file
     *
     * @param invoiceId Invoice's id
     *
     * @return An instance of ResponseWrapper
     */
    @RemoteAction
    public static ResponseWrapper getInvoicePDF(String invoiceId) {
        ResponseWrapper res;

        System.debug('CtrViewInvoicePDF.getInvoicePDF: start, invoice id is: ' + invoiceId);

        try {

            // retrieves invoice record
            Invoice__c invoice = [
                    SELECT
                            Date__c,
                            Invoice_Number__c,
                            Account__c,
                            Account__r.GRID__c,
                            Platform__c
                    FROM Invoice__c
                    WHERE Id = :invoiceId
            ];

            // retrieve api settings based on the platform name
            Integration_Config__c apiSettings = Integration_Config__c.getValues(
                    platformToApiSettings.get(invoice.Platform__c)
            );

            System.debug('CtrViewInvoicePDF.getInvoicePDF: invoice is: ' + invoice);

            // retrieves platform
            Platform_Performance__c plat = useAccountGRID(invoice) ? null :
                    [
                        SELECT
                                Backend_ID__c, GRID__c
                        FROM Platform_Performance__c
                        WHERE Account__c = :invoice.Account__c
                        AND Platform__c = :invoice.Platform__c
                    ];

            System.debug('CtrViewInvoicePDF.getInvoicePDF: platform is: ' + plat);

            Datetime tmp = Datetime.newInstance(
                    invoice.Date__c.year(),
                    invoice.Date__c.month(),
                    invoice.Date__c.day()
            );

            // creates invoice's url
            String pdfUrl = String.format(
                    apiSettings.Endpoint__c + '/{0}/{1}/{2}/{3}_{4}.pdf',
                    new List<String>{
                            useAccountGRID(invoice) ? invoice.Account__r.GRID__c : plat.GRID__c,
                            tmp.format('yyyy'),
                            tmp.format('MM'),
                            tmp.format('yyyyMMdd'),
                            invoice.Invoice_Number__c
                    }
            );

            System.debug('CtrViewInvoicePDF.getInvoicePDF: url is: ' + pdfUrl);

            // create AWS signed request
            HttpRequest request = new AWSConnector(
                    apiSettings.ClientId__c,
                    apiSettings.ClientSecret__c,
                    's3',
                    'eu-central-1'
            ).signedRequest(
                    'GET',
                    new Url(pdfUrl),
                    null,
                    null,
                    false
            );

            request.setTimeout(apiSettings.Timeout__c.intValue());

            System.debug('CtrViewInvoicePDF.getInvoicePDF: request is: ' + request);

            // send request
            HttpResponse response = new Http().send(request);

            System.debug('CtrViewInvoicePDF.getInvoicePDF: response is: ' + response);

            if (response.getStatusCode() == 200) {
                res = new ResponseWrapper(true, EncodingUtil.base64Encode(response.getBodyAsBlob()));
            } else {
                res = new ResponseWrapper(false, Label.AWS_S3_Bucket_download_error + response.getBody());
            }

        } catch (Exception e) {
            System.debug('CtrViewInvoicePDF.getInvoicePDF: exception occurred. Message is: ' + e.getMessage() + ' - Stacktrace is: ' + e.getStackTraceString());
            res = new ResponseWrapper(false, Label.AWS_S3_Bucket_download_error + e.getMessage());
        }

        System.debug('CtrViewInvoicePDF.getInvoicePDF: done');
        return res;
    }

    /**
     * @description Checks whether the invoice is platform dependant or not.
     *
     * @param invoice Invoice__c
     *
     * @return Boolean
     */
    private static Boolean useAccountGRID(final Invoice__c invoice) {
        return invoice.Platform__c.equalsIgnoreCase(PLATFORM_LIEFEHELDDE) ||
                invoice.Platform__c.equalsIgnoreCase(PLATFORM_PIZZADE);
    }

    /**
     * Response wrapper. If no error occurred success flag will be set to true otherwise to false.
     * Data will hold the base64 pdf string or an error message in case success is set to false
     */
    public class ResponseWrapper {
        public Boolean success {
            get;
            set;
        }
        public String data { get; set; }
        public ResponseWrapper(Boolean success, String data) {
            this.success = success;
            this.data = data;
        }
    }
}