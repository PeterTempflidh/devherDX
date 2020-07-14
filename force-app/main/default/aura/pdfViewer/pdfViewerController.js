({
	getAccessLevel : function(component, event, helper) {
		helper.callServer(
            component,
            "c.getAccessLevelCtrl",
            function(result) {
				if(result){
                    component.set('v.hasEditAccess', true);
                    component.set('v.hasReadAccess', false);
                }
                else{
                    component.set('v.hasReadAccess', true);
                    component.set('v.hasEditAccess', false);
                }
				
			}, 
            {
                oppQuoteId: component.get("v.recordId")
            });
        
        component.set("v.isInClassicConsole", (component.get("v.uiTheme") == "Theme3"));
        component.set("v.userId", $A.get("$SObjectType.CurrentUser.Id"));

	},
	enableRefreshNeeded : function(component, event, helper) {
		component.set('v.refreshNeeded', true);        	
    	},
	displayPdf : function(component, event, helper) {
		component.set('v.disableAccept', true);
		component.set('v.disableSendEmail', true);
		component.set('v.disableRegenerateQuote', true);
		component.set('v.disableDocuSign', true);
		helper.loadpdf(component,event,helper);
	},
	loadpdf : function(component, event, helper) {

		var changeType = event.getParams().changeType;
		if(changeType === 'CHANGED'){
		    component.find('recordHandler').reloadRecord(true); 
		}
		else if(changeType === 'LOADED'){   			
			helper.loadpdf(component,event,helper);	
		}
	},
    regenerateQuote : function(component, event, helper) {
        component.set("v.theme", "");
        component.set("v.alertMessage", "");
		helper.regenerateQuoteHelper(component,event,helper);
	},
    sendEmail : function(component, event, helper) {
		helper.sendEmailHelper(component,event,helper);
	},
    accept : function(component, event, helper) {
        component.set("v.theme", "");
        component.set("v.alertMessage", "");
		helper.acceptHelper(component,event,helper);
	},
    onTabClosed : function(component, event, helper) {
	/*On quote creation, quote is opened even before the doc is generated, thereby
	refreshing the LC manually as soon as the doc gen tab is closed*/
	    if(component.get('v.refreshNeeded')){
            	helper.loadpdf(component,event,helper);
        	}		

	},
    
  refresh : function(component, event, helper){
    	component.find('recordHandler').reloadRecord(true); 
      component.set("v.theme", "");
      component.set("v.alertMessage", "");
	},
	
    toggleEmailForm : function(component, event, helper){
      component.set("v.displayPdfViewer", !component.get("v.isSendEmail"));
      helper.toggleButtons(component);
      if(!component.get("v.isSendEmail")){
        component.set("v.body", []);
        var recordHandler = component.find("recordHandler");
        recordHandler.reloadRecord();
      }
    },
    
    sendEmailClassic : function(component, event, helper){
      component.set("v.theme", "");
      component.set("v.alertMessage", "");
      let userRecord = component.get("v.userSimpleRecord");
      let recHandler = component.get("v.simpleRecord")
      let doSendEmail = true;
      console.log("Profile Name : ", userRecord.Profile.Name);
      let restrictedProfile_FI = ['FI Customer Care Team', 'FI Sales Management', 'FI Sales Team'];

      if(restrictedProfile_FI.indexOf(userRecord.Profile.Name) > -1 
         && (!recHandler.Id_Account__r.Delivery_Service__c 
         || recHandler.Id_Account__r.Delivery_Service__c == "None" 
         || recHandler.Id_Account__r.Delivery_Service__c == "Unknown")){
          doSendEmail = false;
      } 
      if(doSendEmail){
        component.set("v.isSendEmail", true);

          helper.createSendEmailForm(component);
          helper.toggleButtons(component);   
      } else {
          helper.displayErrorClassic(component, "error", $A.get("$Label.c.SE_FI_Invalid_Delivery_Service_Error"));
      }
  }
})
