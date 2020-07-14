({
    openModal: function(cmp, event, helper) {

        let action = cmp.get("c.getAttTypePicklistValues");
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let resp = response.getReturnValue();
                let lstOptions = [];
                for(let i=0; i < resp.length; i++){
                    lstOptions.push({label: resp[i], value: resp[i]});
                }
                cmp.set("v.attTypes", lstOptions);
            }
        });
        $A.enqueueAction(action);
        cmp.set("v.isOpen", true);
        window.scrollTo('top',0,0);
    },

    checkBackdrop : function(cmp, event){
        let workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response){
            if(response){
            }else{
                let backDrop = cmp.find("backdrop");
                let mapOfTypes = cmp.get("v.mapOfTypes");
                if(mapOfTypes.length > 0){
                    $A.util.removeClass(backDrop, "slds-hide");
                }else{
                    $A.util.addClass(backDrop, "slds-hide");
                }
            }
        });
    },

    deleteAllFiles : function(cmp, event){
        let spinner = cmp.find("spinner");
        let backdrop = cmp.find("backdrop");
        let mapOfTypes = cmp.get("v.mapOfTypes");
        let docIds = [];
        for(let i=0; i<mapOfTypes.length; i++){
            docIds.push(mapOfTypes[i].docId);
        }
        let deleteAllFiles = cmp.get("c.deleteFile");
        deleteAllFiles.setParams({docIds : docIds});
        
        deleteAllFiles.setCallback(this, function(response){
            let state = response.getState();
            $A.util.addClass(backdrop, "slds-hide");
            $A.util.addClass(spinner, "slds-hide");
            if(state === "SUCCESS"){
                mapOfTypes = [];
                cmp.set("v.mapOfTypes", mapOfTypes);

                let openAtt = cmp.get("v.openAtt");
                let workspaceAPI = cmp.find("workspace");
                let tabId = '';
                let disabled = false;
                workspaceAPI.isConsoleNavigation().then(function(response){
                    if(response){
                        workspaceAPI.getFocusedTabInfo().then(function(response){
                        tabId = response.tabId;
                        workspaceAPI.disableTabClose({tabId, disabled});
                        if(openAtt){
                            workspaceAPI.closeTab({tabId});
                        }else{
                            let compEvent = cmp.getEvent("EventCloseAttachmentsUpload");
                            compEvent.fire();
                        }
                        });
                    }else{
                        if(openAtt){
                            let sObjectType = cmp.get("v.object");
                            let recordId = cmp.get("v.recordId");
                            let pageReference = {
                                type: "standard__recordPage",
                                attributes: {
                                    recordId: recordId,
                                    objectApiName: sObjectType,
                                    actionName: "view"
                                }
                            };
                            cmp.find("navigate").navigate(pageReference);
                        }else{
                            let compEvent = cmp.getEvent("EventCloseAttachmentsUpload");
                            compEvent.fire();
                        }
                    }
                });
                window.scrollTo('top',0,0);
            }else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }else{
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(deleteAllFiles);
    }
})