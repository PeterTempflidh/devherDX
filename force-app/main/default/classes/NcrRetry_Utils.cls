/**
* @author Mantas Jurkunas
* @date 15.11.2019
*
* @description Utility class providing methods to retry failed ncr/midas requests
*
*/
public with sharing class NcrRetry_Utils {

    private final static String LOG_NAME = 'MIDAS_RETRY';
    private Map<String, List<LibWebserviceHelper.oppLineItemBookingData>> bookingDataToCancel;
    private Map<String, List<LibWebserviceHelper.oppLineItemBookingData>> bookingDataToApprove;
    private Map<String, Opportunity_Line_Item__c> lineItems;
    private List<Integer> successfulBookingIds;
    /**
     * @description authorisation token required to access MIDAS web services
     */
    private static String authorisationToken {
        get {
            if (authorisationToken == null) {
                authorisationToken = LibWebserviceHelper.constructMidasRequestForAuthentication(LOG_NAME);
            }
            return authorisationToken;
        } private set {}
    }


    public NcrRetry_Utils() {
        LoggingUtility.createLog(LOG_NAME,'MIDAS_SELFBOOKING','NCR_RETRY',null);
        this.bookingDataToCancel = new Map<String, List<LibWebserviceHelper.oppLineItemBookingData>>();
        this.bookingDataToApprove = new Map<String, List<LibWebserviceHelper.oppLineItemBookingData>>();
        this.lineItems = new Map<String, Opportunity_Line_Item__c>();
        this.successfulBookingIds = new List<Integer>();
    }

    /**
     * @description splits line items that have failed while terminating PP and while trying to approve a pp
     *
     * @param ppLineItems
     */
    public NcrRetry_Utils initialiseLineItemData(List<Opportunity_Line_Item__c> ppLineItems) {
        this.lineItems = (Map<String, Opportunity_Line_Item__c>) ClsSObjectUtils.convertToSingleStringMap(ppLineItems, Opportunity_Line_Item__c.Booking_Api_Id__c.getDescribe().getLocalName());
        List<Additional_Charges__c> additionalCharges = AdditionalChargesSelector.getTerminatedByBookingIds(lineItems.keySet());
        Map<String, Additional_Charges__c> bookingIdAddChargesMap = additionalCharges.isEmpty() ? new Map<String, Additional_Charges__c>()
                : (Map<String, Additional_Charges__c>) ClsSObjectUtils.convertToSingleStringMap(additionalCharges, Additional_Charges__c.Booking_Api_Id__c.getDescribe().getLocalName());
        for (Opportunity_Line_Item__c lineItem : ppLineItems) {
            LibWebserviceHelper.oppLineItemBookingData bookingData = new LibWebserviceHelper.oppLineItemBookingData(Integer.valueOf(lineItem.Booking_Api_Id__c), UserInfo.getUserEmail());
            if (lineItem.Id_Opportunity__r.StageName.equals('Closed Lost') || bookingIdAddChargesMap.containsKey(lineItem.Booking_Api_Id__c)) {
                if (this.bookingDataToCancel.containsKey(lineItem.Id_Opportunity__c)) {
                    this.bookingDataToCancel.get(lineItem.Id_Opportunity__c).add(bookingData);
                } else {
                    this.bookingDataToCancel.put(lineItem.Id_Opportunity__c, new List<LibWebserviceHelper.oppLineItemBookingData> { bookingData });
                }
            } else {
                if (this.bookingDataToApprove.containsKey(lineItem.Id_Opportunity__c)) {
                    this.bookingDataToApprove.get(lineItem.Id_Opportunity__c).add(bookingData);
                } else {
                    this.bookingDataToApprove.put(lineItem.Id_Opportunity__c, new List<LibWebserviceHelper.oppLineItemBookingData> { bookingData });
                }
            }
        }
        return this;
    }

    /**
     * @description Sends requests to Midas backed. Each bulk request has to be made separately for each country since entity name is in the url of the request.
     */
    public NcrRetry_Utils retryBookings() {
        List<Integer> successfulBookingIds = new List<Integer>();
        for (String opportunityId: bookingDataToCancel.keySet()) {
            String country = this.lineItems.get(String.valueOf(bookingDataToCancel.get(opportunityId).get(0).id)).Id_Opportunity__r.Record_Country__c;
            if (country == null) { continue; }
            HttpResponse cancelResponse = LibWebserviceHelper.constructMidasRequestForBookingCancellation(authorisationToken, country, this.bookingDataToCancel.get(opportunityId), LOG_NAME);
            if (cancelResponse == null || (cancelResponse.getStatusCode() != 204 && cancelResponse.getStatusCode() != 208)) {
                LoggingUtility.logError(LOG_NAME, '{' + country + ': ' + opportunityId + '} Failed to cancel bookings- '
                        + ( cancelResponse == null ? 'NULL' : cancelResponse.getStatus() ) + ' Status Code ' + ( cancelResponse == null ? 0 : cancelResponse.getStatusCode()) + '\n');
                continue;
            }
            for (LibWebserviceHelper.oppLineItemBookingData bookingData: this.bookingDataToCancel.get(opportunityId)) {
                successfulBookingIds.add(bookingData.Id);
            }
        }
        for (String opportunityId: bookingDataToApprove.keySet()) {
            String country = this.lineItems.get(String.valueOf(bookingDataToApprove.get(opportunityId).get(0).id)).Id_Opportunity__r.Record_Country__c;
            if (country == null) { continue; }
            HttpResponse approvalResponse = LibWebserviceHelper.constructMidasRequestForBookingApproval(authorisationToken, country, this.bookingDataToApprove.get(opportunityId), LOG_NAME);
            if (approvalResponse == null || (approvalResponse.getStatusCode() != 204 && approvalResponse.getStatusCode() != 208)) {
                LoggingUtility.logError(LOG_NAME, '{' + country + ': ' + opportunityId + '} Failed to approve bookings- '
                        + ( approvalResponse == null ? 'NULL Response \n' : approvalResponse.getStatus() ) + ' Status Code ' + ( approvalResponse == null ? 0 : approvalResponse.getStatusCode()) + '\n');
                continue;
            }
            for (LibWebserviceHelper.oppLineItemBookingData bookingData: this.bookingDataToApprove.get(opportunityId)) {
                successfulBookingIds.add(bookingData.Id);
            }
        }

        LoggingUtility.captureTimeStamp(LOG_NAME,'End');
        this.successfulBookingIds = successfulBookingIds;
        return this;
    }

    /**
     * @description removes the midas failure flags from line items that have been updated in the backend
     */
    public List<Opportunity_Line_Item__c> updateSuccessfulBookings() {
        List<Opportunity_Line_Item__c> lineItemsToUpdate = new List<Opportunity_Line_Item__c>();
        if (successfulBookingIds.isEmpty()) {
            return lineItemsToUpdate;
        }
        for (Integer bookingId: successfulBookingIds) {
            Opportunity_Line_Item__c lineItem = this.lineItems.get(String.valueOf(bookingId));
            lineItem.Midas_Exception__c = false;
            lineItemsToUpdate.add(lineItem);
        }
        return lineItemsToUpdate;
    }
}