({
	doInit : function(component,event,helper){
   		helper.getRecordDetails(component,event,helper);
    },
    doAction : function(component,event,helper){
   		helper.getCloseCase(component,event,helper);
    },
    waiting: function(component, event, helper) {
    	component.set("v.spinner", true);
    },
    doneWaiting: function(component, event, helper) {
    	component.set("v.spinner", false);
    }
});