
public class UnitTestDataFactory {

    public static Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Add_On_Service__c','Lead','List_Add_On__c','Case','Contact','Opportunity','Account', 'Contact', 'Contract', 'List_Product_Group__c','List_Product_Price__c','List_Add_On__c','List_Service_Price__c','Tarif__c','Tarif_Member__c','Opportunity_Tarif_Item__c','Opportunity_Product_Item__c','Opportunity_Service_Item__c','Opportunity_Quote__c',/* 'Opportunity_Quote_Product_Item__c', 'Opportunity_Quote_Service_Item__c',*/ 'Asset__c','Stock_Item__c', 'Additional_Charges__c', 'Opportunity_Line_Item__c', 'Opportunity_Quote_Line_Item__c', 'Yogiyo_Contact'});
    static Map<String, String> mapCountryCurrency = LibBusinessConfig.recordCurrencyMap();
    static Boolean RESPONSE_OK;
    static final String RESPONSE_BODY_OK = '{"foo":"bar"}';
    static final String RESPONSE_BODY_ERROR = 'Error';
   
    public static void getRecordtypeValues(){
        List<RecordType__c> recType =new List<RecordType__c>(); 
        for( RecordType r: [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType!='CustomTasks__c' AND NamespacePrefix = NULL]) {
            recType.add(new RecordType__c(Name=r.Id, Value__c=r.DeveloperName));
            recType.add(new RecordType__c(Name=r.DeveloperName, Value__c=r.Id));
        }
        insert recType;
    }
    public static RecordType getRecordType(String developerName){
        return mapRecordtypes.get(developerName);
    }

    public static Document getDocument(String body, String contentType, String developerName, Boolean isPublic, String name, String folderId ){
   		
        Document document = new Document();
        document.Body = Blob.valueOf(body);
        document.ContentType = contentType;
        document.DeveloperName = developerName;
        document.IsPublic = isPublic;
        document.Name = name;
        document.FolderId = folderId;
        return document;
    }

    public static EmailTemplate createEmailTemplate(String name, String body, String developerName, Boolean isActive, String subject, String templateType, String folderId){
        
        EmailTemplate template = new EmailTemplate(
            Name = name,
            DeveloperName = developerName,
            Body =  body,
            IsActive = isActive,
            Subject = subject,
            TemplateType = templateType,
            FolderId = folderId
        );
        return template;
    }

    /**
    * creates opportunity quote
    *
    * @param 
    *       processName: name of the process
    *       type: process or trigger
    *       businessRuleName: optional (initial business rule)
    *       businessRuleValue: optional (initial business value) 
    *       countryId: country of business config
    *       recordType: recordtype developer name that is used as a key
    * @return List of AccountContactRoles
    */
    public static Business_Config__c createBusinessConfig(String processName, String type, String businessRuleName, String businessRuleValue, String countryId, String recordType, Boolean isActive, Boolean isParent){
        Business_Config__c config = new Business_Config__c(
            Process_Name__c = processName,
            Business_Rule_Name__c = businessRuleName,
            Business_Rule_Value__c = businessRuleValue,
            Id_Country__c = countryId,
            Is_Active__c = isActive,
            Record_Type_Id__c = recordType,
            Type__c = type,
            Parent__c = isParent
        );
        //insert config;
        return config;
    }

