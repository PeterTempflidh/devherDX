({
    onInit : function(component,event,helper) {
       
        component.set("v.formDisabled", true);
        var action = component.get("c.getAllPicklistValuesReason3");
        action.setParams({ caseId : component.get("v.recordId")});
        var action2 = component.get("c.getAllPicklistValues");
        action2.setParams({ caseId : component.get("v.recordId")});
        var action3 = component.get("c.getCurrentCaseReason");
        action3.setParams({caseId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());
                component.set("v.alloptions", retValue);
                component.set("v.formDisabled", false);

                var allLevel1 = [ {label: "-- L1 --", value: null } ];
                var allLevel1_strings = [];
                var typesStrings = [];
                var types = [ {label: "-- Type --", value: null } ];
                // these are searchable options - all level 3 values
                var level3Options=[];
                retValue.forEach(function(combo){
                    var level3Label='';
                    var type = combo.split('&&')[3];
                    if(!typesStrings.includes(type)) {
                        typesStrings.push(type);
                        types.push({label: component.get("v.allPicklistValues")['type'][combo.split('&&')[3]], value: combo.split('&&')[3]});
                    }

                    var level1Option =  {label: combo.split('&&')[2], value: combo.split('&&')[2] };
                    if(!allLevel1_strings.includes(combo.split('&&')[2])) {
                        allLevel1.push(level1Option);
                        allLevel1_strings.push(combo.split('&&')[2]);
                    }
                });
                component.set("v.types", types);
                component.set("v.level1Filtered", allLevel1);
                component.set("v.formDisabled", false);
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                helper.handleCallbackError(response);
            }
        });
        action2.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                component.set("v.allPicklistValues",response.getReturnValue());
            }
        });
        action3.setCallback(this, function(response) {
            component.find("caseRecordEditor").reloadRecord();
            var state = response.getState();
            if (state === "SUCCESS") {
                var types=component.get("v.types");
                var retValue = response.getReturnValue();
                component.set('v.simpleRecord', retValue);
                for (var i = 0; i < types.length; i++) {
	                if(types[i].value==component.get("v.simpleRecord.Type")){
                    	types[i].selected=true;
                    	break;
    	            }
                }
                component.set("v.types",types);
                helper.pupulateAndSelectLevel1(component, component.get('v.simpleRecord.Case_Reason_Level_1__c'),false);
                helper.populateAndSelectLevel2(component, component.get('v.simpleRecord.Case_Reason_Level_2__c'),false);
                helper.populateAndSelectLevel3(component, component.get('v.simpleRecord.Case_Reason_Level_3__c'));
                helper.setAllOptions(component,event,helper);
                component.set("v.formDisabled", false);
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                helper.handleCallbackError(response);
            }
        });
        $A.enqueueAction(action2);
        $A.enqueueAction(action);
        $A.enqueueAction(action3);
    },

    selectedLevel1Changed : function(component, event, helper) {
        component.set("v.simpleRecord.Case_Reason_Level_2__c","");
        component.set("v.simpleRecord.Case_Reason_Level_3__c","");
        helper.populateAndSelectLevel2(component, null, true);
    },

    selectedLevel2Changed : function(component, event, helper) {
        component.set("v.simpleRecord.Case_Reason_Level_3__c","");
        helper.populateAndSelectLevel3(component, null);
    },

    setCaseReason : function(component, event, helper) {
        let foundLevel3 = event.getParam("item");
        let allCombinations = component.get("v.alloptions");
        allCombinations.forEach(function(combo) {
            var trimmedLevel3;
            if(combo.split('&&')[0].indexOf(' (related to')>0){
                trimmedLevel3=combo.split('&&')[0].split(' (related to')[0];
            }
            else
                trimmedLevel3=combo.split('&&')[0];
            var level3=component.get("v.allPicklistValues")['level3'][trimmedLevel3];
            if(foundLevel3.indexOf(' ('+$A.get("{!$Label.c.Case_Reason_related_to}"))>0){
                if(level3==foundLevel3.split(' ('+$A.get("{!$Label.c.Case_Reason_related_to}"))[0])
                    level3=level3+' ('+$A.get("{!$Label.c.Case_Reason_related_to}")+' '+component.get("v.allPicklistValues")['level2'][combo.split('&&')[1].trim()]+')';
            }
            if(level3==foundLevel3) {
                var levels = combo.split('&&');
                var types=component.get("v.types");
                for (var i = 0; i < types.length; i++) {
                    types[i].selected=false;
                    if(types[i].value===levels[3]){
                        types[i].selected=true;
                        component.set("v.simpleRecord.Type",types[i].value);
                    }
                }
                component.set("v.types",types);
                //component.set('v.simpleRecord.Type', component.get("v.allPicklistValues")['type'][levels[3]]);
                helper.pupulateAndSelectLevel1(component, levels[2], false);
                var level1s=component.get("v.level1Filtered");
                for (var i = 0; i < level1s.length; i++) {
                    level1s[i].selected=false;
                    if(level1s[i].value===levels[2]){
                        level1s[i].selected=true;
                        component.set("v.simpleRecord.Case_Reason_Level_1__c",level1s[i].value);
                    }
                }
                component.set("v.level1Filtered",level1s);
                helper.populateAndSelectLevel2(component, levels[1], false);
                var level2s=component.get("v.level2Filtered");
                for (var i = 0; i < level2s.length; i++) {
                    level2s[i].selected=false;
                    if(level2s[i].value===levels[1]){
                        level2s[i].selected=true;
                        component.set("v.simpleRecord.Case_Reason_Level_2__c",level2s[i].value);
                    }
                }
                component.set("v.level2Filtered",level2s);
                if(levels[0].indexOf(' (related to')>0){
                    levels[0]=levels[0].split(' (related to')[0];
                }
                helper.populateAndSelectLevel3(component, levels[0]);
                var level3s=component.get("v.level3Filtered");
                for (var i = 0; i < level3s.length; i++) {
                    level3s[i].selected=false;
                    if(level3s[i].value===levels[0]){
                        level3s[i].selected=true;
                        component.set("v.simpleRecord.Case_Reason_Level_3__c",level3s[i].value);
                    }
                }
                component.set("v.level3Filtered",level3s);
            }
        });
        component.find("Select1").focus();
    },

    caseTypeChanged : function(component, event, helper) {		
        component.set("v.simpleRecord.Case_Reason_Level_1__c","");
        component.set("v.simpleRecord.Case_Reason_Level_2__c","");
        component.set("v.simpleRecord.Case_Reason_Level_3__c","");
        helper.setAllOptions(component,event,helper);
        var searchBox = component.find("searchBox");
        searchBox.resetSearch();	
        component.set("v.isFieldDisabled" , false);
        helper.pupulateAndSelectLevel1(component, null,true);
    },
    
    handleSaveRecord: function(component, event, helper) {
        component.set("v.isSaving",true);
        component.find("notificationsLibrary").showToast({
            title: "Saving",
            message : "Saving to server...",
            type: "info"
        });
		component.set("v.spinner" , true);
        component.find("caseRecordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                var title=$A.get("{!$Label.c.Case_reason_saved}");
                component.find('notificationsLibrary').showToast({
                    "title": title,
                    "message": "",
                    "variant": "success"
                });                  		
                    component.set("v.isFieldDisabled" , true);
                    $A.get('e.force:refreshView').fire();
                } else if (saveResult.state === "ERROR") {
                var title=$A.get("{!$Label.c.Case_Reason_Not_Saved_Title}");
                var message=$A.get("{!$Label.c.Case_Reason_Not_Saved_Message}");
                component.find('notificationsLibrary').showToast({
                    "title": title,
                    "message": message,
                    "variant": "error"
                });
               component.set("v.isFieldDisabled" , false);
            } else {              
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
            component.set("v.isSaving",false);
            var searchBox = component.find("searchBox");
            if(!$A.util.isUndefinedOrNull(searchBox)){
			   searchBox.resetSearch();      
			} 
            var appEvent = $A.get("e.c:compRefreshEvent");
            appEvent.setParams({"doRefresh":true});
            appEvent.fire();
            component.set("v.spinner" , false);            
        }));
    },
	enableform: function(component) {
        component.set("v.isFieldDisabled" , false);    
    },
    disbaleFormOnCancel: function(component,event) {      
       component.set("v.isFieldDisabled" , true);
       component.reinit();
       var searchBox = component.find("searchBox");
       if(!$A.util.isUndefinedOrNull(searchBox)){
		searchBox.resetSearch();      
       }       
    },
    enableFormOnSearch: function(component,event) {
        let eventParam = event.getParam("message");
        if(eventParam == "enableInputForm"){
            component.set("v.isFieldDisabled" , false);
        }
    },
	recordUpdated:function(component,event) {
        var changeType = event.getParams().changeType;
        if(changeType==="CHANGED"){           
           var appEvent = $A.get("e.c:CaseReasonRefreshEvent");
           appEvent.fire();
        }
    },
    handleCompRefreshEvent: function(component,event) {
     component.reinit();
    }
})