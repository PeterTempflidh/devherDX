({
    
    loadpdf: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set('v.displayPdfViewer', true);
        component.set("v.refreshNeeded", false);
        component.set("v.theme", "");
        component.set("v.alertMessage", "");
        helper.callServer(
            component,
            "c.getInitData",
            function(result) {                
                component.set("v.showSpinner", false);        
                if(component.get("v.hasEditAccess")){
                    component.set('v.disableAccept', result.disableAcceptButton);
                    component.set('v.disableSendEmail', result.disableSendEmailButton);
                    component.set('v.disableDocuSign', result.disableDocuSignButton);
                }       
                if (result && result.returnUrl) {
                    component.set('v.pdfData', result.returnUrl);                    
                    var pdfjsframe = component.find('pdfFrame');
                    if (pdfjsframe.getElement() && typeof result.returnUrl != 'undefined') {
                        pdfjsframe.getElement().contentWindow.postMessage(result.returnUrl, '*');
                    }
			//Enabling regenerate quote button only for edit access users
		    if(!component.get('v.hasReadAccess')){
                        component.set('v.disableRegenerateQuote', false); 
                    } 
                    
                }
                else{
                    component.set('v.displayPdfViewer', false);
			//In classic refresh on tab close will not work. Thereby displaying the message to refresh manually
                    if(component.get('v.isInClassicConsole')){
                        var recHandler = component.get("v.simpleRecord");
                        //For Quotes generated from Midas, not disabling the buttons in classic
                        if(recHandler.Id_Opportunity__r.Source_System__c !== 'MIDAS' && 
                           recHandler.Id_Opportunity__r.Source_System__c !== 'Restaurant Portal Service' && 
                           recHandler.Id_Opportunity__r.LeadSource !== 'Self Sign Up' )
                           { 
                                let now = new Date();
                                let currentDateTime = new Date(now);
                                let createdDate = new Date(component.get("v.simpleRecord").CreatedDate);
                                let minDiff = parseInt(currentDateTime-createdDate)/1000;
                                if(minDiff < component.get('v.refreshDuration')){                                    
                                    component.set("v.showSpinner", true);   
                                    component.set('v.alertMessage',$A.get("$Label.c.Nintex_Loading_Message"));
                                    component.set("v.theme", 'slds-theme--warning');
                                    window.setTimeout(
                                        $A.getCallback(function() {                                            
                                            component.find('recordHandler').reloadRecord(true);
                                        }), 10000
                                    );
                                }
                           }

                    }
                    else{
                        //Check for subtabs with 'Drawloop' to enable 'refreshNeeded' to true
                    	this.checkForDrawlooptabs(component, event, helper);
                    }  
                }
            }, 
            {
                oq: component.get("v.simpleRecord")                
            }
        );         
        
    },
	
    checkForDrawlooptabs: function (component, event, helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {    
                    
            workspaceAPI.getTabInfo({
                tabId: response.parentTabId
            }).then(function(parentResponse) {
                for(var i = 0; i< parentResponse.subtabs.length; i++){
                    //Nintex tabs always have the following titles. Refresh is needed only when nintex tabs are closed
                    if(parentResponse.subtabs[i].title === 'Drawloop' ||
                    parentResponse.subtabs[i].title === 'Loop__looplus'){
			component.set('v.alertMessage',$A.get("$Label.c.Nintex_Loading_Message"));
                        component.set("v.theme", 'slds-theme--warning');
                        component.set('v.refreshNeeded', true);
                        component.set("v.showSpinner", true);
                        break;
                    }
                }

            }).catch(function(error) {
                console.log('$$$' +error);
            });

            
        })
        .catch(function(error) {
            console.log('Caused on PDF' +error);
        });
               
   },
    
    regenerateQuoteHelper: function (component, event, helper) {
        let isInClassicConsole = false;
        component.set("v.showSpinner", true);
        component.set("v.refreshNeeded", true);
        let isInClassic = component.get("v.isInClassicConsole");
        
        if(isInClassic){
            isInClassicConsole = sforce.console.isInConsole();
        }

        helper.callServer(
            component,
            "c.generateQuoteUrl",
            function(response) { 
                
                if(response && response.includes('Exception occurred')){
                    component.set('v.theme', 'slds-theme--error');
                    component.set('v.recordError', response);
                }
                else if(response && response.includes('loop__looplus')){
                    
                    if(isInClassic){
                        window.open(response,"_self");
                    } else {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": response
                        });
                        urlEvent.fire();
                    }
                }
                else{
                    component.set("v.showSpinner", false);
                }        
            }, 
            {
                oppQuote : component.get('v.simpleRecord'),
                isInClassic : isInClassicConsole
            }
	); 	
    },
    
    acceptHelper: function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.callServer(
            component,
            "c.updateOpportunityType",
            function(result) {                           
                if(result === ''){
                    component.set('v.simpleRecord.Status__c', 'Accepted');
                    component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
                        // use the recordUpdated event handler to handle generic logic when record is changed
                        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                            helper.showToast(component, 'Success',$A.get("$Label.c.Opportunity_Quote_Accepted"),'Success','sticky');
                            component.find("recordHandler").reloadRecord();
                        } else if (saveResult.state === "INCOMPLETE") {
                            console.log("User is offline, device doesn't support drafts.");
                        } else if (saveResult.state === "ERROR") {
                            component.set('v.theme', 'slds-theme--error');
                            component.set('v.recordError', 'Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        } else {
                            component.set('v.theme', 'slds-theme--error');
                            component.set('v.recordError', 'Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                        }
                        component.set("v.showSpinner", false);
                    })); 
                }else{ 
                    component.set("v.showSpinner", false);
                    helper.showToast(component, "Error", result, "Error", "sticky");
                }
            }, 
            {
                oq: component.get("v.simpleRecord")                
            }
        );
    }, 
    
    createSendEmailForm : function(component){
        $A.createComponent(
            "c:SendEmailForm",
            {
                "recordId": component.get("v.recordId"),
                "isSendEmail" : component.getReference("v.isSendEmail"),
                "isInClassicConsole" : component.get("v.isInClassicConsole")
            },
            function(sendEmailForm, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = []
                    body.push(sendEmailForm);
                    console.log("body : ", body);
                    component.set("v.body", body);
                    component.set("v.displayPdfViewer", false);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    component.set("v.isSendEmail", false);
                    // Show offline error
                }else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    component.set("v.isSendEmail", false);
                    // Show error message
                }
            }
        );
    },
	
    toggleButtons : function(component){
        if(component.get("v.isInClassicConsole")){
            component.set("v.doShowButtons", !component.get("v.isSendEmail"))
        }
    },
    
    displayErrorClassic : function(component, type, message){
        console.log("message :", message)
        let alertTheme = "";
        
        if(type == "error"){
            alertTheme = "slds-theme--error"
        } else if(type == "success"){
            alertTheme = "slds-theme--success"
        }
        
        component.set("v.theme", alertTheme);
        component.set("v.alertMessage", message);
    }
})
