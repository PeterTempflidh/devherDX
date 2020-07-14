public class CtrOrderConfirmationPDF {
    public LeadWrapper leadWrapper { get; set; }
    public Lead leadData { get; set; }
    public CtrOrderConfirmationPDF(ApexPages.StandardController ctr) {
        leadData = [SELECT Name, Restaurant_Name__c, Street, PostalCode, City, Email, Phone, MobilePhone, Owner.Name, Description, Setup_Fee__c, Commission__c, Installments__c,
                Tariff_Name__c, Cuisine__c, Best_Time_To_Contact__c, Salutation, Other_Phone__c FROM Lead WHERE Id =: ctr.getId() LIMIT 1];
        if(leadData.Description != null)
            leadWrapper = (LeadWrapper)System.JSON.deserialize(leadData.Description, CtrOrderConfirmationPDF.LeadWrapper.class);
    }

    public class LeadWrapper {
        public String minOrderDelivery { get; set; }
        public String minOrderFreeDelivery { get; set; }
        public String deliveryCharge { get; set; }
        public String cuisine { get; set; }
        public String cuisineNote { get; set; }
        public String zip1 { get; set; }
        public String zip2 { get; set; }
        public String zip3 { get; set; }
        public String zip4 { get; set; }
        public String zip5 { get; set; }
        public String zip6 { get; set; }
        public String zip7 { get; set; }
        public String zip8 { get; set; }
        public String zip9 { get; set; }
        public String zip10 { get; set; }
        public String zip11 { get; set; }
        public String zip12 { get; set; }
        public String zip13 { get; set; }
        public String zip14 { get; set; }
        public String zip15 { get; set; }
        public String zip16 { get; set; }
        public String zip17 { get; set; }
        public String zip18 { get; set; }

        public String zipFee1 { get; set; }
        public String zipFee2 { get; set; }
        public String zipFee3 { get; set; }
        public String zipFee4 { get; set; }
        public String zipFee5 { get; set; }
        public String zipFee6 { get; set; }

        public String fridayStarts { get; set; }
        public String fridayEnds { get; set; }
        public String saturdayStarts { get; set; }
        public String saturdayEnds { get; set; }
        public String sundayStarts { get; set; }
        public String sundayEnds { get; set; }
        public String mondayStarts { get; set; }
        public String mondayEnds { get; set; }
        public String tuesdayStarts { get; set; }
        public String tuesdayEnds { get; set; }
        public String wednesdayStarts { get; set; }
        public String wednesdayEnds { get; set; }
        public String thursdayStarts { get; set; }
        public String thursdayEnds { get; set; }
        public String bankholidaysStarts { get; set; }
        public String bankholidaysEnds { get; set; }

        public String bladeSign { get; set; }
        public String yes { get; set; }
        public String no { get; set; }
        
        public String tgtablink { get; set; }
        public String wifitablink { get; set; }
        public String tablinktakeover { get; set; }
        public String tablinksharing { get; set; }
        public String livelinktakeover { get; set; }
        public String livelinklinked { get; set; }

        public String otherRestName { get; set; }
        public String otherRestZip { get; set; }
        
        public String rewardStamps{get; set;}
        public String commissionRT{get;set;}
        public String splOffer{get;set;}
        public String tasteTest{get;set;}


    }
}