({
    setWindowInterval : function(component, event, helper){
        //set interval of every 5 seconds to check if the case status is resolved.
        var id=window.setInterval(
            $A.getCallback(function() {
                component.set("v.intervalId",id);
                if(component.get("v.closeTab")!=undefined && !component.get("v.closeTab")){
                    helper.callCheckCaseStatus(component,helper,id);
                }
                else{
                    window.clearInterval(id);
                }
            }), 5000
        );
    },
    callCheckCaseStatus:function(component,helper,id){
        var action = component.get("c.isCaseClosed");
        action.setParams({ recId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()=='Resolved'||response.getReturnValue()=='Closed'){
                    component.set("v.closeTab",true);
                    if(id!=undefined){
                        window.clearInterval(id);
                    }
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        if(!response.isSubtab){
                            workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
                                workspaceAPI.closeTab({
                                    tabId: enclosingTabId
                                });
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        }
                    })
                 }
             }
        });
        $A.enqueueAction(action);
    },
    sendSurvey: function(component,event,helper,result){
        //Trigger action only if the chat is greater than 30 secs and has a response from the visitor
        var firstVisitorMessageTime;
        for(var i=0;i<result.messages.length;i++){
            if(result.messages[i].type=='EndUser'){
                firstVisitorMessageTime=result.messages[i].timestamp;
                break;
            }
        }
        if((result.messages[result.messages.length-1].timestamp) - firstVisitorMessageTime>29000){
            var action = component.get("c.sendSurvey");
            action.setParams({ recId : component.get("v.recordId")});
            action.setCallback(this, function(response) {
                /* eslint no-console: ["error", { allow: ["warn", "error"] }] */
                if(response.getReturnValue()!=='Success'){
                    console.error('Error occurred: ',response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    }
});