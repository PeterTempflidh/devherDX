public with sharing class LibScarfaceCryptor {
	public static String key ='AES256';
	public LibScarfaceCryptor() {
		
	}
	public static String encrypt(String sobjectId,Blob cryptoKey){

		Blob encryptedData = Crypto.encryptWithManagedIV(key,cryptoKey,Blob.valueOf(sobjectId));
		return EncodingUtil.base64Encode(encryptedData);
	}

	public static String decrypt(String encryptedData, Blob cryptoKey){
		Blob deCoded = EncodingUtil.base64Decode(encryptedData);
		Blob decryptedData = Crypto.decryptWithManagedIV(key,cryptoKey,deCoded);
		return decryptedData.toString();
	}

}