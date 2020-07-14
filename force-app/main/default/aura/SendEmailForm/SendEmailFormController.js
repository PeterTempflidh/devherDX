({
	doInit: function(component, event, helper) {

		let workspaceAPI = component.find('workspace');
		workspaceAPI.getEnclosingTabId().then(function(tabId) {

				component.set('v.tabId', tabId);
				workspaceAPI.setTabLabel({
					'tabId': tabId,
					'label': $A.get('$Label.c.Quote_Email_Send_Email')
				});
			})
			.catch(function(error) {
				console.log(error);
			});

		if(!component.get("v.isInClassicConsole")){
			component.set('v.recordId', helper.getUrlParameter('c__recordId'));
		}
		helper.getConfigParams(component, event, helper);
	},

	send: function(component, event, helper) {
		// validation of entered values
		let email = component.get('v.selectedValueFrom').match(/[^<]+(?=(< >)|>$)/g);
		let emailsTo = document.getElementById('txtEmailTo').value.split(';');
		let emailsAdd = document.getElementById('emailAdd').value.split(';');
		let emailsCC = document.getElementById('emailCC').value.split(';');
		let emailsBCC = document.getElementById('emailBCC').value.split(';');
		let subject = document.getElementById('txtSubject').value;
		let message = component.get("v.myMessage");
		let validationPassed = true;

		if (!email || !email[0]) {

			helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), $A.get('$Label.c.Send_Email_No_From_Address_Error'), 'sticky');
			validationPassed = false;
		}
		if (!emailsTo) {

			helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), $A.get('$Label.c.Send_Email_No_To_Address_Error'), 'sticky');
			validationPassed = false;
		}
		if (!helper.validateEmails(email) || !helper.validateEmails(emailsTo) || !helper.validateEmails(emailsAdd) || !helper.validateEmails(emailsCC) || !helper.validateEmails(emailsBCC)) {

			helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), $A.get('$Label.c.Send_Email_Non_Valid_Email_Error'), 'sticky');
			validationPassed = false;
		} else if (subject == '') {

			helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), $A.get('$Label.c.Send_Email_No_Subject_Error'), 'sticky');
			validationPassed = false;
		} else if (message == '') {

			helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), $A.get('$Label.c.Send_Email_No_Message_Error'), 'sticky');
			validationPassed = false;
		}

		if (validationPassed) {

			helper.sendEmail(component, event, helper, email, emailsTo, emailsAdd, emailsCC, emailsBCC, subject, message);
		}


	},

	showSpinner: function(component, event, helper) {
		component.set("v.Spinner", true);
	},

	hideSpinner: function(component, event, helper) {
		component.set("v.Spinner", false);
	},

	toOpenAttachments: function(component, event, helper) {

	},

	cancel: function(component, event, helper) {
		helper.closeTab(component, helper);
	},

	addRecipient: function(component, event, helper) {

		let eventSource = event.getSource();
		let name = eventSource.get('v.name');
		let selectedValue = eventSource.get('v.value');
		let inputField;
		switch (name) {
			case 'contactEmailPicklistAdd':
				inputField = document.getElementById('emailAdd');
				break;
			case 'contactEmailPicklistCC':
				inputField = document.getElementById('emailCC');
				break;
			case 'contactEmailPicklistBCC':
				inputField = document.getElementById('emailBCC');
				break;
			default:

		}
		if (selectedValue !== 'None') {
			if (!inputField.value) {

				inputField.value = selectedValue;
			} else {

				if (inputField.value[inputField.value.length - 1] !== ';') {

					inputField.value = inputField.value + '; ' + selectedValue;
				} else {

					inputField.value = inputField.value + ' ' + selectedValue;
				}
			}
		}
		eventSource.set('v.value', 'None');

	},

	handleUploadFinished: function(component, event, helper) {

	}


})