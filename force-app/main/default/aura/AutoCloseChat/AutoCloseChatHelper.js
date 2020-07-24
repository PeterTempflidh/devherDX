({

    onChatEnded : function(component, event) {
        const WAIT = 10;
        let chatRecordId = event.getParam('recordId');
        
        /*
        * Asks the user if close the current tab
        */
        let askIfcloseCurrentTab = () => {
            let workspaceAPI = component.find("workspace");
            workspaceAPI.getAllTabInfo().then(res => {
                console.log(JSON.stringify(res));
                let chatTabData = res.find(el => {
                        return el.recordId.substring(0, 15) == chatRecordId}                
                    );
    
                if (chatTabData) {
                    console.log('current currentTabData ', JSON.stringify(chatTabData ));
                    this.showAskModal(component, chatTabData.tabId);
                }
    
            }).catch(tabData => {
                console.log('### workspaceAPI.getAllTabInfo error ', error);
            });    
        }

        let changeLabelOnTab = (tabId) => {
            let workspaceAPI = component.find("workspace");
            
            let setTabLabelPromise = workspaceAPI.setTabLabel({
                tabId : tabId,
                label : 'OOOO ITS END'
            });

            let setTabHighlightedPromise = workspaceAPI.setTabHighlighted({
                tabId: tabId,
                highlighted: true,
                options: {
                    pulse: true,
                    state: "error"
                }
            });
            
            Promise.all([setTabLabelPromise, setTabHighlightedPromise]).then(r => {
                console.log('setTabLabelPromise, setTabHighlightedPromise good', r);
            }).catch(r => {
                console.log('setTabLabelPromise, setTabHighlightedPromise', r);
            });

        }


        let isActiveTab = this.isActiveTab(component, chatRecordId);
        isActiveTab.then(currentTabData => { // the tab is focused
            window.setTimeout($A.getCallback( askIfcloseCurrentTab ), WAIT);
        }).catch(currentTabData => { // the tab is not focused
            if (currentTabData) {
                changeLabelOnTab(currentTabData.tabId);
            }
        })
    },

    /*
    * Closes the selected tabId
    */
    closeTab : function(component, tabId) {
        console.log('closeTab');

        let workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({tabId : component.get('v.tabId')}).then(closeTabRes => {
            console.log('### closeTab success', JSON.stringify(closeTabRes));
        })
    },
    
    /*
    * Asks the user on a model if he wants to close the current tab.
    */
   showAskModal : function(component, tabId) {
        console.log('showAskModal');
        component.set('v.tabId',tabId);        
        component.set('v.showCloseModal',true);        
        // return modalPromise;
    },
    
    /*
    * Returns a Promise. 
    * Resolves, if the tab where the chat is happening is focused.
    * Rejects, if not
    */
    isActiveTab : function(component, chatRecordId) {
        console.log('promise start naaa');

        let activeTabPromise = new Promise(
            $A.getCallback((tabIsFocused, tabIsNotFocused) => {
                let workspaceAPI = component.find("workspace");

                workspaceAPI.getAllTabInfo().then(allTabInfo => {
                    let currentTab = allTabInfo.find(el => {
                            return el.recordId.substring(0, 15) == chatRecordId;
                        });

                    if (currentTab) {
                        if (currentTab.focused === true) {
                            tabIsFocused(currentTab);
                        } else {
                            tabIsNotFocused(currentTab);
                        }
                    } else {
                        tabIsNotFocused(undefined);
                    }

                }).catch(err => {
                    console.log('## getAllTabInfo error ', err);
                });
            }));

        return activeTabPromise;

    },

    // UI HELPERS
    ////////////////////

    /*
    * If the user wants to close the tab, closes the tab
    */
    closeTabButtonPressed : function(component) {
        console.log('closeTabButtonPressed');
        window.setTimeout($A.getCallback(() => {
            this.closeTab(component, component.get('v.tabId'));
        }), 1400);
    },

})
