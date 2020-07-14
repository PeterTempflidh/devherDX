global with sharing class CtrOrderConfirmation {
    public Id leadId { get; set; }
    public Lead leadData { get; set; }
    public Boolean leadConverted { get; set; }
    public CtrOrderConfirmation() {
    }

    public CtrOrderConfirmation(ApexPages.StandardController controller) {
    }

    // Method for populating Tarif Dropdown list
    @RemoteAction
    global static Lead getLead(String lId) {
        return [SELECT Name, Restaurant_Name__c, Street, PostalCode, City, Email, Phone, MobilePhone, Owner.Name, Description, Setup_Fee__c, Commission__c, Installments__c,
                Tariff_Name__c, Best_Time_To_Contact__c, Company_Code__c, Cuisine__c, Other_Phone__c,Non_Standard_Contract_Components__c , Salutation FROM Lead WHERE Id =: lId LIMIT 1];
    }

    @RemoteAction
    global static List<Schema.PicklistEntry> getCuisineTypes(String lId) {
        Lead l = [SELECT Cuisine__c FROM Lead WHERE Id =: lId LIMIT 1];
        Schema.Describefieldresult result = Lead.Cuisine__c.getDescribe();
        return result.getPicklistValues();
    }

    // Method for saving and converting Lead
    @RemoteAction
    global static String updateLead(String leadId, String restName,String nonStandardTerm, String name, String street,
                                    String postalCode, String city, String email, String phone, 
                                    String mobile, String orderDate, Decimal commission, Decimal setup, String tarif, String description,
                                    Integer installments, String bestTimeContact, String nonStandardComponent, String otherPhone, String salutation) {

        String[] nameSplit = name.split(' ');
       system.debug('$$'+nonStandardTerm);
        Lead lead = new Lead(Id = leadId,
            Restaurant_Name__c = restName,
            Street = street,
            PostalCode = postalCode,
            City = city,
            Email = email,
            Phone = phone,
            MobilePhone = mobile,
            Commission__c = commission,
            Setup_Fee__c = setup,
            Tariff_Name__c = tarif,
            Order_Date__c = Date.today(),
            Description = description,
            Best_Time_To_Contact__c = bestTimeContact,
            Installments__c = installments,
            Non_Standard_Contract_Components__c = nonStandardComponent,
            non_standard_contract_terms__c=nonStandardTerm,
            Other_Phone__c = otherPhone,
            Salutation = salutation
            );

        
        if(nameSplit.size() == 1)
            lead.LastName = nameSplit[0];
        if(nameSplit.size() == 2) {
            lead.FirstName = nameSplit[0];
            lead.LastName = nameSplit[1];
        }
        if(nameSplit.size() == 3) {
             System.debug('@@@ Rijad 3333');
            lead.FirstName = nameSplit[0];
            lead.MiddleName = nameSplit[1];
            lead.LastName = nameSplit[2];
        }

        update lead;
       
        return leadId;

    }

     // Method for saving and converting Lead
    @RemoteAction
    global static String convertLead(String leadId, String tarifName) {
       
        // does not work in salesforce1
        PageReference orderConfirmationPDF;
        if(tarifName.contains('Regional')){
            orderConfirmationPDF = new PageReference('/apex/OrderConfirmationRegionalPDF?id=' + leadId);
        }
        else
        orderConfirmationPDF = new PageReference('/apex/OrderConfirmationPDF?id=' + leadId);
        Blob body;
        if(!test.isRunningtest())
        body = orderConfirmationPDF.getContent(); 
        else
         body = blob.valueof('test');    

        String oppQuoteId = null;
        List<String> result = ClsLeadProcessor.processLeadConversion(leadId,'UK', false);
        //if(!result.isEmpty()){
          //  if(result[0]!='error')
                
        //}
        if(!result.isEmpty()){
            if(result[0]=='success'){
                oppQuoteId = ClsLeadProcessor.createOppQuote();
                if(result[1]=='showConversionPage'){
                    Attachment attachment = new Attachment();
                    attachment.ContentType = 'application/pdf';
                    attachment.Body = body;
                    attachment.Name = String.valueOf('OrderConfirmation.pdf');
                    attachment.ParentId = leadId;

                    insert attachment;
                    return '/'+leadId; 
                } else if(oppQuoteId != null) {
                    Contact con = [SELECT Id FROM Contact WHERE AccountId = :result[1]];
                    ////Attachment att = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :con.Id];
                    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :result[1]];
                    Attachment attachment = new Attachment();
                    attachment.ContentType = 'application/pdf';
                    attachment.Body = body;
                    attachment.Name = String.valueOf('OrderConfirmation.pdf');
                    attachment.ParentId = opp.Id;

                    insert attachment;
                    //update att;
                    return '/'+oppQuoteId; 
                }
                else{
                    Contact con = [SELECT Id FROM Contact WHERE AccountId = :result[1]];
                    //Attachment att = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :con.Id];
                    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :result[1]];
                    Attachment attachment = new Attachment();
                    attachment.ContentType = 'application/pdf';
                    attachment.Body = body;
                    attachment.Name = String.valueOf('OrderConfirmation.pdf');
                    attachment.ParentId = opp.Id;

                    insert attachment;
                    return '/'+result[1]; 
                }

            }else{
                    Attachment attachment = new Attachment();
                    attachment.ContentType = 'application/pdf';
                    attachment.Body = body;
                    attachment.Name = String.valueOf('OrderConfirmation.pdf');
                    attachment.ParentId = leadId;

                    insert attachment;
    
                ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, result[1]));
                return '/' + leadId;
            }
        }

    //}
            Attachment attachment = new Attachment();
            attachment.ContentType = 'application/pdf';
            attachment.Body = body;
            attachment.Name = String.valueOf('OrderConfirmation.pdf');
            attachment.ParentId = leadId;

            insert attachment;
    
        
        return '/' + leadId;

    }


}