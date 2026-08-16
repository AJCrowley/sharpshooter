package ca.revolve.sharpshooter.models
{
	import ca.revolve.sharpshooter.controllers.SceneController;
	import ca.revolve.sharpshooter.elements.Puck;
	import ca.revolve.utils.Config;
	import ca.revolve.utils.Singleton;
	
	import starling.display.Stage;

	public class SharpshooterModel extends Singleton
	{
		public var cryptoKey:String = "WompWomp";
		public var config:Config = Singleton.getInstance(Config) as Config; // our main config
		public var stage:Stage; // reference to our stage
		public var currentScene:SceneController; // reference to current scene
		public var currentSceneIndex:uint = 0; // index of current scene
		public var puck:Puck; // reference to puck
		public var shotCount:uint = 0; // shot counter
		public var sessionID:String; // instance ID for server validation
		public var buttonPressing:Boolean = false; // track if a button is being pressed to suspend aim mode
	}
}