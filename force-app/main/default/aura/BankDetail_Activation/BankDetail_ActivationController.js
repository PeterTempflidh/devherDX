/**
 * Created by c.kumari on 25.09.2019.
 */
({
    handleSaveRecord : function(component, event, helper) {
        var nameFieldValue = component.find("statusField").set("v.value", "Active");
    },

    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        title : 'Success Message',
        message: $A.get("$Label.c.Bank_Activation_Success_Message"),
        type: 'success',
        });
        toastEvent.fire();
    }
})