    public static List<Lead> createLeads (Integer numberOfRecordsToCreate, Country__c country, String lastName, String company, String currencyIsoCode, String restaurantName, String recordTypeDeveloperName){
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            leads.add(new Lead(
                Company = company,
                Restaurant_Name__c = restaurantName,
                LastName = lastName,
                CurrencyIsoCode = currencyIsoCode,
                Record_Country__c = country.Name,
                RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    GRID__C = 'ABC'+i

                )
            );
        }
        return leads;
    }

    @TestVisible
    public static List<AddressDetail__c> createAddressDetails(List<String> addressTypes, Id accountId) {
        List<AddressDetail__c> addressDetails = new List<AddressDetail__c>();
        for (String addressType: addressTypes) {
            addressDetails.add(
                    new AddressDetail__c(
                            GPA_formatted_address__c = 'Oranienburger Str. 70, Berlin, Germany',
                            Account__c = accountId,
                            GPA_Country_long_name__c = 'Germany',
                            GPA_Country_short_name__c = 'DE',
                            GPA_Street_number_long_name__c = '70',
                            GPA_Admin_area_level_1_long_name__c = 'Oranienburgerstr.',
                            AddressLine__c = 'Oranienburger Str. 70, Berlin, Germany',
                            CountryCode__c = 'DE',
                            CountryName__c = 'Germany',
                            CountryDevName__c = 'Germany',
                            AdministrativeAreaName__c ='Oranienburgerstr',
                            AdministrativeAreaDevName__c = 'Oranienburgerstr',
                            Type__c = addressType
                    )
            );
        }
        return addressDetails;
    }

    /**
    * creates account records to use when creating contact and opportinuty records. Takes a parameter which determines how man accounts will be created
    *
    * @param numberOfRecordsToCreate : how many accounts should be created
    * @return List of accounts
    */
    public static List<Account> createAccounts(Integer numberOfRecordsToCreate, Country__c country, String recordTypeDeveloperName){
        List<Account> accounts = new List<Account>();
        String phoneNumber = '+421917123456';
        if(recordTypeDeveloperName == 'SE_Account'){
            phoneNumber = '+4712345678';
        } else if(recordTypeDeveloperName == 'FP_Account'){
            phoneNumber = '+85212345678';
        }
        
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            accounts.add(new Account(
                    Name = 'Test Account_' + i,
                    GRID__c = generateRandomString(5),
                    Record_Country__c = country.Name,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(country.Name),
                    Relay_Method__c = 'Email'
                //PKALINA ADDED:
                	,Account_Email__c = 'unittestaccount@deliveryhero.com'
                	,Phone = phoneNumber
                //PKALINA ADDED END
                )
            );
        }
        //insert accounts;
        return accounts;
    }

    /**
    * creates account records to use when creating contact and opportinuty records. Takes a parameter which determines how man accounts will be created
    *
    * @param 
    * @return account
    */
    public static Account createAccount(String name,Country__c country, String recordTypeDeveloperName){
        String phoneNumber = '+421917123456';
        if(recordTypeDeveloperName == 'SE_Account'){
            phoneNumber = '+4712345678';
        } else if(recordTypeDeveloperName == 'FP_Account'){
            phoneNumber = '+85212345678';
        }
        Account account = new Account(
                    Name = name,
                    Record_Country__c = country.Name,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(country.Name),
                    Relay_Method__c = 'Email'
            //PKALINA ADDED:
                	,Account_Email__c = 'unittestaccount@deliveryhero.com'
                	,Phone = phoneNumber 
                //PKALINA ADDED END
                );
        return account;
    }

    /**
    * creates contact records. Takes a parameter which determines how man contacts will be created
    *
    * @param numberOfRecordsToCreate : how many contacts should be created
    * @return List of contacts
    */
    public static List<Contact> createContacts(List<Account> accounts, String lastName, String firstName, String salutation, String role, Integer numberOfRecordsToCreate, String emailPrefix, String recordTypeDeveloperName){
        //List<Account> accounts = createAccounts(numberOfRecordsToCreate);
        List<Contact> contacts = new List<Contact>();
        for(Account acct : accounts){
            for(Integer i = 0; i < numberOfRecordsToCreate; i++){
                contacts.add(new Contact(
                    Salutation = salutation,
                    FirstName = firstName,
                    LastName = lastName,
                    Contact_Role__c = role,
                    AccountId = acct.Id,
                    Email = emailPrefix + '_contact_' + i + '_@deliveryhero.com',
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(acct.Record_Country__c)
                ));
            }
        }
        //insert contacts;
        return contacts;
    }

    /**
    * creates contracts records for an account
    *
    * @param 
    * @return
    */
    public static List<Contract> createContracts(Account acct, Date startDate, Date endDate, String status, String recordTypeDeveloperName, Integer numberOfRecordsToCreate){
        List<Contract> contracts = new List<Contract>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            contracts.add(new Contract(
                AccountId = acct.Id,
                StartDate = startDate,
                End_Date__c = endDate,
                Status = status,
                RecordTypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                )
            );
        }
        return contracts;
    }


    /**
  * creates contracts records for an account
  *
  * @param
  * @return
  */
    public static List<Contract> createContracts(Account acct, Date startDate, Date endDate, String status, String recordTypeDeveloperName, Integer numberOfRecordsToCreate,String serviceType){
        List<Contract> contracts = new List<Contract>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            contracts.add(new Contract(
                    AccountId = acct.Id,
                    StartDate = startDate,
                    End_Date__c = endDate,
                    Status = status,
                    RecordTypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    Service_Type__c = serviceType
            )
            );
        }
        return contracts;
    }

    /**
    * creates a single contract record
    *
    * @param 
    * @return
    */
    public static Contract createContract(Account acct, Date startDate, Date endDate, String status, String recordTypeDeveloperName){
        return new Contract( AccountId = acct.Id, StartDate = startDate, End_Date__c = endDate, Status = status, RecordTypeId = mapRecordtypes.get(recordTypeDeveloperName).Id);
    }

    /**
    *Create a Case for an Account
    *
    **/
    public static Case createCase(Account acc, String status,String type, String caseReason, String origin,Country__c country, String recordTypeDeveloperName,String subject){
        Case c = new Case(
            AccountId=acc.id,
            status = status,
            type = type,
            case_reason__c = caseReason,
            origin = origin,
            CurrencyIsoCode = country.CurrencyIsoCode,
            recordtypeid = mapRecordtypes.get(recordTypeDeveloperName).Id,
            subject = subject,
            Order_Number__c = '0'
        );
        return c;
    }

    /**
    *Create LiveChatTranscript record
    *
    **/
    public static LiveChatTranscript createChat(String country, String platform,String visitorId,String orderNumber,String owner){
        LiveChatTranscript chat = new  LiveChatTranscript(
            Order_Number__c = orderNumber,
            Platform__c = platform,	
            Country__c = country,
            LiveChatVisitorId = visitorId,
             OwnerId=owner 
        );   
        return chat;
    }
    
    /**
    * creates opportunity records. Takes a parameter which determines how man opportunities will be created
    *
    * @param numberOfRecordsToCreate : how many contacts should be created
    * @return List of opportunities
    */
    public static List<Opportunity> createOpportunities(List<Account> accounts, Integer numberOfRecordsToCreate, String recordTypeDeveloperName, Date closeDate){
        //List<Account> accounts = createAccounts(numberOfRecordsToCreate);
        List<Opportunity>  opportunities = new List<Opportunity>();
        for(Account acct : accounts){
            for(Integer i = 0; i < numberOfRecordsToCreate; i++){
                opportunities.add(new Opportunity(
                    Name = 'Test_Opportunity_' + i,
                    AccountId = acct.Id,
                    CloseDate = closeDate,
                    StageName = 'New',
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    //CurrencyIsoCode = mapCountryCurrency.get(acct.Record_Country__c)
                    CurrencyIsoCode = acct.CurrencyIsoCode
                    //RecordtypeId = mapRecordtypesKR.get('Yogiyo_Opportunity').id
                ));
            }
        }
        //insert opportunities;
        return opportunities; 
    }

    /**
    * creates opportunity records. Takes a parameter which determines how man opportunities will be created
    *
    * @param numberOfRecordsToCreate : how many contacts should be created
    * @return List of opportunities
    */
    public static Opportunity createOpportunity(String name,Account account,String recordTypeDeveloperName, Date closeDate){
        Opportunity  opportunity = new Opportunity(
                    Name = name,
                    AccountId = account.Id,
                    CloseDate = closeDate,
                    StageName = 'New',
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(account.Record_Country__c)
                );
            
        return opportunity;
    }

    /**
  * creates opportunity records.
  *
  * @param  String Name : name of the Opportunity
  * @return Opportunity
  */
    public static Opportunity createOpportunity(String name,Account account,String recordTypeDeveloperName,String stageName, Date closeDate){

        Opportunity opportunity = new Opportunity(
                Name = name,
                RecordTypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                AccountId = account.Id,
                CloseDate = Date.newInstance(2014, 12, 21),
                StageName = stageName,
                Business_Type__c = 'New Business');

        return opportunity;
    }


    /**
    * creates contact opportunity roles. Set the first contact as the primary contact
    *
    * @param
    *       contacts: list of contacts for whom contact roles will be created
    *       acct: opportunity for which opportunity contact roles will be created
    *       setPrimary: if true, the first contact is set as primary contact
    * @return List of OpportunityContactRoles
    */
    public static List<OpportunityContactRole> createOpportunityContactRoles(List<Contact> contacts, Opportunity opp, Boolean setPrimary){
        List<OpportunityContactRole> ocr = new List<OpportunityContactRole>();
        for(Integer i = 0; i < contacts.size(); i++){
            OpportunityContactRole oc = new OpportunityContactRole();
            oc.ContactId = contacts[i].id;
            oc.OpportunityId = Opp.Id;
            if(setPrimary && i == 0){
                oc.isPrimary = true;
            }
            ocr.add(oc);
        }
        //insert ocr;
        return ocr;
    }

    /**
    * creates account opportunity roles. Set the first contact as the primary contact
    *
    * @param 
    *       contacts: list of contacts for whom contact roles will be created
    *       acct: account for which account contact roles will be created
    *       setPrimary: if true, the first contact is set as primary contact
    * @return List of AccountContactRoles
    */
    public static List<AccountContactRole> createAccountContactRoles(List<Contact> contacts, Account acct, Boolean setPrimary){
        List<AccountContactRole> acr = new List<AccountContactRole>();
        for(Integer i = 0; i < contacts.size(); i++){
            AccountContactRole ar = new AccountContactRole();
            ar.ContactId = contacts[i].Id;
            ar.AccountId = acct.Id;
            if(setPrimary && i == 0){
                ar.isPrimary = true;
            }
            acr.add(ar);
        }
        //insert acr;
        return acr;
    }
    
    /**
    * creates opportunity quote
    *
    * @param 
    *       acct: account to which the opportunity of the quote belongs
    *       opp: opportunity to which the quote belongs 
    * @return List of AccountContactRoles
    */
    /*public static Opportunity_Quote__c createQuote(Account acct, Opportunity opp){
        Opportunity_Quote__c quote = new Opportunity_Quote__c();
        quote.Id_Account__c = acct.Id;
        quote.Id_Opportunity__c = opp.Id;
        quote.Status__c = 'Draft';
        insert quote;
        return quote;
    }*/

    /**
    * creates User
    *
    * @param 
    *       profileName: profile name for which user needs to be created
    *       companyName: comapany which user belongs eg: Yogiyo
    *       countryCode: country which user belongs eg: KR  
    * @return User record
    */
    /*public static User createUser(String profileName,String companyName, String countryCode){
        Profile p = [SELECT Id, Name, UserType, UserLicenseId FROM Profile where name=:profileName limit 1];

        User testUser = new User();
        testUser.FirstName = 'testClassUser';
        testUser.LastName = 'lastName';
        testUser.alias = 'testU';
        testUser.email ='unittestclassuser@testclass.com';
        testUser.UserName='testuser@testclass.com';
        testUser.profileId = p.id;
        testUser.Company_Name__c = companyName;
        testUser.CountryCode__c = countryCode;
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'de_DE_EURO';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.isActive = true;
        //insert testUser;
        return testUser;
    }*/

    /**
    * creates User
    *
    * @param 
    *       profileName: profile name for which user needs to be created
    *       companyName: comapany which user belongs eg: Yogiyo
    *       countryCode: country which user belongs eg: KR  
    * @return User record
    */
    public static User createUser(String profileName, String userName, String companyName, String countryCode){
        Profile p = [SELECT Id, Name, UserType, UserLicenseId FROM Profile where name=:profileName limit 1];
		
        User testUser = new User();
        testUser.FirstName = 'testClassUser';
        testUser.LastName = 'lastName';
        testUser.alias = 'testU';
        testUser.email = userName;
        testUser.UserName= userName;
        testUser.profileId = p.id;
        testUser.Company_Name__c = companyName;
        testUser.CountryCode__c = countryCode;
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'de_DE_EURO';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.isActive = true;
        testUser.federationIdentifier = userName;
        //insert testUser;
        return testUser;
    }
	
	/**
    * creates User With Role
    *
    * @param 
    *       profileName: profile name for which user needs to be created
    *       companyName: comapany which user belongs eg: Yogiyo
    *       countryCode: country which user belongs eg: KR  
    *       role       : Role that needs to be assigned to user
    * @return User record
    */
    public static User createUserWithRole(String profileName, String userName, String companyName, String countryCode, String userRoleId){
        Profile p = [SELECT Id, Name, UserType, UserLicenseId FROM Profile where name=:profileName limit 1];
		
        User testUser = new User();
        testUser.FirstName = 'testClassUser';
        testUser.LastName = 'lastName';
        testUser.alias = 'testU';
        testUser.email = userName;
        testUser.UserName= userName;
        testUser.profileId = p.id;
        testUser.userRoleId = userRoleId;
        testUser.Company_Name__c = companyName;
        testUser.CountryCode__c = countryCode;
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'de_DE_EURO';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.isActive = true;
        testUser.federationIdentifier = userName;
        //insert testUser;
        return testUser;
    }


    public static Country__c  createCountry(String iso, String name, String currencyIsoCode){
        Country__c c = new Country__c(Iso__c = iso, Name =name, CurrencyIsoCode = currencyIsoCode);
        //insert c;
        return c;

    }

    public static Company__c  createCompany(String name, String companyCode, Country__c country){
        Company__c com = new Company__c(Name = name, Company_Code__c = companyCode, Country__c = country.Id);
        //insert com;
        return com;

    }

    /**
    * creates product groups
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea    
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Product Groups
    */
    public static List<List_Product_Group__c> createProductGroups(Company__c company, Country__c country, Integer numberOfRecordsToCreate, String recordTypeDeveloperName){
        List<List_Product_Group__c> lpg = new List<List_Product_Group__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            lpg.add(new List_Product_Group__c(
                    Name =' Test_Product_Group_' + i, 
                    Company__c = company.Id, 
                    Id_Country__c = country.Id,
                    CurrencyIsoCode = country.CurrencyIsoCode,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_List_Product_Group').id
                )
            );
        }
        //insert lpg;
        return lpg;

    }

    /**
    * creates product groups
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea    
    *       groupName: name of the group
    *       recordTypeDeveloperName: recordtype developer name
    * @return Product Group
    */
    public static List_Product_Group__c createProductGroup(Company__c company, Country__c country,String groupName, String recordTypeDeveloperName){
        List_Product_Group__c lpg = new List_Product_Group__c(
                    Name =groupName,
                    Company__c = company.Id, 
                    Id_Country__c = country.Id,
                    CurrencyIsoCode = country.CurrencyIsoCode,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                );
        return lpg;
    }

    /**
    * creates product(s)
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea
    *       productId: product group Id         
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Products
    */
    public static List<List_Product_Price__c> createProducts(Company__c company, Country__c country, String productGroupId, Integer numberOfRecordsToCreate, String recordTypeDeveloperName,
        Integer installments, Boolean isActive, Decimal listPrice, Integer defaultQuantity, Boolean requiresAsset, Decimal maximumDiscount){
        List<List_Product_Price__c> products = new List<List_Product_Price__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            products.add(new List_Product_Price__c(
                    Product_Name__c ='Test_Product_' + i, 
                    Company__c = company.Id, 
                    Id_Country__c = country.Id,
                    Id_List_Product_Group__c = productGroupId,
                    Installments__c = installments,
                    Is_Active__c = isActive,
                    List_Price__c = listPrice,
                    Default_Quantity__c = defaultQuantity,
                    Requires_Asset__c = requiresAsset,
                    Maximum_discount__c = maximumDiscount,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = country.CurrencyIsoCode
                )
            );
        }
        //insert products;
        return products;

    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (RESPONSE_OK) {
                res.setBody(RESPONSE_BODY_OK);
                res.setStatusCode(200);
            } else {
                res.setBody(RESPONSE_BODY_ERROR);
                res.setStatusCode(400);
            }
            return res;
        }
    }


	public static List<List_Add_On__c> createAddOns(Company__c company, Country__c country, Integer numberOfRecordsToCreate,String recordTypeDeveloperName,
    													String ContractAddition,String type,Boolean IsActive){
    	List<List_Add_On__c> addOns = new List<List_Add_on__c>();
    	for(Integer i = 0; i < numberOfRecordsToCreate; i++){
    		addOns.add(new List_Add_On__c(name = 'Test_Add_On_' +i,
    					Company__c = company.id,
    					Id_Country__c = country.Id,
    					CurrencyISOCode = country.CurrencyISOCode,
    					RecordTypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
    					Contract_Addition__c = contractAddition,
    					Type__c = type,
    					Is_Active__c = isActive));
    	}
    	
    	return addOns;
    }
	

    /**
    * creates product(s)
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea
    *       productId: product group Id         
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Products
    */
    public static List_Product_Price__c createProduct(Company__c company, Country__c country,String name, String productGroupId, String recordTypeDeveloperName,Integer installments, Boolean isActive, Decimal listPrice, Integer defaultQuantity, Boolean requiresAsset, Decimal maximumDiscount){
        List_Product_Price__c product = new List_Product_Price__c(
                    Product_Name__c =name, 
                    Company__c = company.Id, 
                    Id_Country__c = country.Id,
                    Id_List_Product_Group__c = productGroupId,
                    Installments__c = installments,
                    Is_Active__c = isActive,
                    List_Price__c = listPrice,
                    Default_Quantity__c = defaultQuantity,
                    Requires_Asset__c = requiresAsset,
                    Maximum_discount__c = maximumDiscount,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = country.CurrencyIsoCode
                );
        return product;
    }

    

    /**
    * creates service(s)
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea        
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Services
    */
    public static List<List_Service_Price__c> createServices(Company__c company, Country__c country, Integer numberOfRecordsToCreate, String recordTypeDeveloperName, Decimal commissionPercentage,
        Decimal defaultCommisionPercentage, Decimal maximumCommission, Decimal minimumCommission, Integer commissionOrder, String commisionType, Boolean isActive, Integer recurringFee,
        String recurringInterval, String type, String serviceType){
        List<List_Service_Price__c> services = new List<List_Service_Price__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            services.add(new List_Service_Price__c(
                    Name ='Test_Service_' + i, 
                    Company__c = company.Id, 
                    Id_Country__c = country.Id, 
                    Commission_In_Percentage__c = commissionPercentage,
                    Default_Commission_In_Percentage__c = defaultCommisionPercentage,
                    Is_Active__c = isActive,
                    Maximum_Commission_In_Percentage__c = maximumCommission,
                    Minimum_Commission_in_Percentage__c = minimumCommission,
                    Type__c = type,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = country.CurrencyIsoCode,
                    Service_Type__c = serviceType
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_List_Service_Price').id
                )
            );
        }
        //insert services;
        return services;

    }

    /**
    * creates service(s)
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea        
    *       numberOfRecordsToCreate: number or records to create
    * @return List_Service_Price__c
    */
    public static List_Service_Price__c createService(Company__c company, Country__c country,String name, String recordTypeDeveloperName, Decimal commissionPercentage, Decimal defaultCommisionPercentage, Decimal maximumCommission, Decimal minimumCommission, Integer commissionOrder, Boolean isActive, Integer recurringFee, String type, String serviceType){
        List_Service_Price__c service = new List_Service_Price__c(
                    Name = name, 
                    Company__c = company.Id, 
                    Id_Country__c = country.Id, 
                    Commission_In_Percentage__c = commissionPercentage,
                    Default_Commission_In_Percentage__c = defaultCommisionPercentage,
                    Is_Active__c = isActive,
                    Maximum_Commission_In_Percentage__c = maximumCommission,
                    Minimum_Commission_in_Percentage__c = minimumCommission,
                    Type__c = type,
                    Recurring_Fee__c = recurringFee,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = country.CurrencyIsoCode,
                    Service_Type__c = serviceType
                );
        return service;
    }

    /**
    * creates tarif(s)
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea        
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Tarifs
    */
    public static List<Tarif__c> createTarifs(Company__c company, Country__c country, Integer numberOfRecordsToCreate, String recordTypeDeveloperName, Boolean isActive){
        List<Tarif__c> tarifs = new List<Tarif__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            tarifs.add(new Tarif__c(
                    Name = 'Test_Tarif_' + i,
                    Company__c = company.Id, 
                    Id_Country__c = country.Id,
                    Is_Active__c = isActive,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Tarif').id
                )
            );
        }
        //insert tarifs;
        return tarifs;
    }

    /**
    * creates tarif member
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea        
    *       numberOfRecordsToCreate: number or records to create
    * @return Tarif_Member__c
    */
    public static List<Tarif_Member__c> createTarifMembers(String prodSerMmemberId, Integer numberOfRecordsToCreate, String recordTypeDeveloperName, String tarifId, String type){
        List<Tarif_Member__c> tarifMembers = new List<Tarif_Member__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            tarifMembers.add(
                new Tarif_Member__c(
                    Id_Tarif_Item__c = prodSerMmemberId,
                    Tarif_Name__c = tarifId, 
                    Type__c = type,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                )
            );
        }
                
            
        return tarifMembers;
    }

    /**
    * creates tarif
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea        
    *       numberOfRecordsToCreate: number or records to create
    * @return Tarif
    */
    public static Tarif__c createTarif(Company__c company, Country__c country,String name,String recordTypeDeveloperName, Boolean isActive){
        Tarif__c tarif =new Tarif__c(
                    Name = name,
                    Company__c = company.Id, 
                    Id_Country__c = country.Id,
                    Is_Active__c = isActive,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                );
            
        return tarif;
    }

    /**
    * creates tarif
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea        
    *       numberOfRecordsToCreate: number or records to create
    * @return Opportunity_Tarif_Item__c
    */
    public static Opportunity_Tarif_Item__c createOpportunityTarif(String name,String tarifId,String oppId,String recordTypeDeveloperName){
        Opportunity_Tarif_Item__c oppTarif =new Opportunity_Tarif_Item__c(
                    Name = name,
                    Id_Opportunity__c = oppId, 
                    Id_Tarif__c = tarifId,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                );
            
        return oppTarif;
    }


    /**
    * creates tarif member
    *
    * @param 
    *       companyName: company Id eg: Id for Yogiyo
    *       countryCode: country Id eg: Id for Korea        
    *       numberOfRecordsToCreate: number or records to create
    * @return Tarif_Member__c
    */
    public static Tarif_Member__c createTarifMember(String prodSerMmemberId,String recordTypeDeveloperName,String tarifId,String type ){
        Tarif_Member__c tarifMem =new Tarif_Member__c(
                    Id_Tarif_Item__c = prodSerMmemberId,
                    Tarif_Name__c = tarifId, 
                    Type__c = type,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                );
            
        return tarifMem;
    }


    /**
    * creates Opportunity Product Items(s)
    *
    * @param 
    *       opportunityId: Id of opportunity which this item will be related to (Master of Master-detail)
    *       productId: Id of the product that makes up this opportunity item        
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Opportuinty Product Items
    */
    public static List<Opportunity_Product_Item__c> createOpportunityProductItems(Opportunity opportunityRecord,String prodgroupId, String productId, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
        Integer installments, String rabbat, Decimal listPrice, Integer quantity, Decimal totalAmount){
        List<Opportunity_Product_Item__c> opi = new List<Opportunity_Product_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opi.add(new Opportunity_Product_Item__c(
                    Name = 'Test_Opportunity_Product_Item_' + i,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Price_Product__c = productId,
                    Has_Related_Tarif__c = hasTarif,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Quantity__c = quantity,
                    Total_Amount__c = totalAmount,
                    Rabbat__c = rabbat,
                    Product_Group__c = prodgroupId,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c)
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Product_Item').id
                )
            );
        }
        //insert opi;
        return opi;
    }


    /**
    * creates Opportunity Product Item
    *
    * @param 
    *       opportunityId: Id of opportunity which this item will be related to (Master of Master-detail)
    *       productId: Id of the product that makes up this opportunity item        
    *       numberOfRecordsToCreate: number or records to create
    * @return Opportuinty Product Items
    */
    public static Opportunity_Product_Item__c createOpportunityProductItem(String name, Opportunity opportunityRecord,String prodgroupId, String productId, Boolean hasTarif, String recordTypeDeveloperName,Integer installments, String rabbat, Decimal listPrice, Integer quantity, Decimal totalAmount){
        Opportunity_Product_Item__c opi = new Opportunity_Product_Item__c(
                    Name = name,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Price_Product__c = productId,
                    Has_Related_Tarif__c = hasTarif,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Quantity__c = quantity,
                    Total_Amount__c = totalAmount,
                    Rabbat__c = rabbat,
                    Product_Group__c = prodgroupId,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    //CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c)
                    CurrencyIsoCode = opportunityRecord.CurrencyIsoCode
            );
        return opi;
    }

    /**
    * creates Opportunity Service Items(s)
    *
    * @param 
    *       opportunityId: Id of opportunity which this item will be related to (Master of Master-detail)
    *       serviceId: Id of the service that makes up this opportunity item        
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Opportuinty Service Items
    */
    public static List<Opportunity_Service_Item__c> createOpportunityServiceItems(Opportunity opportunityRecord, String serviceId, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
         Decimal commissionPercentage, Integer commissionOrder, Date startDate, String type, Decimal recurringFee){
        List<Opportunity_Service_Item__c> opi = new List<Opportunity_Service_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opi.add(new Opportunity_Service_Item__c(
                    Name = 'Test_Opportunity_Service_Item_' + i,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Service_Price__c = serviceId,
                    Has_Related_Tarif__c = hasTarif,
                    Commission_In_Percentage__c = commissionPercentage,
                    Commission_Per_Order__c = commissionOrder,
                    Start_Date__c = startDate,
                    Type__c = type,
                    Recurring_Fee__c = recurringFee,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c)
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Service_Item').id
                )
            );
        }
        //insert opi;
        return opi;
    }

    /**
    * creates Opportunity Service Items
    *
    * @param 
    *       opportunityId: Id of opportunity which this item will be related to (Master of Master-detail)
    *       serviceId: Id of the service that makes up this opportunity item        
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Opportuinty Service Item
    */
    public static Opportunity_Service_Item__c createOpportunityServiceItem(String name, Opportunity opportunityRecord, String serviceId, Boolean hasTarif, String recordTypeDeveloperName, Decimal commissionPercentage, Integer commissionOrder, Date startDate, String type, Decimal recurringFee){
        Opportunity_Service_Item__c opi = new Opportunity_Service_Item__c(
                    Name = name,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Service_Price__c = serviceId,
                    Has_Related_Tarif__c = hasTarif,
                    Commission_In_Percentage__c = commissionPercentage,
                    Commission_Per_Order__c = commissionOrder,
                    Start_Date__c = startDate,
                    Type__c = type,
                    Recurring_Fee__c = recurringFee,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c)
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Service_Item').id
                
            );
        
        
        return opi;
    }


    /**
    * creates Opportunity Quotes(s)
    *
    * @param    
    *       opportunityRecord: Opportunity to which the quote is attached (Master of Master-detail) 
    *       numberOfRecordsToCreate: number or records to create
    * @return List of Opportunity Quotes
    */
    /*public static List<Opportunity_Quote__c> createOpportunityQuotes(Opportunity opportunityRecord, Integer numberOfRecordsToCreate, String recordTypeDeveloperName){
        List<Opportunity_Quote__c> quotes = new List<Opportunity_Quote__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            quotes.add(new Opportunity_Quote__c(
                    Id_Account__c = opportunityRecord.AccountId,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Quote').id
                )
            );
        }
        insert quotes;
        return quotes;
    }*/
    

    /**
    * creates Opportunity Quotes(s)
    *
    * @param    
    *       opportunityRecord: Opportunity to which the quote is attached (Master of Master-detail) 
    *       numberOfRecordsToCreate: number or records to create
    *       recordTypeDeveloperName: recordType developer name
    * @return List of Opportunity Quotes
    */
    public static List<Opportunity_Quote__c> createOpportunityQuotes(Opportunity opportunityRecord, Integer numberOfRecordsToCreate, String recordTypeDeveloperName, String status,
        String description, Decimal subTotal, Decimal total, String urlKey, String key, Decimal vat){
        List<Opportunity_Quote__c> quotes = new List<Opportunity_Quote__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            quotes.add(new Opportunity_Quote__c(
                    Id_Account__c = opportunityRecord.AccountId,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Status__c = status,
                    Subtotal__c = subTotal,
                    Total__c = total,
                    Url_Key__c = urlKey,
                    Key__c = key,
                    VAT__c = vat,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    //CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c)
                    CurrencyIsoCode = opportunityRecord.CurrencyIsoCode
                )
            );
        }
        //insert quotes;
        return quotes;
    }


    /**
    * creates Opportunity Quote Product Items(s)
    *
    * @param 
    *       opportunityQuoteId: Id of Quote to which the quote item is related (Master of Master-detail)
    *       productId: Id of the product the the quote item is related to (LookUp)      
    *       productGroupName: name of productGroup
    *       numberOfRecordsToCreate: number or records to create
    *       Boolean: is the product related to this quote item, also related to a tarif?
    * @return List of Opportuinty Quote Product Items
    */
