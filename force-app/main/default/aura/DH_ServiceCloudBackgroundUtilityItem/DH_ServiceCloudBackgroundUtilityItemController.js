({
    init: function(component,event,helper){
        window.setTimeout(function() {
            helper.disablePopOut(component,event,helper)
        }, 1000);
    }
});