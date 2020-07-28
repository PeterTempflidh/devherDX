({

    onChatEnded : function(component, event) {
        const WAIT_CLOSE = 6000;
		const WAIT_POPUP = 10
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
			/*
			let workspaceAPI = component.find("workspace");
        	
			workspaceAPI.getFocusedTabInfo().then(chatTabData => {
   				if (!component.get('v.recordId')) return;
				if (!chatTabData.recordId) return;
							
				if (component.get('v.recordId').substring(0, 15) == chatTabData.recordId.substring(0, 15)) {
					this.showAskModal(component, chatTabData.tabId);
				}  
			}).catch(tabData => {
                console.log('### workspaceAPI.getAllTabInfo error ', error);
            });
			*/    
        };
		
		
		/*
		* Closes a tab in N seconds
		*/
		let scheduleCloseTab = (recordId) => {
			window.setTimeout($A.getCallback(() => {
				console.log('#### executing');
				this.closeTab2(component, recordId);
			}), WAIT_CLOSE);
		};

		///////////////////
		// decide what to do
		/////////////////		
       	this.isActiveTab(component, chatRecordId).then(currentTabData => { // the tab is focused
            window.setTimeout($A.getCallback( askIfcloseCurrentTab ), WAIT_POPUP);
        }).catch(currentTabData => { // the tab is not focused
            if (currentTabData) {
				if (currentTabData.recordId.substring(0,15) == pageRecordId.substring(0,15)) { 
					
					let title = currentTabData.title;

					component.set('v.isHl', true); // hl property means it is higlighted
					component.set('v.originalTitle', title); // save the original tab title
					this.changeLabelOnTab(component, currentTabData.tabId, 'Time out Warning', true);
                	scheduleCloseTab(currentTabData.recordId);
				}
            }
        });
    },

	askIfCloseCurrentTab : function(component) {
		let workspaceAPI = component.find("workspace");
        	
		workspaceAPI.getFocusedTabInfo().then(chatTabData => {
   				if (!component.get('v.recordId')) return;
				if (!chatTabData.recordId) return;
							
				if (component.get('v.recordId').substring(0, 15) == chatTabData.recordId.substring(0, 15)) {
					console.log('%%%% showing modal for record ', component.get('v.recordId')); 
					this.showAskModal(component, chatTabData.tabId);
				}  
		}).catch(tabData => {
               console.log('### workspaceAPI.getAllTabInfo error ', error);
        });    
	},

	onTabFocused : function(component, event, tabId) {
		let isHl = component.get('v.isHl');
		if (isHl == true) { // the logic starts only if the tab was highlighted
    		this.changeLabelOnTab(component, tabId, component.get('v.originalTitle'), false);
			this.askIfCloseCurrentTab(component);
		}
	},

    /*
    * Closes the selected tabId
    */
    closeTab : function(component, tabId) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({tabId : component.get('v.tabId')}).then(closeTabRes => {
            console.log('### closeTab success', JSON.stringify(closeTabRes));
        })
    },
    
	/*	
	* close a tab base on recordId
	*/
    closeTab2 : function(component, recordId) {
		let chatRecordId = component.get('v.recordId');
		console.log('..... ' + chatRecordId);
		if (chatRecordId.substring(0, 15) != recordId.substring(0, 15)) return;	


	
		let isFocused = component.get('v.isFocused');
		console.log('7777 ##### isFocused ', isFocused, recordId);
		if (isFocused == true) return;

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
     	component.set('v.tabId',tabId);        
       	component.set('v.showCloseModal',true);        
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
    */
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
                console.log('setTabLabelPromise, setTabHighlightedPromise', r);
            });

	}
})
