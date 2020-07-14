({
	getChatDetails : function(component,event,helper,recordId,focusedTabId) {
		var action=component.get("c.getChatDetails");
        action.setParams({recId: recordId});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
                var tabName='';
                var tabNameMap=[];
                if(response.getReturnValue() != null) {
                    tabNameMap=response.getReturnValue().split('&&');
                    if(tabNameMap[1]!='null')
	                    tabName=tabNameMap[0]+'-Chat-'+tabNameMap[1];
                    else
                        tabName=tabNameMap[0]+'-Chat';
                }
                if(tabName!=''){
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: tabName
                    });
                }
            }
        });
        $A.enqueueAction(action);
	}
})