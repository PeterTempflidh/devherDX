/**
* @author Shivani
* @date 15/05/2020
*
* @description (SSC-2796 and 2794) wrapper class to hold parse response of JSON string 
from Facility Business config LeadConversionAndAccountCloneFacilityCheck to be used in
1. AccountClone.page
2. Lead conversion2.page
3. CreateNewAddress.page
4. PY_LeadConvertFields.component
5. PY_AccountConvertFields.component
*/
public inherited sharing class FacilityBusinessConfigWrapper {
    
    /*******************************************************************************************************
    * @description holds all labels for condition check 
    * returns condLabels if found in config
    */
    public CondLabels condLabels{get;set;}
    
    /*******************************************************************************************************
    * @description holds all Recordtypes for condition check 
    * returns RecTypes if found in config
    */
    public RecTypes recTypes{get;set;}
    
     /*******************************************************************************************************
    * @description holds all Errormessages for different conditions 
    * returns ErrMessages if found in config
    */
    public ErrMessages errMessages{get;set;}

     /*******************************************************************************************************
    * @description holds all countries based on address model
    * returns AddModels if found in config
    */
    public AddModels addModels{get;set;}
       
    /**
    * @author Shivani
    * @date 2020
    * @description wrapper for Error messages 
    */
	public class ErrMessages {
        
        /*******************************************************************************************************
        * @description String to validation message for brnach kitchen selection
        * returns String if found in config
        */
   public String errorAddressMessageForKitchen{get;set;}

        /*******************************************************************************************************
        * @description String to validation message for empty type field on lead conversion
        * returns String if found in config
        */
		public String typeFieldRequired{get;set;}

        /*******************************************************************************************************
        * @description String to validation message for Empty Facility field
        * returns String if found in config
        */
		public String kitchenRestaurantFacilityValidationMessage{get;set;}

        /*******************************************************************************************************
        * @description String to validation message for commmon error
        * returns String if found in config
        */
		public String errorValidationOnAddressForm{get;set;}

        /*******************************************************************************************************
        * @description String to validation message for restaurnat address change on createNewAddresspage
        * returns String if found in config
        */
		public String errorAddressMessageForRestaurant{get;set;}
	}

    /**
    * @author Shivani
    * @date 2020
    * @description wrapper for Recordtypes
    */
	public class RecTypes {

        
        /*******************************************************************************************************
        * @description String to hold Account
        * returns String if found in config
        */
		public String accRecordType{get;set;}
         

        /*******************************************************************************************************
        * @description String to hold Facility_Account
        * returns String if found in config
        */
		public String facilityRecordType{get;set;}
	}

    /**
    * @author Shivani
    * @date 2020
    * @description wrapper for CondLabels like Restaurant address
    * and Branch -Kitchen Restaurant
    */
    public class CondLabels {
        
        /*******************************************************************************************************
        * @description String to hold Restaurant address 
        * returns String if found in config
        */
		public String restaurantAddressType{get;set;}
        
        /*******************************************************************************************************
        * @description String to hold Branch -Kitchen Restaurant 
        * returns String if found in config
        */
		public String branchKitchenRestaurantAccountType{get;set;}
	}
    
    /**
    * @author Shivani
    * @date 2020
    * @description wrapper for countries based on addModels 
    */
    public class AddModels{
        
        /*******************************************************************************************************
        * @description String to hold countries that follow xal New address model 
        * returns String if found in config
        */
		public String xalNewCountries{get;set;}
        
        /*******************************************************************************************************
        * @description String to hold countries that follow xal address model 
        * returns String if found in config
        */
		public String xalCountries{get;set;}
        
        /*******************************************************************************************************
        * @description String to hold countries that follow gpa address model 
        * returns String if found in config
        */
		public String gpaCountries{get;set;}
        
        /*******************************************************************************************************
        * @description String to hold countries that follow daum address model  
        * returns String if found in config
        */
		public String daumCountries{get;set;}
	}

}

