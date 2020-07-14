({
    onInit : function(component,event,helper){
        var action = component.get("c.isCaseClosed");
        action.setParams({ recId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            if(response.getState()!='SUCCESS'){
                return;
            }
            //Do not close tab if the case is already resolved/closed
            if(response.getReturnValue()=='Resolved' || response.getReturnValue()=='Closed'){
                return;
            }
            var workspaceAPI = component.find("workspace");
            //Check if the opened subtab is a case
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                if(!response.isSubtab && response.pageReference.attributes.objectApiName=='Case'){
                    helper.callCheckCaseStatus(component,helper);
                    helper.setWindowInterval(component,event,helper);
                }
            })
            .catch(function(error) {
                console.log(error);
            });
        });
        $A.enqueueAction(action);
    },

    //Called only when the chat has ended
    onChatEnded : function(component, event, helper) {
        var conversation = component.find('conversationKit');
        var recordId = component.get("v.recordId");
        conversation.getChatLog({
            recordId: recordId
        })
        .then(function(result){
            if (result) {
                    helper.sendSurvey(component,event,helper,result);
                } else {
                    /* eslint no-console: ["error", { allow: ["warn", "error"] }] */
                    console.error("Failed to retrieve chat log");
                }
        });
        helper.callCheckCaseStatus(component,helper);
        if(!component.get("v.closeTab")){
            helper.setWindowInterval(component,event,helper);
        }
    },
    onTabClosed : function(component, event, helper) {
        //Remove interval if the tab is closed
        window.clearInterval(component.get("v.intervalId"));
    }
});