({
    disablePopOut: function(component,event,helper){
        var utilityBarAPI = component.find("utilitybar");
        utilityBarAPI.getAllUtilityInfo().then(function(allInfo) {
            var utilInfo;
            for(utilInfo of allInfo){
                if(utilInfo.utilityLabel == 'Phone'){
                    utilityBarAPI.getUtilityInfo({
                        utilityId: utilInfo.id
                    }).then(function(phoneUtil) {
                        utilityBarAPI.disableUtilityPopOut({
                            utilityId: phoneUtil.id,
                            disabled: true
                        });
                    });
                }
            }
        }).catch();
    }
});