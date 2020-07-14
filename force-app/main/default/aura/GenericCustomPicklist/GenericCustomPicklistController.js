({
	doInit: function(component, event, helper) {

		helper.getBusinessConfigData(component, event, helper);
	},

	saveValue: function(component, event, helper) {

		helper.saveSelectedValue(component, event, helper);
	}
})