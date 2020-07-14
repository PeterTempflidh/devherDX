({
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
    }
})