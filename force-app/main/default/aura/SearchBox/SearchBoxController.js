({
    onInit : function(c,e,h) {
        var input = document.getElementById("query-box");
        if(input && input.getAttribute("autocomplete") !== "off"){
            input.setAttribute("autocomplete","off");
        }
        c.set("v.searchInput","");
    },

    query  : function(cmp, event, helper) {
        const typedQuery = event.getSource().get('v.value');
        try {
            helper.autoComplete(cmp, typedQuery);
        } catch(e){
            console.log(e.message);
        }
    },

    hideSuggestions : function(c, e, h) {
        setTimeout(function() {
            const qrySuggBox = c.find('query-suggest-box');
            $A.util.addClass(qrySuggBox, 'slds-hide');
        }, 300);
    },

    showSuggestions : function(c, e, h) {
        const qrySuggBox = c.find('query-suggest-box');
        $A.util.removeClass(qrySuggBox, 'slds-hide');	
    },
    enablecasereasonform: function(c, e, h) {
        var enableCompEvent = c.getEvent("CaseReasonFormEventonSearch");
        enableCompEvent.setParams({"message" :  "enableInputForm"});        
        enableCompEvent.fire();    
    },
    moveToSuggestionBox : function(component,event,helper){
        helper.handleSelectEnter(component,event,helper,event.code,1);
    },

    handlesuggestionClick  : function(cmp, event, helper) {
        var selectedItem=helper.handleSelect(cmp, event, helper);
        var applicationEvent = cmp.getEvent("caseReasonSelected");
        applicationEvent.setParams({"item" : selectedItem})
        applicationEvent.fire();
    },

    focus: function(el){
        el.focus();
        return el==document.activeElement;
    }
})