({
    OpenChildComponent : function(c, e, h) {
        c.set("v.ModalBoxCmp" , true);
    },

    closeDlPopup: function (c, e, h) {
        c.set("v.ModalBoxCmp", false);
    },
    
    terminateRestaurantJs : function(component, event, helper)  {
        var recordId = component.get("v.recordId");
        var newPage = component.get("v.showNewPage");

        var action = component.get("c.terminateRestaurant");
        action.setParams({ accountId : recordId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());

                if(retValue.Success == true) {
                    component.set("v.ModalBoxCmp", false);
                    helper.openTab(component, recordId, newPage);
                } else {
                    component.set("v.userMessage", retValue.UserMessage);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                        errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
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
            component.set('v.btnDisabled', status == 'Closed');
        } else if(eventParams.changeType === "CHANGED") {
            component.set('v.btnDisabled', status == 'Closed');
            component.set('v.btnLabel', status == 'Closed' ? 'Case Closed' : 'Close Case');
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})