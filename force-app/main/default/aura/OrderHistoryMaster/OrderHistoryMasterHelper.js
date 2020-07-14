({
	setRecordId: function(component, event, helper){
    	var pageRef = component.get("v.pageReference");
        var recId = pageRef && pageRef.state ? pageRef.state.c__paramRec : "";
		var sobjName = pageRef && pageRef.state ? pageRef.state.c__paramsObjName : "";
        component.set("v.recId",recId);
		component.set("v.sObj",sobjName);
        helper.getCompVisibility(component, event, helper);
	},
	getCompVisibility : function(component, event, helper) {
       var action = component.get("c.getOrderCompsVisibilitySetting");
        action.setParams({settingName:$A.get("{!$Label.c.OrderHistoryComponents}")});
    	action.setCallback(this, function(response){
           if(!$A.util.isUndefinedOrNull(response) &&
               response.getState() == 'SUCCESS'){
               component.set("v.visibiltySetting", response.getReturnValue());
            }       
        });
        $A.enqueueAction(action);
	}	
    
})