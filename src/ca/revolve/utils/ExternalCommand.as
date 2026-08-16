package ca.revolve.utils
{
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	
	import flash.external.ExternalInterface;

	public class ExternalCommand
	{	
		public static const SERVER_COMMAND:String = "serverCommand";
		public static const CLIENT_COMMAND:String = "clientCommand";
		public static const COMMAND_SAVE_SCORE:String = "saveScore";
		public static const GAME_OVER:String = "gameOver";
		public static const LOADING:String = "loading";
		public static const SCORESCREEN:String = "scoreScreen";
		
		public static function call(func:String, command:String, encrypted:Boolean = false):void
		{
			var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
			// encrypt command data if necessary
			if(encrypted)
			{
				var crypto:CryptoWrapper = new CryptoWrapper(_model.cryptoKey);
				command = crypto.encrypt(command);
			}
			// and pass the call on
			try
			{
				ExternalInterface.call(func, command);
			}
			catch(e:Error)
			{
				// do nothing
			}
		}
	}
}