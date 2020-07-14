/*
Controller for both DE_SpecialDeals_LH and DE_SpecialDeals_PDE web forms
 */

public class CtrDE_SpecialDeals {

	@testVisible
	private static final Integer ATTACHMENTS_NUMBER = 3;

	public String customerId						{get; set;}
	public String restaurantName					{get; set;}
	public String phone								{get; set;}
	public String dealDescription					{get; set;}
	public string splDealType						{get; set;}
	public String selectedSplDeal					{get; set;}
	public String EmailAdd							{get; set;}
	public List<Attachment> newAttachments 			{get; set;}
	public boolean showForm 						{get; private set;}


	public CtrDE_SpecialDeals() {
		showForm = true;
		initAttachmentsList();
	}

	public void save() {
		// checks whether this request is coming from LH or PDE portal
		Boolean isLhPortal = ApexPages.currentPage().getUrl().containsIgnoreCase('DE_SpecialDeals_LH');
		
		// fetch the queue
		Group queue = [SELECT Id from GROUP Where type = 'Queue' and developerName = 'DE_Account_Management'];
		
		Case specialDeals = new Case();

		specialDeals.Subject 		= splDealType + ': ' + selectedSplDeal;
		specialDeals.SuppliedEmail 	= EmailAdd;
		specialDeals.Description 	= isLhPortal ? 'Kundennummer Lieferheld: ' + customerId : 'Kundennummer PDE: ' + customerId;
		specialDeals.Description 	+= '\nName des Restaurants: ' + RestaurantName;
		specialDeals.Description 	+= '\nRückrufnummer: ' + phone;
		specialDeals.Description 	+= '\nBeschreibungsfeld : ' + dealDescription;
		specialDeals.Type 			= 'Sales Task';
		specialDeals.Case_Reason__c = 'Meal Deals';
		specialDeals.Origin 		= 'Web';
		specialDeals.RecordTypeId 	= LibRecordTypeHelper.getRecordTypeValue('DE_Internal_Case');
		specialDeals.ownerId		= queue.Id;
		specialDeals.Platform__c 	= isLhPortal ? 'LieferheldDE' : 'PizzaDE'; // set platform value

		try {
			// insert new case
			insert specialDeals;

			// try to insert attachments
			List<Attachment> toInsert = new List<Attachment>();

			for (Attachment att : newAttachments) {
				if (att.Body == null) {
					continue; // no file to store
				}

				att.ParentId = specialDeals.Id;
				toInsert.add(att);
			}

			if (!toInsert.isEmpty()) {
				insert toInsert;
			}

			// hide form on the page
			showForm = false;

			ClsUtilsApexPages.addConfirmMessage('Vielen Dank!');

		} catch (DmlException dmlEx) {
			ClsUtilsApexPages.addErrorMessage(dmlEx.getDmlMessage(0));
			System.debug('CtrDE_MenuChange.save: dml exception occurred while saving case. Message is: ' + dmlEx.getMessage() + ' - Stack trace is: ' + dmlEx.getStackTraceString());
		} catch (Exception e) {
			ClsUtilsApexPages.addErrorMessage('Something went wrong, please contact Customer Care');
			System.debug('CtrDE_MenuChange.save: exception occurred while saving case. Message is: ' + e.getMessage() + ' - Stack trace is: ' + e.getStackTraceString());
		}

		// reset the attachment list
		initAttachmentsList();
	}

	private void initAttachmentsList() {
		newAttachments = new List<Attachment>();
		for (Integer i = 0; i < ATTACHMENTS_NUMBER; i++) {
			newAttachments.add(new Attachment());
		}
	}
}