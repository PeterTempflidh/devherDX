({
    
    newCallCaseJs : function(component, event, helper)  {
    	var recordId = component.get("v.recordId");

        console.log('Account Id: ' + recordId);

        var action = component.get("c.newCallCase");
        action.setParams({ accountId : recordId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());
                
                if($A.get('e.force:refreshView')) {
                    $A.get('e.force:refreshView').fire();
                }

                component.find("notificationsLibrary").showToast({
                    "title": "Case Created",
                    "message": retValue.UserMessage
                });
                helper.openTab(component, retValue.Id);
                // else
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                helper.handleCallbackError(response);
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        var status = component.get("v.record.fields.Status.value");

        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            console.log("Record removed");
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            console.log("Record error");
            // there’s an error while loading, saving, or deleting the record
        }
    }
})