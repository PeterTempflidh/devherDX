({
    openTab : function(component, event, helper) {
        helper.openTab(component, event,helper, true);
    },
    //This method's purpose needs to be evaluated 
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            var orderNumber = component.get("v.record.fields.Order_Number__c.value");
            var platform = component.get("v.record.fields.Platform__c.value"); 
            var country = component.get("v.record.fields.Country__c.value");
            var autoRedirect = component.get("v.AutoRedirect");

            component.set('v.Order_Number__c', orderNumber);
            component.set('v.Platform__c', platform);
            component.set('v.Country__c', country);

            if(autoRedirect)
                helper.openTab(component, orderNumber, platform, country, false);

        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },

    events : function(cmp, evt, hlp){
        console.log('EVENT ' + evt.getName() + ', PARAMS:' + evt.getParams());
    }
})