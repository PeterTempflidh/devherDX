({
    takeOwnershipJs : function(component, event, helper) {
        var caseId = component.get("v.recordId");

        var action = component.get("c.takeOwnership");
        action.setParams({ caseIdString : caseId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());

                if(retValue.Success) {
                    component.find('notificationsLibrary').showToast( {
                        "message": $A.get("{!$Label.c.Case_Take_Ownership_Success}"),
                        "variant": "success"
                    });
                }
                else {
                    component.find('notificationsLibrary').showToast( {
                        "message": $A.get("{!$Label.c.Case_Take_Ownership_Error}"),
                        "variant": "error"
                    });
                }

                if($A.get('e.force:refreshView')) {
                    $A.get('e.force:refreshView').fire();
                }

                component.set('v.btnDisabled', true);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                component.find('notificationsLibrary').showToast( {
                    "message": $A.get("{!$Label.c.Case_Take_Ownership_Error}"),
                    "variant": "error"
                });
                helper.handleCallbackError(response);
            }
        });
        $A.enqueueAction(action);
    },

    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            //component.set('v.btnDisabled', ownerId == userId);
        } else if(eventParams.changeType === "CHANGED") {
            //component.set('v.btnDisabled', ownerId == userId);
            //component.set('v.btnLabel', status == 'Closed' ? 'Case Closed' : 'Close Case');
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})