/**
 * Class CaseHandler
 *
 * Trigger Handler for the Opportunity SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class ClsOpportunityHandler implements ITrigger{
    
    private Map<Id,Opportunity> closedWonOpportunitiesmap	= new Map<Id,Opportunity>(); 	// Map of Closed Won Opportunities
    private Map<Id,Opportunity> closedLostOpportunitiesmap	= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> nonContractedMPOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> genericMPOppMap				= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> adSalesOppMap				= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> photoListingProcessOppMap	= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> dishLevelProcessOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> noncontractedMCOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> contractedMPOppMap			= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> qualityCheckOppMap			= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> assetCreationOppMap			= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> brandingCreationOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> flatCommissionOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> PPCancellationOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> restaurantCareOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> formstackDescUpdateMap      = new Map<Id,Opportunity>(); // shortlist opportunities for formstack update
    private Map<Id,Opportunity> backendShippingOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> platformCreationOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> contractProcessOppMap		= new Map<Id,Opportunity>();
    private Map<Id,Opportunity> OppMap						= new Map<Id,Opportunity>(); // Opportunity map for parent and child records
    private List<Case> casesRelatedtoOpp					= new List<Case>();
    private Map<Id,List<Case>> OppVsCaseMap					= new Map<Id,List<Case>>();		
    private Map<Id,List<Case>> OppVsMPCaseMap				= new Map<Id,List<Case>>();		// Map of Opp Id and Menu Processing Case
    private Map<Id,List<Case>> OppVsATCaseMap				= new Map<Id,List<Case>>();
    private Map<Id,List<Case>> photoListingCaseMap			= new Map<Id,List<Case>>();
    private Map<Id,List<Case>> onboardingCaseMap			= new Map<Id,List<Case>>();
    private Map<Id,List<Case>> formstackUpdateCaseMap       = new Map<Id,List<Case>>(); // formstack update case map
    private Map<String,List<Case>> accountVsCasesMap		= new Map<String,List<Case>>();
    private Map<Id,Account> oppVsAccountMap					= new Map<Id,Account>();
    private Map<Id,Opportunity_Quote__c> oppVsQuoteMap		= new Map<Id,Opportunity_Quote__c>();
    private List<String> accountIdsForBackend				= new List<String>();
    private List<SObject> SObjectList						= new List<SObject>();
	private List<Contact> contactList						= new List<Contact>();
    private Map<Id,List<Opportunity>> allOppsPerAccount		= new Map<Id,List<Opportunity>>();
    private Map<Id,Opportunity> PremPlacApprovedOppMap		= new Map<Id,Opportunity>();
    private Map<String,List<Opportunity_Line_Item__c>> oppVsLineItemMap 		
    														= new Map<String,List<Opportunity_Line_Item__c>>();
    private Map<Id,Opportunity> childChainOppMap            = new Map<Id,Opportunity>(); 
    private Map<String,List<Opportunity_Quote_Line_Item__c>> oppVsQuoteLineItemMap 	
    														= new Map<String,List<Opportunity_Quote_Line_Item__c>>();
    
    // Constructor
    public ClsOpportunityHandler(){
    	
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     *
     * NOTE: This method also performs bulk before oprations 
     */
    public void bulkBefore(){	
    	Boolean fetchCases		= false;
    	Boolean fetchOpps		= false;
    	Boolean fetchQuotes		= false;
    	Boolean fetchAccounts	= false;
    	
    	Integer oppWithoutCurrencyAndCompanyCode = 0;
    	for(Opportunity opp : (List<Opportunity>)Trigger.New){
    		if(opp.currencyISOCode == null || opp.Company_Code__c == null)
    			oppWithoutCurrencyAndCompanyCode++;
    	}
    	
     	/* mark which items should be fetched(queried)*/
     	If(Trigger.isUpdate){
     		/* Prepare the maps which are going to be used in the trigger */
     		// prepare map for non contracted Menu processsing
        	nonContractedMPOppMap 	= ClsOpportunityProcessor.getNonContractedMPOpps(Trigger.New);
     		// fetch all the closed won opps
    		closedWonOpportunitiesmap = ClsOpportunityProcessor.getClosedWonOpps(Trigger.New,Trigger.oldMap);
             // Prepare map for the child of chain Opportunity which should be validated for required fields
            childChainOppMap    = ClsOpportunityProcessor.getChildChainOpps(Trigger.New,Trigger.oldMap);
		
		//SSC-1533
		ClsOpportunityProcessor.updateOppsCountryFromAccount(Trigger.New,Trigger.oldMap);
    		
     		fetchCases 	= true;
     		fetchOpps	= true;
     		fetchQuotes	= true;
     	}
    	
    	If(Trigger.isInsert){
    		fetchAccounts = true;
    	}
    	
    	/**
    	* Fetch the cases, accounts and line items. The fetched records are used accross the trigger.
    	*/
    	if(fetchCases){
    		// Fetch all the against against the opportunities		
    		casesRelatedtoOpp	= ClsOpportunityProcessor.fetchCasesFromOppIds((List<Opportunity>)Trigger.New);
    		oppVsCaseMap		= ClsOpportunityProcessor.populateOppVsCaseMap(casesRelatedToOpp);
    		// populate the map of opportunity against the Menu processing cases based on the case list fetched
    		OppVsMPCaseMap 		= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Menu Processing');
    		OppVsATCaseMap		= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Arabic Translation');
    		photoListingCaseMap	= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Photo Listing');
    		onboardingCaseMap	= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Onboarding');
    	}
    	if(fetchOpps){
    		// ftech all the opportunities for parent and child records
    		OppMap	= ClsOpportunityProcessor.fetchOpportunityMap((List<Opportunity>)Trigger.New);
    	}
    	if(fetchQuotes){
    		// fetch all the quotes for the opportunities
    		oppVsQuoteMap = ClsOpportunityProcessor.fetchOppVsQuoteMap((List<Opportunity>)Trigger.New);
    	}
    	if(fetchAccounts && oppWithoutCurrencyAndCompanyCode > 0){
    		// Fetch all the accounts
    		oppVsAccountMap	= ClsOpportunityProcessor.getAccountMapFromOpps((List<Opportunity>)Trigger.New);
    	}
        // Fetch all the opps per account
        allOppsPerAccount = ClsOpportunityProcessor.fetchAllOppsPerAccount((List<Opportunity>)Trigger.New);

    	/* Perform the bulk operation in this section */
     	If(Trigger.isInsert){
     		ClsOpportunityProcessor.setDefaultValueForOpportunityQuoteComment(Trigger.New, false);
		//SSC-1533
	        ClsOpportunityProcessor.insertOppsCountryFromAccount(Trigger.New);
     	}

    	if(!closedWonOpportunitiesmap.isEmpty()){
    		ClsOpportunityProcessor.updateBookingsStatusInMidas(closedWonOpportunitiesmap,oppMap);		
		
    	}

    	// Add Debug statements
    	System.debug('********** Opportunity Trigger Bulk Before ************');
    	System.debug('Fetch Cases -> ' + fetchCases);
    	System.debug('Fetch Opps -> ' + fetchOpps);
    	System.debug('Fetch Quotes -> ' + fetchQuotes);
    	System.debug('Fetch Accounts -> ' + fetchAccounts);
    	System.debug('nonContractedMPOppMap -> ' + nonContractedMPOppMap.size());
    	System.debug('closedWonOpportunitiesmap -> ' + closedWonOpportunitiesmap.size());
    	System.debug('casesRelatedtoOpp -> ' + casesRelatedtoOpp.size());
    	System.debug('OppVsMPCaseMap -> ' + OppVsMPCaseMap.size());
    	System.debug('OppMap -> ' + OppMap.size());
    	System.debug('oppVsQuoteMap -> ' + oppVsQuoteMap.size());	
    	System.debug('oppVsAccountMap -> ' + oppVsAccountMap.size() );
        System.debug('allOppsPerAccount -> ' + allOppsPerAccount.size() );
    	
    }
	
	/**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     *
     * NOTE: This method also performs some bulk operations
     */
    public void bulkAfter(){
       Boolean fetchCases			= false;
       Boolean fetchAccounts		= false;
	   Boolean fetchLineItems		= false;
	   Boolean fetchCaseFromAccount = false;
	   Boolean fetchQuoteLineItems	= false;
	   Boolean fetchOpps			= false;
	   
	   /* Prepare the maps which are going to be used in the trigger */
       nonContractedMPOppMap 	= ClsOpportunityProcessor.getNonContractedMPOpps(Trigger.New);
       // prepare the map for quality check process
	   qualityCheckOppMap		= ClsOpportunityProcessor.shortListOppsForQCProcessing(Trigger.New,Trigger.oldMap);

       if(Trigger.isUpdate){
	       // prepare map for generic menu processing
	       genericMPOppMap			= ClsOpportunityProcessor.shortListOppsForMenuProcessing(Trigger.New,Trigger.oldMap);
	       // Prepare map for ad sales processing
	       adSalesOppMap			= ClsOpportunityProcessor.shortListOppsAdSalesProcessing(Trigger.New,Trigger.oldMap);
	       // prepare map for photo listing process
	       photoListingProcessOppMap= ClsOpportunityProcessor.shortlistPhotoListOpps(Trigger.New,Trigger.oldMap);
	       // prepare map for Dish level photo listing process
	       dishLevelProcessOppMap	= ClsOpportunityProcessor.shortlistDishLevelPhototOpps(Trigger.New,Trigger.oldMap);
	       // prepare the map for non contracted menu change
	       noncontractedMCOppMap	= ClsOpportunityProcessor.shortListNonContractedMenuChangeOpps(Trigger.New,Trigger.oldMap);
	       // prepare the map for contracted menu processing
	       contractedMPOppMap		= ClsOpportunityProcessor.shortListOppsForContractedMenuProcessing(Trigger.New,Trigger.oldMap);
	       // prepare the map for asset creation
	       assetCreationOppMap		= ClsOpportunityProcessor.shortListOppsForAssetCreationProcess(Trigger.New,Trigger.oldMap);
	       // Prepare the map for branding creation
	       brandingCreationOppMap	= ClsOpportunityProcessor.shortListOppsForBrandingCreation(Trigger.New,Trigger.oldMap);
	       // Prepare the map for flat commission entry case
	       flatCommissionOppMap		= ClsOpportunityProcessor.shortListOppsForflatCommissionEntryProcess(Trigger.New,Trigger.oldMap);
	       // prepare the map for the Premium placement cancellation
	       PPCancellationOppMap		= ClsOpportunityProcessor.shortListOppsForPPCancellation(Trigger.New,Trigger.oldMap);
	       // prepare the map for the creation of the backend id
	       accountIdsForBackend		= ClsOpportunityProcessor.shortListOppsForBackendIdCreation(Trigger.New,Trigger.oldMap);
	       // prepare the map for the creation of restaurant care (onboarding) cases
	       restaurantCareOppMap		= ClsOpportunityProcessor.shortListOppsForOnboardingCase(Trigger.New,Trigger.oldMap);
	       // prepare the map for the shipping backend id case
	       backendShippingOppMap	= ClsOpportunityProcessor.shortListOppsForBackendShippingCase(Trigger.New,Trigger.oldMap);
	       // Prepare the closed lost opportunities map
	       closedLostOpportunitiesmap= ClsOpportunityProcessor.getClosedLostOpps(Trigger.New,Trigger.oldMap);
	       // Prepare the map for the creation of platform records
	       platformCreationOppMap	= ClsOpportunityProcessor.shortListOppsForplatformCreation(Trigger.New,Trigger.oldMap);
	       // prepare the map for the contract process
	       contractProcessOppMap	= ClsOpportunityProcessor.shortListOppsForContractProcess(Trigger.New,Trigger.oldMap);
               // prepare the map for formstack description update
               formstackDescUpdateMap = ClsOpportunityProcessor.shortListOppsForFormstackUpdate(Trigger.New,Trigger.oldMap);
               // prepare the map for the Premium placement approval v2 Integration
               PremPlacApprovedOppMap		= ClsOpportunityProcessor.shortListOppsForPPApproval(Trigger.New,Trigger.oldMap);

		   clsOpportunityprocessor.createOpportunityLineItemForSelfSignUp(Trigger.New,Trigger.oldMap);
       
       }
       /* mark which items should be fetched(queried)*/
       if(!genericMPOppMap.isEmpty() || !photoListingProcessOppMap.isEmpty()
       		|| !noncontractedMCOppMap.isEmpty() || !contractedMPOppMap.isEmpty() || !restaurantCareOppMap.isEmpty()
       		|| !backendShippingOppMap.isEmpty() || !qualityCheckOppMap.isEmpty() || !nonContractedMPOppMap.isEmpty() || !formstackDescUpdateMap.isEmpty()){
       			fetchCases = true;
       } 
	   if(!genericMPOppMap.isEmpty() || !platformCreationOppMap.isEmpty() || !qualityCheckOppMap.isEmpty() 
	   		|| !restaurantCareOppMap.isEmpty()){
       		fetchAccounts	= true;
	   }
		if(!genericMPOppMap.isEmpty() || !contractedMPOppMap.isEmpty() || !dishLevelProcessOppMap.isEmpty()
				|| !PremPlacApprovedOppMap.isEmpty() || !PPCancellationOppMap.isEmpty()) {
	   		fetchLineItems	= true;
	   }
	   if(!noncontractedMCOppMap.isEmpty()){
	   		fetchCaseFromAccount = true;
	   }
	   if(!assetCreationOppMap.isEmpty() || !backendShippingOppMap.isEmpty() || !brandingCreationOppMap.isEmpty()
	   		|| !platformCreationOppMap.isEmpty() || !contractProcessOppMap.isEmpty()){
	   		fetchQuoteLineItems = true;
	   }
	   if(!flatCommissionOppMap.isEmpty() || !PPCancellationOppMap.isEmpty() || !closedLostOpportunitiesmap.isEmpty()
	   		|| !restaurantCareOppMap.isEmpty() || !PremPlacApprovedOppMap.isEmpty()){
	   		fetchOpps = true;
	   }

	   /**
    	* Fetch the cases, accounts,line items,quote line items and opportunities. The fetched records are used accross the trigger.
    	*/
    	if(fetchCases && casesRelatedtoOpp.size() == 0){
    		// Fetch all the against against the opportunities		
    		casesRelatedtoOpp	= ClsOpportunityProcessor.fetchCasesFromOppIds((List<Opportunity>)Trigger.New);
    		oppVsCaseMap		= ClsOpportunityProcessor.populateOppVsCaseMap(casesRelatedToOpp);
    		// populate the map of opportunity against the Menu processing cases based on the case list fetched
    		OppVsMPCaseMap 		= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Menu Processing');
    		OppVsATCaseMap		= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Arabic Translation');
    		photoListingCaseMap	= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Photo Listing');
    		onboardingCaseMap	= ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Onboarding');

            // Formstack Description update cases
            formstackUpdateCaseMap  = ClsOpportunityProcessor.getOppVsSpecificCaseMap(casesRelatedtoOpp,'Onboarding');
    	}
    	if(fetchAccounts && oppVsAccountMap.isEmpty()){
    		// fetch account
    		oppVsAccountMap		= ClsOpportunityProcessor.getAccountMapFromOpps((List<Opportunity>)Trigger.New);
    	}
    	if(fetchLineItems && oppVsLineItemMap.isEmpty()){
    		List<Opportunity> oppsTobeConsidered = new List<Opportunity>();
    		oppsTobeConsidered.addAll(genericMPOppMap.values());
    		oppsTobeConsidered.addAll(contractedMPOppMap.values());
            oppsTobeConsidered.addAll(dishLevelProcessOppMap.values());
			oppsTobeConsidered.addAll(PremPlacApprovedOppMap.values());
			oppsTobeConsidered.addAll(PPCancellationOppMap.values());
    		// Fetch line items and populate line items map
    		oppVsLineItemMap 	= ClsOpportunityProcessor.fetchOppIdVsLineItemMap(oppsTobeConsidered);
    	}
    	if(fetchCaseFromAccount){
    		// fetch all the cases against the account id
    		accountVsCasesMap = ClsOpportunityProcessor.fetchCasesFromAccountIds(noncontractedMCOppMap.values());
    	}
    	if(fetchQuoteLineItems){
    		List<Opportunity> oppsTobeConsidered = new List<Opportunity>();
    		oppsTobeConsidered.addAll(assetCreationOppMap.values());
    		oppsTobeConsidered.addAll(backendShippingOppMap.values());
    		oppsTobeConsidered.addAll(brandingCreationOppMap.values()); 
	   		oppsTobeConsidered.addAll(platformCreationOppMap.values());
	   		oppsTobeConsidered.addAll(contractProcessOppMap.values());
    		// fetch all the quote line items associated with the opps
    		oppVsQuoteLineItemMap = ClsOpportunityProcessor.fetchOppIdVsQuoteLineItemMap(oppsTobeConsidered);
    	}
    	if(fetchOpps && oppMap.isEmpty()){
    		// ftech all the opportunities for parent and child records
    		OppMap	= ClsOpportunityProcessor.fetchOpportunityMap((List<Opportunity>)Trigger.New);
    	}
    	
    	/******* Bulk operations **********/
    	// Perform bulk operation for backend ids creation
    	if(accountIdsForBackend.size() > 0){
    		ClsOpportunityProcessor.createBackendId(accountIdsForBackend);
    	}
    	// insert quote attachments
    	ClsOpportunityProcessor.insertQuoteAttOnOppWon(Trigger.New,Trigger.oldMap);
    	// Contract process - create contracts,additional charges,assets,addons and branding
    	if(!contractProcessOppMap.isEmpty()){
    		ClsOpportunityProcessor.createRelatedRecords(contractProcessOppMap,oppVsQuoteLineItemMap);
    	}
    	
    	/****************** Add Debug statements ************/
    	System.debug('********** Opportunity Trigger Bulk After ************');
    	System.debug('Fetch Cases -> ' + fetchCases);
    	System.debug('Fetch Opps -> ' + fetchOpps);
    	System.debug('Fetch Accounts -> ' + fetchAccounts);
    	System.debug('Fetch Line Items -> ' + fetchLineItems);
    	System.debug('Fetch Case from Accounts -> ' + fetchCaseFromAccount);
    	System.debug('Fetch Quote Line Items -> ' + fetchQuoteLineItems);
    	System.debug('nonContractedMPOppMap -> ' + nonContractedMPOppMap.size());
    	System.debug('genericMPOppMap -> ' + genericMPOppMap.size());
    	System.debug('adSalesOppMap -> ' + adSalesOppMap.size());
    	System.debug('photoListingProcessOppMap -> ' + photoListingProcessOppMap.size());
    	System.debug('dishLevelProcessOppMap -> ' + dishLevelProcessOppMap.size());
    	System.debug('noncontractedMCOppMap -> ' + noncontractedMCOppMap.size());
    	System.debug('contractedMPOppMap -> ' + contractedMPOppMap.size());
    	System.debug('qualityCheckOppMap -> ' + qualityCheckOppMap.size());
    	System.debug('assetCreationOppMap -> ' + assetCreationOppMap.size());
    	System.debug('brandingCreationOppMap -> ' + brandingCreationOppMap.size());
    	System.debug('flatCommissionOppMap -> ' + flatCommissionOppMap.size());
    	System.debug('PPCancellationOppMap -> ' + PPCancellationOppMap.size());
    	System.debug('accountIdsForBackend -> ' + accountIdsForBackend.size());
    	System.debug('restaurantCareOppMap -> ' + restaurantCareOppMap.size());
    	System.debug('backendShippingOppMap -> ' + backendShippingOppMap.size());
    	System.debug('closedLostOpportunitiesmap -> ' + closedLostOpportunitiesmap.size());
    	System.debug('platformCreationOppMap -> ' + platformCreationOppMap.size());
    	System.debug('contractProcessOppMap -> ' + contractProcessOppMap.size());
    	System.debug('casesRelatedtoOpp -> ' + casesRelatedtoOpp.size());
    	System.debug('oppVsAccountMap -> ' + oppVsAccountMap.size());
    	System.debug('oppVsLineItemMap -> ' + oppVsLineItemMap.size());
    	System.debug('accountVsCasesMap -> ' + accountVsCasesMap.size());
    	System.debug('oppVsQuoteLineItemMap -> ' + oppVsQuoteLineItemMap.size());
    	System.debug('OppMap -> ' + OppMap.size());
    }
	
	/**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so){
    	Opportunity opp = (Opportunity)so;
    	ClsOpportunityProcessor.checkOppStageOnCreation(opp);
    	
    	// Update the currency iso and company code
    	Account acc = oppVsAccountMap.get(opp.accountId);
    	if(acc != null && (opp.currencyISOCode == null || opp.Company_Code__c == null)){
    		ClsOpportunityProcessor.populateCurrencyISOCodeAndCompanyCode(opp,acc.Company_Code__c,acc.currencyISOCode);
    	}
    	
    	// validate opportunity stage for opportunity without accepted quote.
    	// Newly inserted opportunity will never have accepted quote, hence false is passed by default.
    	if(!ClsOpportunityProcessor.validateOpportunityStageWithoutQuote(opp,false))
    		return;
    	/* Non contracted menu processing opportunity stage and probability update.
    		Passing null as no cases will be there at the time of creation
    	*/
    	ClsOpportunityProcessor.nonContractedMenuProcessingOppUpdate(opp,null);

        if(allOppsPerAccount.containsKey(opp.AccountId)) {
			if (opp.Business_Type__c != null && opp.StageName != null) {
				ClsOpportunityProcessor.checkduplicateNewBusinessValidation(opp, allOppsPerAccount.get(opp.AccountId));
			}
        }
    }
	
	/**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so){
    	Opportunity opp 		= (Opportunity)so;
    	Opportunity oldRecord	= (Opportunity)oldSo;

    	// Populate closed Date
    	ClsOpportunityProcessor.populateCloseDate(opp,oldRecord);
    	// populate the currency ISO code and company code if it is not already populated
    	if(!OppMap.isEmpty() &&  OppMap.get(opp.Id).account.currencyISOCode != null && 
    		OppMap.get(opp.Id).account.company_Code__c != null &&
    		(opp.currencyISOCode == null || opp.Company_Code__c == null)){
    			ClsOpportunityProcessor.populateCurrencyISOCodeAndCompanyCode(opp,OppMap.get(opp.Id).account.company_Code__c,
    																		 OppMap.get(opp.Id).account.currencyISOCode);
    	}
    	// Non contracted menu processing opportunity stage and probability update.
    	if(nonContractedMPOppMap.containsKey(opp.Id)){
    		ClsOpportunityProcessor.nonContractedMenuProcessingOppUpdate(opp,OppVsMPCaseMap.get(opp.Id));
    	}
    	// validate opportunity stage
    	if(!ClsOpportunityProcessor.validateOpportunityStage(opp,oldRecord,
    														oppMap.get(opp.Id).Id_tarif__r.name == 'Premium Placement',
    														OppVsCaseMap.get(opp.Id)))
    		return;
    	// validate opportunity stage for opportunity without accepted quote
    	if(!ClsOpportunityProcessor.validateOpportunityStageWithoutQuote(opp,oppVsQuoteMap.containsKey(opp.Id)))
    		return;
    	// validate opportunity on closed won
    	if(closedWonOpportunitiesmap.containsKey(opp.Id)){
    		if(!ClsOpportunityProcessor.validateOpportunityOnClosedWon(opp,oppMap.get(opp.Id),OppVsCaseMap.get(opp.Id),
    																	oppVsQuoteMap.containsKey(opp.Id)))
    			return;
    	}
        if(allOppsPerAccount.containsKey(opp.AccountId)) {
            ClsOpportunityProcessor.checkduplicateNewBusinessValidation(opp, allOppsPerAccount.get(opp.AccountId));
        }
         // Validate child chain opportunities for the required fields
        if(childChainOppMap.containsKey(opp.Id)){
          if(!ClsOpportunityProcessor.validateChildChainOpportunity(opp))
            return;
        }
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {


    }
	
	/**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject so){
    	Opportunity opp = (Opportunity)so;
    	// Non Contracted MP case process. creating MP Case. passing null as no cases will be there at creation
    	if(nonContractedMPOppMap.containsKey(opp.Id)){
    		SObjectList.addAll(ClsOpportunityProcessor.nonContractedMenuProcessing(opp,null));
    	}
    	// Quality check process
    	if(qualityCheckOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createQualityCheckCase(opp,oppVsCaseMap.get(opp.Id),
    																		oppVsAccountMap.get(opp.accountId));
    		if(obj != null)
    			SObjectList.add(obj);
    	}
    }
	
	/**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so){
    	Opportunity opp     = (Opportunity)so;
    	Opportunity oldOpp  = (Opportunity)oldSo;

        // Update Onboarding case with Onboarding Formstack Description of the Opportunity
        if(!formstackUpdateCaseMap.isEmpty() && formstackDescUpdateMap.containsKey(opp.Id)){
            List<SOBject> objList = ClsOpportunityProcessor.updateFormstackDescriptionOnCase(opp,formstackUpdateCaseMap.get(opp.Id),oppVsAccountMap.get(opp.accountId));
            if(objList != null && !objList.isEmpty())
                SObjectList.addAll(objList);
        }
    	
    	// Generic Menu Processing
    	if(genericMPOppMap.containsKey(opp.Id)){
    		SObjectList.addAll(ClsOpportunityProcessor.createMenuProcessingCase(opp,oppVsLineItemMap.get(opp.Id),
    														oppVsAccountMap.get(opp.accountId),OppVsMPCaseMap.get(opp.Id),
    														OppVsATCaseMap.get(opp.Id)));
    	}
    	// Ad Sales Case creation process
    	if(adSalesOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createAdSalesCase(opp);
    		if(obj != null)
    			SObjectList.add(obj);
    	}
    	// Photo Listing case creation process
    	if(photoListingProcessOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createPhotoListingCase(opp,photoListingCaseMap.get(opp.Id), oldOpp);
    		if(obj != null)
    			SObjectList.add(obj);
    	}
    	// Dish level case creation process
    	if(dishLevelProcessOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createDishLevelPhotoCase(opp,oppVsLineItemMap.get(opp.id));
    		if(obj != null)
    			SObjectList.add(obj);
    	}
    	// Non Contracted MP case process. creating MP Case
    	if(nonContractedMPOppMap.containsKey(opp.Id)){
    		SObjectList.addAll(ClsOpportunityProcessor.nonContractedMenuProcessing(opp,OppVsMPCaseMap.get(opp.Id)));
    	}
    	// Non Contracted menu change process
    	if(noncontractedMCOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createMenuChangeCase(opp,oldOpp,accountVsCasesMap.get(opp.accountId),
    																		OppVsMPCaseMap.get(opp.Id), oppVsAccountMap.get(opp.accountId));
			if(obj != null)
    			SObjectList.add(obj);
    	}
    	// Quality check process
    	if(qualityCheckOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createQualityCheckCase(opp,oppVsCaseMap.get(opp.Id),
    																		oppVsAccountMap.get(opp.accountId));
    		if(obj != null)
    			SObjectList.add(obj);
    	}
    	// Asset Creation process
    	if(assetCreationOppMap.containsKey(opp.Id)){ 
    		SObjectList.addAll(ClsOpportunityProcessor.createAssets(opp,oppVsQuoteLineItemMap.get(opp.id)));
    	}
    	// Branding creation process
    	if(brandingCreationOppMap.containsKey(opp.Id)){
    		SObjectList.addAll(ClsOpportunityProcessor.createBrandings(opp,oppVsQuoteLineItemMap.get(opp.id)));
    	}
    	// Flat commission entry case process
    	if(flatCommissionOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createFlatCommissionEntryCase(opp,oppMap.get(opp.Id));
    		if(obj != null)
    			SObjectList.add(obj);
    	}

        //Premium placement cancellation process for closed lost/won opps for v2 integration in if condition
        /*
    		Premium placement cancellation process for closed lost opps v1 in else condition
    		Note: Cancellation is only done for 1 valid opportunity, for rest of the opps no operations are performed.
    			  No support for bulk operation as callout is made using future method.
    	*/
		if(PPCancellationOppMap.containsKey(opp.Id) && oppVsLineItemMap.containsKey(opp.Id) && isMidasOpportunity(oppVsLineItemMap.get(opp.Id))) {
			if (oppMap.get(opp.Id).Record_Country__c != 'Kingdom of Saudi Arabia') {
				ClsOpportunityProcessor.cancelPremiumPlacementInMidas(opp.Id);
			} else {
				ClsOpportunityProcessor.cancelMidasPP(opp);
			}
		}

		if(PremPlacApprovedOppMap.containsKey(opp.Id) && oppVsLineItemMap.containsKey(opp.Id) && isMidasOpportunity(oppVsLineItemMap.get(opp.Id))) {
			ClsOpportunityProcessor.approvePremiumPlacementInMidas(opp.Id);
		}

    	// Restaurant care case creation process
    	if(restaurantCareOppMap.containsKey(opp.Id)){
    		SOBject obj = ClsOpportunityProcessor.createOnboardingCase(opp,onboardingCaseMap.get(opp.Id),oppVsAccountMap.get(opp.accountId),
    																	oppMap.get(opp.Id).assets__r);
    		if(obj != null)
    			SObjectList.add(obj);
    	}
    	// Backend shipping case creation process
    	if(backendShippingOppMap.containsKey(opp.Id)){
    		SObjectList.addAll(ClsOpportunityProcessor.createBackendShippingCase(opp,oppVsCaseMap.get(opp.Id),
    																			oppVsQuoteLineItemMap.get(opp.Id)));
    	}
    	// Termination of child records on lost of opportunity
    	if(closedLostOpportunitiesmap.containsKey(opp.Id)){
    		SObjectList.addAll(ClsOpportunityProcessor.terminateOpportunityChildRecordsOnLost(oppMap.get(opp.Id)));
    	}
    	// Platform record creation process
    	if(platformCreationOppMap.containsKey(opp.Id)){
    		SObjectList.addAll(ClsOpportunityProcessor.createPlatforms(opp,oppVsQuoteLineItemMap.get(opp.Id),
    																	oppVsAccountMap.get(opp.accountId)));
    	}
    }

	private static Boolean isMidasOpportunity(List<Opportunity_Line_Item__c> lineItems) {
		if (lineItems == null || lineItems.isEmpty()) {
			return false;
		}
		for (Opportunity_Line_Item__c lineItem: lineItems) {
			if (String.isNotBlank(lineItem.Booking_Api_Id__c)) {
				return true;
			}
		}
		return false;
	}
	
	/**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so)
    {
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     
     NOTE: List<SObject> only supports insert,update and delete operation. Upsert operation is not supported. Seperating
     		the sobject list before.
     */
    public void andFinally(){
    	List<SObject> sobjectsToBeInserted = new List<SObject>();
    	List<SObject> sobjectsToBeUpdated = new List<SObject>();
		ClsOpportunityProcessor.PreventQCValidation = true;
		if(SObjectList.size() > 0){
			for(Sobject obj : SObjectList){
				if(obj.id != null){
					sobjectsToBeUpdated.add(obj);
				}else{
					sobjectsToBeInserted.add(obj);
				}
			}
			if(sobjectsToBeUpdated.size() > 0)
				update sobjectsToBeUpdated;
			if(sobjectsToBeInserted.size() > 0)
				insert sobjectsToBeInserted;
		}
		ClsOpportunityProcessor.PreventQCValidation = false;
    }
}
