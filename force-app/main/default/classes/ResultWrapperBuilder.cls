public inherited sharing class ResultWrapperBuilder {
    private Id id;
    private Id ownerId;
    private Id queueId;
    private String userMessage;
    private Boolean success;
    private String errorMessage;
    private Map<String,String> values { get;set; }

    public ResultWrapper Build() {
        ResultWrapper resObject = new ResultWrapper(this.success);
        resObject.UserMessage = this.userMessage;
        resObject.Error = this.errorMessage;
        resObject.OwnerId = this.ownerId;
        resObject.Id = this.id;
        resObject.values = this.values;
        return resObject;
    }

    public ResultWrapperBuilder(Boolean success) {
        this.id = id;
        this.success = success;
    }

    public ResultWrapperBuilder setId(Id id) {
        this.id = id;
        return this;
    }


    public ResultWrapperBuilder setOwnerId(Id ownerId) {
        this.ownerId = ownerId;
        return this;
    }

    public ResultWrapperBuilder setQueueId(Id queueId) {
        this.queueId = queueId;
        return this;
    }


    public ResultWrapperBuilder setUserMessage(String message) {
        this.userMessage = message;
        return this;
    }

    public ResultWrapperBuilder setErrorMessage(String message) {
        this.errorMessage = message;
        return this;
    }

    public ResultWrapperBuilder setErrorMessage(Database.Error error) {
        this.errorMessage = error.getMessage();
        return this;
    }

    public ResultWrapperBuilder setErrorMessage(Database.Error[] errors) {
        for(Database.Error err : errors) {
            this.errorMessage += err.getMessage() + '  ';
        }
        return this;
    }

    public ResultWrapperBuilder setKeyValuePair(String key, String value) {
        if(values == null) {
            values = new Map<String, String>();
        }

        values.put(key, value);
        return this;
    }
}