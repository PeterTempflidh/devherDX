({
    pupulateAndSelectLevel1 : function(component, selectedValue, isChanged) {
        let allCombinations = component.get("v.alloptions");
        let selectedType;
        let allTypes = component.get("v.types");
        console.log(selectedType);
        if(component.get("v.simpleRecord.Type")==null || component.get("v.simpleRecord.Type")==undefined){
            if(allTypes.constructor === Array){
                for(var i=0;i<allTypes.length;i++){
                    if(allTypes[i].selected){
                        selectedType=allTypes[i].value;
                        component.set("v.simpleRecord.Type",allTypes[i].value);
                    }
                }
            }
        }
        else{
            if(component.get("v.simpleRecord.Type").constructor === Object)
                selectedType=component.get("v.simpleRecord.Type").value;
            else
                selectedType=component.get("v.simpleRecord.Type");
        }
        var allLevel1 = [ {label: "-- L1 --", value: null } ];       
        var allLevel1_strings = [];
        var allLevels3ForSearch = [];
        var allLabelValues = component.get("v.allPicklistValues")['level1'];
        allCombinations.forEach(function(combo) {
            allLevels3ForSearch.push(combo.split('&&')[0]);
            if(combo.split('&&')[3] == selectedType) {
                var level1Option =  {label: allLabelValues[combo.split('&&')[2]], value: combo.split('&&')[2], selected:false};
                if(selectedValue==level1Option.value){
                    level1Option.selected=true;
                    component.set("v.simpleRecord.Case_Reason_Level_1__c",level1Option.value);
                }
                if(!allLevel1_strings.includes(combo.split('&&')[2])) {
                    allLevel1.push(level1Option);
                    allLevel1_strings.push(combo.split('&&')[2]);
                }
            }
        });
        component.set("v.level1Filtered", allLevel1);
        if(isChanged) {
            component.set("v.level2Filtered", [ {label: "-- L2 --", value: null, selected: true } ]);
            component.set('v.simpleRecord.Case_Reason_Level_2__c', null);
            component.set("v.level3Filtered", [ {label: "-- L3 --", value: null, selected: true } ]);
            component.set('v.simpleRecord.Case_Reason_Level_3__c', null);
        }
    },

    populateAndSelectLevel2 : function(component, selectedValue, isChanged) {
        let allCombinations = component.get("v.alloptions");
        let selectedLevel1;
        let allLevel1 = component.get("v.level1Filtered");
        if(component.get("v.simpleRecord.Case_Reason_Level_1__c")==null || component.get("v.simpleRecord.Case_Reason_Level_1__c")==undefined){
            if(allLevel1.constructor === Array){
                for(var i=0;i<allLevel1.length;i++){
                    if(allLevel1[i].selected){
                        selectedLevel1=allLevel1[i].value;
                        component.set("v.simpleRecord.Case_Reason_Level_1__c",allLevel1[i].value);
                    }
                }
            }
        }
        else{
            if(component.get("v.simpleRecord.Case_Reason_Level_1__c").constructor === Object)
                selectedLevel1=component.get("v.simpleRecord.Case_Reason_Level_1__c").value;
            else
                selectedLevel1=component.get("v.simpleRecord.Case_Reason_Level_1__c");
        }
        var allLevel2 = [ {label: "-- L2 --", value: null } ];
        var allLevel2_strings = [];
        var allLabelValues = component.get("v.allPicklistValues")['level2'];
        allCombinations.forEach(function(combo) {
            if(combo.split('&&')[2] == selectedLevel1) {
                var level2Option =  {label: allLabelValues[combo.split('&&')[1]], value: combo.split('&&')[1], selected:false };
                if(!allLevel2_strings.includes(combo.split('&&')[1])) {
                    if(selectedValue==level2Option.value){
                        level2Option.selected=true;
                        component.set("v.simpleRecord.Case_Reason_Level_2__c",level2Option.value);
                    }
                    allLevel2.push(level2Option);
                    allLevel2_strings.push(combo.split('&&')[1]);
                }
            }
        });

        component.set("v.level2Filtered", allLevel2);

        if(isChanged) {
            component.set("v.level3Filtered", [ {label: "-- L3 --", value: null, selected: true } ]);
            component.set('v.simpleRecord.Case_Reason_Level_3__c', null);
        }
    },

    populateAndSelectLevel3 : function(component, selectedValue) {
        let allCombinations = component.get("v.alloptions");
        let selectedLevel2;
        let allLevel2 = component.get("v.level2Filtered");
        console.log(selectedLevel2);
        if(component.get("v.simpleRecord.Case_Reason_Level_2__c")==null || component.get("v.simpleRecord.Case_Reason_Level_2__c")==undefined){
            if(allLevel2.constructor === Array){
                for(var i=0;i<allLevel2.length;i++){
                    if(allLevel2[i].selected){
                        selectedLevel2=allLevel2[i].value;
                        component.set("v.simpleRecord.Case_Reason_Level_2__c",allLevel2[i].value);
                    }
                }
            }
        }
        else{
            if(component.get("v.simpleRecord.Case_Reason_Level_2__c").constructor === Object)
                selectedLevel2=component.get("v.simpleRecord.Case_Reason_Level_2__c").value;
            else
                selectedLevel2=component.get("v.simpleRecord.Case_Reason_Level_2__c");
        }
        var allLevel3 = [ {label: "-- L3 --", value: null } ];        
        var allLevel3_strings = [];
        var allLabelValues = component.get("v.allPicklistValues")['level3'];
        allCombinations.forEach(function(combo) {
            var combo3 = combo.split('&&')[0];
            if(combo.split('&&')[1] == selectedLevel2) {
                if(combo3.indexOf(' (related to ')>0){
                    combo3=combo3.split(' (related to ')[0];
                }
                var level3Option =  {label: allLabelValues[combo3], value: combo3, selected:false };
                if(!allLevel3_strings.includes(combo3)) {
                    if(selectedValue==level3Option.value){
                        level3Option.selected=true;
                        component.set("v.simpleRecord.Case_Reason_Level_3__c",level3Option.value);
                    }
                    allLevel3.push(level3Option);
                    allLevel3_strings.push(combo3);
                }
            }
        });
        component.set("v.level3Filtered", allLevel3);
        if(selectedValue) {
            component.set('v.simpleRecord.Case_Reason_Level_3__c', selectedValue);
        }
    },

    handleCallbackError : function(response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + 
                errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
    },

    setAllOptions: function(component,event,helper){
        var retValue=component.get("v.alloptions");
        var level3Options=[];
        retValue.forEach(function(combo){
            var level3Label='';
            if(component.get("v.simpleRecord.Type")!=null){
                if(combo.split('&&')[0].includes(' (related to')){
                    var level3Val=combo.split('&&')[0].split(' (related to');
                    var level3Value=component.get("v.allPicklistValues")['level3'][level3Val[0]];
                    var l2=component.get("v.allPicklistValues")['level2'][level3Val[1].split(')')[0].trim()];

                    if(combo.split('&&')[3]==component.get('v.simpleRecord.Type')){
                        level3Label=level3Value+' ('+$A.get("{!$Label.c.Case_Reason_related_to}")+' '+l2+')';
                    }
                }

                else{
                    if(combo.split('&&')[3]==component.get('v.simpleRecord.Type'))
                        level3Label=component.get("v.allPicklistValues")['level3'][combo.split('&&')[0]];
                }
                if(level3Label!=''){
                    level3Options.push(level3Label);
                }
            }
        });
        component.set("v.level3options", level3Options);
    }
})