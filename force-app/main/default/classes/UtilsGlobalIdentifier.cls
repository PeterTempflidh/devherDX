/**
 * Contains utility method to generate global identifiers.
 * A global identifier is nothing else than a 8 digit integer converted to a
 * base 36 numerical system.
 *
 * WARNING:
 * For integration with other systems, is important that we use only capital
 * letters!
 */
public class UtilsGlobalIdentifier {

	static final String SYMBOLS	= 'B43DEG86HLKZWARPTSN0UYJO5FCM72VXQ19I';
	static final List<String> ALPHABET = SYMBOLS.split('');
	static final Integer BASE = ALPHABET.size();

	/**
	 * Converts an integer from base 10 to base 36, using capital letters and numbers
	 * @param  seq Integer to be converted
	 * @return     base 36 representation of seq
	 */
	public static String getGlobalIdentifierFromSequenceNumber(Integer seq) {

		if (seq == 0) {
			return ALPHABET.get(0);
		}

		String res = '';

		while (seq > 0) {
			res += ALPHABET.get(Math.mod(seq, BASE));
			seq = seq / BASE;
		}

		res = res.reverse();


		return res;
	}

	/**
	 * Converts a number expressed in base 36 to an integer in base 10.
	 * @param  globalId base 36 number to convert
	 * @return          Base 10 representation of globalId
	 */
	public static Integer getSequenceNumberFromGlobalIdentifier(String globalId) {

		Integer res = 0;

		for (String c : globalId.split('')) {
			res = (res * BASE) + SYMBOLS.indexOf(c);
		}


		return res;
	}

}