({
	 getRecordDetails : function(component,event,helper){
        var action = component.get("c.getCurrentRecord");

         action.setParams({
        	caseId : component.get("v.recordId")
    	});

        action.setCallback(this,function(response){
            console.log("method call");
            var state = response.getState();
            if(state === "SUCCESS"){
            	var caseData = response.getReturnValue();
                if(caseData!=null && caseData!=undefined){
                	var recordType = caseData.RecordTypeId;
                    component.set("v.recordTypeId",recordType);
                    if(caseData.OwnerId.startsWith("00G")){
                        component.set("v.isQueueError",true);
                    } else {
                        component.set("v.isQueueError",false);
                    }
                    if(caseData.Status == 'Closed'){
                    	component.set("v.disabled",true);
                    } else {
                        component.set("v.disabled",false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    getCloseCase : function(component,event,helper){
        var caseId = component.get("v.recordId");
        var caseCloReason = component.get("v.myClosedReason");
        var caseRotCause = component.get("v.myRootCause");
        if (caseCloReason == "" || caseCloReason == null) {
            component.find('notificationsLibrary').showToast ({
                "title": 'Case Closed',
                "message": $A.get("{!$Label.c.Closed_Reason_mandatory}"),
                "variant": "error"
            });
        } else {
            var action = component.get("c.closeCase");
        	action.setParams({ caseIdString : caseId, caseClosedReason : caseCloReason, caseRootCause : caseRotCause});

        	action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS" || state == null) {
                    var retValue = JSON.parse(response.getReturnValue());
                	if(retValue.Success) {
                        component.find('notificationsLibrary').showToast( {
                            "message": $A.get("{!$Label.c.Case_closed}"),
                            "variant": "success"
                        });
                    }
                    else {
                        component.find('notificationsLibrary').showToast( {
                            "message": retValue.UserMessage,
                            "variant": "error",
                            "mode":"sticky"
                        });
                    }
                    component.set('v.btnDisabled', true);
                	$A.get('e.force:refreshView').fire();
                } else { // If unsuccessful, display error message to the user
                    component.set("v.isError", true);
                }
            });
        	$A.enqueueAction(action);
        }
    }
})