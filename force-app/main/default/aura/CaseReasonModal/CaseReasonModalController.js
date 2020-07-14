({
    onInit : function(component, e, helper) {
        component.set("v.modalTitle", "Loading data...");

        var action = component.get("c.getCaseFromChat");
        action.setParams({ 
            objrecId : component.get("v.recordId"),
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());

                if(retValue.Success) {
                    console.log('Modal dialog retValue');
                    component.set("v.lookupRecordId", retValue.Id);
                } else {
                    component.set("v.lookupRecordId", component.get("v.recordId"));
                }

                var usesLookup = component.get("v.lookupRecordId") != component.get("v.recordId") && component.get("v.lookupRecordId") != null;
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                helper.handleCallbackError(response);
                component.set("v.lookupRecordId", component.get("v.recordId"));
            }
        });
        $A.enqueueAction(action);
    }  
   
})