/**
 * Created by c.kumari on 06.05.2019.
 * Description - API to book Premium Placement in Salesforce from external system eg. MIDAS
 */

public class BookingServiceHandler {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public static BookingService.bookingDetails recBookingDetail;
    public static string logName = '';
    public static string insertedLogName;
    public static boolean doNotCreateCase = false;
    private enum SourceSystem { MIDAS, RESTAURANT_PORTAL_SERVICE }
    private static final String INVALID_SOURCE_SYSTEM = 'Invalid source system provided: {0}';
    private static final String CONTACT_NOT_FOUND = 'SelfBooking Contact not found. Email: {0}';

    /**
     * @description source system enum to string value map
     */
    private static Map<String, SourceSystem> nameToSourceSystem {
        get {
            Map<String, SourceSystem> sourceSystemValues = new Map<String, SourceSystem>();
            if (nameToSourceSystem == null) {
                for (SourceSystem enumValue : SourceSystem.values()) {
                    sourceSystemValues.put(String.valueOf(enumValue).toUpperCase(), enumValue);
                }
            }
            return sourceSystemValues;
        }
        private set;
    }

    private static SourceSystem getSourceSystem(String name){
        return String.isBlank(name) ? null : nameToSourceSystem.get(name.toUpperCase().replaceAll(' ', '_'));
    }

    /*******************************************************************************************************
    * @description Method to hold the data from the serialized request from Main class.
    * @param keys instance of BookingService.bookingDetails.
    * @return None
    */
    public static void processBookingServiceData(BookingService.bookingDetails bookingData){

        recBookingDetail = bookingData;
        logName = recBookingDetail.type+' Bookings';
        saveErrorLogs(logName,logName+' For: GridID '+recBookingDetail.restaurantGridId);
        LoggingUtility.captureTimeStamp(logName,'Begin');
        Savepoint sp = Database.setSavepoint();
        try {
            if (recBookingDetail.type == 'Create') {
                Opportunity opp = createOpportunity();
                insert opp;
                if (opp.Id != null) {
                    List<Opportunity_Line_Item__c> listOppLineItem = createOpportunityLineItems(opp, opp.company_code__c);
                    if (!listOppLineItem.isEmpty()) {
                        insert listOppLineItem;
                        Opportunity_Quote__c oppQuote = createOpportunityQuote(opp);
                        doNotCreateCase = true;
                        insert oppQuote;
                        if (oppQuote.Id != null) {
                            createOppQuoteLineItem(opp, oppQuote);
                            opp = updateOpportunityOwner(opp);
                            if (BookingService.mapBusinessdata.containsKey('finalOpportunityStage')) {
                                opp.StageName = BookingService.mapBusinessdata.get('finalOpportunityStage').Business_Rule_Value__c;
                            }
                            update opp;
                            List<Additional_Charges__c> listAddCharge = validateBookingsandRespond(opp);
                            
                            if (BookingService.mapBusinessdata.containsKey('invokeAutomaticQuoteGeneration') && BookingService.mapBusinessdata.get('invokeAutomaticQuoteGeneration').Business_Rule_Value__c == 'TRUE') {
                                
                                updateOppQuoteToGenerateQuote(oppQuote.Id, opp.RecordTypeId);
                                
                            }
                        }
                    }
                }
                /** Cancellations **/
            } else if (recBookingDetail.type == 'Cancel' && BookingService.mapBusinessdata.containsKey('cancellationAllowed')) { //additional check for cancel only allowed for Sweden from Midas
                List<Additional_Charges__c> listAdditionalCharge = terminateAdditionalCharges();
                if(!listAdditionalCharge.isEmpty())    {
                    update listAdditionalCharge;
                }
            }
            if(BookingService.isError == true){
                Database.rollback(sp);
                LoggingUtility.logError(logName,BookingService.errorMessage);
            }
        }catch(exception e){
            Database.rollback(sp);
            BookingService.isError = true;
            BookingService.errorMessage =  e.getMessage();
            LoggingUtility.logError(logName,'Failed to '+recBookingDetail.type+' bookings- '+e.getMessage());
        }
        LoggingUtility.captureTimeStamp(logName,'End');
        LoggingUtility.commitLogs();
        insertedLogName = returnLogRecord(logName+' For: GridID '+recBookingDetail.restaurantGridId);
    }

