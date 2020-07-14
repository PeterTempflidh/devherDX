({
    onInit : function(component, e, helper) {
        component.set("v.oneViewUrl",'');
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
        var action = component.get("c.getOneViewUrl");
        action.setParams({
            chatRecId : component.get("v.recordId"),
            iFrameUrl : component.get("v.iframeUrl")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = response.getReturnValue();
                component.set("v.oneViewUrl",retValue);
            }else if (state === "ERROR") {
                helper.handleCallbackError(response);
            }
            $A.util.toggleClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action); 
    }
})