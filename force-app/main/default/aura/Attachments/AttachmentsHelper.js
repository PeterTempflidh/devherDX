({
    viewAll : function(cmp, event, openAtt, compName){

        let recordId = cmp.get("v.recordId");
        let sObjectType = cmp.get("v.sObjectType");
        let workspaceApi = cmp.find("workspace");
        let name = cmp.get("v.name");

        workspaceApi.isConsoleNavigation().then(function(response){
            if(response){
                workspaceApi.openTab({
                    url: '/lightning/r/' + sObjectType + '/' + recordId +  '/view',
                    focus: true
                }).then(function(response){
                    workspaceApi.openSubtab({
                        parentTabId: response,
                        pageReference: {
                            type: "standard__component",
                            attributes: {
                                componentName: compName,
                            },
                            state: {
                                c__recordId: recordId,
                                c__sObjectType: sObjectType,
                                c__name: name,
                                c__openAtt: openAtt
                            }
                        },
                        url: '/lightning/cmp/' + compName + '\'',
                        focus: true
                    }).then(function(subtabId){
                        workspaceApi.setTabLabel({
                            tabId: subtabId,
                            label: "Attachments"
                        });
                        workspaceApi.setTabIcon({
                            tabId: subtabId, 
                            icon: "standard:file"
                        }); 
                    })
                }).catch(function(error){
                    console.log(error);
                });
            }else{
                let pageReference = {
                    type: "standard__component",
                    attributes: {
                        componentName: compName,
                    },
                    state: {
                        c__recordId: recordId,
                        c__sObjectType: sObjectType,
                        c__name: name,
                        c__openAtt: openAtt
                    }
                };
                cmp.set("v.pageReference", pageReference);
                cmp.find("navigate").navigate(pageReference);
            }
        });
    },

    sortData : function(cmp, data, fieldName, sortDirection){

        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel text type fields 
        data.sort(function(a,b){ 
            var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a>b) - (b>a));
        });

        if(data.length >= 5){
            cmp.set("v.attachments", data.slice(0, 5));
        }else{
            cmp.set("v.attachments", data);
        }
    }
})