    /*******************************************************************************************************
    * @description Update opportunity quote record to automatically invoke quote generation process
    * @return Opportunity Record
    */
    @future
    public static void updateOppQuoteToGenerateQuote(Id oqId, Id oppRecordTypeId){
        /*All Nintex related variables*/
        String docGenPackageId;
        String deliveryOptionId;
        String docGenPackageName;
        String deliveryOptionName;
        Opportunity_Quote__c oq = new Opportunity_Quote__c(Id = oqId);
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('nintexDocumentGeneration');
        Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();

        mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oppRecordTypeId));
        if(mapBusinessRules != null && mapBusinessRules.get('docGenPackageName') != null && mapBusinessRules.get('deliveryOptionName') != null){
            docGenPackageName = mapBusinessRules.get('docGenPackageName').Business_rule_value__c;
            deliveryOptionName = mapBusinessRules.get('deliveryOptionName').Business_rule_value__c;
    		
    	}

        List<Loop__DDP_Integration_Option__c> doList = [SELECT Id, Loop__DDP__r.Id FROM Loop__DDP_Integration_Option__c WHERE Name = :deliveryOptionName AND Loop__DDP__r.Name = :docGenPackageName];
        if(!doList.isEmpty()){            
            docGenPackageId = doList[0].Loop__DDP__r.Id;
            deliveryOptionId = doList[0].Id;
            oq.Automate_quote_generation__c = true;
            oq.Drawloop_Next_Text__c = 'SFOpportunity_Quote__c:' +oq.Id+';DDPId:' +docGenPackageId+';Deploy:' +deliveryOptionId;
            update oq;
        }

        
    }

    /*******************************************************************************************************
    * @description Create Opportunity of type Premium Placement for requested Account GridID.
    * @return Opportunity Record
    */
    public static opportunity createOpportunity(){

        Opportunity opp = new Opportunity();
        List<Account> acctlist = new List<Account>();
        try{
            // Check whether the account Id is the ID of the account or its the GRID of the account
            if(recBookingDetail.restaurantGridId != null){
                acctlist = ClsAccountSelector.findAccountsByGrid(new Set<string>{recBookingDetail.restaurantGridId});
                if(acctlist!=null && !acctlist.isEmpty()){
                    String accountId = acctlist[0].Id;
                    if(BookingService.mapBusinessdata.containsKey('tarifName')) {
                        Map<String, String> productNames = getProductNames();
                        String tarifName = productNames == null || !productNames.containsKey('Tarif') ? BookingService.mapBusinessdata.get('tarifName').Business_Rule_Value__c : productNames.get('Tarif');
                        Tarif__c tr = TarifSelector.findTarifRecordByTarifName(tarifName, acctlist[0].company_code__c, acctlist[0].record_country__c);
                        if ( productNames == null && BookingService.mapBusinessdata.containsKey('opportunityName')) {
                            opp.Name = BookingService.mapBusinessdata.get('opportunityName').Business_Rule_Value__c;
                        } else {
                            opp.Name = productNames == null || !productNames.containsKey('Opportunity') ? 'Premium Placement' : productNames.get('Opportunity');
                        }

                        if(BookingService.mapBusinessdata.containsKey('opportunityType')){
                            opp.Type = BookingService.mapBusinessdata.get('opportunityType').Business_Rule_Value__c;
                        }
                        if(BookingService.mapBusinessdata.containsKey('businessType')){
                             opp.business_type__c = BookingService.mapBusinessdata.get('businessType').Business_Rule_Value__c ;
                        }
                        if( BookingService.mapBusinessdata.containsKey('stageName')) {
                            opp.stageName = BookingService.mapBusinessdata.get('stageName').Business_Rule_Value__c;
                        }
                        if((recBookingDetail.paymentMethod != null || recBookingDetail.paymentMethod != '') && BookingService.mapBusinessdata.containsKey('updatePaymentMethod')){
                            opp.Payment_Method__c = recBookingDetail.paymentMethod;
                        }
                            opp.accountId = accountId;
                            opp.recordtypeId = LibRecordTypeHelper.getRecordTypeValue(acctlist[0].company_code__c + '_Opportunity');
                            opp.Id_Tarif__c = tr.Id;
                            opp.closeDate = Date.today();
                            opp.Source_System__c = recBookingDetail.sourceSystem;
                            opp.company_code__c = acctlist[0].company_code__c;
                            opp.CurrencyIsoCode = acctlist[0].CurrencyIsoCode;
                    }

                }
            }
        }catch(Exception e){
            BookingService.isError = true;
            BookingService.errorMessage = 'Failed to create Opportunity: '+e.getMessage();
        }
        return opp;

    }

    private static Map<String,String> getProductNames() {
        if (!BookingService.mapBusinessdata.containsKey('nonPremiumPlacementProducts')) {
            return null;
        }
        try {
            Map<String, Map<String,String>> productNameMap = (Map<String, Map<String,String>>) JSON.deserialize(BookingService.mapBusinessdata.get('nonPremiumPlacementProducts').Business_Rule_Value__c, Map<String, Map<String,String>>.class);
            for (BookingService.OppLineItem lineItem : recBookingDetail.oppLineItem) {
                if (productNameMap.containsKey(lineItem.productName)) {
                    return productNameMap.get(lineItem.productName);
                }
            }
        } catch (JSONException e) {
            System.debug(e.getStackTraceString());
        }
        return null;
    }


    /*******************************************************************************************************
   * @description Queries for account records by provided GRID numbers.
   * @param keys Opportunity record and Company Code<string>.
   * @return Opportunity Line Items
   */
    public static List<Opportunity_Line_Item__c> createOpportunityLineItems(Opportunity Oppty, String companyCode) {

        List<Opportunity_Line_Item__c> listOppLineItem = new List<Opportunity_Line_Item__c>();
        List<List_Product_Price__c> listProdPrice = new List<List_Product_Price__c>();
        Map<String,List_Product_Price__c> premiumPlacementProductMap = new Map<String,List_Product_Price__c>();
        try {
            listProdPrice = ListProductPriceSelector.findListProdPriceByrecTypeandCountry(companyCode + '_List_Product_Price',recBookingDetail.Country);
            for(List_Product_Price__c listPP : listProdPrice){
                premiumPlacementProductMap.put(listPP.Product_Name__c,listPP);
            }

            for (BookingService.OppLineItem tempVar : recBookingDetail.oppLineItem) {

                Opportunity_Line_Item__c lineItem = new Opportunity_Line_Item__c();
                lineItem.City_ZipCode__c = tempVar.promoAreaName;
                lineItem.Sales_Area_Id__c = tempVar.promoAreaId;
                lineItem.Sub_type__c = premiumPlacementProductMap.get(tempVar.productName).Product_Type__c;
                lineItem.Has_related_tarif__c = false;
                lineItem.Id_Opportunity__c = Oppty.Id;
                if(BookingService.mapBusinessdata.containsKey('oppLineItemType')){
                    lineItem.Line_Item_Type__c = BookingService.mapBusinessdata.get('oppLineItemType').Business_Rule_Value__c;
                }
                lineItem.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(companyCode + '_Opportunity_Line_Item');
                lineItem.name = premiumPlacementProductMap.get(tempVar.productName).Displayed_Name__c;
                if(BookingService.mapBusinessdata.containsKey('addPromoArea')) {
                    lineItem.name += '-' + tempVar.promoAreaName; //Concatenate area name just for Sweden
                }
                lineItem.start_date__c =Date.valueOf(tempVar.startDate);
                if(String.isNotBlank(tempVar.endDate)) {
                    lineItem.End_Date__c = Date.valueOf(tempVar.endDate);
                }
                lineItem.position__c = tempVar.restaurantPosition;
                lineItem.listed_price__c = tempVar.listPrice;
                if(String.isNotBlank(tempVar.discount) && BookingService.mapBusinessdata.containsKey('discountType')) {
                    lineItem.discount__c = tempVar.discount + BookingService.mapBusinessdata.get('discountType').Business_Rule_Value__c;
                }
                lineItem.Id_List_Price_Product__c = premiumPlacementProductMap.get(tempVar.productName).Id;
                lineItem.Total_Amount__c = tempVar.totalAmount;
                lineItem.Booking_Api_Id__c = tempVar.bookingId;
                lineItem.Quantity__c = premiumPlacementProductMap.get(tempVar.productName).Default_Quantity__c;
                lineItem.Product_Group__c = premiumPlacementProductMap.get(tempVar.productName).Id_List_Product_Group__r.Name;
                lineItem.CurrencyIsoCode = Oppty.CurrencyIsoCode;
                lineItem.Unit_Cost__c = tempVar.costPerUnit;
                lineItem.Quantity__c = tempVar.quantity;
                lineItem.Sub_Product_Name__c = tempVar.subProductName;
                lineItem.Budget__c = tempVar.budget;
                lineItem.Interval__c = tempVar.interval;

                listOppLineItem.add(lineItem);
            }
        }catch(Exception e){
            BookingService.isError = true;
            BookingService.errorMessage = BookingService.errorMessage +' '+'Failed to create OpportunityLineItem: '+e.getMessage() + e.getLineNumber();
        }
        return listOppLineItem;
    }

    /*******************************************************************************************************
   * @description Create Quote for the above Opportunity.
   * @param keys Opportunity record.
   * @return Opportunity Quote record.
   */
    public static Opportunity_Quote__c createOpportunityQuote(Opportunity opp) {

        Opportunity_Quote__c quote = new Opportunity_Quote__c();
        try {
            //Create Quote
            quote.Id_tarif__c 	= opp.Id_Tarif__c;
            quote.recordtypeId 	= LibRecordTypeHelper.getRecordTypeValue(opp.company_code__c + '_Opportunity_Quote');
            quote.Id_Opportunity__c = opp.Id;
            quote.CurrencyISOCode = opp.CurrencyISOCode;
            if(BookingService.mapBusinessdata.containsKey('quoteStatus')) {
                quote.status__c = BookingService.mapBusinessdata.get('quoteStatus').Business_Rule_Value__c;
            }
            quote.Id_Account__c = opp.accountId;

        }catch(Exception e){
            BookingService.isError = true;
            BookingService.errorMessage = BookingService.errorMessage +' '+'Failed to create Quote: '+e.getMessage();
        }
        return quote;
    }

    /*******************************************************************************************************
   * @description Create QuoteLineItem from methods in Trigger.
   * @param keys Opportunity record.
   * @return Opportunity Quote record
   */
    public static void createOppQuoteLineItem(Opportunity opp,Opportunity_Quote__c quote) {

        try {
            // Create Quote Line items
            if(quote != null) {
                Tarif.createQuoteLineItems(quote, opp);
            }
        }catch(Exception e){
            BookingService.isError = true;
            BookingService.errorMessage = BookingService.errorMessage+' '+'Failed to create QuoteLineItem: '+e.getMessage();
        }
    }

    /*******************************************************************************************************
   * @description Verify whether Additional Charges created successfully or not and return response accordingly.
   * @param keys Opportunity record.
   * @return List of Additional Charges
   */
    public static List<Additional_Charges__c> validateBookingsandRespond(Opportunity opp) {

        List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();
        try {
            listAdditional = AdditionalChargesSelector.getAdditionalChargesForOpportunity(new Set<ID>{opp.Id});
        }catch(exception e){
            BookingService.isError = true;
            BookingService.errorMessage = BookingService.errorMessage+' '+'Failed to create AdditionalCharges: '+e.getMessage();
        }
        return listAdditional;
    }

    /*******************************************************************************************************
   * @description Terminate Additional Charges from the Booking Id provided by MIDAS.
   */
    public static List<Additional_Charges__c> terminateAdditionalCharges() {

        List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();
        List<Additional_Charges__c> listAdditionalToUpdate = new List<Additional_Charges__c>();
        set<String> addChargeBookingIds = new set<String>();
        try {
            for (BookingService.OppLineItem tempVar : recBookingDetail.oppLineItem) {
                addChargeBookingIds.add(tempVar.bookingId);
            }
            listAdditional = AdditionalChargesSelector.getAdditionalChargesByBookingID(addChargeBookingIds);
            if (listAdditional.size() > 0) {
                for (Additional_Charges__c addCharge : listAdditional) {
                    if(BookingService.mapBusinessdata.containsKey('terminationStatus') && BookingService.mapBusinessdata.containsKey('terminationReason')) {
                        addCharge.Status__c = BookingService.mapBusinessdata.get('terminationStatus').Business_Rule_Value__c;
                        addCharge.Termination_Reason__c = BookingService.mapBusinessdata.get('terminationReason').Business_Rule_Value__c;
                    }
                    addCharge.Termination_Date__c = Date.today();
                    listAdditionalToUpdate.add(addCharge);
                }
            }else{
                BookingService.errorMessage = BookingService.errorMessage+' '+'Bookings already terminated or does not exist';
                BookingService.isError = true;
                BookingService.errorCode = 208;
            }
        }catch(exception e){
            BookingService.isError = true;
            BookingService.errorMessage = BookingService.errorMessage+' '+'Failed to terminate Additional Charges/Bookings: '+e.getMessage();
        }

        return listAdditionalToUpdate;
    }

    /**
     * @description Update opportunity owner fields based on source system
     *
     * @param opportunity booking opportunity
     *
     * @return opportunity with updated owner
     */
    private static Opportunity updateOpportunityOwner(Opportunity opportunity) {
        SourceSystem sourceSystem = getSourceSystem(recBookingDetail.sourceSystem);
        switch on sourceSystem {
            when MIDAS {
                processOwnerUser(opportunity);
            } when RESTAURANT_PORTAL_SERVICE {
                processOwnerContact(opportunity);
            } when else {
                throw new BookingService.BookingServiceException(String.format(INVALID_SOURCE_SYSTEM, new List<String>{recBookingDetail.sourceSystem}));
            }
        }
        return opportunity;
    }

    /**
     * @description Assign contact to opportunity Selfbooking_Owner__c for Midas SelfBooking
     *
     * @param opp booking opportunity
     */
    private static void processOwnerContact(Opportunity opp) {
        if (String.isBlank(recBookingDetail.Owner)) { return; }
        Contact cont = ContactSelector.getByEmailAndAccountGrid(recBookingDetail.Owner, recBookingDetail.restaurantGridId);
        if (!cont.isSet(Contact.Id.getDescribe().getLocalName())) {
            LoggingUtility.logError(logName,String.format(CONTACT_NOT_FOUND, new List<String> {recBookingDetail.Owner}));
            return;
        }
        opp.Selfbooking_Owner__c = cont.Id;
    }

    /**
     * @description Assign user to opportunity Owner for Midas booking
     *
     * @param opp booking opportunity
     */
    private static void processOwnerUser(Opportunity opp) {
        User oppOwner = UserSelector.findUserByEmail(recBookingDetail.Owner);
        if (oppOwner != null) {
            opp.OwnerId = oppOwner.Id;
        }
    }

    /*******************************************************************************************************
   * @description Common method to call error log method.
   * @param keys Log name and sub type as String.
   * @return None
   */
    public static void saveErrorLogs(String logName, String subType){
        LoggingUtility.createLog(logName,'MIDAS_SELFBOOKING',subType,null);
        LoggingUtility.log(logName,'Request Body: ' +recBookingDetail);
    }

    /*******************************************************************************************************
   * @description Query the latest inserted error log record to return in the API response.
   */
    public static String returnLogRecord(string subType){
        Log_Error_Message__c logRecord = [select name from Log_Error_Message__c where type__c = 'MIDAS_SELFBOOKING'
                                          and Sub_Type__c =:subType order by lastmodifiedDate desc limit 1];

            return logRecord.Name;
    }

}
