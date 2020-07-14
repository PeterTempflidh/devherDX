/**
 * Utility class to access values stored in NumberToStringLiteral__c.
 * Throw this custom setting is possible to retrieve numbers string literal 
 * representation in different locales
 */
public class UtilsNumberToStringLiteral {

	/**
	 * Given a number returns the string literal representation using 
	 * current user locale
	 * @param  num Number to retrieve
	 * @return     Number string literal or empty string
	 */
	public static  String getStringLiteralByUserLocale(Integer num) {
		return getStringLiteralByLocale(num, UserInfo.getLocale());
	}

	/**
	 * Given a number and a locale retrieves number string literal
	 * @param  num    Number to retrieve
	 * @param  locale String literal locale to retrieve
	 * @return        Number String literal or an empty string
	 */
	public static String getStringLiteralByLocale(Integer num, String locale) {
		// checks for null values
		if (num == null || String.isBlank(locale)) {
			return '';
		}

		// try to retrieve the value
		NumberToStringLiteral__c res = NumberToStringLiteral__c.getInstance(locale + '_' + String.valueOf(num));
		return res != null ? res.String_Literal__c : '';
	}
}