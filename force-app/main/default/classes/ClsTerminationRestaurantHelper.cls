/**
 * Created by w.novoa on 16.03.2018.
 */

public inherited sharing class ClsTerminationRestaurantHelper {


    public Map<String, Business_Config__c> mapBusinessData { get; set; }
    public Set<String> doNotOverwriteStatusSet;

    public String assetStatus {get; set;}
    public Boolean showButtons {get; set;}

    public Boolean contractTerminationReasonMandatory {get; private set;}
    public Boolean addChargesTerminationReasonMandatory {get; private set;}
    public Boolean brandingTerminationReasonMandatory {get; private set;}

    public Boolean addOnTerminationReasonMandatory {get; private set;}

    public Boolean contractTerminationDateMandatory {get; private set;}
    public Boolean addChargesTerminationDateMandatory {get; private set;}
    public Boolean brandingTerminationDateMandatory {get; private set;}
    public Boolean addOnTerminationDateMandatory {get; private set;}

    public ClsTerminationRestaurantHelper(String RecordTypeid) {
        System.debug('CtrTerminationRestaurantVue');
        this.contractTerminationReasonMandatory = false;
        this.addChargesTerminationReasonMandatory = false;
        this.brandingTerminationReasonMandatory = false;
        this.addOnTerminationReasonMandatory = false;

        this.contractTerminationDateMandatory = false;
        this.addChargesTerminationDateMandatory = false;
        this.brandingTerminationDateMandatory = false;
        this.addOnTerminationDateMandatory = false;

        this.doNotOverwriteStatusSet = new Set<String>();

        Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('TerminateRestaurant');

        this.mapBusinessData = mapProcessData.get(LibRecordTypeHelper.getRecordTypeForIds(new Set<String> {'Account'}).get(RecordTypeid).DeveloperName);

        System.debug('CtrTerminationRestaurantVue-->'+mapBusinessData);


        if (this.mapBusinessData != null && !this.mapBusinessData.isEmpty()) {

            System.debug('CtrTerminationRestaurantVue-->'+mapBusinessData.get('AssetTerminateStatus'));
            if (mapBusinessData.get('AssetTerminateStatus') != null) {
                this.assetStatus = mapBusinessData.get('AssetTerminateStatus').Business_Rule_Value__c;
                this.showButtons = true;
            } else {
                this.showButtons = false;
                ClsUtilsApexPages.addErrorMessage('Business rule AssetTerminateStatus is required');
                return;
            }

            if (mapBusinessData.containsKey('contractTerminationReasonMandatory')) {
                this.contractTerminationReasonMandatory = Boolean.valueOf(mapBusinessData.get('contractTerminationReasonMandatory').Business_Rule_Value__c);
            }

            if (mapBusinessData.containsKey('addChargesTerminationReasonMandatory')) {
                this.addChargesTerminationReasonMandatory = Boolean.valueOf(mapBusinessData.get('addChargesTerminationReasonMandatory').Business_Rule_Value__c);
            }

            if (mapBusinessData.containsKey('brandingTerminationReasonMandatory')) {
                this.brandingTerminationReasonMandatory = Boolean.valueOf(mapBusinessData.get('brandingTerminationReasonMandatory').Business_Rule_Value__c);
            }

            if (mapBusinessData.containsKey('addonTerminationReasonMandatory')) {
                this.addOnTerminationReasonMandatory = Boolean.valueOf(mapBusinessData.get('addonTerminationReasonMandatory').Business_Rule_Value__c);
            }

            if (mapBusinessData.containsKey('contractTerminationDateMandatory')) {
                this.contractTerminationDateMandatory = Boolean.valueOf(mapBusinessData.get('contractTerminationDateMandatory').Business_Rule_Value__c);
            }

            if (mapBusinessData.containsKey('addChargesTerminationDateMandatory')) {
                this.addChargesTerminationDateMandatory = Boolean.valueOf(mapBusinessData.get('addChargesTerminationDateMandatory').Business_Rule_Value__c);
            }

            if (mapBusinessData.containsKey('brandingTerminationDateMandatory')) {
                this.brandingTerminationDateMandatory = Boolean.valueOf(mapBusinessData.get('brandingTerminationDateMandatory').Business_Rule_Value__c);
            }

            if (mapBusinessData.containsKey('addonTerminationDateMandatory')) {
                this.addOnTerminationDateMandatory = Boolean.valueOf(mapBusinessData.get('addonTerminationDateMandatory').Business_Rule_Value__c);
            }

            system.debug('mapBusinessData.get(DoNotOverwriteStatus)--->'+mapBusinessData.get('DoNotOverwriteStatus'));
            if (mapBusinessData.get('DoNotOverwriteStatus') != null) {
                if (mapBusinessData.get('DoNotOverwriteStatus').Business_Rule_Value__c.indexOf(',') > -1) {
                    this.doNotOverwriteStatusSet.addAll(mapBusinessData.get('DoNotOverwriteStatus').Business_Rule_Value__c.split(','));
                } else {
                    this.doNotOverwriteStatusSet.add(mapBusinessData.get('DoNotOverwriteStatus').Business_Rule_Value__c);
                }
            }

        } else {
            this.showButtons = false;
            ClsUtilsApexPages.addErrorMessage(Label.Terminate_process_required);
        }
    }

    public String terminateMidasPP(List<String> bookingIds) {

        String result = '';
        string logName = 'BookingOrAddCharge_Termination';
        Id currentUserId = UserInfo.getUserId();
        List<LibWebserviceHelper.oppLineItemBookingData> listBookData;
        HttpResponse response;
        try {
            List<User> userData = UserSelector.getAllByUserId(new set<ID>{currentUserId});
            List<Opportunity_line_item__c> oppLines = OpportunityLineItem_Selector.getOLIByBookingId(bookingIds);
            if (oppLines.isEmpty()) {
                return result;
            }
            LoggingUtility.createLog(logName, 'MIDAS_SELFBOOKING', ' OPP ID- ' + oppLines[0].Id_Opportunity__c, null);
            if (!mapBusinessData.containsKey('EnableCancelBookingInMidas')  || oppLines[0].Id_Opportunity__r.Source_System__c != 'MIDAS') {
                return ClsOpportunityProcessor.cancelBookings(userData[0], oppLines, oppLines[0].Id_Opportunity__r.record_country__c);
            }
            listBookData = prepareDataForMidasCancelCallout(oppLines);
            LoggingUtility.log(logName, 'Request Body: ' + listBookData);
            LoggingUtility.captureTimeStamp(logName, 'Begin');
            response = LibWebserviceHelper.constructMidasRequestForBookingCancellation(oppLines[0].Id_Opportunity__r.record_country__c, listBookData, logName);
            if (response != null && (response.getStatusCode() == 204 || response.getStatusCode() == 208)) {
                result = Label.Midas_Terminate_Page_Success_Message;
            } else if (response == null) {
                result = Label.Midas_Terminate_Page_Error_Message ;
                LoggingUtility.logError(logName, 'No Token or response for Premium Placement');
                ClsOpportunityProcessor.updateExceptionInOpp(listBookData);
            }else {
                result = Label.Midas_Terminate_Page_Error_Message + ' ' + response.getStatus();
                LoggingUtility.logError(logName, ' Failed to terminate PremPlacements ' + response.getStatus() + ' Status Code ' + response.getStatusCode());
                ClsOpportunityProcessor.updateExceptionInOpp(listBookData);
            }
            LoggingUtility.captureTimeStamp(logName, 'End');
            LoggingUtility.commitLogs();
            return result;
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.logError(logName, e.getStackTraceString());
            if ((response == null || response.getStatusCode() != 204 && response.getStatusCode() != 208) && listBookData != null) {
                ClsOpportunityProcessor.updateExceptionInOpp(listBookData);
            }
            return e.getMessage();
        }
    }

    /**
   * @description To prepare data to send as body to Midas cancellations
   * @Param        ID oppLineId
   * @return       Wrapper oppLineItemBookingData
   */
    public static List<LibWebserviceHelper.oppLineItemBookingData> prepareDataForMidasCancelCallout(List<Opportunity_line_item__c> premPlacementLineItems ){

        List<LibWebserviceHelper.oppLineItemBookingData> wrapper = new List<LibWebserviceHelper.oppLineItemBookingData>();
        try {
            for (Opportunity_Line_item__c lineItem : premPlacementLineItems) {
                LibWebserviceHelper.oppLineItemBookingData bookData = new LibWebserviceHelper.oppLineItemBookingData(Integer.valueOf(lineItem.Booking_Api_Id__c), UserInfo.getUserEmail());
                wrapper.add(bookData);
            }
        }catch(exception e){
            system.debug('Error: '+e.getMessage());
        }
        return wrapper;
    }


}
