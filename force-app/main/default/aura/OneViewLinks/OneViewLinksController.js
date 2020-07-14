({
    onInit : function(component, event, helper) {
        helper.getCaseDetails(component,event,helper);
		helper.getPandoraPlatforms(component);
    },

    openOrderSubTab: function(component,event,helper){
        helper.openSubtab(component,component.get("v.orderNumberURL"),$A.get("{!$Label.c.Order_Details}"),'standard:order');
    },

    openCustomerSubTab: function(component,event,helper){
        helper.openSubtab(component,component.get("v.customerIdURL"),$A.get("{!$Label.c.Customer_Details}"),'standard:customer');
    }
})