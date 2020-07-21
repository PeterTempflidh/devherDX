/**
 * Created by danish.farooq on 6/6/20.
 */

({
    selectRecord : function(component, event, helper){
        // get the selected record from list
        var getSelectRecord = component.get("v.recordObject");
        // call the event
        var compEvent = component.getEvent("selectedRecordEvent");
        // set the Selected sObject Record to the event attribute.
        compEvent.setParams({"recordByEvent" : getSelectRecord });
        // fire the event
        compEvent.fire();
    },
})