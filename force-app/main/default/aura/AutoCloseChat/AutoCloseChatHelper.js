({
    onChatEnded : function(component, event) {
        const INACTIVE_CLOSE_WAIT = component.get('v.INACTIVE_CLOSE_WAIT');
		const POPUP_WAIT = component.get('v.POPUP_WAIT');
        let chatRecordId = event.getParam('recordId');
        let pageRecordId = component.get('v.recordId');

		/////////////////////////
		// all the possible behavior functions
		///////////////////////////
        
        /*
        * Asks the user if close the current tab
        */
        let askIfcloseCurrentTab = () => {
			this.askIfCloseCurrentTab(component);
        };
		
		
		///////////////////
		// decide what to do
		/////////////////		
       	this.isActiveTab(component, chatRecordId).then(currentTabData => { // the tab is focused
            window.setTimeout($A.getCallback( askIfcloseCurrentTab ), POPUP_WAIT);
        }).catch(currentTabData => { // the tab is not focused
            if (currentTabData) {
				if (currentTabData.recordId.substring(0,15) == pageRecordId.substring(0,15)) { 
					
					let title = currentTabData.title;

					component.set('v.isHl', true); // hl property means it is higlighted
					component.set('v.originalTitle', title); // save the original tab title
					this.changeLabelOnTab(component, currentTabData.tabId, 'Time out Warning', true);
                	this.scheduleCloseTab(component, currentTabData.recordId, INACTIVE_CLOSE_WAIT);
				}
            }
        });
    },

	scheduleCloseTab : function(component, recordId, wait) {
		let timeoutId = window.setTimeout($A.getCallback(() => {
			this.closeTab2(component, recordId);
		}), wait);
	},

	askIfCloseCurrentTab : function(component) {
		let workspaceAPI = component.find("workspace");
        	
		workspaceAPI.getFocusedTabInfo().then(chatTabData => {
   				if (!component.get('v.recordId')) return;
				if (!chatTabData.recordId) return;
							
				if (component.get('v.recordId').substring(0, 15) == chatTabData.recordId.substring(0, 15)) {
					this.showAskModal(component, chatTabData.tabId);
				}  
		}).catch(err => {
			console.log('### getFocusedTabInfo error ', err);
        });    
	},

	onTabFocused : function(component, event, tabId) {
		let isHl = component.get('v.isHl');
		if (isHl == true) { // the logic starts only if the tab was highlighted
    		this.changeLabelOnTab(component, tabId, component.get('v.originalTitle'), false);
			this.askIfCloseCurrentTab(component);
			component.set('v.isHl', false); // setting the is highlighted property to false, so not firing this logic again
		}
	},

    /*
    * Closes the selected tabId
    */
    closeTab : function(component, tabId) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({tabId : component.get('v.tabId')}).then(closeTabRes => {
        })
    },
    
	/*	
	* close a tab based on recordId
	*/
    closeTab2 : function(component, recordId) {
		let chatRecordId = component.get('v.recordId');
		if (!chatRecordId) return; // this means the tab is already closed -- STOP!
		if (chatRecordId.substring(0, 15) != recordId.substring(0, 15)) return;	

		// closeCancelled -- indicates that the user clicked Cancel on the close tab modal
		// isFocused -- indicates that the user focused the tab, so no need to finish the scheduled close
        let closeCancelled = component.get('v.closeCancelled'); 

		let isFocused = component.get('v.isFocused');
		if (isFocused == true || closeCancelled) return;

    	let workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(res => {
            let chatTabData = res.find(el => {
            	return el.recordId == recordId;                
			});
       		if (chatTabData) { 
				workspaceAPI.closeTab({tabId : chatTabData.tabId} ).then(closeTabRes => {
        		}).catch(err => {
					console.log('#### CLOSETAB2 closeTab error ', err);
				});
			}
        }).catch(err => {
			console.log('### getAllTabInfo error ', err);
		});

    },

    /*
    * Asks the user on a model if he wants to close the current tab.
    */
    showAskModal : function(component, tabId) {
		const CLOSE_MODAL_WAIT = component.get('v.CLOSE_MODAL_WAIT');
        const INACTIVE_CLOSE_WAIT = component.get('v.INACTIVE_CLOSE_WAIT');
		const recordId = component.get('v.recordId');
		component.set('v.tabId',tabId);        
       	component.set('v.showCloseModal',true);        

		var that = this;	
		// close model after N seconds
		window.setTimeout($A.getCallback(() => {
			that.closeModal(component);
			window.setTimeout($A.getCallback(() => {
				component.set('v.isFocused', false); // this will let closeTab2 to close
				that.closeTab2(component, recordId);
			}), INACTIVE_CLOSE_WAIT);
		}), CLOSE_MODAL_WAIT);
	},

    /*
    * Returns a Promise. 
    * Resolves, if the tab where the chat is happening is focused.
    * Rejects, if not
    */
    isActiveTab : function(component, chatRecordId) {

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
    *
	*/

	closeModal : function(component) {
        component.set('v.showCloseModal', false);
	},

    closeTabButtonPressed : function(component) {
    	this.closeTab(component, component.get('v.tabId'));
    },

	changeLabelOnTab : function(component, tabId, label, hl) {
            let workspaceAPI = component.find("workspace");
            
            let setTabLabelPromise = workspaceAPI.setTabLabel({
                tabId : tabId,
                label : label
            });

            let setTabHighlightedPromise = workspaceAPI.setTabHighlighted({
                tabId: tabId,
                highlighted: hl,
                options: {
                    pulse: true,
                    state: "error"
                }
            });
            
            Promise.all([setTabLabelPromise, setTabHighlightedPromise]).then(r => {
            }).catch(r => {
                console.log('setTabLabelPromise, setTabHighlightedPromise error', r);
            });

	}
})
