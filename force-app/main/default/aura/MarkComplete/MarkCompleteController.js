({
    toggleSpinner : function(component,event,helper){
        // hide when aura:downwaiting
        //component.set("v.toggleSpinner", false);
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    },
    
    init: function (component, event, helper)  {
        var action = component.get("c.isCloseCaseButtonDisabled");
        action.setParams({ caseIdString : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.btnDisabled', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                helper.handleCallbackError(response);
            }
        });

        $A.enqueueAction(action);
    },
    
    markCompleteJs: function(component, event, helper)  {
    	var caseId = component.get("v.recordId");

        var action = component.get("c.markComplete");
        action.setParams({ caseIdString : caseId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());
                
                // SP-3399
                // console.log('retValue'+JSON.stringify(retValue));
                if(!retValue.Success){
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error: ",
                        "message": retValue.UserMessage,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                
                if($A.get('e.force:refreshView')) {
                    $A.get('e.force:refreshView').fire();
                }
                
                component.set('v.btnDisabled', status == 'Closed');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                helper.handleCallbackError(response);
            }
        });

        $A.enqueueAction(action);
    },
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        var status = component.get("v.record.fields.Status.value");

        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            component.set('v.btnDisabled', status == 'Closed');
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})