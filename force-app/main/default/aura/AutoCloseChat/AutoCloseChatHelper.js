({

    onChatEnded : function(component, event) {
        let chatRecordId = event.getParam('recordId');

        let workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(res => {
            console.log(JSON.stringify(res));
            let chatTabData = res.find(el => {
                    return el.recordId.substring(0, 15) == chatRecordId}                
                );

            if (chatTabData) {
                console.log('current currentTabData ', JSON.stringify(chatTabData ));
                this.closeTab(component, chatTabData.tabId);
            }

        }).catch(error => {
            console.log('### workspaceAPI.getAllTabInfo error ', error);
        });
    },

    closeTab : function(component, tabId) {
        console.log('closetab');
       
        

        let workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({tabId : tabId}).then(closeTabRes => {
            console.log('### closeTab success', JSON.stringify(closeTabRes));
        }).catch(error => {
            console.log('### closeTab error ', error);
        });
    },

    showModal : function(component) {
        // let modalPromise = new Promise(
        
        // component.set('v.showCloseModal',true);        
        // component.set('v.modalPromise', modalPromise);
        // return modalPromise;
    },

    closeTabButtonPressed : function() {

    }
})
