({
	getBusinessConfigData: function(component, event, helper) {
		let businessRuleName = component.get('v.businessRuleProcessName');
		let recordId = component.get('v.recordId');
		let sObjectName = component.get('v.sObjectName')
		if (!businessRuleName) {

			helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Missing_Process_Name_Message'), 'error', 'sticky');
		}
		if (!recordId) {

			helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Missing_Id_Message'), 'error', 'sticky');
		}
		if (!sObjectName) {

			helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Missing_Object_API_Name_Message'), 'error', 'sticky');
		}
		let action = component.get('c.getDataFromBusinessConfig');
		action.setParams({
			'businessRuleName': businessRuleName,
			'recordId': recordId,
			'sObjectName': sObjectName
		});

		action.setCallback(this, function(response) {
			let state = response.getState();
			if (state === 'SUCCESS') {

				let result = JSON.parse(response.getReturnValue());
				if (!result['picklistData'] || !result['picklistCustomLabel'] || !result['messageTitleCustomLabel'] || !result['messageSeverity'] ||
					!result['messageBodyCustomLabel'] || !result['fieldToUpdate'] || !result['fieldToDisplay']) {

					helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Bad_Business_Config_Bad_Message'), 'error', 'sticky');
				} else if (result['error']) {

					helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), result['error'], 'error', 'sticky');
				} else {

					component.set('v.picklistData', result['picklistData']);
					if (result['currentValue']) {

						component.set('v.picklistValue', result['currentValue']);
					}
					component.set('v.picklistCustomLabel', $A.getReference('$Label.c.' + result['picklistCustomLabel']));
					component.set('v.messageTitleCustomLabel', $A.getReference('$Label.c.' + result['messageTitleCustomLabel']));
					component.set('v.messageSeverity', result['messageSeverity']);
					component.set('v.messageBodyCustomLabel', $A.getReference('$Label.c.' + result['messageBodyCustomLabel']));
					if ("isPleaseSelectOptionDisplayed" in result) {

						component.set('v.isPleaseSelectOptionDisplayed', result['isPleaseSelectOptionDisplayed']);
					}
					if ("isNoneOptionDisplayed" in result) {

						component.set('v.isNoneOptionDisplayed', result['isNoneOptionDisplayed']);
					}
					if ("isMessageDisplayed" in result) {

						component.set('v.isMessageDisplayed', result['isMessageDisplayed']);
					}
					component.set('v.fieldToUpdate', result['fieldToUpdate']);
					component.set('v.fieldToDisplay', result['fieldToDisplay']);
				}

			} else if (state === 'INCOMPLETE') {
				helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Server_Error_Message'), 'error', 'sticky');
			} else if (state === 'ERROR') {
				helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Server_Error_Message'), 'error', 'sticky');
			}
		});
		$A.enqueueAction(action);
	},

	showMessage: function(component, title, message, type, mode) {

		component.find('notificationsLibrary').showToast({
			'title': title,
			'message': message,
			'type': type,
			'mode': mode,
		});
	},

	saveSelectedValue: function(component, event, helper) {

		let picklistValue = component.get('v.picklistValue');
		if (picklistValue !== 'pleaseSelect') {

			let fieldToUpdate = component.get('v.fieldToUpdate');
			let recordId = component.get('v.recordId');
			let sObjectName = component.get('v.sObjectName');
			let action = component.get('c.saveSelectedValue');
			action.setParams({
				'picklistValue': picklistValue,
				'fieldToUpdate': fieldToUpdate,
				'recordId': recordId,
				'sObjectName': sObjectName
			});
			action.setCallback(this, function(response) {
				let state = response.getState();
				if (state === 'SUCCESS') {
					let result = response.getReturnValue();
					if (result == 'OK') {

						helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Success_Label'), $A.get('$Label.c.Custom_Picklist_Success_Message'), 'success', 'sticky');
					} else {

						helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Update_Fail_Error_Message'), 'error', 'sticky');
					}
				} else if (state === 'INCOMPLETE') {
					helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Update_Fail_Error_Message'), 'error', 'sticky');
				} else if (state === 'ERROR') {
					helper.showMessage(component, $A.get('$Label.c.Custom_Picklist_Server_Error_Title'), $A.get('$Label.c.Custom_Picklist_Update_Fail_Error_Message'), 'error', 'sticky');
				}
			});
			$A.enqueueAction(action);
		}
	}
})