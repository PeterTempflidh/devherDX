/**
* @author Keerthan Tantry
* @date 19.03.2020
*
* @description Contants class for storing constant values
*/
public without sharing class Constants {

    /* SObject API Names */
    public static final String SOBJECT_ACCOUNT = 'Account';
    public static final String SOBJECT_TASK = 'Task';
    public static final String SOBJECT_ACTION_ITEM = 'ActionItem__c';

    /**
     * Account Constants
     */
    public static final string ACCOUNT_TYPE_BRANCH_KITCHEN_RESTAURANT = 'Branch - Kitchen Restaurant';
    public static final string ACCOUNT_TYPE_GROUP = 'Group';
    public static final string ACCOUNT_TYPE_BRAND = 'Brand';
    public static final string ACCOUNT_TYPE_BRANCH_MAIN = 'Branch - Main';
    public static final string ACCOUNT_STATUS_ACTIVE = 'Active';
    public static final string FACILITY_ACCOUNT_DEVELOPERNAME = 'Facility_Account';
    public static final string FP_ACCOUNT_DEVELOPERNAME = 'FP_Account';
    public static final string ACCOUNT_REVENUE_MODEL_ORDERING = 'Ordering Platform';
    public static final string ACCOUNT_RT_TALABAT_ACCOUNT = 'Talabat_Account';

    /**
    * Action Items Constants
    **/
    public static final String  ACTION_ITEM_TYPE_COMMISSION_UPGRADE = 'Commission Upgrade';

    /**
    * Task Constants
    **/
    public static final String  TASK_RT_TALABAT_TASK = 'Talabat_Task';
    public static final String  TASK_SUBJECT_CALL = 'Call';
    public static final String  TASK_STATUS_NOT_STARTED = 'Not Started';
    public static final String  TASK_PRIORITY_LOW = 'Low';
    public static final String  TASK_PRIORITY_NORMAL = 'Normal';
    public static final String  TASK_PRIORITY_HIGH = 'High';

    /**
     * Opportunity Constants
     */
    public static final string OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    public static final string OPPORTUNITY_TYPE_CONTRACT_ONLY = 'Contract Only';
    public static final string OPPORTUNITY_RT_TALABAT_OPPORTUNITY = 'Talabat_Opportunity';
    public static final string OPPORTUNITY_STAGE_DELIVERY_PENDING = 'Delivery Pending';
    public static final string FP_OPPORTUNITY_DEVELOPERNAME = 'FP_Opportunity';
    public static final String OPPORTUNITY_STAGE_QUALITY_CHECK_REQUEST = 'Quality Check Request';
    public static final String OPPORTUNITY_BUSINESSTYPE_UPGRADE_UPSELL = 'Upgrade/Upsell';
    public static final String OPPORTUNITY_TYPE_PRODUCT_ONLY = 'Product Only';

    /**
    * Case Constants
    */
    public static final string CASE_TYPE_QUALITY_CHECK = 'Quality Check';
    public static final string CASE_STATUS_CLOSED = 'Closed';
    public static final string CASE_CLOSED_REASON_SUCCESSFUL = 'Successful';

    /**
     * Contract Constants
     */
    public static final string CONTRACT_STATUS_ACTIVATED = 'Activated';
    public static final string CONTRACT_STATUS_DRAFT = 'Draft';
    public static final string CONTRACT_SERVICE_DEAL_SUBSCRIPTION = 'Deal Subscription Fee';
    public static final string CONTRACT_SERVICE_COMMISSION_FEE = 'Commission Fee';
    public static final string CONTRACT_TERMINATION_REASON = 'Reason Selected';
    public static final string CONTRACT_RT_TALABAT_CONTRACT = 'Talabat_Contract';

    /**
     * Opportunity Quote Constants
     */
    public static final string OPPORTUNITY_QUOTE_RT_TALABAT_QUOTE = 'Talabat_Opportunity_Quote';
    public static final String OPPORTUNITY_QUOTE_STATUS_ACCEPTED = 'Accepted';
    public static final String OPPORTUNITY_QUOTE_STATUS_DRAFT = 'Draft';
    public static final String OPPORTUNITY_QUOTE_STATUS_APPROVED = 'Approved';
    public static final String OPPORTUNITY_QUOTE_NON_STD_CONTRCT_COMP = 'Registration fee';

    /**
     * Quote Constants
     */
    public static final string QUOTE_STATUS_ACCEPTED = 'Accepted';

    /**
    * Address Constants
    */
    public static final string ADDRESS_TYPE_RESTAURANT_ADDRESS = 'Restaurant Address';

    /**
    * Additional Charges Constants
    */
    public static final string ADD_CHARGES_STATUS_PENDING_ACTIVATION = 'Pending Activation';
    public static final string ADD_CHARGES_STATUS_DRAFT = 'Draft';

    /**
    * Country Constants
    */
    public static final string COUNTRY_NAME_AUSTRIA = 'Austria';
    public static final string COUNTRY_NAME_MALAYSIA = 'Malaysia';
    /**
    * Tarif Constants
    */
    public static final string TARIF_NAME_PREMIUM_PLACEMENT = 'Premium Placement';
    public static final string TARIF_RT_TALABAT_DEVELOPERNAME = 'Talabat_Tarif';

    /**
    * Business Config Process Name Constants
    */
    public static final string BUSINESSCONFIG_PROCESSNAME_ADDOPPORTUNITYLINEITEMS = 'addOpportunityLineItems';
    public static final string BUSINESSCONFIG_PROCESSNAME_NINTEXDOCGENERATION = 'nintexDocumentGeneration';
    public static final string BUSINESSCONFIG_PROCESSNAME_NINTEXFORCHAINOPP = 'nintexForChainOpp';
    public static final string BUSINESSCONFIG_PROCESSNAME_SYNCTASKS = 'SyncTasks';

    /**
    * Business Config Rule Name Constants
    */
    public static final string BUSINESSCONIFG_RULENAME_ENABLESFPREMIUMPLACEMENTUI = 'enableSFPremiumPlacementUI';
    public static final string BUSINESSCONIFG_RULENAME_CHECKCOMMISSIONTYPES = 'checkCommissionTypes';
    public static final string BUSINESSCONIFG_RULENAME_CHECKCLOSEDCASES = 'CheckClosedCases';
    public static final string BUSINESSCONIFG_RULENAME_TASKFIELDTOMAP = 'TaskFieldsToMap';

    /**
    * Case Constants
    */
    public static final string CASE_STATUS_CLOSE = 'Closed';
    public static final string CASE_STATUS_NEW = 'New';
    public static final string CASE_TYPE_MENU_PROCESSING = 'Menu Processing';
    public static final string FP_ENTRY_CASE_DEVELOPERNAME = 'FP_Entry_Case';
    public static final string CASE_CLOSED_REASON_TAKE_ONLINE = 'Take Online';

    /**
    * Add On Service
    */
    public static final string ADD_ON_SERVICE_STATUS_ACTIVE = 'Active';
    public static final string ADD_ON_SERVICE_STATUS_NEW = 'New';
    public static final string FP_ADD_ON_DEVELOPERNAME = 'FP_Add_On';

    /**
   * Add On List
   */
    public static final string FP_LIST_ADD_ON_DEVELOPERNAME = 'FP_List_Add_On';

    /**
    * lIST Service Price
    */
    public static final string FP_LIST_SERVICE_PRICE_DEVELOPERNAME = 'FP_List_Service_Price';


    /**
    * Contact
    */
    public static final string FP_CONTACT_DEVELOPERNAME = 'FP_Contact';
    public static final String CONTACT_RT_TALABAT_DEVELOPERNAME = 'Talabat_Contact';
    public static final String CONTACT_CONTACTROLE_OWNER = 'Owner';


    /**
    * Opportunity line Item
    */
    public static final string FP_OPPORTUNITY_LINE_ITEM_DEVELOPERNAME = 'FP_Opportunity_Line_Item';

    /**
    * Opportunity  Quote line Item
    */
    public static final string FP_OPPORTUNITY_QUOTE_LINE_ITEM_DEVELOPERNAME = 'FP_Opportunity_Quote_Line_Item';
    public static final String TALABAT_OPPORTUNITY_QUOTE_LINE_ITEM_DEVELOPERNAME = 'Talabat_Opportunity_Quote_Line_Item';

    /**
    * Opportunity Quote
    */
    public static final string FP_OPPORTUNITY_QUOTE_DEVELOPERNAME = 'FP_Opportunity_Quote';

    /**
    * Branding Content
    */
    public static final string BRANDINGCONTENT_TYPE_WHITE_LABEL_APP = 'White Label App';
    public static final string BRANDINGCONTENT_STATUS_INSTALLED_SUCCESSFULLY = 'Installed Successfully';

    /**
   * Assets
   */
    public static final string ASSET_STATUS_ACTIVATED_SUCCESSFULLY = 'Activated Successfully';
    public static final string ASSET_TAG_EXCEPTION = 'Exception';
    public static final string ASSET_TAG_DELIVERED = 'Delivered';
    /**
   * Shipment Order
   */
    public static final string SHIPMENTORDER_STATUS_READY_TO_BE_SHIPPERD = 'Ready to be shipped';

    /**
    * Opportunity Line Item Constants
    */
    public static final string OLI_RT_TALABAT_OLI = 'Talabat_Opportunity_Quote_Line_Item';
    
    /**
    * Bank Details Constants
    */
    public static final String BANKDETAIL_STATUS_NEW = 'New';
    public static final String BANKDETAIL_STATUS_INACTIVE = 'Inactive';
    public static final String BANKDETAIL_STATUS_APPROVAL_PENDING = 'Approval Pending';
    public static final String BANKDETAIL_STATUS_SCHEDULED_UPDATE_FAILED ='Scheduled Update Failed';
    public static final String BANKDETAIL_STATUS_APPROVED ='Approved';
    public static final String BANKDETAIL_STATUS_ACTIVE ='Active';
    public static final String BANKDETAIL_STATUS_REJECTED ='Rejected';

    /**
    * Nintex Config
    */
    public static final Set<String> NINTEX_CONFIG_CLASSICUI_COUNTRIES =
            new Set<String>{'Egypt','United Arab Emirates','Oman'};

    /**
    * List Product Group
    */
    public static final string LPG_RT_TALABAT_DEVELOPERNAME = 'Talabat_List_Product_Group';

    /**
    * List Product Price
    */
    public static final string LPP_RT_TALABAT_DEVELOPERNAME = 'Talabat_List_Product_Price';

    /**
    * Business Config Record Type Name
    */
    public static final string BUSINESSCONFIG_RECORDTYPE_TALABATTASK = 'Talabat_Task';

    /**
    * Stock Item Constants
    */
    public static final String FP_STOCKITEM_DEVELOPERNAME = 'FP_Stock_Item';
}

