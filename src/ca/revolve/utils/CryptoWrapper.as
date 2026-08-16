package ca.revolve.utils
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	
	public class CryptoWrapper
	{
		private var type:String = "simple-des-ecb"; // set encryption type
		private var key:ByteArray; // encryption key
		
		public function CryptoWrapper(key:String)
		{
			// convert key from string to bytearray
			this.key = Hex.toArray(Hex.fromString(key));
		}
		
		public function encrypt(txt:String = ""):String
		{
			// convert input string to bytearray
			var data:ByteArray = Hex.toArray(Hex.fromString(txt));
			// create pad
			var pad:IPad = new PKCS5;
			// get cipher mode
			var mode:ICipher = Crypto.getCipher(type, key, pad);
			pad.setBlockSize(mode.getBlockSize());
			// encrypt
			mode.encrypt(data);
			// and return as base64 encoded
			return Base64.encodeByteArray(data);
		}
		
		public function decrypt(txt:String = ""):String
		{
			// convert input to bytearray
			var data:ByteArray = Base64.decodeToByteArray(txt);
			var pad:IPad = new PKCS5;
			var mode:ICipher = Crypto.getCipher(type, key, pad);
			pad.setBlockSize(mode.getBlockSize());
			// decrypt data
			mode.decrypt(data);
			// and return as string
			return Hex.toString(Hex.fromArray(data));
		}
	}
}