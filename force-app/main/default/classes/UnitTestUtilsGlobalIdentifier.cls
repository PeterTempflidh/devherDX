@isTest
private class UnitTestUtilsGlobalIdentifier {
	
	@isTest static void getGlobalIdentifierFromSequenceNumberReturnsCorrectlyIfSequenceIsZero() {
		System.assertEquals('B', UtilsGlobalIdentifier.getGlobalIdentifierFromSequenceNumber(0));
	}
	
	@isTest static void getGlobalIdentifierFromSequenceNumberReturnsCorrectlyIfSequenceGreaterThanZero() {
		Integer seq = 112357080;
		System.assertEquals('4VQ6KB', UtilsGlobalIdentifier.getGlobalIdentifierFromSequenceNumber(seq));
	}

	@isTest static void getGlobalIdentifierFromSequenceNumberReturnsEmptyStringIfSequenceIsLessThanZero() {
		System.assert(String.isBlank(UtilsGlobalIdentifier.getGlobalIdentifierFromSequenceNumber(-423162934)));
	}

	@isTest static void getSequenceNumberFromGlobalIdentifierReturnsZeroIfStringIsEmpty() {
		System.assertEquals(0, UtilsGlobalIdentifier.getSequenceNumberFromGlobalIdentifier(''));
	}

	@isTest static void getSequenceNumberFromGlobalIdentifierReturnsCorrectly() {
		System.assertEquals(112357080, UtilsGlobalIdentifier.getSequenceNumberFromGlobalIdentifier('4VQ6KB'));
	}
	
}