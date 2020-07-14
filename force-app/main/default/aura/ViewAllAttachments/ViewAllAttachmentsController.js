({
    init : function(cmp, event, helper) {
 
        let spinner = cmp.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");

        const fieldmap = new Map([["title", "Title"],
        ["attachmenttype", "Attachment Type" ],
        ["formatteddate", "Last Modified"],
        ["createdby", "Created By"],
        ["contentsize", "Content Size"],
        ["fielextension", "Type"]]);
        cmp.set("v.fieldMap", fieldmap);

        let fetchAttachments = cmp.get("c.getAttachments");
        fetchAttachments.setParams({recordId : cmp.get("v.recordId")});
        
        fetchAttachments.setCallback(this, function(response){
            let state = response.getState();
            $A.util.addClass(spinner, "slds-hide");
            if(state === "SUCCESS"){
                let resp = response.getReturnValue();
                cmp.set("v.attachments", resp);
                cmp.set("v.numberOfAtt", resp.length);
                helper.sortData(cmp, resp, "formatteddate", "desc");
                
            }else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                }
            }else{
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(fetchAttachments);

        let workspaceAPI = cmp.find("workspace");
        let tabId = '';
        workspaceAPI.isConsoleNavigation().then(function(response){
            if(response){
                workspaceAPI.getFocusedTabInfo().then(function(response){
                tabId = response.tabId;
                });
            }
        });
        cmp.set("v.tabId", tabId);
        window.scrollTo('top',0,0);

    },

    viewList : function(cmp, event, helper){

        let sObjectType = cmp.get("v.sObjectType");

        let pageReference = {
            type: "standard__objectPage",
            attributes: {
                objectApiName: sObjectType,
                actionName: "list"
            }
        };
        cmp.find("navigate").navigate(pageReference);
    },

    viewRecord : function(cmp, event, helper){

        let sObjectType = cmp.get("v.sObjectType");
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
    },

    previewFile : function(cmp, event, helper){
        let target = event.currentTarget.getAttribute("data-Id");
        let type = event.currentTarget.getAttribute("data-Type");
        
        if(type == 'Attachment'){
            let pageReference =
            {    
                "type": "standard__recordPage",
                "attributes": {
                    recordId: target,
                    objectApiName: "Attachment",
                    actionName: "view"
                }
            }
        cmp.find("navigate").navigate(pageReference);
        }else{        
            $A.get('e.lightning:openFiles').fire({
            recordIds: [target]
            });
        }
    },

    handleSort : function(cmp,event,helper){

        let sortDir = cmp.get("v.sortDir");
        let sortField = cmp.get("v.sortField");
        let fieldMap = cmp.get("v.fieldMap");
        let clickedColumn = event.currentTarget.id;
        let data = cmp.get("v.attachments");
        
        if(sortField == clickedColumn){
            if(sortDir == 'asc'){
                sortDir = 'desc';
                cmp.set("v.sortDir", sortDir);
            }else{
                sortDir = 'asc';
                cmp.set("v.sortDir", sortDir);
            }
        }else{
            sortField = clickedColumn;
            sortDir = 'asc';
            cmp.set("v.sortField", sortField);
            cmp.set("v.sortDir", sortDir);
        }

        cmp.set("v.sortByLabel", fieldMap.get(sortField));
            
        helper.sortData(cmp, data, sortField, sortDir);
    },

    openModal : function(cmp, event, helper){
        helper.openModal(cmp, event);
    },

    refreshView : function(cmp, event, helper){

        $A.get('e.force:refreshView').fire();
    },

    openViewAllPage : function(cmp, event, helper){

        let header = cmp.find("headerdiv");
        let table = cmp.find("tablecard");
        $A.util.removeClass(header, "slds-hide");
        $A.util.removeClass(table, "slds-hide");
        $A.get('e.force:refreshView').fire();
    },

    reInit : function(cmp, event, helper){
        $A.get('e.force:refreshView').fire();
    },

})