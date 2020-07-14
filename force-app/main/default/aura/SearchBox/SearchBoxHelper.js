({
    
    autoComplete : function(cmp, query){
        let suggestions = cmp.get('v.allSearchOptions');
        let activeSuggestionArray = [];
        const querySuggestBox = cmp.find("query-suggest-box");
        suggestions.forEach(function(element){
            if(element.label && element.label.toLowerCase().indexOf(query.toLowerCase()) > -1 || element.toLowerCase().indexOf(query.toLowerCase()) > -1)
                activeSuggestionArray.push(element);
        });

        //also, can change collection type to receive a map in order
        //to keep leverage other attributes for sorting/displaying
        cmp.set('v.activeQuerySuggestions', activeSuggestionArray.sort());

        /*---class validation to hide/display suggestion box---*/
        if(cmp.get('v.activeQuerySuggestions').length > 0 && $A.util.hasClass(querySuggestBox, "slds-hide")){
            $A.util.removeClass(querySuggestBox, 'slds-hide');
        }
        else if(cmp.get('v.activeQuerySuggestions').length == 0){
            $A.util.addClass(querySuggestBox, 'slds-hide');
        }
    
    },
    
    onSuggestionClick : function(cmp, event, selection){
        this.executeQuery(cmp, event, selection)
    },

    /* -- community search -- */
    executeQuery : function(cmp, event, theQuery){
        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/global-search/"+theQuery
        });
        urlEvent.fire();  
    },

    handleSelect : function(cmp,event,helper,item){
        const qrySuggBox = cmp.find('query-suggest-box');
        const qryBox = cmp.find('query-box');
        $A.util.addClass(qrySuggBox, 'slds-hide');
        var selectedItem;
        if(selectedItem==null){
            selectedItem = event.target.id;
        }
        else{
            selectedItem = item;
        }
        qryBox.set('v.value', selectedItem);
        return selectedItem;
    },

    handleSelectEnter : function(component,event,helper,evt,count){
        if(count==1){
            var qryListItem = component.find('query-suggest-item');
            count++;
            //Checking if the keyboard event is a Down Arrow Key. Moving the focus to the next element.
            if(evt=='ArrowDown'){
                if(qryListItem!=undefined && qryListItem.length!=0){
                    if(qryListItem.length>1){
                        qryListItem.sort((a, b) => (a.getElement().id > b.getElement().id) ? 1 : -1);
                    }
                    else if(qryListItem.length==undefined){
                        var element=qryListItem.getElement();
                        qryListItem = [];
                        qryListItem.push(element);
                    }
                    var qryList=component.find("query-suggest-list");
                    var isPresent=false;
                    for(var i = 0; i < qryListItem.length; i++){
                        if($A.util.hasClass(qryListItem[i], "selected")){
                            if((i+1)!=qryListItem.length){
                                document.getElementById(qryListItem[i+1].getElement().id).scrollIntoView(true);
                                $A.util.addClass(qryListItem[i+1], "selected");
                                $A.util.removeClass(qryListItem[i], "selected");
                                isPresent=true;
                                break;
                            }
                            else{
                                $A.util.removeClass(qryListItem[i], "selected");
                            }
                        }
                    }
                    if(!isPresent){
                        $A.util.addClass(qryListItem[0], "selected");
                        if(qryListItem.length>1){
                            document.getElementById(qryListItem[0].getElement().id).scrollIntoView(true);
                            $A.util.removeClass(qryListItem[qryListItem.length-1], "selected");
                        }
                    }
                }
            }
            //Checking if the keyboard event is a Up Arrow Key. Moving the focus to the previous element.
            else if(evt=='ArrowUp'){
                if(qryListItem!=undefined && qryListItem.length!=0){
                    if(qryListItem.length>1){
                        qryListItem.sort((a, b) => (a.getElement().id > b.getElement().id) ? 1 : -1);
                    }
                    else if(qryListItem.length==undefined){
                        var element=qryListItem.getElement();
                        qryListItem = [];
                        qryListItem.push(element);
                    }
                    var qryList=component.find("query-suggest-list");
                    var isPresent=false;
                    for(var i = qryListItem.length; i > 0; i--){
                        if($A.util.hasClass(qryListItem[i], "selected")){
                            document.getElementById(qryListItem[i-1].getElement().id).scrollIntoView(true);
                            $A.util.addClass(qryListItem[i-1], "selected");
                            $A.util.removeClass(qryListItem[i], "selected");
                            isPresent=true;
                            break;
                        }
                    }
                    if(!isPresent){
                        $A.util.addClass(qryListItem[qryListItem.length-1], "selected");
                        if(qryListItem.length>1){
                            document.getElementById(qryListItem[qryListItem.length-1].getElement().id).scrollIntoView(true);
                            $A.util.removeClass(qryListItem[0], "selected");
                        }
                    }
                }
            }
            //Checking if the keyboard event is Enter Key. Selecting the element and setting it to the case reason level 3 field.
            else if(evt=='Enter'){
                if(qryListItem!=undefined && qryListItem.length!=0){
                    var qryList=component.find("query-suggest-list");
                    if(qryListItem.length==undefined){
                        component.set("v.selectedOption",qryListItem.getElement().textContent);
                        component.set("v.searchInput",qryListItem.getElement().textContent);
                        $A.util.removeClass(qryListItem, "selected")
                    }
                    else{
                        for(var i = 0; i < qryListItem.length; i++){
                            if($A.util.hasClass(qryListItem[i], "selected")){
                                component.set("v.selectedOption",qryListItem[i].getElement().id);
                                component.set("v.searchInput",qryListItem[i].getElement().id);
                                $A.util.removeClass(qryListItem[i], "selected");
                                break;
                            }
                        }
                    }
                    if(component.get("v.selectedOption")!=undefined){
                        var applicationEvent = component.getEvent("caseReasonSelected");
                        applicationEvent.setParams({"item" : component.get("v.selectedOption")})
                        applicationEvent.fire();
                        const qrySuggBox = component.find('query-suggest-box');
                        $A.util.addClass(qrySuggBox, 'slds-hide');
                    }
                    $A.util.addClass(component.find('query-suggest-box'), 'slds-hide');
                }
            }
            //Removing the focus from component in case of any other key press to be able to start from the top.
            else{
                if(qryListItem!=undefined && qryListItem.length>0){
                    if(qryListItem.length>1){
                        qryListItem.sort((a, b) => (a.getElement().id > b.getElement().id) ? 1 : -1);
                    }
                    for(var i = 0; i < qryListItem.length; i++){
                        if($A.util.hasClass(qryListItem[i], "selected")){
                            $A.util.removeClass(qryListItem[i], "selected");
                        }
                    }
                }
            }
        }
    }
})