/*
 * Contains utility method to work with apex pages
 */
public class ClsUtilsApexPages
{

	public static void addInfoMessage(String message) {
		addMessage(ApexPages.Severity.INFO, message);
	}

    public static void addConfirmMessage(String message) {
        addMessage(ApexPages.Severity.CONFIRM, message);
    }
    
    public static void addErrorMessage(String message) {
    	addMessage(ApexPages.Severity.ERROR, message);
    }

    public static void addWarningMessage(String message) {
        addMessage(ApexPages.Severity.WARNING, message);
    }

    public static void addMessage(ApexPages.Severity sev, String msg) {
        ApexPages.addMessage(
            new ApexPages.Message(sev, msg)
        );
    }
}