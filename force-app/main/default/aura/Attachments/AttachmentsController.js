({
    init : function(cmp, event, helper) {
        let spinner = cmp.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        let attachmentTable = cmp.find("attachmentTable");
        let fetchAttachments = cmp.get("c.getAttachments");
        fetchAttachments.setParams({recordId : cmp.get("v.recordId")});
        
        fetchAttachments.setCallback(this, function(response){
            let state = response.getState();
            $A.util.addClass(spinner, "slds-hide");
            if(state === "SUCCESS"){
                let resp = response.getReturnValue();
                cmp.set("v.numberOfAtt", resp.length);
                if(resp.length == 0){
                    $A.util.addClass(attachmentTable, "slds-hide");
                }else{
                    $A.util.removeClass(attachmentTable, "slds-hide");
                    cmp.set("v.name", resp[0].name);
                    helper.sortData(cmp, resp, "formatteddate", "desc");
                }
            }else if (state === "ERROR") {
                $A.util.addClass(attachmentTable, "slds-hide");
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    $A.util.addClass(attachmentTable, "slds-hide");
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(fetchAttachments);
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

    viewAll : function(cmp, event, helper){
        helper.viewAll(cmp, event, false, "c__ViewAllAttachments");
    },

    openModal : function(cmp, event, helper){
        helper.viewAll(cmp, event, true);
    },

    refreshView : function(cmp, event, helper){
        $A.get('e.force:refreshView').fire();
    },

    openUploadFiles : function(cmp, event, helper){
        helper.viewAll(cmp,event, true, "c__AttachmentsUploadPage");
    }
})