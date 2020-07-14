/*
Legacy menu change controller, coming from Old Salesforce.
This is the controller for both: DE_MenuChange_LH and DE_MenuChange_PDE
 */
public class CtrDE_MenuChange {

	@testVisible 
	private static final Integer ATTACHMENTS_NUMBER = 3;

	public Boolean allergens								{get; set;}
	public String changeInPrice								{get; set;}
	public String lieferheldId								{get; set;}
	public String restaurantName							{get; set;}
	public String postalCode								{get; set;}
	public String addDeleteDish								{get; set;}
	public String addDeleteCategory							{get; set;}
	public String menuChangeDetails							{get; set;}
	public String menuSpecials								{get; set;}
	public String changeOnPizzade							{get; set;}
	public String changeOnLh                                {get; set;}
	public String pizzadeId									{get; set;}
	public String EmailAdd									{get; set;}
	public List<Attachment> newAttachments 					{get; set;}
	public boolean showForm									{get; private set;}


	public CtrDE_MenuChange() {
		showForm = true;
		initAttachmentsList();
	}
	
	public void save() {
		// checks whether this request is coming from PDE or LH portal
		Boolean isLhPortal = ApexPages.currentPage().getUrl().containsIgnoreCase('DE_MenuChange_LH');

		Case menuChange = new Case();

		// for case created through LH portal
		if (isLhPortal && changeOnPizzade == 'Yes' && String.isBlank(pizzadeId)) {
			ClsUtilsApexPages.addErrorMessage('Bitte eintragen pizza.de Kundennummer');
			initAttachmentsList();
			return;
		}

		// for case created through pizza.de portal
		if (!isLhPortal && changeOnLh == 'Yes' && String.isBlank(lieferheldId)) {
			ClsUtilsApexPages.addErrorMessage('Bitte eintragen Lieferheld Kundennummer');
			initAttachmentsList();
			return;
		}
		
		// fetch the queue
		Group queue = [SELECT Id from GROUP Where type = 'Queue' and developerName = 'DE_Editorial'];
		
		menuChange.subject = 'Menü-Änderung beantragen';

		// lmiv menu change
		if (allergens) {
			menuChange.subject += '-Allergens';
			menuChange.Priority = 'Urgent - LMIV';
		}

		menuChange.SuppliedEmail 	= EmailAdd;
		menuChange.Type 			= 'Menu Change';
		menuChange.Origin 			= 'Web';
		menuChange.RecordTypeId 	= LibRecordTypeHelper.getRecordTypeValue('DE_Entry_Case');
		menuChange.ownerId			= queue.id;
		menuChange.Description 		= isLhPortal ? 'Kundennummer Lieferheld: ' + lieferheldId : 'Kundennummer Pizza.de: ' + pizzadeId;
		menuChange.Description 		+= '\nName des Restaurants: ' + RestaurantName;
		menuChange.Description 		+= '\nPLZ: ' + postalCode;
		menuChange.Description 		+= '\nPreisänderung: ' + ChangeInPrice;
		menuChange.Description 		+= '\nHinzufügen oder Löschen von Gerichten: ' + addDeleteDish;
		menuChange.Description 		+= '\nHinzufügen oder Löschen von Kategorien: ' + addDeleteCategory;
		menuChange.Description 		+= '\nVollständige Menüänderung: ' + menuChangeDetails;
		menuChange.Description 		+= '\nBesondere Menüs(Mittagsmenü, Sommerangebot,…): ' + menuSpecials;

		if (isLhPortal) {
			menuChange.Description 	+= '\nÄndert sich das Menü auch auf pizza.de? ' + changeOnPizzade;
			menuChange.Description 	+= '\nWenn ja, hinterlassen Sie Ihre pizza.de Kundennummer: ' + pizzadeId;
		} else {
			menuChange.Description 	+= '\nÄndert sich das Menü auch auf Lieferheld? ' + changeOnLh;
			menuChange.Description 	+= '\nWenn ja, hinterlassen Sie Ihre Lieferheld Kundennummer: ' + lieferheldId;
		}

		// set platform based on input fields
		menuChange.Platform__c = '';

		if (String.isNotBlank(lieferheldId)) {
			menuChange.Platform__c += 'LieferheldDE;';
		}
		if (String.isNotBlank(pizzadeId)) {
			menuChange.Platform__c += 'PizzaDE;';
		}

		try {

			// insert new case
			insert menuChange;

			// try to insert attachments
			List<Attachment> toInsert = new List<Attachment>();

			for (Attachment att : newAttachments) {
				if (att.Body == null) {
					continue; // no file to store
				}

				att.ParentId = menuChange.Id;
				toInsert.add(att);
			}

			if (!toInsert.isEmpty()) {
				insert toInsert;
			}

			// hide form on the page
			showForm = false;

			ClsUtilsApexPages.addConfirmMessage('Vielen Dank! Wir haben ihre die Menü-Änderungen erhalten und werden die Änderungswünsche so schnell wie möglich umsetzen.');

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