({
    getLastCall: function(component,event,helper){
        var action=component.get("c.getTaskDetails");
        action.setParams({chatId: component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                    var taskRelationList='[';
                    component.set("v.task.Id",response.getReturnValue().Id);
                    component.set("v.task.Subject",response.getReturnValue().Subject);
                    component.set("v.task.Activity_Subject__c",response.getReturnValue().Activity_Subject__c);
                    component.set("v.task.Description",response.getReturnValue().Description);
                    if(response.getReturnValue().TaskRelations!=undefined && response.getReturnValue().TaskRelations.length>0){
                        for(var i=0; i<response.getReturnValue().TaskRelations.length; i++) {
                            var taskRelation=[];
                            taskRelation.id=response.getReturnValue().TaskRelations[i].RelationId;
                            taskRelation.context={"jidListName":"nullWhoIds"};
                            taskRelationList=taskRelationList+'{"id":"'+response.getReturnValue().TaskRelations[i].RelationId+'","context":{"jidListName":"nullWhoIds"}},';
                        }
                        taskRelationList=taskRelationList.substring(0,taskRelationList.length-1)+']';
                    }
                    component.set("v.taskTemp.WhoId",taskRelationList);
                }
            }
        });
        $A.enqueueAction(action);
    },
    saveRecord: function(component){
        var action=component.get("c.saveTask");
        action.setParams({chatId: component.get("v.recordId"),taskRec: component.get("v.task"),taskTemp: component.get("v.taskTemp")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().includes('Success')){
                    var taskId=[];
                    taskId=response.getReturnValue().split(':');
                    component.set("v.task.Id",taskId[1]);
                    component.find("notificationsLibrary").showToast({
                        title: "SUCCESS",
                        message : $A.get("{!$Label.c.Call_Logged_Successfully}"),
                        variant: "success"
                    });
                }
                else if(response.getReturnValue()=='No Case Present'){
                    component.find("notificationsLibrary").showToast({
                        title: "ERROR",
                        message : $A.get("{!$Label.c.Chat_No_Case_Present}"),
                        variant: "error"
                    });
                }
                else{
                    component.find("notificationsLibrary").showToast({
                        title: "ERROR",
                        message : $A.get("{!$Label.c.Call_Log_Error}"),
                        variant: "error"
                    });
                }
            }
            else{
                component.find("notificationsLibrary").showToast({
                    title: "ERROR",
                    message : $A.get("{!$Label.c.Call_Log_Error}"),
                    variant: "error"
                });
            }
            var spinner = component.find("loadingSpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            component.set("v.isSaving",false);
        });
        $A.enqueueAction(action);
    }
});