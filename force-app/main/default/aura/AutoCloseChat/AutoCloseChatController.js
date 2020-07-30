({
    onInit : function(component,event,helper){
   		var action = component.get("c.getTimes");
        action.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                let res = response.getReturnValue();
				component.set('v.POPUP_WAIT', res[0]);				
				component.set('v.CLOSE_MODAL_WAIT', res[1]);				
				component.set('v.INACTIVE_CLOSE_WAIT', res[2]);				
			}
		});
        $A.enqueueAction(action);

	},
	
	onTabFocused : function(component, event, helper) {
		let recordId = component.get('v.recordId');
		if (!recordId) return;
		
		let currentTabId = event.getParam('currentTabId');
		
		let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(chatTabData => {
			if (chatTabData.tabId == currentTabId) {
				if (chatTabData.recordId == recordId) {
					component.set('v.isFocused', true);
					helper.onTabFocused(component, event, chatTabData.tabId);
				}
			}
		});
		
	},
    
	onChatEnded : function(component, event, helper) {
		let recordId = component.get('v.recordId');
		if (!recordId) return;

        helper.onChatEnded(component, event);
    },

    onCloseTabButtonPressed : function(component, event, helper) {
		let recordId = component.get('v.recordId');
		if (!recordId) return;

        helper.closeModal(component);
		helper.closeTabButtonPressed(component);
    },

    onCancelButtonPressed : function(component, event, helper) {
		let recordId = component.get('v.recordId');
		if (!recordId) return;

        component.set('v.showCloseModal', false); 
        component.set('v.closeCancelled', true); 
    }    
})
