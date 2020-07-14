({

    doInit : function(component, event, helper) {
        helper.getUITheme(component,event,helper);
        helper.checkEnvelopeCount(component,event,helper);
    },

    gotoDocuSignURL : function (component, event, helper) {

	//Logic to refresh pdf component on docusign tab close
	var p = component.get("v.parent");
    	p.refreshMethod();
	    
        if(component.get("v.envelopeCountError")) {
            component.set('v.theme', 'slds-theme--error');
            component.set('v.recordError', $A.get("$Label.c.DocuSign_Envelope_Consumption_Error"));
        }
        else {
            if(component.get("v.uiTheme") == "Theme3") {
              helper.navigateToURLClassic(component,event,helper);
            }
            else {
              helper.navigateToURLLightning(component,event,helper);
            }
        }

    }

});
