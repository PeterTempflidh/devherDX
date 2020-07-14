({
	getDestination: function(component, event, helper) {

		let recordId = component.get('v.recordId');
		let action = component.get('c.getDestination');
		action.setParams({
			'recordId': recordId
		});
		action.setCallback(this, function(response) {
			let state = response.getState();
			if (state === 'SUCCESS') {

				let destination = response.getReturnValue();
				if (!destination) {

					helper.showToast('error', 'Error!', $A.get('$Label.c.Send_Email_Button_URL_Error'), 'sticky');
				}
				let parsedDestination = JSON.parse(destination);
				switch (parsedDestination['type']) {
					case 'standard__component':
						if (parsedDestination['state']['recordId']) {

							parsedDestination['state']['recordId'] = recordId;

						}
						break;
					default:
						helper.showToast('error', 'Error!', $A.get('$Label.c.Send_Email_Button_URL_Error'), 'sticky');
				}
				component.set('v.destination', parsedDestination);
			} else {

				helper.showToast('error', 'Error!', $A.get('$Label.c.Send_Email_Button_URL_Error'), 'sticky');
			}
		});
		$A.enqueueAction(action);

	},
	showToast: function(type, title, message, mode) {

		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			'type': type,
			'title': title,
			'message': message,
			'mode': mode
		});
		toastEvent.fire();
	}
})