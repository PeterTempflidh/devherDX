public without sharing class CtrAccountClone {

    public Boolean createOpportunityFlag {get; set;}

    public Account theAccount {get; set;}
    public Account theClonedAccount {get; set;}

    public String selectedCloneOption {get; set;}
    public String accountCountryCode {get; private set;}

    private static Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private Map<String, Business_Config__c> mapBusinessData;

    // used for CD and Talabat
    public List<SelectOption> citiesPerCountry {
        get{
            List<SelectOption> res = new List<SelectOption>();
            if (String.isNotBlank(accountCountryCode)) {
                for (String city : ClsBEIntegrationUtils.getCitiesByCountryCode(accountCountryCode)) {
                    res.add(new SelectOption(city, city));
                }
            }
            return res;
        }
    }

    public List<SelectOption> freeProducts {
        get {
            List<SelectOption> res = new List<SelectOption>();

            for (List_Product_Price__c lp : idToProduct.values()) {
                res.add(new SelectOption(lp.Id, lp.Product_Name__c));
            }

            return res;
        }
    }

    public Id productToCreate {get; set;}

    private Map<Id, List_Product_Price__c> idToProduct {
        get {
            if (idToProduct != null) {
                return idToProduct;
            }

            idToProduct = new Map<Id, List_Product_Price__c>(
                [
                    Select
                    Product_Name__c,
                    Product_Type__c
                    From List_Product_Price__c
                    Where List_Price__c = 0.0
                    And Is_Active__c = true
                    And Requires_Asset__c = true
                    And Id_Country__r.Name = :theAccount.Record_Country__c
                ]
            );

            return idToProduct;
        }
        set;
    }
    
    public String sourceFranchiseType;
    
    public CtrAccountClone(ApexPages.StandardController stdController) {
        System.debug('CtrAccountClone.init: start. Record is is: ' + stdController.getId());


        theAccount = [
                         Select
                         Type,
                         ParentId,
                         Name,
                         Record_Country__c,
                         RecordTypeId,Facility__c,
                         RecordType.DeveloperName
                         From Account
                         Where Id = :stdController.getId()
                     ];

        for (Country__c c : [select Iso__c from Country__c where Name = : theAccount.Record_Country__c]) {
            accountCountryCode = c.Iso__c;
        }
        
        sourceFranchiseType = '';

        System.debug('CtrAccountClone.init: done');
    }

    /**
     * Retrieves available close options from Business config
     * @return [description]
     */
    public List<SelectOption> getCloneOptions() {
        System.debug('CtrAccountClone.getCloneOptions: start');

        List<SelectOption> listResult = new List<SelectOption>();

        String rtDevName = LibRecordTypeHelper.getRecordTypeValue(theAccount.RecordTypeId);

        mapBusinessData = moam.get('Account Clone Select Options').get(rtDevName);

        // checks if user has to specify the account type before cloning
        if (mapBusinessData.containsKey('checkAccountTypeNotBlank')
                && Boolean.valueOf(mapBusinessData.get('checkAccountTypeNotBlank').Business_Rule_Value__c)
                && String.isBlank(theAccount.Type)) {

            System.debug('CtrAccountClone.getCloneOptions: account type is blank!');

            ClsUtilsApexPages.addWarningMessage(Label.SelectAccountType);
            return listResult; // empty list
        }

        // checks if cloning is enabled for this specific account type
        if (mapBusinessData.containsKey('allowedAccountTypeForCloning')) {
            Set<String> allowedType = new Set<String>(mapBusinessData.get('allowedAccountTypeForCloning').Business_Rule_Value__c.split(','));
            if (!allowedType.contains(theAccount.Type)) {

                System.debug('CtrAccountClone.getCloneOptions: account type not allowed');

                ClsUtilsApexPages.addWarningMessage(Label.Account_Clone_Type_Not_Allowed + ' ' + theAccount.Type);
                return listResult; // empty list
            }
        }

        String optvalues = mapBusinessData.get('selectOptionValues').Business_Rule_Value__c;

        // add an empty option
        listResult.add(new SelectOption('', '--Select--'));

        // checks for legacy value list
        if (optvalues != 'json_format') {
            // csv list of key:value options
            for (String keyValue : optvalues.split(',')) {
                listResult.add(new SelectOption(keyValue.split(':')[0], keyValue.split(':')[1]));
            }
        } else {
            // get clone options from business rule
            List<CloneOptionRule> optionsRule = (List<CloneOptionRule>) JSON.deserialize(mapBusinessData.get('selectOptionValuesJsonFormat').Business_Rule_Value__c, List<CloneOptionRule>.class);

            for (CloneOptionRule option : optionsRule) {
                // checks if options apply to this account
                System.debug('option-->'+option);
                if (option.appliesTo(theAccount)) {
                    listResult.add(new SelectOption(option.value, option.label));
                }
            }
        }

        return listResult;
    }

    /**
     * Called after user selected the clone option, initializes the account to clone
     * @return [description]
     */
    public void drawPanel() {

        System.debug('CtrAccountClone.drawPanel: start, selectedCloneOption is: ' + selectedCloneOption);

        if (String.isBlank(selectedCloneOption)) {
            return;
        }

        System.debug('CtrAccountClone.drawPanel: getting matrix');

        mapBusinessData = moam.get(selectedCloneOption).get(LibRecordTypeHelper.getRecordTypeValue(theAccount.RecordTypeId));

        String clonedAccountType = mapBusinessData.containsKey('clonedAccountType') ? mapBusinessData.get('clonedAccountType').Business_Rule_Value__c : theAccount.Type;


        String stringNamesOfFieldsToCopy = mapBusinessData.get('Copy fields').Business_Rule_Value__c;

        theAccount = queryAccount(stringNamesOfFieldsToCopy.split(','));
        theClonedAccount = new Account(recordtypeid = theAccount.recordtypeid);

        theClonedAccount.Type = clonedAccountType;
        sourceFranchiseType = theAccount.Franchise_Type__c;

        System.debug('CtrAccountClone.drawPanel: theAccount id is: ' + theAccount.Id);

        for (String field : stringNamesOfFieldsToCopy.split(',')) {
            if (field.containsIgnoreCase('ownerid')) {
                //Check if user is not inactive
                User u =  [Select isActive from user where id = :theAccount.OwnerId];
                if (!u.isActive) {
                    continue; // skips owner field if user is not active, default one will apply
                }
            }

            theClonedAccount.put(field, theAccount.get(field));
        }

        System.debug('CtrAccountClone.drawPanel: done');
    }

    public PageReference cancel() {
        return new PageReference('/' + theAccount.Id);
    }

    public PageReference doClone() {

        System.debug('CtrAccountClone.doClone: start, selectedCloneOption is: ' + selectedCloneOption);

        // checks for valid options
        if (String.isBlank(selectedCloneOption)) {
            return null;
        }

        mapBusinessData = moam.get(selectedCloneOption).get(LibRecordTypeHelper.getRecordTypeValue(theAccount.RecordTypeId));

        Boolean deeperLevelOfHierarchy = mapBusinessData.containsKey('deeperLevel') ? Boolean.valueOf(mapBusinessData.get('deeperLevel').Business_Rule_Value__c) : false;
        Boolean higherLevelOfHierarchy = mapBusinessData.containsKey('higherLevel') ? Boolean.valueOf(mapBusinessData.get('higherLevel').Business_Rule_Value__c) : false;
        Boolean relContacts = mapBusinessData.containsKey('Copy Related Contact') ? Boolean.valueOf(mapBusinessData.get('Copy Related Contact').Business_Rule_Value__c) : false;
        Boolean relPartners = mapBusinessData.containsKey('Copy Partner') ? Boolean.valueOf(mapBusinessData.get('Copy Partner').Business_Rule_Value__c) : false;
		Boolean isSharedLocation = mapBusinessData.containsKey('sharedLocation') ? Boolean.valueOf(mapBusinessData.get('sharedLocation').Business_Rule_Value__c) : false;
        Boolean restrictToGroupMembers = mapBusinessData.containsKey('Parent or grandparent must be group') ? Boolean.valueOf(mapBusinessData.get('Parent or grandparent must be group').Business_Rule_Value__c) : false;

        // --- SP-2775 -----------------------------------------------------
        if (restrictToGroupMembers) {
            // check if parent or grandparnt are of type group
            Account accParentDetails = ClsAccountSelector.getAccountParentsTypes(theAccount.Id);
            if(accParentDetails.Parent.Type != 'Group' && accParentDetails.Parent.Parent == null 
                ||
               accParentDetails.Parent.Type != 'Group' && accParentDetails.Parent.Parent != null && accParentDetails.Parent.Parent.Type != 'Group' ) {
                   ClsUtilsApexPages.addErrorMessage(Label.AccountParentOrGrandParentInvalid);
                   return null;
            }
        }
        // -----------------------------------------------------------------

        // either from business config or same type as original account
        String clonedAccountType = mapBusinessData.containsKey('clonedAccountType') ? mapBusinessData.get('clonedAccountType').Business_Rule_Value__c : theAccount.Type;

        System.debug('CtrAccountClone.doClone: clonedAccountType is: ' + clonedAccountType);
        System.debug('CtrAccountClone.doClone: deeperLevelOfHierarchy is: ' + deeperLevelOfHierarchy);
        System.debug('CtrAccountClone.doClone: higherLevelOfHierarchy is: ' + higherLevelOfHierarchy);
        System.debug('CtrAccountClone.doClone: relContacts is: ' + relContacts);
        System.debug('CtrAccountClone.doClone: relPartners is: ' + relPartners);

        theClonedAccount.Type = clonedAccountType;

        if (deeperLevelOfHierarchy) {
            // we are going one level deep in the hierarchy
            theClonedAccount.ParentId = theAccount.Id;

        } else if (higherLevelOfHierarchy) {
            // we are going one level up in the hierarchy
            theClonedAccount.ParentId = null;

        } else {
            // we are staying at same level
            theClonedAccount.ParentId = theAccount.ParentId;
        }

        Savepoint sp = Database.setSavepoint();
        
        try{
            // create the clone
            insert theClonedAccount;
        }catch(DmlException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Target Account: ' + ex.getDmlMessage(0)));
            return null;
        }

        List<Account> toUpdateSource = new List<Account>();

        if(theAccount.Franchise_Type__c != sourceFranchiseType){
            toUpdateSource.add(theAccount);
        }

        if (higherLevelOfHierarchy) {
            // we are going one level up in the hierarchy
            theAccount.ParentId = theClonedAccount.Id;
            if(!toUpdateSource.contains(theAccount)){
                toUpdateSource.add(theAccount);
            }
        }

        if(!toUpdateSource.isEmpty()){
            try{
                update toUpdateSource;
            }catch(DmlException ex){
                Database.rollback(sp);
                theClonedAccount.Id = null;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Source Account: ' + ex.getDmlMessage(0)));
                return null;
            }
        }

        System.debug('CtrAccountClone.doClone: accounts updated successfully');

        if (relContacts) {

            // Clone the the contacts:
            List<AccountContactRelation> conlst = [Select Id, ContactId, AccountId from AccountContactRelation where AccountId = :theAccount.Id];

            if (!(conlst.isEmpty())) {
                // create a new
                List<AccountContactRelation> accConRelLst = new List<AccountContactRelation>();
                List<AccountContactRole> listOfContactRolesToInsert = new List<AccountContactRole>();

                for (AccountContactRelation con : conlst) {
                    AccountContactRelation accConRel = new AccountContactRelation();
                    accConRel.AccountId = theClonedAccount.Id;
                    accConRel.ContactId = con.ContactId;
                    accConRel.IsActive = true;
                    // FIXME: soql inside for, what the fuuuuuckkkkkk!!!!!!!! - @CreatedBy m.zeuli
                    List<AccountContactRole> listRoles = [Select AccountId, ContactId, isPrimary, Role from AccountContactRole where AccountId = : theAccount.Id and ContactId = :con.ContactId];

                    if (!(listRoles.isEmpty())) {
                        for (AccountContactRole rol : listRoles) {
                            AccountContactRole accContactRole = new AccountContactRole(
                                AccountId = theClonedAccount.Id,
                                ContactId = rol.ContactId,
                                //Only one role per contact should be selected in multipicklist.
                                Role = mapBusinessData.containsKey('Related Contact Role') ?
                                       mapBusinessData.get('Related Contact Role').Business_Rule_Value__c : rol.Role
                            );

                            listOfContactRolesToInsert.add(accContactRole);
                        }
                    }

                    accConRelLst.add(accConRel);
                }

                insert accConRelLst;
                if (!(listOfContactRolesToInsert.isEmpty())) {
                    insert listOfContactRolesToInsert;
                }
            }
        }
		
		List<Partner> partnersToBeInserted = new List<Partner>();
        if (relPartners) {
            //Cloned the partners:
            List<Partner> partnerList = [Select Id, AccountFromId, AccountToId, Role from Partner where AccountFromId = :theAccount.Id];
            if (!(partnerList.isEmpty())) {
                for (Partner prtn : partnerList) {
                    Partner part = new Partner();
                    part.AccountFromId = theClonedAccount.Id;
                    part.AccountToId = prtn.AccountToId;
                    part.Role = mapBusinessData.containsKey('Partner Role') ? mapBusinessData.get('Partner Role').Business_Rule_Value__c : prtn.Role;
                    partnersToBeInserted.add(part);
                }
            }
        }
        
        
        // Create an AccountPartner related list with role as "Shared Location" for Branch Express and Branc Virtual
		if(isSharedLocation){
			Partner part 			= new Partner();
            part.AccountFromId 		= theAccount.Id;
            part.AccountToId 		= theClonedAccount.Id;
            part.Role 				= mapBusinessData.containsKey('sharedLocationRole')?
            							mapBusinessData.get('sharedLocationRole').Business_Rule_Value__c : 
            							'Shared Location';
            partnersToBeInserted.add(part);
		}         
		
		if(partnersToBeInserted.size() > 0){
			insert partnersToBeInserted;
		}
		
        if (createOpportunityFlag) {
            Opportunity theOpportunity = new Opportunity(
                Name = mapBusinessData.get('Opportunity name').Business_Rule_Value__c,
                AccountId = theClonedAccount.Id,
                CloseDate = System.today() + Integer.valueOf(mapBusinessData.get('Opportunity CloseDate days in future').Business_Rule_Value__c),
                StageName = mapBusinessData.get('Opportunity Stagename').Business_Rule_Value__c,
                Probability = Double.valueOf(mapBusinessData.get('Opportunity Percentage').Business_Rule_Value__c),
                Business_Type__c = mapBusinessData.get('Opportunity BusinessType') != null ? mapBusinessData.get('Opportunity BusinessType').Business_Rule_Value__c : null,
                Recordtypeid = LibRecordTypeHelper.getRecordTypeValue(mapBusinessData.get('OpportunityRecordtype').Business_Rule_Value__c)
            );
            insert theOpportunity;
        }

        if (String.isNotBlank(productToCreate)) {
            Asset__c ast = createAssetFromProduct(idToProduct.get(productToCreate));
            insert ast;
        }

        if (mapBusinessData.get('Partner Account') != null && Boolean.valueOf(mapBusinessData.get('Partner Account').Business_Rule_Value__c)) {
            Partner accPartner = new Partner();
            accPartner.AccountFromId 	= theAccount.Id;
            accPartner.AccountToId 		= theClonedAccount.Id;
			accpartner.Role 			= mapBusinessData.get('Partner Account Role') != null ? 
											mapBusinessData.get('Partner Account Role').Business_Rule_Value__c : 
											Label.Account_Clone_Role;
            insert accPartner;
        }

        return null;
    }

    /**
     * Creates asset record from List Product Price
     * Replicate part of the logic inside ClsAssetProcessor.changeAssetStatusByProductType
     * because this asset does not have an Opp. Quote Line Item
     * @param  prod [description]
     * @return      [description]
     */
    private Asset__c createAssetFromProduct(List_Product_Price__c prod) {

        System.debug('CtrAccountClone.createAssetFromProduct: start, prod is: ' + prod);

        String rtId = mapBusinessData.get('AssetRecordType').Business_Rule_Value__c;
        String rtDevName = LibRecordTypeHelper.getRecordTypeValue(rtId);
        String status = 'New - Awaiting Shipping'; // default status

        System.debug('CtrAccountClone.createAssetFromProduct: rtDevName is: ' + rtDevName);

        Map<String, Business_Config__c> rules = moam.containsKey('ChangeAssetStatusByProductType') ? moam.get('ChangeAssetStatusByProductType').get(rtDevName) : null;

        if (rules != null) {

            System.debug('CtrAccountClone.createAssetFromProduct: checking if has to change status value...');

            Map<String, String> typeToStatus = (Map<String, String>) JSON.deserialize(rules.get('productTypeToAssetStatus').Business_Rule_Value__c, Map<String, String>.class);
            status = typeToStatus.containsKey(prod.Product_Type__c) ? typeToStatus.get(prod.Product_Type__c) : status;
        }

        System.debug('CtrAccountClone.createAssetFromProduct: status value is: ' + status);

        Asset__c ast = new Asset__c(
            Name = prod.Product_Name__c,
            CurrencyIsoCode = prod.CurrencyIsoCode,
            Status__c = status,
            Account__c = theClonedAccount.Id,
            RecordTypeId = rtId
        );

        System.debug('CtrAccountClone.createAssetFromProduct: done, asset is: ' + ast);

        return ast;
    }

    /**
    * Get the Account with all fields needed for cloning
    * @param  fields List of fields to query for
    * @return              [description]
    */
    private Account queryAccount(List<String> fields) {
        // these are fields are not meant to be copied!
        Set<String> fieldsSet = new Set<String> {'currencyisocode', 'recordtypeid', 'record_country__c', 'recordtype.developername', 'type', 'parentid', 'Facility__c'};

        String accId = theAccount.Id; // theAccount.Id won't work inside the query

        // avoid duplicate fields in soql query, in case above fields are also in business config
        for (String field : fields) {
            fieldsSet.add(field.toLowerCase());
        }

        fields.clear();
        fields.addAll(fieldsSet);

        String query = 'SELECT ' + String.join(fields, ',') + ',(SELECT Id FROM Contacts) FROM Account WHERE Id =:accId';
        Sobject obj = Database.query(query);

        return (Account)obj;
    }

    /**
     * Wraps a clone option to be displayed to the user.
     * Each options has a set of rules that Account's fields have to fulfill
     * in order for the option to be displayed
     */
    class CloneOptionRule {
        public Map<String, String> fieldsRequirements {get; set;}
        public String label {get; set;}
        public String value {get; set;}

        /**
         * Checks if this option applies to specified Account record
         * @param  a Account record to check
         * @return   true if Account's fields fulfill all rules, false otherwise
         */
        public Boolean appliesTo(Account a) {
            Boolean res = true; // return value

            if (fieldsRequirements == null) {
                return res; // no requirements for this option
            }

            for (String field : fieldsRequirements.keySet()) {
                String valueToFulfill = fieldsRequirements.get(field);
                String accFieldValue = String.valueOf(a.get(field));
                System.debug('valueToFulfill--> '+valueToFulfill + 'accFieldValue-->'+ accFieldValue);
                if (valueToFulfill == 'not_null') {
                    res &= String.isNotBlank(accFieldValue);
                } else {
                    res &= (valueToFulfill == accFieldValue);
                }
            }
            System.debug('res-->'+res);
            return res;
        }
    }
}