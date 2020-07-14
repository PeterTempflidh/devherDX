/**
* @author Chaitali Kumari
* @date 28.05.2019
*
* @description Common class for retrieving Restaurant Owner or Contact information
*/

public with sharing class ContactSelector {

    /*******************************************************************************************************
    * @description Query for Main Contact record where contact role is owner.
    * @param keys Account Id
    * @return one single contact per account where contact role = owner
    */

    public static Contact getAccountOwnerInformation (final String paramAccId) {
        Contact primaryContact = new Contact();
        try {
            primaryContact = [SELECT Id, Email, Salutation, LastName, FirstName, Translated_Name__c FROM Contact WHERE AccountId = :paramAccId AND Contact_Role__c = 'Owner' LIMIT 1];
            if (primaryContact == null) {
                Set<id> conIds = new Set<Id>();
                for (AccountContactRelation accCon : [select contactid, contact.email, contact.name from AccountContactRelation where accountid = :paramAccId and contact.contact_role__c = 'Owner' and isactive = true order by createddate desc Limit 1]) {
                    conIds.add(accCon.contactid);
                }
                primaryContact = [SELECT Id, Email, Salutation, LastName, FirstName, Translated_Name__c FROM Contact WHERE Contact_Role__c = 'Owner' and id in:conIds LIMIT 1];
            }
        } catch (QueryException e) {
        system.debug('Error: '+e.getMessage());
        }

        return primaryContact;
    }

    public static List<Contact> getNonPrimaryContactListForAccount (String accountId, String primaryEmail) {

        return [SELECT Id, Email FROM Contact WHERE Account.Id = :accountId AND Email!=:primaryEmail];
    }
    
    /*******************************************************************************************************
    * @description returns contacts with owner role for the given account Id's
    * @param Set<Id> : account id set
    * @return List<Contact>
    */
    public static List<Contact> fetchContactsWithOwnerRole(Set<Id> accIdSet) {
        // Putting limit 1 as there won't be more than one contact - confirmed from business
        return [SELECT Id, AccountId,Passport_ID_Number__c, (SELECT Id, ContactId FROM AccountContactRelations WHERE isactive = TRUE LIMIT 1) FROM Contact WHERE AccountId =: accIdSet AND Contact_Role__c = 'Owner'];
    }

    /**
     * @description get contact related to an Account by Email
     *
     * @param email contact email
     * @param grid parent account grid
     *
     * @return contact
     */
    public static Contact getByEmailAndAccountGrid(final String email, final String grid) {
        Contact cont = new Contact();
        try {
            cont = [SELECT Id FROM Contact WHERE Account.GRID__c = :grid AND Email = :email LIMIT 1];
        } catch (QueryException e) {
            System.debug(LoggingLevel.ERROR, 'getByEmailAndAccountGrid: Contact not found! Email: ' + email + ' GRID:' + grid);
        }
        return cont;
    }

}
