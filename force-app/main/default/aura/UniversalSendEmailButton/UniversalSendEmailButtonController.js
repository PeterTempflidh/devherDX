({
	doInit: function(component, event, helper) {

		helper.getDestination(component, event, helper);
	},

	navigateToDestination: function(component, event, helper) {
		//Logic to refresh quote tab on email tab close
		var p = component.get("v.parent");
		p.refreshMethod();
		
		let navService = component.find('navService');
		let destination = component.get('v.destination');
		switch (destination['type']) {
			case 'standard__component':
				destination['state']['c__recordId'] = component.get('v.recordId');
				break;
			default:
				// code block
		}
		event.preventDefault();
		navService.navigate(destination);
	}
})
