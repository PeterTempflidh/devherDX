({
	
    getUITheme : function(component, event, helper) {
        helper.callServer(
        component,
        "c.getUIThemeDescription",
        function(result) {
            component.set("v.uiTheme", result);
        },
        {
            
        });
    },

    checkEnvelopeCount : function(component, event, helper) {
        helper.callServer(
            component,
            "c.checkDocuSignEnvelopeCount",
            function(result) {
                if(result){
                    component.set('v.envelopeCountError', result);
                }
            },
            {
                quoteId: component.get("v.recordId")
            }
        );
    },

    navigateToURLClassic : function(component, event, helper) {
        var oppQuoteId = component.get("v.recordId");
        var url = '/console#/apex/DocuSignURLGenerator?Id='+oppQuoteId;
        window.open(url,"_top");
	},

    navigateToURLLightning : function(component, event, helper) {
		var oppQuoteId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/apex/DocuSignURLGenerator?Id='+oppQuoteId
        });
        urlEvent.fire();
	}
    
})