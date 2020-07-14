({
    init: function (component, event, helper)  {
        var action = component.get("c.isCloseCaseButtonDisabled");
        action.setParams({ caseIdString : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.btnDisabled', response.getReturnValue());
            } else {
                helper.handleCallbackError(response);
                console.log(state, response);
            }
        });

        $A.enqueueAction(action);
    },

    undoCompleteJs: function(component, event, helper)  {
    	var caseId = component.get("v.recordId");

        var action = component.get("c.undoComplete");
        action.setParams({ caseIdString : caseId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());

                if($A.get('e.force:refreshView')) {
                    $A.get('e.force:refreshView').fire();
                }

                component.set('v.btnDisabled', status == 'Closed');
            } else {
                helper.handleCallbackError(response);
                console.log(state, response);
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
        } else {
            console.log(eventParams.changeType, status);
        }
    }
})