/*public static List<Opportunity_Quote_Product_Item__c> createOpportunityQuoteProductItems(Opportunity_Quote__c opportunityQuoteRecord, String productId, String productGroupName, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
        Integer installments, String rabbat, Decimal listPrice, Integer quantity, Decimal totalAmount){
        List<Opportunity_Quote_Product_Item__c> opportunityQuoteProductItem = new List<Opportunity_Quote_Product_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opportunityQuoteProductItem.add(new Opportunity_Quote_Product_Item__c(
                    Name = 'Test_Opportunity_quote_Product_Item_' + i,
                    Id_Opportunity_Quote__c = opportunityQuoteRecord.Id,
                    Id_List_Product_Price__c = productId,
                    Product_Group__c = productGroupName,
                    Has_Related_Tarif__c = hasTarif,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Quantity__c = quantity,
                    Rabbat__c = rabbat,
                    Total_Amount__c = totalAmount,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityQuoteRecord.Id_Opportunity__r.Record_Country__c)
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Quote_Product_Item').id
                )
            );
        }
        //insert opportunityQuoteProductItem;
        return opportunityQuoteProductItem;
    }

    /**
    * creates Opportunity Quote Service Items(s)
    *
    * @param 
    *       opportunityQuoteId: Id of Quote to which the quote item is related (Master of Master-detail)
    *       numberOfRecordsToCreate: number or records to create
    *       Boolean: is the product related to this quote item, also related to a tarif?
    * @return List of Opportuinty Quote Service Items
    */
   /* public static List<Opportunity_Quote_Service_Item__c> createOpportunityQuoteServiceItems(Opportunity_Quote__c opportunityQuoteRecord, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
        Decimal commissionPercentage, Integer commissionOrder, Boolean isActive, Integer recurringFee, Date startDate, String type){
        List<Opportunity_Quote_Service_Item__c> opportunityQuoteServiceItem = new List<Opportunity_Quote_Service_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opportunityQuoteServiceItem.add(new Opportunity_Quote_Service_Item__c(
                    Name = 'Test_Opportunity_Quote_Service_Item_' + i,
                    Id_Opportunity_Quote__c = opportunityQuoteRecord.Id,
                    Has_Related_Tarif__c = hasTarif,
                    Commission_In_Percentage__c = commissionPercentage,
                    Commission_Per_Order__c = commissionOrder,
                    Recurring_Fee__c = recurringFee,
                    Type__c = type,
                    Start_Date__c = startDate,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityQuoteRecord.Id_Opportunity__r.Record_Country__c)
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Quote_Service_Item').id
                )
            );
        }
        //insert opportunityQuoteServiceItem;
        return opportunityQuoteServiceItem;
    }*/

    public static List<Asset__c> createAssets(Integer numberOfRecordsToCreate, Account acct, Opportunity opp, Date dateShipped, Boolean isActive, Stock_Item__c stock, Stock_Item__c replaceStock, String recordTypeDeveloperName,
        String trackingNumber, String numberOfReturns, String numberOfRetours, Date retourDate, Date returnDate, String retourStatus, Boolean retourInProgress, String returnReason, String sharedInfomation, String takeOverInformation, 
        String status, Date returnDueDate, String retourTrackingNumber, String returnStatus){
        List<Asset__c> assets = new List<Asset__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            Asset__c asset = new Asset__c(
                Name = 'Test_Asset_' + i,
                Account__c = acct.Id,
                Opportunity__c = opp.Id,
                Date_Shipped__c = dateShipped,
                Is_Active__c = isActive,
                Status__c = status,
                RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                Tracking_Number__c =trackingNumber,
                Number_of_Retours__c = numberOfRetours,
                Number_of_Returns__c =  numberOfReturns,
                Retour_Date__c = retourDate,
                Retour_Status__c = retourStatus,
                Returned_Date__c = returnDate,
                Returned_Reason__c = returnReason,
                Shared_Information__c = sharedInfomation,
                Takeover_Information__c = takeOverInformation,
                Return_Due_Date__c = returnDueDate,
                //Retour_Shipping_Company__c = retourShippingCompany,
                Retour_Tracking_Number__c = retourTrackingNumber,
                Return_Status__c = returnStatus
                );
            if(replaceStock!=null)
            asset.Replaced_Stock_Item__c = replaceStock.Id;
            if(stock!=null)
            asset.Stock_Item__c = stock.Id;
            assets.add(asset);
        }
        return assets;
    }

     public static List<Asset__c> createAssets(Integer numberOfRecordsToCreate, Account acct, Opportunity opp, Date dateShipped, Boolean isActive, Stock_Item__c stock, Stock_Item__c replaceStock, String recordTypeDeveloperName,
        String trackingNumber, String numberOfReturns, String numberOfRetours, Date retourDate, Date returnDate, String retourStatus, Boolean retourInProgress, String returnReason, String sharedInfomation, String takeOverInformation, 
        String status, Date returnDueDate, String retourShippingCompany, String retourTrackingNumber, String returnStatus){
        List<Asset__c> assets = new List<Asset__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            Asset__c asset = new Asset__c(
                Name = 'Test_Asset_' + i,
                Account__c = acct.Id,
                Opportunity__c = opp.Id,
                Date_Shipped__c = dateShipped,
                Is_Active__c = isActive,
                Status__c = status,
                RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                Tracking_Number__c =trackingNumber,
                Number_of_Retours__c = numberOfRetours,
                Number_of_Returns__c =  numberOfReturns,
                Retour_Date__c = retourDate,
                Retour_Status__c = retourStatus,
                Returned_Date__c = returnDate,
                Returned_Reason__c = returnReason,
                Shared_Information__c = sharedInfomation,
                Takeover_Information__c = takeOverInformation,
                Return_Due_Date__c = returnDueDate,
                Retour_Shipping_Company__c = retourShippingCompany,
                Retour_Tracking_Number__c = retourTrackingNumber,
                Return_Status__c = returnStatus
                );
            if(replaceStock!=null)
            asset.Replaced_Stock_Item__c = replaceStock.Id;
            if(stock!=null)
            asset.Stock_Item__c = stock.Id;
            assets.add(asset);
        }
        return assets;
    }

    public static List<Asset__c> createAssets(Integer numberOfRecordsToCreate, Account acct, Opportunity opp, Date dateShipped, Boolean isActive, Stock_Item__c stock, Stock_Item__c replaceStock, String recordTypeDeveloperName,
            String trackingNumber, String numberOfReturns, String numberOfRetours, Date retourDate, Date returnDate, String retourStatus, Boolean retourInProgress, String returnReason, String sharedInfomation, String takeOverInformation,
            String status, String type, Date returnDueDate, String retourShippingCompany, String retourTrackingNumber, String returnStatus){
        List<Asset__c> assets = new List<Asset__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            Asset__c asset = new Asset__c(
                    Name = 'Test_Asset_' + i,
                    Account__c = acct.Id,
                    Opportunity__c = opp.Id,
                    Date_Shipped__c = dateShipped,
                    Is_Active__c = isActive,
                    Status__c = status,
                    Type__c = type,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    Tracking_Number__c =trackingNumber,
                    Number_of_Retours__c = numberOfRetours,
                    Number_of_Returns__c =  numberOfReturns,
                    Retour_Date__c = retourDate,
                    Retour_Status__c = retourStatus,
                    Returned_Date__c = returnDate,
                    Returned_Reason__c = returnReason,
                    Shared_Information__c = sharedInfomation,
                    Takeover_Information__c = takeOverInformation,
                    Return_Due_Date__c = returnDueDate,
                    Retour_Shipping_Company__c = retourShippingCompany,
                    Retour_Tracking_Number__c = retourTrackingNumber,
                    Return_Status__c = returnStatus
            );
            if(replaceStock!=null)
                asset.Replaced_Stock_Item__c = replaceStock.Id;
            if(stock!=null)
                asset.Stock_Item__c = stock.Id;
            assets.add(asset);
        }
        return assets;
    }

    public static List<Additional_Charges__c> createAdditionalCharges(Account account, Asset__c asset, Opportunity opportunity, Opportunity_Quote__c quote, List_Product_Price__c product, List_Product_Group__c productGroup,
            String rabbat, Integer quantity, Decimal totalAmount, Integer installments, Decimal listPrice, Integer numberOfRecordsToCreate, String recordTypeDeveloperName, Date terminationDate){
        List<Additional_Charges__c> additionalCharges = new List<Additional_Charges__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            additionalCharges.add(
                new Additional_Charges__c(
                    Id_Account__c = account.Id,
                    Id_Asset__c = asset.Id,
                    Id_List_Product_Price__c = product.Id,
                    Id_Opportunity__c = opportunity.Id,
                    Id_Opportunity_Quote__c = quote.Id,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Product__c = product.Name,
                    Product_Group__c = productGroup.Name,
                    Quantity__c = quantity,
                    Rabbat__c = rabbat,
                    Total_Amount__c = totalAmount,
                    Termination_Date__c = terminationDate
                )
            );
        }
        return additionalCharges;
    }

     public static List<Additional_Charges__c> createAdditionalChargesWithRecordType(Account account, Asset__c asset, Opportunity opportunity, Opportunity_Quote__c quote, List_Product_Price__c product, List_Product_Group__c productGroup,
            String rabbat, Integer quantity, Decimal totalAmount, Integer installments, Decimal listPrice, Integer numberOfRecordsToCreate, String recordTypeId, Date terminationDate){
        List<Additional_Charges__c> additionalCharges = new List<Additional_Charges__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            additionalCharges.add(
                new Additional_Charges__c(
                    Id_Account__c = account.Id,
                    Id_Asset__c = asset.Id,
                    Id_List_Product_Price__c = product.Id,
                    Id_Opportunity__c = opportunity.Id,
                    Id_Opportunity_Quote__c = quote.Id,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Product__c = product.Name,
                    Product_Group__c = productGroup.Name,
                    RecordTypeId = recordTypeId,
                    Quantity__c = quantity,
                    Rabbat__c = rabbat,
                    Total_Amount__c = totalAmount,
                    Termination_Date__c = terminationDate
                )
            );
        }
        return additionalCharges;
    }

    public static List<Stock_Item__c> createStockItems(Integer numberOfRecordsToCreate, String recordTypeDeveloperName, Account acct, Consignment__c consignment, String condition, Date orderDate, Date arrivalDate, Date productionDate,
        String simcardNumber, String simMobileNumber, String simProvider, String status, String type){
        List<Stock_Item__c> stockItems = new List<Stock_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            Stock_Item__c stock = new Stock_Item__c(
                Name = 'Test_Stock_Item_' + i,
                Id_Account__c = acct.Id,
                Condition__c = condition,
                Date_Arrived__c = orderDate,
                Date_Ordered__c = arrivalDate,
                Production_Date__c = productionDate,
                Simcard_Number__c = simcardNumber,
                SIM_Mobile_Number__c = simMobileNumber,
                Simcard_Provider__c =simProvider,
                Status__c = status,
                Type__c = type,
                RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id
                );
            if(consignment!=null)
            stock.Consignment__c = consignment.Id;
            stockItems.add(stock);
        }
        return stockItems;
    }
    
    public static List<Consignment__c> createConsignments(Integer numberOfRecordsToCreate, Boolean pORequired, String status, String supplier, String trackingUrl){
        List<Consignment__c> consignments = new List<Consignment__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            consignments.add(new Consignment__c(
                PO_Required__c = pORequired,
                Status__c = status,
                Supplier__c = supplier,
                Tracking_Link__c = trackingUrl
                )
            );
        }
        return consignments;
    }



    public static void testDataForTalabatApproval(){
        Country__c c = UnitTestDataFactory.createCountry('AE','United Arab Emirates', 'AED');
        Company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', c);

        insert new List<sObject>{c,com};

        Business_Config__c bc = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','oppServiceItemRecordType','Opportunity_Line_Item', c.id, 'Talabat_Opportunity', true, true);
        Business_Config__c bc4 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','usesServiceTypes','true', c.id, 'Talabat_Opportunity', true, true);
        Business_Config__c bc1 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','oppTarifItemRecordType','Opportunity_Tarif_Item', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc2 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','VATInPercentage','10', c.id, 'Talabat_Opportunity', true, false);            
        Business_Config__c bc3 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','oppProductItemRecordType','Opportunity_Line_Item', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc5 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','adSalesTarif','Ad Sales', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc6 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','usesRecurringCharges','true', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc7 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','recurringFee','Recurring Fee,Monthly Box Fee', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc8 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','approvalProcess','false', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc9 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','productGroupName','AU Recurring Fee', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc10 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','nonStandardContractValue','Platform exclusivity', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc11 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','skipAutoApprovalQuote','true', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc12 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','showCommissionPerOrder','true', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc13 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','approvalMap','true', c.id, 'Talabat_Opportunity', true, false);
        Business_Config__c bc14 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','skipApprovalForTheseNonStandardComponents','Registration fee,Renewal fee', c.id, 'Talabat_Opportunity', true, false);
        insert new List<sObject>{bc,bc4,bc1,bc2,bc3,bc5,bc6,bc7,bc8,bc9,bc10,bc11,bc12,bc13,bc14};

        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckButton',Record_Type_Id__c='Talabat_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='yogiyo_Asset',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='Talabat_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='95',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='Talabat_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='Asset Status__c',Business_Rule_Value__c='New - Awaiting Shipping',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='Talabat_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='createAsset',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='Talabat_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='permittedProfiles',Business_Rule_Value__c='Yogiyo Sales Team',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='Talabat_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='level1ApprovedStatus',Business_Rule_Value__c='Pending - legal',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='finalApprovalStatus',Business_Rule_Value__c='Accepted',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='level2ApprovedStatus',Business_Rule_Value__c='Accepted',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterFinalApproval',Business_Rule_Value__c='Quality Check Request',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='rejectionTemplate',Business_Rule_Value__c='Quality Check Request',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Approval',Business_Rule_Value__c='Positive Feedback - HOS',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel1',Business_Rule_Value__c='Approval pending',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Rejection',Business_Rule_Value__c='Negotiating',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
        Business_Config__c b15 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Rejection',Business_Rule_Value__c='Please correct errors',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');


        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15};

        Account acc = createAccount('TestAccount',c,'Talabat_Account');

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','Talabat_List_Product_Group');
        insert new List<sObject>{lpg,acc};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c,'Annual Fee',lpg.id,'Talabat_List_Product_Price',1,true,100,1,false,20); 
        /*createService(Company__c company, Country__c country,String name, String recordTypeDeveloperName, Decimal commissionPercentage, Decimal defaultCommisionPercentage, Decimal maximumCommission, Decimal minimumCommission, Integer commissionOrder, Boolean isActive, Integer recurringFee, String type, String serviceType){
        List_Service_Price__c service = new List_Service_Price__c(
        */List_Service_Price__c lsp = UnitTestDataFactory.createService(com,c,'testService1','Talabat_List_Service_Price',12,12,25,5,null,true,null,'Per Order','ServiceType');
        lsp.Requires_Approval__c = true;
        lsp.Commission_In_Percentage__c = null;
        lsp.Commission_Type__c = 'Per Order';
        lsp.Commission_Per_Order__c = 43;

        Tarif__c t = UnitTestDataFactory.createTarif(com,c,'testTarif1','Talabat_Tarif',false);
        Opportunity opp = UnitTestDataFactory.createOpportunity('TestOppTalabat',acc,'Talabat_Opportunity',Date.today());
        insert new List<sObject>{lpp,lsp,t,opp};

        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'Talabat_Tarif_Member',t.id,'Product');
        Opportunity_Tarif_Item__c oppTarif= UnitTestDataFactory.createOpportunityTarif('testTarif1',t.id,opp.id,'Talabat_Opportunity_Tarif_Item');
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 2',opp,lpg.id,lpp.id,true,'Talabat_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp,lsp.id,true,'Talabat_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);

        insert new List<sObject>{tm};

        t.Is_Active__c = true;
        update new List<Tarif__c>{t};

        insert new List<sObject>{oppTarif,oppProduct,oppService};





    }



    /**
    * Test data for opportunity processes
    *
    * @param 
    *           
    * @return void
    */
    public static void testDataForYogiyoOpportunityProcesses(){
        Country__c c = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert new List<sObject>{c,com};

            Business_Config__c qa1 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','OppQuoteEmailTemplate','koreanQuoteVFTemplate', c.id, 'Yogiyo_Account', true, true);
            Business_Config__c qa2 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','quoteEmailSubject','Quote', c.id, 'Yogiyo_Account', true, false);
            Business_Config__c qa3 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','IncludeService','true', c.id, 'Yogiyo_Account', true, false);
            Business_Config__c qa4 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','IncludeProduct','true', c.id, 'Yogiyo_Account', true, false);
            Business_Config__c qa5 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','OrgWideEmailAddId','12345', c.id, 'Yogiyo_Account', true, false);

            Business_Config__c b = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','oppServiceItemRecordType','Opportunity_Line_Item', c.id, 'Yogiyo_Opportunity', true, true);
            Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','usesServiceTypes','false', c.id, 'Yogiyo_Opportunity', true, true);
            Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','oppTarifItemRecordType','Opportunity_Tarif_Item', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','VATInPercentage','10', c.id, 'Yogiyo_Opportunity', true, false);            
            Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','oppProductItemRecordType','Opportunity_Line_Item', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b5 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','adSalesTarif','Ad Sales', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b6 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','usesRecurringCharges','true', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','recurringFee','Recurring Fee,Monthly Box Fee,Terminal Box', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b8 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','approvalProcess','false', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b9 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','productGroupName','AU Recurring Fee', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b10 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','nonStandardContractValue','Platform exclusivity', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b11 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','skipAutoApprovalQuote','true', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b12 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','showCommissionPerOrder','true', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b13 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','FlatCommissionTarif','0% commission', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b14 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','annualRenewalFeeAdditionalCharge','Korea', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b15 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','updateAnnualAdditionalChargeStartDateWithMonths','24', c.id, 'Yogiyo_Opportunity', true, false);
            
            
            
            
            Business_Config__c q1 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','OppQuoteEmailTemplate','Yogiyo_QuoteVFTemplate_Asset,Yogiyo_QuoteVFTemplate_Service,Yogiyo_QuoteVFTemplate_Both,Yogiyo_QuoteVFTemplate_AdSales', c.id, 'Yogiyo_Account', true, true);
            Business_Config__c q2 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','quoteEmailSubject','Quote', c.id, 'Yogiyo_Account', true, false);
            Business_Config__c q3 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','IncludeService','true', c.id, 'Yogiyo_Account', true, false);
            Business_Config__c q4 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','IncludeProduct','true', c.id, 'Yogiyo_Account', true, false);
            Business_Config__c q5 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','OrgWideEmailAddId','12345', c.id, 'Yogiyo_Account', true, false);
            Business_Config__c b1_kr = new Business_Config__c(Business_Rule_Name__c='baseURL',Business_Rule_Value__c='https://www.yogiyo.co.kr/salesforce/restaurant/',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b2_kr = new Business_Config__c(Business_Rule_Name__c='endpointURL',Business_Rule_Value__c='/available_districts_and_categories/',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b3_kr = new Business_Config__c(Business_Rule_Name__c='apiKey',Business_Rule_Value__c='salesforce',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b4_kr = new Business_Config__c(Business_Rule_Name__c='secret',Business_Rule_Value__c='23752ba30a8811e5a0b434363bd33456',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b1f_kr = new Business_Config__c(Business_Rule_Name__c='baseURL',Business_Rule_Value__c='https://www.yogiyo.co.kr/salesforce/restaurant/',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b2f_kr = new Business_Config__c(Business_Rule_Name__c='endpointURL',Business_Rule_Value__c='/zero_commission/',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b3f_kr = new Business_Config__c(Business_Rule_Name__c='apiKey',Business_Rule_Value__c='salesforce',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b4f_kr = new Business_Config__c(Business_Rule_Name__c='secret',Business_Rule_Value__c='23752ba30a8811e5a0b434363bd33456',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            
            
            Business_Config__c b5_kr = new Business_Config__c(Business_Rule_Name__c='Greeting',Business_Rule_Value__c='Salutation,LastName',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b6_kr = new Business_Config__c(Business_Rule_Name__c='EmailSubject',Business_Rule_Value__c='Partnership Confirmation',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b7_kr = new Business_Config__c(Business_Rule_Name__c='Use_Default_Content',Business_Rule_Value__c='false',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            
            Business_Config__c b8_kr = new Business_Config__c(Business_Rule_Name__c='approvalProcess',Business_Rule_Value__c='false',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b9_kr = new Business_Config__c(Business_Rule_Name__c='productGroupName',Business_Rule_Value__c='false',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b10_kr = new Business_Config__c(Business_Rule_Name__c='skipAutoOverlappingServiceStartDate',Business_Rule_Value__c='test',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b11_kr = new Business_Config__c(Business_Rule_Name__c='autoAnnualEndDate',Business_Rule_Value__c='test,test2',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b12_kr = new Business_Config__c(Business_Rule_Name__c='useCombinedSaveAndCreateQuote',Business_Rule_Value__c='true',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c ba13_kr = new Business_Config__c(Business_Rule_Name__c='Registration fee',Business_Rule_Value__c='KRW=dfdfsdfsdf::KRW=dfsdfgsdfsdf',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c ba14_kr = new Business_Config__c(Business_Rule_Name__c='Renewal fee',Business_Rule_Value__c='KRW=dfdfsdfsdf::KRW=dfsdfgsdfsdf',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c ba15_kr = new Business_Config__c(Business_Rule_Name__c='PremiumPlaceTarif',Business_Rule_Value__c='Premium Placement',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            Business_Config__c ba16_kr = new Business_Config__c(Business_Rule_Name__c='MenuPrintingTarif',Business_Rule_Value__c='Menu Printing',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
            //Business_Config__c b13_kr = new Business_Config__c(Business_Rule_Name__c='usesRecurringCharges',Business_Rule_Value__c='true',Id_Country__c=c.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
    
           /* Business_Config__c b34_kr = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process', 'Process','opportunity stage','Closed Won', c.id, 'Yogiyo_Opportunity', true, true);
            Business_Config__c b35_kr = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process', 'Process','Asset RecordType','Yogiyo_Asset', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b36_kr = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process', 'Process','contract_RecordType','Yogiyo_Contract', c.id, 'Yogiyo_Opportunity', true, false);
            Business_Config__c b37_kr = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process', 'Process','AdditionalCharges RecordType','Yogiyo_Contract', c.id, 'Yogiyo_Opportunity', true, false);
            */
            
            Business_Config__c bCP1 = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
	        Business_Config__c bcp2 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='Yogiyo_Contract',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
	        Business_Config__c bcp3 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='Yogiyo_Additional_Charges',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
	        Business_Config__c bcp4 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='Yogiyo_Asset',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
	        Business_Config__c bcp5 = new Business_Config__c(Business_Rule_Name__c='AddOnRecordType',Business_Rule_Value__c='Yogiyo_Add_On',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
	        Business_Config__c bcp6 = new Business_Config__c(Business_Rule_Name__c='BrandingContentRecordType',Business_Rule_Value__c='Yogiyo_Branding_Content',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
	        Business_Config__c bcp7 = new Business_Config__c(Business_Rule_Name__c='startDateIsOppCloseDate',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
	        Business_Config__c bcp8 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', c.Id, 'Yogiyo_Contract', true, true);
            
            Business_Config__c b13_kr = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b14_kr = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='yogiyo_Asset',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b15_kr = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='95',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b16_kr = new Business_Config__c(Business_Rule_Name__c='Asset Status__c',Business_Rule_Value__c='New - Awaiting Shipping',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b17_kr = new Business_Config__c(Business_Rule_Name__c='createAsset',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
            Business_Config__c b18_kr = new Business_Config__c(Business_Rule_Name__c='permittedProfiles',Business_Rule_Value__c='Yogiyo Sales Team',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckButton',Record_Type_Id__c='yogiyo_Opportunity',Type__c='Process');
            Business_Config__c b19_kr = new Business_Config__c(Business_Rule_Name__c='level1ApprovedStatus',Business_Rule_Value__c='Pending - legal',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b20_kr = new Business_Config__c(Business_Rule_Name__c='finalApprovalStatus',Business_Rule_Value__c='Accepted',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b21_kr = new Business_Config__c(Business_Rule_Name__c='level2ApprovedStatus',Business_Rule_Value__c='Accepted',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b22_kr = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterFinalApproval',Business_Rule_Value__c='Quality Check Request',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b23_kr = new Business_Config__c(Business_Rule_Name__c='rejectionTemplate',Business_Rule_Value__c='Quality Check Request',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b24_kr = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Approval',Business_Rule_Value__c='Positive Feedback - HOS',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b25_kr = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel1',Business_Rule_Value__c='Approval pending',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b26_kr = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Rejection',Business_Rule_Value__c='Negotiating',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b27_kr = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Rejection',Business_Rule_Value__c='Please correct errors',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='yogiyo_Opportunity_Quote',Type__c='Process');
            
            Business_Config__c b28_kr = new Business_Config__c(Business_Rule_Name__c='allowedProfileIds',Business_Rule_Value__c='00ew0000001Al2IAAS,00ew0000001Al2HAAS,00ew0000001Al2JAAS,00ew0000001HfA4AAK',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            Business_Config__c b29_kr = new Business_Config__c(Business_Rule_Name__c='allowedAccountType',Business_Rule_Value__c='Child',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            Business_Config__c b30_kr = new Business_Config__c(Business_Rule_Name__c='ReturnedStockItemStatus',Business_Rule_Value__c='In Stock',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='StockUpdateProcess',Record_Type_Id__c='Yogiyo_Stock_Item',Type__c='Process');
            Business_Config__c b31_kr = new Business_Config__c(Business_Rule_Name__c='ReturnedStockItemCondition',Business_Rule_Value__c='U - Undefined',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='StockUpdateProcess',Record_Type_Id__c='Yogiyo_Stock_Item',Type__c='Process');
            Business_Config__c b32_kr = new Business_Config__c(Business_Rule_Name__c='UpdateAssignedStockCondition',Business_Rule_Value__c='B - Used',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='StockUpdateProcess',Record_Type_Id__c='Yogiyo_Stock_Item',Type__c='Process');
            Business_Config__c b33_kr = new Business_Config__c(Business_Rule_Name__c='AllowUpdateStockCondition',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='StockUpdateProcess',Record_Type_Id__c='Yogiyo_Stock_Item',Type__c='Process');
            
            

            insert new List<sObject>{qa1,qa2,qa3,qa4,qa5,b,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,q1,q2,q3,q4,q5,b1_kr,b2_kr,b3_kr,b4_kr,b5_kr,b6_kr ,b7_kr, b8_kr, b9_kr, b10_kr,b11_kr ,b12_kr,b13_kr ,b14_kr, b15_kr, b16_kr, b17_kr, b18_kr, b19_kr, b20_kr,b22_kr,b23_kr,b24_kr,b25_kr,b26_kr,b27_kr,b28_kr ,b29_kr,b30_kr,b31_kr,b32_kr,b33_kr,b14,b15,b1f_kr,b2f_kr,b3f_kr,b4f_kr,ba13_kr,ba14_kr,ba15_kr,ba16_kr,bcp1,bcp2,bcp3,bcp4,bcp5,bcp6,bcp7,bcp8/*,b34_kr,b35_kr,b36_kr,b37_kr */};
        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c,'Setup Fee','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg2 = UnitTestDataFactory.createProductGroup(com,c,'Terminal','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg3 = UnitTestDataFactory.createProductGroup(com,c,'AdSales product','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg4 = UnitTestDataFactory.createProductGroup(com,c,'0% Commission','Yogiyo_List_Product_Group');

        Account acc = createAccount('TestAccount',c,'Yogiyo_Account');
        Account acc1 = createAccount('TestAccount1',c,'Yogiyo_Account');

        insert new List<sObject>{lpg,lpg1,lpg2,lpg3,lpg4,acc,acc1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c,'Annual Fee',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);        
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,c,'Annual Renewal Fee',lpg1.id,'Yogiyo_List_Product_Price',1,true,100,1,false,null);
        lpp1.Product_Type__c = 'Renewal Fee';
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 2',lpg1.id,'Yogiyo_List_Product_Price',1,true,50,1,true,20);
        List_Product_Price__c lpp3 = UnitTestDataFactory.createProduct(com,c,'Terminal A (One-time Payment)',lpg2.id,'Yogiyo_List_Product_Price',1,true,100,1,false,null);
        List_Product_Price__c lpp4 = UnitTestDataFactory.createProduct(com,c,'AdSales product',lpg3.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);        
        List_Product_Price__c lpp5 = UnitTestDataFactory.createProduct(com,c,'0% Commission',lpg4.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);
        List_Product_Price__c lpp6 = UnitTestDataFactory.createProduct(com,c,'Premium Placement API',lpg4.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);
        lpp6.Product_Type__c = 'Premium placement - 1 Month';
        List_Product_Price__c lpp7 = UnitTestDataFactory.createProduct(com,c,'Menu Printing',lpg4.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);
        lpp7.Product_Type__c = 'Menu Printing';
        
        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,c,'testService1','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp1 = UnitTestDataFactory.createService(com,c,'testService2','Yogiyo_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp2 = UnitTestDataFactory.createService(com,c,'testService3','Yogiyo_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');

        Tarif__c t = UnitTestDataFactory.createTarif(com,c,'testTarif1','Yogiyo_Tarif',false);
        Tarif__c t1 = UnitTestDataFactory.createTarif(com,c,'testTarif2','Yogiyo_Tarif',false);
        Tarif__c t2 = UnitTestDataFactory.createTarif(com,c,'Ad Sales','Yogiyo_Tarif',false);
        Tarif__c t3 = UnitTestDataFactory.createTarif(com,c,'0% Commission','Yogiyo_Tarif',false);
        Tarif__c t4 = UnitTestDataFactory.createTarif(com,c,'Premium Placement','Yogiyo_Tarif',false);
        Tarif__c t5 = UnitTestDataFactory.createTarif(com,c,'TieredCommission','Yogiyo_Tarif',false);
        Tarif__c t6 = UnitTestDataFactory.createTarif(com,c,'Menu Printing','Yogiyo_Tarif',false);



        Opportunity opp = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'Yogiyo_Opportunity',Date.today());
        Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp456',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp2 = UnitTestDataFactory.createOpportunity('Ad Sales',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp3 = UnitTestDataFactory.createOpportunity('0% commission',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp4 = UnitTestDataFactory.createOpportunity('AddChargeStartDateTest',acc1,'Yogiyo_Opportunity',Date.newInstance(1987, 4, 22));
        Opportunity opp5 = UnitTestDataFactory.createOpportunity('Premium Placement',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp6 = UnitTestDataFactory.createOpportunity('Menu Printing',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp7 = UnitTestDataFactory.createOpportunity('TieredCommission',acc1,'Yogiyo_Opportunity',Date.today());


        opp.type = 'Contract & Product';
        opp.Id_Tarif__c = t1.id;
        opp3.Id_Tarif__c = t3.id;
        opp5.Id_Tarif__c = t4.id;
        opp7.Id_Tarif__c = t5.id;



        insert new List<sObject>{lpp,lpp1,lpp2,lpp3,lpp4,lpp5,lpp6,lpp7,lsp,lsp1,lsp2,t,t1,t2,t3,t4,t5,t6,opp,opp1,opp2,opp3,opp4,opp5,opp6,opp7};
        
        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm1 = UnitTestDataFactory.createTarifMember(lpp3.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm2 = UnitTestDataFactory.createTarifMember(lsp.id,'Yogiyo_Tarif_Member',t.id,'Service');
        Tarif_Member__c tm3 = UnitTestDataFactory.createTarifMember(lsp2.id,'Yogiyo_Tarif_Member',t1.id,'Service');
        Tarif_Member__c tm4 = UnitTestDataFactory.createTarifMember(lpp2.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm5 = UnitTestDataFactory.createTarifMember(lpp1.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm6 = UnitTestDataFactory.createTarifMember(lpp4.id,'Yogiyo_Tarif_Member',t2.id,'Product');
        Tarif_Member__c tm7 = UnitTestDataFactory.createTarifMember(lpp5.id,'Yogiyo_Tarif_Member',t3.id,'Product');
        Tarif_Member__c tm8 = UnitTestDataFactory.createTarifMember(lsp.id,'Yogiyo_Tarif_Member',t5.id,'Service');
        Tarif_Member__c tm9 = UnitTestDataFactory.createTarifMember(lpp5.id,'Yogiyo_Tarif_Member',t4.id,'Service');
        Tarif_Member__c tm10 = UnitTestDataFactory.createTarifMember(lpp5.id,'Yogiyo_Tarif_Member',t6.id,'Service');


        //Opportunity_Tarif_Item__c oppTarif= UnitTestDataFactory.createOpportunityTarif('testTarif1',t1.id,opp.id,'Yogiyo_Opportunity_Tarif_Item');
       
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 2',opp,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppProduct2 = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 1',opp,lpg1.id,lpp1.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp,lsp2.id,true,'Yogiyo_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        Opportunity_Line_Item__c oppProductADSales = UnitTestDataFactory.createOpportunityLineItemProduct('Adsales',opp2,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Ad Sales');
        Opportunity_Line_Item__c oppProductPP = UnitTestDataFactory.createOpportunityLineItemProduct('testService4',opp5,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Premium Placement');
        Opportunity_Line_Item__c oppProductMP = UnitTestDataFactory.createOpportunityLineItemProduct('Menu Printing',opp6,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Menu Printing');

        insert new List<sObject>{tm,tm1,tm2,tm3,tm4,tm5,tm6,tm7,tm8,tm9,tm10};
        t.Is_Active__c = true;
        t1.Is_Active__c = true;
        t2.Is_Active__c = true;
        t3.Is_Active__c = true;
        t4.Is_Active__c = true;
        t5.Is_Active__c = true;
        t6.Is_Active__c = true;
        update new List<Tarif__c>{t,t1,t2,t3,t4,t5,t6};
        
        lpp.Product_Type__c='Terminal Box';
        lpp.Unapproved_Discount_Limit__c=2;
        update lpp;

        insert new List<sObject>{oppProduct,oppProduct2,oppService,oppProductADSales,oppProductPP,oppProductMP};
        oppProduct.Sub_Type__c='Flat Commission';
        update oppProduct;

    }

    public static void testDataForYogiyoContractProcess(){
        UnitTestDataFactory.testDataForYogiyoOpportunityProcesses();
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,AccountId,recordtypeid,subtotal__c,vat__c,total__c,currencyIsoCode from Opportunity where name='TestOpp123'];
        Opportunity_Quote__c oppQuote = new Opportunity_Quote__c(CurrencyIsoCode=listOpp[0].currencyIsoCode,Id_Account__c=listOpp[0].accountid,Id_Opportunity__c=listOpp[0].id,Description__c='test data',RecordTypeId=mapRecordtypes.get('Yogiyo_Opportunity_Quote').id,Status__c='Accepted',Subtotal__c=19900,Total__c=19900);
        insert oppQuote;
        /*List<Opportunity_Product_Item__c> oppProductItem = [SELECT CurrencyIsoCode,Has_Related_Tarif__c,Id,Id_List_Price_Product__c,Id_Opportunity__c,Installments__c,Listed_Price__c,Name,Product_Group__c,Quantity__c,Rabbat__c,RecordTypeId,Total_Amount__c FROM Opportunity_Product_Item__c where  Id_Opportunity__c =:listOpp[0].id ];
        List<Opportunity_Quote_Product_Item__c> listOppQuoteProduct = new List<Opportunity_Quote_Product_Item__c>();
        for(Opportunity_Product_Item__c oppQP : oppProductItem){
            Opportunity_Quote_Product_Item__c oppQuoteProduct = new Opportunity_Quote_Product_Item__c(CurrencyIsoCode=listOpp[0].currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppQP.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppQP.Installments__c,Listed_Price__c=oppQP.Listed_Price__c,Name=oppQP.name,Product_Group__c=oppQP.Product_Group__c,Quantity__c=oppQP.Quantity__c,Rabbat__c=oppQP.Rabbat__c,RecordTypeId=mapRecordtypes.get('Yogiyo_Opportunity_Quote_Product_Item').id,Total_Amount__c=oppQp.Total_Amount__c);
            listOppQuoteProduct.add(oppQuoteProduct);

        }
        insert listOppQuoteProduct;*/
        List<Opportunity_Line_Item__c> oppProductItem = [SELECT Commission_In_Percentage__c,Commission_Per_Order__c,Id_List_Service_Price__c,CurrencyIsoCode,Has_Related_Tarif__c,Id,Id_List_Price_Product__c,Id_Opportunity__c,Installments__c,Listed_Price__c,Name,Product_Group__c,Quantity__c,Discount__c,RecordTypeId,Total_Amount__c,Sub_Type__c,Line_Item_Type__c,Recurring_Fee__c,Start_Date__c,End_Date__c FROM Opportunity_Line_Item__c where  Id_Opportunity__c =:listOpp[0].id ];
        List<Opportunity_Quote_Line_Item__c> listOppQuotelines = new List<Opportunity_Quote_Line_Item__c>();
        for(Opportunity_Line_Item__c oppQP : oppProductItem){
            Opportunity_Quote_Line_Item__c oppQuoteLine = new Opportunity_Quote_Line_Item__c(Id_List_Service_Price__c=oppQP.Id_List_Service_Price__c,Commission_In_Percentage__c=oppQP.Commission_In_Percentage__c,Commission_Per_Order__c=oppQP.Commission_Per_Order__c,End_Date__c=oppQP.End_Date__c,Recurring_Fee__c=oppQP.Recurring_Fee__c,Start_Date__c=oppQP.Start_Date__c,CurrencyIsoCode=listOpp[0].currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppQP.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppQP.Installments__c,Listed_Price__c=oppQP.Listed_Price__c,Name=oppQP.name,Product_Group__c=oppQP.Product_Group__c,Quantity__c=oppQP.Quantity__c,Discount__c=oppQP.Discount__c,RecordTypeId=mapRecordtypes.get('Yogiyo_Opportunity_Quote_Line_Item').id,Total_Amount__c=oppQp.Total_Amount__c,Sub_Type__c=oppQp.Sub_Type__c,Line_Item_Type__c=oppQp.Line_Item_Type__c,Id_Opportunity__c=oppQp.Id_Opportunity__c);
            listOppQuotelines.add(oppQuoteLine);

        }
        insert listOppQuotelines;   

    }

    // <name> createOpportunityQuoteLineItems </name>
    // <summary> created opportunity quote line item test data </sumary> 
    public static List<Opportunity_Quote_Line_Item__c> createOpportunityQuoteLineItems(Opportunity_Quote__c opportunityQuoteRecord, String productId, String productGroupName, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
        Integer installments, String rabbat, Decimal listPrice, Integer quantity, Decimal totalAmount, String lineItemType){
        List<Opportunity_Quote_Line_Item__c> opportunityQuoteProductItem = new List<Opportunity_Quote_Line_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opportunityQuoteProductItem.add(new Opportunity_Quote_Line_Item__c(
                    Name = 'Test_Opportunity_Quote_Line_Item_' + i,
                    Id_Opportunity_Quote__c = opportunityQuoteRecord.Id,
                    Id_List_Product_Price__c = productId,
                    Product_Group__c = productGroupName,
                    Has_Related_Tarif__c = hasTarif,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Quantity__c = quantity,
                    Discount__c = rabbat,
                    Total_Amount__c = totalAmount,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    //CurrencyIsoCode = mapCountryCurrency.get(opportunityQuoteRecord.Id_Opportunity__r.Record_Country__c),
                    CurrencyIsoCode = opportunityQuoteRecord.CurrencyIsoCode,
                    Line_Item_Type__c = lineItemType
                )
            );
        }
        return opportunityQuoteProductItem;
    }

        public static List<Opportunity_Quote_Line_Item__c> createOpportunityQuoteLineItems(Opportunity_Quote__c opportunityQuoteRecord, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
        Decimal commissionPercentage, Integer commissionOrder, Boolean isActive, Integer recurringFee, Date startDate, String type, String lineItemType){
        List<Opportunity_Quote_Line_Item__c> opportunityQuoteServiceItem = new List<Opportunity_Quote_Line_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opportunityQuoteServiceItem.add(new Opportunity_Quote_Line_Item__c(
                    Name = 'Test_Opportunity_Quote_Line_Item_' + i,
                    Id_Opportunity_Quote__c = opportunityQuoteRecord.Id,
                    Has_Related_Tarif__c = hasTarif,
                    Commission_In_Percentage__c = commissionPercentage,
                    Commission_Per_Order__c = commissionOrder,
                    Recurring_Fee__c = recurringFee,
                    Sub_Type__c = type,
                    Start_Date__c = startDate,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = opportunityQuoteRecord.CurrencyIsoCode,
                    //CurrencyIsoCode = mapCountryCurrency.get(opportunityQuoteRecord.Id_Opportunity__r.Record_Country__c),
                    Line_Item_Type__c = lineItemType
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Quote_Line_Item').id
                )
            );
        }
        //insert opportunityQuoteServiceItem;
        return opportunityQuoteServiceItem;
    }

    public static List<Opportunity_Line_Item__c> createOpportunityLineItems(Opportunity opportunityRecord,String prodgroupId, String productId, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
        Integer installments, String rabbat, Decimal listPrice, Integer quantity, Decimal totalAmount, String lineItemType){
        List<Opportunity_Line_Item__c> opi = new List<Opportunity_Line_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opi.add(new Opportunity_Line_Item__c(
                    Name = 'Test_Opportunity_Line_Item_' + i,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Price_Product__c = productId,
                    Has_Related_Tarif__c = hasTarif,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Quantity__c = quantity,
                    Total_Amount__c = totalAmount,
                    Discount__c = rabbat,
                    Product_Group__c = prodgroupId,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c),
                    Line_Item_Type__c = lineItemType
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Line_Item').id
                )
            );
        }
      /*  insert listOppQuoteProduct;
        List<Opportunity_Service_Item__c> listOppService = [SELECT Commission_In_Percentage__c,Commission_Per_Order__c,CurrencyIsoCode,End_Date__c,Has_Related_Tarif__c,Id,Id_List_Service_Price__c,Id_Opportunity__c,Name,RecordTypeId,Recurring_Fee__c,Start_Date__c,Type__c FROM Opportunity_Service_Item__c where Id_Opportunity__c=:listOpp[0].id];
        List<Opportunity_Quote_Service_Item__c> listOppQuoteService = new List<Opportunity_Quote_Service_Item__c>();
    for(Opportunity_Service_Item__c oppQS : listOppService){
        Opportunity_Quote_Service_Item__c oppQSER = new Opportunity_Quote_Service_Item__c(Commission_In_Percentage__c=oppQS.Commission_In_Percentage__c,Commission_Per_Order__c=oppQS.Commission_Per_Order__c,CurrencyIsoCode=listOpp[0].currencyIsoCode,End_Date__c=oppQS.End_Date__c,Has_Related_Tarif__c=oppQS.Has_Related_Tarif__c,Id_Opportunity_Quote__c=oppQuote.id,Name=oppQS.Name,RecordTypeId=mapRecordtypes.get('DH_AU_Opportunity_Quote_Service_Item').id,Recurring_Fee__c=oppQS.Recurring_Fee__c,Start_Date__c=oppQS.Start_Date__c,Type__c=oppQS.Type__c);
        listOppQuoteService.add(oppQSER);*/
         return opi;
    }
    //insert listOppQuoteService;

    public static List<Opportunity_Line_Item__c> createOpportunityLineItems(Opportunity opportunityRecord, String serviceId, Integer numberOfRecordsToCreate, Boolean hasTarif, String recordTypeDeveloperName,
         Decimal commissionPercentage, Integer commissionOrder, Date startDate, String type, Decimal recurringFee, String lineItemType){
        List<Opportunity_Line_Item__c> opi = new List<Opportunity_Line_Item__c>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            opi.add(new Opportunity_Line_Item__c(
                    Name = 'Test_Opportunity_Line_Item_' + i,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Service_Price__c = serviceId,
                    Has_Related_Tarif__c = hasTarif,
                    Commission_In_Percentage__c = commissionPercentage,
                    Commission_Per_Order__c = commissionOrder,
                    Start_Date__c = startDate,
                    Sub_Type__c = type,
                    Recurring_Fee__c = recurringFee,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c),
                    Line_Item_Type__c = lineItemType
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Line_Item').id
                )
            );
        }
        //insert opi;
        return opi;
    }


    public static Opportunity_Line_Item__c createOpportunityLineItemService(String name, Opportunity opportunityRecord, String serviceId, Boolean hasTarif, String recordTypeDeveloperName, Decimal commissionPercentage, Integer commissionOrder, Date startDate, String subType, Decimal recurringFee){
        Opportunity_Line_Item__c opi = new Opportunity_Line_Item__c(
                    Name = name,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Service_Price__c = serviceId,
                    Has_Related_Tarif__c = hasTarif,
                    Commission_In_Percentage__c = commissionPercentage,
                    Commission_Per_Order__c = commissionOrder,
                    Start_Date__c = startDate,
                    Recurring_Fee__c = recurringFee,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c),
                    Sub_Type__c = subType,
                    Line_Item_Type__c = 'Service'
                    //Recordtypeid = mapRecordtypesKR.get('Yogiyo_Opportunity_Line_Item').id
                
            );
        return opi;
    }


    public static Opportunity_Line_Item__c createOpportunityLineItemProduct(String name, Opportunity opportunityRecord,String prodgroupId, String productId, Boolean hasTarif, String recordTypeDeveloperName,Integer installments, String rabbat, Decimal listPrice, Integer quantity, Decimal totalAmount,String subType){
        Opportunity_Line_Item__c opi = new Opportunity_Line_Item__c(
                    Name = name,
                    Id_Opportunity__c = opportunityRecord.Id,
                    Id_List_Price_Product__c = productId,
                    Has_Related_Tarif__c = hasTarif,
                    Installments__c = installments,
                    Listed_Price__c = listPrice,
                    Quantity__c = quantity,
                    Total_Amount__c = totalAmount,
                    Discount__c = rabbat,
                    Product_Group__c = prodgroupId,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    Line_Item_Type__c = 'Product',
                    Sub_Type__c = subType,
                    CurrencyIsoCode = mapCountryCurrency.get(opportunityRecord.Record_Country__c)
            );
        return opi;
    }



    public static Opportunity_Quote_Line_Item__c createOpportunityQuoteLineItem(Opportunity_Quote__c opportunityQuoteRecord,Opportunity_Line_Item__c opplineItem, String recordTypeDeveloperName){
            Opportunity_Quote_Line_Item__c opportunityQuoteLineItem = new Opportunity_Quote_Line_Item__c(
                    Name = opplineItem.name,
                    Id_Opportunity_Quote__c = opportunityQuoteRecord.Id,
                    Id_List_Product_Price__c = opplineItem.Id_List_Price_Product__c,
                    Product_Group__c = opplineItem.Product_Group__c,
                    Installments__c  = opplineItem.Installments__c,
                    Listed_Price__c = opplineItem.Listed_Price__c,
                    Quantity__c = opplineItem.Quantity__c,
                    Discount__c = opplineItem.Discount__c,
                    Total_Amount__c = opplineItem.Total_Amount__c,
                    Has_Related_Tarif__c = opplineItem.Has_Related_Tarif__c,
                    Id_List_Service_Price__c = opplineItem.Id_List_Service_Price__c,
                    Commission_In_Percentage__c = opplineItem.Commission_In_Percentage__c,
                    Commission_Per_Order__c = opplineItem.Commission_Per_Order__c,
                    Recurring_Fee__c = opplineItem.Recurring_Fee__c,
                    Sub_Type__c = opplineItem.Sub_Type__c,
                    Start_Date__c = opplineItem.Start_Date__c,
                    End_Date__c = opplineItem.End_Date__c,
                    RecordtypeId = mapRecordtypes.get(recordTypeDeveloperName).Id,
                    Line_Item_Type__c  = opplineItem.Line_Item_Type__c,
                    CurrencyIsoCode = opplineItem.CurrencyIsoCode
                );
        return opportunityQuoteLineItem;
    }


    Public static List_Add_On__c createAddOn(String countryId,String companyId,String name,
                                                    String type,String ContractAddition){
        List_Add_On__c addOn    = new List_Add_On__c();
        addOn.Id_Country__c     = countryId;
        addOn.Company__c        = companyId;
        addOn.name              = name;
        addOn.type__c           = type;
        addOn.contract_Addition__c = contractAddition;
        addOn.is_Active__c      = true;
        return addOn;

    }

    public static List<List_Add_On__c> createAddOns(String countryId,String companyId,String name,
                                                        String type,String ContractAddition,
                                                        String recordTypeDeveloperName,Integer size){
        List<List_Add_On__c> addOns = new List<List_Add_On__c>();
        for(Integer i=0;i<size;i++){
            List_Add_On__c addOn    = new List_Add_On__c();
            addOn.Id_Country__c     = countryId;
            addOn.Company__c        = companyId;
            addOn.name              = name;
            addOn.type__c           = type;
            addOn.contract_Addition__c = contractAddition;
            addOn.is_Active__c      = true;
            addOn.recordTypeId      = mapRecordtypes.get(recordTypeDeveloperName).Id;
            addOns.add(addOn);
        }

        return addOns;
    }

	
	public static void testDataForYogiyoContractProcessWithoutConfigs(){
        UnitTestDataFactory.testDataForYogiyoOpportunityProcessesWithoutConfigs();
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,AccountId,recordtypeid,subtotal__c,vat__c,total__c,currencyIsoCode from Opportunity where name='TestOpp123'];
        Opportunity_Quote__c oppQuote = new Opportunity_Quote__c(CurrencyIsoCode=listOpp[0].currencyIsoCode,Id_Account__c=listOpp[0].accountid,Id_Opportunity__c=listOpp[0].id,Description__c='test data',RecordTypeId=mapRecordtypes.get('Yogiyo_Opportunity_Quote').id,Status__c='Accepted',Subtotal__c=19900,Total__c=19900);
        insert oppQuote;

        List<Opportunity_Line_Item__c> oppProductItem = [SELECT Commission_In_Percentage__c,Commission_Per_Order__c,Id_List_Service_Price__c,CurrencyIsoCode,Has_Related_Tarif__c,Id,Id_List_Price_Product__c,Id_Opportunity__c,Installments__c,Listed_Price__c,Name,Product_Group__c,Quantity__c,Discount__c,RecordTypeId,Total_Amount__c,Sub_Type__c,Line_Item_Type__c,Recurring_Fee__c,Start_Date__c,End_Date__c FROM Opportunity_Line_Item__c where  Id_Opportunity__c =:listOpp[0].id ];
        List<Opportunity_Quote_Line_Item__c> listOppQuotelines = new List<Opportunity_Quote_Line_Item__c>();
        for(Opportunity_Line_Item__c oppQP : oppProductItem){
            Opportunity_Quote_Line_Item__c oppQuoteLine = new Opportunity_Quote_Line_Item__c(Id_List_Service_Price__c=oppQP.Id_List_Service_Price__c,Commission_In_Percentage__c=oppQP.Commission_In_Percentage__c,Commission_Per_Order__c=oppQP.Commission_Per_Order__c,End_Date__c=oppQP.End_Date__c,Recurring_Fee__c=oppQP.Recurring_Fee__c,Start_Date__c=oppQP.Start_Date__c,CurrencyIsoCode=listOpp[0].currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppQP.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppQP.Installments__c,Listed_Price__c=oppQP.Listed_Price__c,Name=oppQP.name,Product_Group__c=oppQP.Product_Group__c,Quantity__c=oppQP.Quantity__c,Discount__c=oppQP.Discount__c,RecordTypeId=mapRecordtypes.get('Yogiyo_Opportunity_Quote_Line_Item').id,Total_Amount__c=oppQp.Total_Amount__c,Sub_Type__c=oppQp.Sub_Type__c,Line_Item_Type__c=oppQp.Line_Item_Type__c,Id_Opportunity__c=oppQp.Id_Opportunity__c);
            listOppQuotelines.add(oppQuoteLine);

        }
        insert listOppQuotelines;   

    }
    
     /**
    * Test data for opportunity processes
    *
    * @param
    *           
    * @return void
    */
    public static void testDataForYogiyoOpportunityProcessesWithoutConfigs(){
        Country__c c = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert new List<sObject>{c,com};
 
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c,'Setup Fee','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg2 = UnitTestDataFactory.createProductGroup(com,c,'Terminal','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg3 = UnitTestDataFactory.createProductGroup(com,c,'AdSales product','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg4 = UnitTestDataFactory.createProductGroup(com,c,'0% Commission','Yogiyo_List_Product_Group');

        Account acc 	= createAccount('TestAccount',c,'Yogiyo_Account');
        Account acc1 	= createAccount('TestAccount1',c,'Yogiyo_Account');

        insert new List<sObject>{lpg,lpg1,lpg2,lpg3,lpg4,acc,acc1};

        List_Product_Price__c lpp 	= UnitTestDataFactory.createProduct(com,c,'Annual Fee',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);        
        List_Product_Price__c lpp1 	= UnitTestDataFactory.createProduct(com,c,'Annual Renewal Fee',lpg1.id,'Yogiyo_List_Product_Price',1,true,100,1,false,null);
        lpp1.Product_Type__c = 'Renewal Fee';
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 2',lpg1.id,'Yogiyo_List_Product_Price',1,true,50,1,true,20);
        List_Product_Price__c lpp3 = UnitTestDataFactory.createProduct(com,c,'Terminal A (One-time Payment)',lpg2.id,'Yogiyo_List_Product_Price',1,true,100,1,false,null);
        List_Product_Price__c lpp4 = UnitTestDataFactory.createProduct(com,c,'AdSales product',lpg3.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);        
        List_Product_Price__c lpp5 = UnitTestDataFactory.createProduct(com,c,'0% Commission',lpg4.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);
        List_Product_Price__c lpp6 = UnitTestDataFactory.createProduct(com,c,'Premium Placement API',lpg4.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);
        lpp6.Product_Type__c = 'Premium placement - 1 Month';
        List_Product_Price__c lpp7 = UnitTestDataFactory.createProduct(com,c,'Menu Printing',lpg4.id,'Yogiyo_List_Product_Price',null,true,0,1,false,null);
        lpp7.Product_Type__c = 'Menu Printing';
        
        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,c,'testService1','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp1 = UnitTestDataFactory.createService(com,c,'testService2','Yogiyo_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp2 = UnitTestDataFactory.createService(com,c,'testService3','Yogiyo_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');

        Tarif__c t = UnitTestDataFactory.createTarif(com,c,'testTarif1','Yogiyo_Tarif',false);
        Tarif__c t1 = UnitTestDataFactory.createTarif(com,c,'testTarif2','Yogiyo_Tarif',false);
        Tarif__c t2 = UnitTestDataFactory.createTarif(com,c,'Ad Sales','Yogiyo_Tarif',false);
        Tarif__c t3 = UnitTestDataFactory.createTarif(com,c,'0% Commission','Yogiyo_Tarif',false);
        Tarif__c t4 = UnitTestDataFactory.createTarif(com,c,'Premium Placement','Yogiyo_Tarif',false);
        Tarif__c t5 = UnitTestDataFactory.createTarif(com,c,'TieredCommission','Yogiyo_Tarif',false);
        Tarif__c t6 = UnitTestDataFactory.createTarif(com,c,'Menu Printing','Yogiyo_Tarif',false);

        Opportunity opp = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'Yogiyo_Opportunity',Date.today());
        Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp456',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp2 = UnitTestDataFactory.createOpportunity('Ad Sales',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp3 = UnitTestDataFactory.createOpportunity('0% commission',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp4 = UnitTestDataFactory.createOpportunity('AddChargeStartDateTest',acc1,'Yogiyo_Opportunity',Date.newInstance(1987, 4, 22));
        Opportunity opp5 = UnitTestDataFactory.createOpportunity('Premium Placement',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp6 = UnitTestDataFactory.createOpportunity('Menu Printing',acc1,'Yogiyo_Opportunity',Date.today());
        Opportunity opp7 = UnitTestDataFactory.createOpportunity('TieredCommission',acc1,'Yogiyo_Opportunity',Date.today());


        opp.type = 'Contract & Product';
        opp.Id_Tarif__c = t1.id;
        opp3.Id_Tarif__c = t3.id;
        opp5.Id_Tarif__c = t4.id;
        opp7.Id_Tarif__c = t5.id;

		 insert new List<sObject>{lpp,lpp1,lpp2,lpp3,lpp4,lpp5,lpp6,lpp7,lsp,lsp1,lsp2,t,t1,t2,t3,t4,t5,t6,opp,opp1,opp2,
		 						opp3,opp4,opp5,opp6,opp7};
        
        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm1 = UnitTestDataFactory.createTarifMember(lpp3.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm2 = UnitTestDataFactory.createTarifMember(lsp.id,'Yogiyo_Tarif_Member',t.id,'Service');
        Tarif_Member__c tm3 = UnitTestDataFactory.createTarifMember(lsp2.id,'Yogiyo_Tarif_Member',t1.id,'Service');
        Tarif_Member__c tm4 = UnitTestDataFactory.createTarifMember(lpp2.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm5 = UnitTestDataFactory.createTarifMember(lpp1.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm6 = UnitTestDataFactory.createTarifMember(lpp4.id,'Yogiyo_Tarif_Member',t2.id,'Product');
        Tarif_Member__c tm7 = UnitTestDataFactory.createTarifMember(lpp5.id,'Yogiyo_Tarif_Member',t3.id,'Product');
        Tarif_Member__c tm8 = UnitTestDataFactory.createTarifMember(lsp.id,'Yogiyo_Tarif_Member',t5.id,'Service');
        Tarif_Member__c tm9 = UnitTestDataFactory.createTarifMember(lpp5.id,'Yogiyo_Tarif_Member',t4.id,'Service');
        Tarif_Member__c tm10 = UnitTestDataFactory.createTarifMember(lpp5.id,'Yogiyo_Tarif_Member',t6.id,'Service');
       
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 2',opp,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppProduct2 = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 1',opp,lpg1.id,lpp1.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp,lsp2.id,true,'Yogiyo_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        Opportunity_Line_Item__c oppProductADSales = UnitTestDataFactory.createOpportunityLineItemProduct('Adsales',opp2,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Ad Sales');
        Opportunity_Line_Item__c oppProductPP = UnitTestDataFactory.createOpportunityLineItemProduct('Premium Placement',opp5,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Premium Placement');
        Opportunity_Line_Item__c oppProductMP = UnitTestDataFactory.createOpportunityLineItemProduct('Menu Printing',opp6,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Menu Printing');

        insert new List<sObject>{tm,tm1,tm2,tm3,tm4,tm5,tm6,tm7,tm8,tm9,tm10};
        t.Is_Active__c = true;
        t1.Is_Active__c = true;
        t2.Is_Active__c = true;
        t3.Is_Active__c = true;
        t4.Is_Active__c = true;
        t5.Is_Active__c = true;
        t6.Is_Active__c = true;
        update new List<Tarif__c>{t,t1,t2,t3,t4,t5,t6};
        
        lpp.Product_Type__c='Terminal Box';
        lpp.Unapproved_Discount_Limit__c=2;
        update lpp;

        insert new List<sObject>{oppProduct,oppProduct2,oppService,oppProductADSales,oppProductPP,oppProductMP};
        oppProduct.Sub_Type__c='Flat Commission';
        update oppProduct;

    }
	
	 /**
    * @desc :Test data for AuraComponentVisibilityControl
    *
    * @param : Name of the custom setting
    *           
    * @return : AuraComponentVisibilityControl__c 
    */
    public static AuraComponentVisibilityControl__c  createAuraComponentVisibilityControlCustSetTestData(){
    
        AuraComponentVisibilityControl__c custSet = new AuraComponentVisibilityControl__c(Name=System.Label.OrderHistoryComponents,
                                                                                          HideOrderDetails__c = false,
                                                                                          HidePreviousOrders__c = false,
                                                                                          HideRestaurantDetails__c = false);
        insert custSet;
        return custSet ;
    }

    private static String generateRandomString(final Integer length) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }


    public static void testDataForApacApprovals(){
        Country__c hk = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
        Company__c com = UnitTestDataFactory.createCompany('Foodpanda Hong Kong', 'Foodpanda Hong Kong', hk);

        insert new List<sObject>{hk,com};
            
        // set business configs
        Business_Config__c bc1 = UnitTestDataFactory.createBusinessConfig('DishLevelProcessClosingAction', 'Process','ClosedReason', '{"positive":"Take Online","negative":"Take Online Is Not Possible"}', hk.Id, 'FP_Opportunity', true, true );
        Business_Config__c bc2 = UnitTestDataFactory.createBusinessConfig('DishLevelProcessClosingAction', 'Process','negativeStageName', 'Please Check', hk.Id, 'FP_Opportunity', true, false );
        Business_Config__c bc3 = UnitTestDataFactory.createBusinessConfig('DishLevelProcessClosingAction', 'Process','positiveStageName', 'Editorial Queue', hk.Id, 'FP_Opportunity', true, false );
        Business_Config__c bc4 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','RequiredAddOnName', 'Dish Level Photoshoot', hk.Id, 'FP_Opportunity', true, true );
        
        insert new List<sObject>{bc1,bc2,bc3,bc4};

        Account acc = createAccount('FP TestAccount',hk,'FP_Account');
        acc.Phone = '+85212345678';
        acc.Record_Country__c = hk.Id;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,hk,'Apple','Talabat_List_Product_Group');
        insert new List<sObject>{lpg,acc};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,hk,'Annual Fee',lpg.id,'FP_List_Product_Price',1,true,100,1,false,20); 
        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,hk,'testService1','FP_List_Service_Price',12,12,25,5,null,true,null,'Per Order','ServiceType');
        lsp.Requires_Approval__c = true;
        lsp.Commission_In_Percentage__c = null;
        lsp.Commission_Type__c = 'Per Order';
        lsp.Commission_Per_Order__c = 43;

        Tarif__c t = UnitTestDataFactory.createTarif(com,hk,'testTarif1','Talabat_Tarif',false);
        Opportunity opp = UnitTestDataFactory.createOpportunity('TestOppTalabat',acc,'Talabat_Opportunity',Date.today());
        insert new List<sObject>{lpp,lsp,t,opp};

        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'Talabat_Tarif_Member',t.id,'Product');
        Opportunity_Tarif_Item__c oppTarif= UnitTestDataFactory.createOpportunityTarif('testTarif1',t.id,opp.id,'Talabat_Opportunity_Tarif_Item');
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 2',opp,lpg.id,lpp.id,true,'Talabat_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp,lsp.id,true,'Talabat_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);

        insert new List<sObject>{tm};

        t.Is_Active__c = true;
        update new List<Tarif__c>{t};

        insert new List<sObject>{oppTarif,oppProduct,oppService};
    }

    public static Approval_Rule__c createApprovalRule(Id serviceId, Id productId, Id addOnId, Id Approver, String Level1, String Level2, Id CountryId) {
        return new Approval_Rule__c(Commission__c = serviceId, Product__c = productId, Add_On__c = addOnId, Level1_Approver__c = Approver, Level2_Approver__c = Approver, Level1__c = level1, Level2__c = level2, Applies_To__c = 'Commissions', Country__c = CountryId);
    }
	
	//SCC-303 Test data for APAC - Service Recovery Escalation custom setting
    public static List<Service_Recovery_Escalation__c> createServiceEscCustomSetting(String pType,String platformName, List<String> pCaseReasons){
        List<Service_Recovery_Escalation__c> lst = new List<Service_Recovery_Escalation__c>();
        Integer i =1;
        String namePrefix = '';
        if(platformName == 'Foodpanda'){
            namePrefix = 'FP-';
        }
        for(String str:pCaseReasons){
            Service_Recovery_Escalation__c rec = new Service_Recovery_Escalation__c();
            rec.Name = namePrefix+i;
            rec.Platforms__c = platformName ;
            rec.Type__c = pType ;
            rec.CLR2__c = str.substringBefore(':');
            rec.CLR3__c = str.substringAfter(':');
            lst.add(rec);
            i++;
        }
        return lst;
    }

    /**
    * @description Method to create opportunity field history records
    *
    * @param opportunityIds parent opportunities
    *
    * @return list of opportunity field histories
    */
    public static List<OpportunityFieldHistory> createOpportunityFieldHistories(Set<Id> opportunityIds) {
        List<OpportunityFieldHistory> histories = new List<OpportunityFieldHistory>();
        for (Id oppId: opportunityIds) {
            OpportunityFieldHistory fieldHistory = new OpportunityFieldHistory(Field='StageName', OpportunityId = oppId);
            histories.add(fieldHistory);
        }
        return histories;
    }

}
