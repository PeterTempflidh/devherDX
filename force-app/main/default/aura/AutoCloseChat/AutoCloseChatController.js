({
    onInit : function(component,event,helper){
    },
	
	onTabFocused : function(component, event, helper) {
		let recordId = component.get('v.recordId');
		let currentTabId = event.getParam('currentTabId');
		
		let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(chatTabData => {
			if (chatTabData.tabId == currentTabId) {
				if (chatTabData.recordId == recordId) {
					console.log('IM HAPPY', chatTabData.tabId, chatTabData.recordId);
					component.set('v.isFocused', true);
					console.log('##### ', component.get('v.isFocused'));
					helper.onTabFocused(component, event, chatTabData.tabId);
				}
			}
		});
		
	},
    
	onChatEnded : function(component, event, helper) {
        helper.onChatEnded(component, event);
    },
    onCloseTabButtonPressed : function(component, event, helper) {
        component.set('v.showCloseModal', false);
        helper.closeTabButtonPressed(component);
    },

    onCancelButtonPressed : function(component, event, helper) {
        component.set('v.showCloseModal', false); 
    }    
})
