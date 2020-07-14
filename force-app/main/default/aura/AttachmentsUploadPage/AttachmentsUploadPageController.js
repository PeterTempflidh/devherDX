({
    init : function(cmp, event, helper){
        
        if(cmp.get("v.openAtt")){
            helper.openModal(cmp, event);
        }
    },

    openModal: function(cmp, event, helper) {
        helper.openModal(cmp, event);
    },
  
    closeModal: function(cmp, event, helper) {
        cmp.set("v.files", []); 
        cmp.set("v.listTypes", []);
        cmp.set("v.isOpen", false);
        let compEvent = cmp.getEvent("EventCloseAttachmentsUpload");
    	compEvent.fire();
    },

    handleFilesChange: function(cmp, event, helper) {

        let lstFiles = cmp.get("v.files");
        let fileName = '';
        let docId = '';

        let mapOfTypes = cmp.get("v.mapOfTypes");

        //for fileupload
        let files = event.getParam("files");
        
        let workspaceAPI = cmp.find("workspace");
        let tabId = '';
        let disabled;
        if(files.length > 0){
            workspaceAPI.isConsoleNavigation().then(function(response){
                if(response){
                    workspaceAPI.getFocusedTabInfo().then(function(response){
                    tabId = response.tabId;
                    disabled = true;
                    workspaceAPI.disableTabClose({tabId, disabled});
                    });
                }
            });
        }else{
            workspaceAPI.isConsoleNavigation().then(function(response){
                if(response){
                    workspaceAPI.getFocusedTabInfo().then(function(response){
                    tabId = response.tabId;
                    disabled = false;
                    workspaceAPI.disableTabClose({tabId, disabled});
                    });
                }
            });
        }

        let numberOfFiles = mapOfTypes.length+files.length;
        let numberOfMaptypes = mapOfTypes.length;
        
            for(let i = numberOfMaptypes; i < numberOfFiles; i++){
                    mapOfTypes[i] = {"docId" : null,
                                            "lstAtt" : null,
                                            "halalDate" : null,
                                            "halalBolean" : null,
                                            "name" : null
                                            };
            }
            

        if (files.length > 0) {
            for(let i=0; i< files.length; i++){
                fileName = files[i]['name'];
                docId = files[i]['documentId'];
                lstFiles.push(files[i]);
                let x = numberOfMaptypes + i;
                mapOfTypes[x].name = fileName;
                mapOfTypes[x].docId = docId;
            }
        } 
        cmp.set("v.files", lstFiles);
        cmp.set("v.mapOfTypes", mapOfTypes);
        
        helper.checkBackdrop(cmp, event);
    },

    attTypeChange : function(cmp, event, helper){
 
        let listTypes = cmp.get("v.listTypes");
        let mapOfTypes = cmp.get("v.mapOfTypes");
        let files = cmp.get("v.files");
        
        let attTypes = event.getSource().get("v.value"); 
        let rowIndex = event.getSource().get("v.name");

        let lstAttTypes = [...attTypes];
        let halal = lstAttTypes.includes("Halal Certification");
        let docId = files[rowIndex].documentId;


        listTypes[rowIndex] = halal;
        let halalDate = mapOfTypes[rowIndex].halalDate;
        mapOfTypes[rowIndex].docId = docId;
        mapOfTypes[rowIndex].lstAtt = lstAttTypes;
        mapOfTypes[rowIndex].halalDate = halalDate;
        mapOfTypes[rowIndex].halalBolean = halal;

        cmp.set("v.listTypes", listTypes);
        cmp.set("v.mapOfTypes", mapOfTypes);

        for(let i=0; i<mapOfTypes.length;i++){
            if(mapOfTypes[i].halalBolean){
                cmp.set("v.halalHeader", true);
                break;
            }
        }
    },

    halalDateChange : function(cmp, event, helper){
        
        let rowIndex = event.getSource().get("v.name");
        let mapOfTypes = cmp.get("v.mapOfTypes");
        let halalDate = event.getSource().get("v.value"); 

        mapOfTypes[rowIndex].halalDate = halalDate;

        cmp.set("v.mapOfTypes", mapOfTypes);   
    },

   uploadFiles: function(cmp, event, helper) {
    let spinner = cmp.find("spinner");
    $A.util.removeClass(spinner, "slds-hide");

    let openAtt = cmp.get("v.openAtt");
    let recordId = cmp.get("v.recordId");
    let files = cmp.get("v.files");
    let listOfFilesIds = [];
    let mapOfTypesToString = cmp.get("v.mapOfTypes");

        for(let i=0; i<mapOfTypesToString.length;i++){
            if(mapOfTypesToString[i].lstAtt == null || mapOfTypesToString[i].lstAtt == '' || 
                (mapOfTypesToString[i].halalBolean == true && (mapOfTypesToString[i].halalDate == null || mapOfTypesToString[i].halalDate == ''))){
        
                $A.util.addClass(spinner, "slds-hide");
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": $A.get("{!$Label.c.File_Upload_Validation_Error}")
                });
                toastEvent.fire();
                return cmp;
            }
        }
        
    let mapOfTypes = JSON.stringify(mapOfTypesToString);

    for(let i=0; i < files.length; i ++){
        listOfFilesIds.push(files[i].documentId);
    }

    let action = cmp.get("c.saveFile");
    action.setParams({
        parentId : recordId,
        contentDocIds : listOfFilesIds,
        mapOfTypes : mapOfTypes
     });

     action.setCallback(this, function(response){
        let state = response.getState();
        let appEvent = $A.get("e.c:EventUpdateAttachmentsComp");
        appEvent.fire();

        if(state === "SUCCESS"){
            cmp.set("v.files", []); 
            cmp.set("v.listTypes", []);
            cmp.set("v.mapOfTypes", []);
            cmp.set("v.isOpen", false);
            $A.util.addClass(spinner, "slds-hide");

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
                            $A.util.addClass(spinner, "slds-hide");
                        }
                        });
                    }else{
                        $A.util.addClass(spinner, "slds-hide");
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

                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": $A.get("{!$Label.c.File_Upload_Success_Message}")
                });
                
                toastEvent.fire();
                cmp.set("v.isOpen", true);
        }else{
            $A.util.addClass(spinner, "slds-hide");
        }
     });
     $A.enqueueAction(action); 
     
    },
 
    closeFileUpload : function(cmp, event, helper){
        let spinner = cmp.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");

        let mapOfTypes = cmp.get("v.mapOfTypes");
        if(mapOfTypes.length){ 
            helper.deleteAllFiles(cmp, event);
        }else{
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
                        $A.util.addClass(spinner, "slds-hide");
                        $A.util.addClass(backDrop, "slds-hide");
                    }else{
                        $A.util.addClass(spinner, "slds-hide");
                        $A.util.addClass(backDrop, "slds-hide");
                        let compEvent = cmp.getEvent("EventCloseAttachmentsUpload");
                        compEvent.fire();
                    }
                }
            });
            window.scrollTo('top',0,0);
        }
    },

    removeFile : function(cmp, event, helper){
        let backDrop = cmp.find("v.backDrop");
        let spinner = cmp.get("v.spinner");
        $A.util.removeClass(spinner, "slds-hide");
        let rowIndex = event.getSource().get("v.name");
        let mapOfTypes = cmp.get("v.mapOfTypes");
        let docIds = [mapOfTypes[rowIndex].docId];

        let removeFile = cmp.get("c.deleteFile");
        removeFile.setParams({docIds : docIds});
        
        removeFile.setCallback(this, function(response){
            let state = response.getState();
            $A.util.addClass(spinner, "slds-hide");
            if(state === "SUCCESS"){
                mapOfTypes.splice(rowIndex,1);
                cmp.set("v.mapOfTypes", mapOfTypes);
                if(mapOfTypes.length == 0){

                    let workspaceAPI = cmp.find("workspace");
                    let tabId = '';
                    let disabled = false;
                    workspaceAPI.isConsoleNavigation().then(function(response){
                        if(response){
                            workspaceAPI.getFocusedTabInfo().then(function(response){
                            tabId = response.tabId;
                            workspaceAPI.disableTabClose({tabId, disabled});
                            });
                        }
                    });
                }

                for(let i=0; i<mapOfTypes.length;i++){
                    if(mapOfTypes[i].halalBolean){
                        cmp.set("v.halalHeader", true);
                        break;
                    }
                }
                helper.checkBackdrop(cmp, event);
                window.scrollTo('top',0,0);
            }else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
                $A.util.addClass(backDrop, "slds-hide");
            }else{
                $A.util.addClass(backDrop, "slds-hide");
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(removeFile);
    }
 })