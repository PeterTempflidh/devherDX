public class ResultWrapper {
    public String Error { get; set; }
    public Boolean Success { get; set; }
    public String UserMessage { get; set; }
    public Id Id { get; set; }
    public Id OwnerId { get; set; }
    public Id QueueId { get; set; }
    public Map<String,String> Values { get;set; }

    public ResultWrapper(Boolean success) {
        this.Success = success;
    }

    public static ResultWrapper parse(String jsonStr) {
        JSONParser parser = JSON.createParser(jsonStr);
        if (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                // Read entire ResultWrapper object
                ResultWrapper res = (ResultWrapper)parser.readValueAs(ResultWrapper.class);
                return res;
            }
        }

        return null;
    }
}