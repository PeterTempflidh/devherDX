/**
 * Created by danish.farooq on 6/6/20.
 */

({
    onblur : function(component,event,helper){
        // on mouse leave clear the listOfSeachRecords & hide the search result component
        component.set("v.listOfSearchRecords", null );
        component.set("v.searchKeyWord", '');
        var forclose = component.find("searchSection");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event,helper){
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null );
        var forOpen = component.find("searchSection");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },

    onKeyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword
        var getInputkeyWord = component.get("v.searchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and
        // call the helper
        // else close the lookup result List part.
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("searchSection");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchSection");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selaction
    onClear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        var allPillsList = component.get("v.lstSelectedRecords");

        for(var i = 0; i < allPillsList.length; i++){
            if(allPillsList[i].Id == selectedPillId){
                allPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", allPillsList);
            }
        }
        component.set("v.searchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
    },

    // This function call when the end User Select any record from the result list.
    showSelectedRecordInLookUp : function(component, event, helper) {
        component.set("v.searchKeyWord",null);
        // get the selected object record from the COMPONENT event
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.lstSelectedRecords" , listSelectedItems);

        var forClose = component.find("lookup-pill");
        $A.util.addClass(forClose, 'slds-show');
        $A.util.removeClass(forClose, 'slds-hide');

        var searchSection = component.find("searchSection");
        $A.util.addClass(searchSection, 'slds-is-close');
        $A.util.removeClass(searchSection, 'slds-is-open');
    },
})

