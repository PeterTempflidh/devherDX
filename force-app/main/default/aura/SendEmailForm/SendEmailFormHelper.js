({
	sendEmail: function(component, event, helper, email, emailsTo, emailsAdd, emailsCC, emailsBCC, subject, message) {

		let action = component.get('c.processEmail');
		let config = component.get('v.config');
		let attachmentIds = Object.keys(config['mandatoryAttachments']);
		message = helper.addLogoAndIcons(component, helper, message);
		let datapack = {
			'email': email,
			'emailsTo': emailsTo,
			'emailsAdd': emailsAdd,
			'emailsCC': emailsCC,
			'emailsBCC': emailsBCC,
			'subject': subject,
			'message': message,
			'attachmentIds': attachmentIds,
			'recordId': component.get('v.recordId')
		};
		action.setParams({
			'emailDatapack': JSON.stringify(datapack)
		});
		action.setCallback(this, function(e) {
			if (e.getState() == 'SUCCESS') {
				let result = e.getReturnValue();
				if (result == 'Success') {

					helper.showToast(component, 'success', $A.get('$Label.c.Send_Email_Success_Title'), $A.get('$Label.c.Send_Email_Success_Message'), 'sticky');
					helper.closeTab(component, helper);
				} else if (result == 'missingBusinessConfig') {

					helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), result, 'sticky');
					helper.closeTab(component, helper);
				} else {

					helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), result, 'sticky');
				}
			} else {
				alert(JSON.stringify(e.getError()));
			}
		});
		$A.enqueueAction(action);
	},

	getUrlParameter: function(sParam) {
		let sPageURL = decodeURIComponent(window.location.search.substring(1)),
			sURLletiables = sPageURL.split('&'),
			sParameterName,
			i;

		for (i = 0; i < sURLletiables.length; i++) {
			sParameterName = sURLletiables[i].split('=');

			if (sParameterName[0] === sParam) {
				return sParameterName[1] === undefined ? true : sParameterName[1];
			}
		}
	},

	getConfigParams: function(component, event, helper) {

		let recordId = component.get('v.recordId');
		if (recordId) {
			let action = component.get('c.getConfigParams');
			action.setParams({
				recordId: recordId
			})
			action.setCallback(this, function(e) {
				if (e.getState() == 'SUCCESS') {

					if (e.getReturnValue() == 'missingBusinessConfig') {

						helper.showToast(component, 'error','Error', $A.get('$Label.c.Custom_Picklist_No_Business_Config_Error_Message'), 'sticky');
						helper.closeTab(component, helper);
                        return; 
					}
					let result = JSON.parse(e.getReturnValue());
					component.set('v.config', result);
					if (!result['listOfEmails']) {

						component.set('v.contactEmailsPresented', false);
					} else {

						component.set('v.emailsFromContactRecords', result['listOfEmails']);
					}
					component.set('v.subject', result['emailSubject']);
					helper.handleAndUpdateEmailTemplate(component, helper, result['emailTemplate']);
					component.set('v.primaryContactEmail', result['primaryContactEmail']);
					component.set('v.recordName', result['recordName']);
					component.set('v.validFromEmails', result['validFromEmails']);
					component.set('v.selectedValueFrom', result['validFromEmails'][0]);
					let mandatoryAttachments = [];
					let counter = 1;
					Object.keys(result['mandatoryAttachments']).forEach(function(key) {
						let attachment = {};
						attachment['Name'] = result['mandatoryAttachments'][key];
						if (key.substring(0, 3) == '068') {

							let splittedId = key.split('-');
							attachment['Id'] = splittedId[0];
							attachment['Url'] = '/sfc/servlet.shepherd/version/download/' + splittedId[0];
						} else {

							attachment['Id'] = key;
							attachment['Url'] = '/servlet/servlet.FileDownload?file=' + key;
						}
						mandatoryAttachments.push(attachment);
					});
					component.set('v.mandatoryAttachments', mandatoryAttachments);

				} else {
					helper.showToast(component, 'error', $A.get('$Label.c.Send_Email_Error_Title'), $A.get('$Label.c.Send_Email_Config_Error'), 'sticky');
				}
			});
			$A.enqueueAction(action);
		}
	},

	showToast: function(component, type, title, message, mode) {

		let alertTheme = "";
		let toastEvent = $A.get('e.force:showToast');

		if(toastEvent){
			toastEvent.setParams({
				'type': type,
				'title': title,
				'message': message,
				'mode': mode
			});
			toastEvent.fire();
		} else {
			if(type == "error"){
				alertTheme = "slds-theme--error"
			} else if(type == "success"){
				alertTheme = "slds-theme--success"
			}
			component.set("v.theme", alertTheme);
			component.set("v.alertMessage", message);
		}
	},

	validateEmails: function(emails) {

		if (!emails) {

			return true;
		}
		let regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
		for (let i = 0; i < emails.length; i++) {

			emails[i] = emails[i].trim();
			if (!emails[i].match(regExpEmailformat) && emails[i]) {

				return false;
			}
		}
		return true;
	},

	closeTab: function(component, helper) {

		let workspaceAPI = component.find('workspace');
		workspaceAPI.closeTab({
			'tabId': component.get('v.tabId')
		});

		component.set("v.isSendEmail", false);
	},

	handleAndUpdateEmailTemplate: function(component, helper, template) {

		let logoMatches = template.match(/<div\s+id=”logotoinsert”>[\S\s]*?<\/div>/gi);
		let templateWithCutOffImages = template;
		if (logoMatches) {

			component.set('v.messageLogo', logoMatches[0]);
			template = template.replace(/<div\s+id=”logotoinsert”>[\S\s]*?<\/div>/gi, '');
		}
		let iconsMatches = template.match(/<div\s+id=”iconstoinsert”>[\S\s]*?<\/div>/gi);
		if (iconsMatches) {

			component.set('v.messageIcons', iconsMatches[0]);
			template = template.replace(/<div\s+id=”iconstoinsert”>[\S\s]*?<\/div>/gi, '');
		}
		component.set('v.myMessage', template);
	},

	addLogoAndIcons: function(component, helper, message) {

		return component.get('v.messageLogo') + message + component.get('v.messageIcons');
	}
})