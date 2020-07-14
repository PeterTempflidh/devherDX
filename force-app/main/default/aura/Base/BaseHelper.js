({
    callServer: function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    //Displaying apex class errors 
                    component.set('v.theme', 'slds-theme--error');
                    component.set('v.recordError',JSON.stringify(errors));
                    component.set('v.showSpinner', false);
                    component.set('v.doShowButtons', false);
                    component.set('v.displayPdfViewer', false);
                    
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    isLightningExperience: function() {
        var toast = $A.get("e.force:showToast");
        if (toast){
            return true;
        } else {
            return false;
        }
    },
    
    showToast: function(component, title, message, type, mode) {
        if (this.isLightningExperience()) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type" : type,
                "mode" : mode
            });
            toastEvent.fire();
        }
    }
    
})
