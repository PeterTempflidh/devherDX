({

    onChatEnded : function(component, event) {
        const WAIT = 10;
        let chatRecordId = event.getParam('recordId');
        
        let closeCurrentTab = () => {
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
            window.setTimeout($A.getCallback( closeCurrentTab ), WAIT);
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
        this.showModal(component).then(r => {
            let workspaceAPI = component.find("workspace");
            workspaceAPI.closeTab({tabId : tabId}).then(closeTabRes => {
                console.log('### closeTab success', JSON.stringify(closeTabRes));
            }).catch(error => {
                console.log('### closeTab error ', error);
            });
        });
        

    },
    
    /*
    * Asks the user on a model if he wants to close the current tab.
    * Returns a promise which resolves if user clicks Yes
    */
    showModal : function(component) {
        let modalPromise = new Promise(
            $A.getCallback((resolve, reject) => {
                component.set('v.closeModalPromiseResolve', resolve);
            })
        );
        
        component.set('v.showCloseModal',true);        
        return modalPromise;
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
    * If the user wants to close the tab, resolves the `closeModalPromiseResolve` promise
    */
    closeTabButtonPressed : function(component) {
        component.set('v.showCloseModal', false);     
        let closeResolve = component.get('v.closeModalPromiseResolve');
        closeResolve('1');
    },

})
