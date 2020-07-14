/**
 * Created by p.bansal on 02-Jan-20.
 * Description: This class will contain limit evalutaions to handle the limits errors 
 */

public class GovernorLimits_Utils {
    
    /** 
	 * @description while processing records, 
	 * monitor our query count and throw a custom 
	 */   
   	public static void checkGovenorLimits() { 
       
   		if (Limits.getQueries() >= Limits.getLimitQueries()-1 ) {
   			throw new GovernorLimits_UtilsException('Salesforce Governor Limits has been reached. Please raise a case with Salesforce team');
   		}   		
    }

    public class GovernorLimits_UtilsException extends Exception { }
}
