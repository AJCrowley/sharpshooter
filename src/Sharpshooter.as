package
{
	import ca.revolve.sharpshooter.constants.FileConstants;
	import ca.revolve.sharpshooter.controllers.GameController;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.events.ConfigEvent;
	
	import com.sociodox.theminer.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	
	import starling.core.Starling;
	
	// set SWF basic properties
	[SWF(frameRate=60, width=760, height=600, backgroundColor=0x222222)]
	public class Sharpshooter extends Sprite
	{
		// create singleton instance of Model
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// reference to starling engine
		private var _starling:Starling;
		
		public function Sharpshooter()
		{
			Starling.multitouchEnabled = true;
			// set listener for config loaded
			_model.config.addEventListener
			(
				ConfigEvent.LOADED,
				function(event:Event):void
				{
					// config has loaded, init
					initialize();
				}
			);
			// load config into model from default assets dir/config file
			_model.config.loadConfig(FileConstants.ASSETS_DIR + FileConstants.CONFIG_FILE);
		}
		
		private function initialize():void
		{
			if(_model.config.data.debug.@log == "true")
			{
				// set up handler for uncaught errors
				loaderInfo.uncaughtErrorEvents.addEventListener
				(
					UncaughtErrorEvent.UNCAUGHT_ERROR,
					function(event:UncaughtErrorEvent):void
					{
						ExternalInterface.call("console.log", "Error " + event.error.errorID + ": " + event.error.text);
					}
				);
			}
			if(stage.loaderInfo.parameters.sessionID)
			{
				// get session ID from flashvars
				_model.sessionID = stage.loaderInfo.parameters.sessionID;
			}
			if(stage.loaderInfo.parameters.stage)
			{
				// get first stage from flashvars
				_model.currentSceneIndex = stage.loaderInfo.parameters.stage;
			}
			// set handleLostContext - if browser loses context, rendering will resume on regained context if true, at small performance cost
			Starling.handleLostContext = (_model.config.data.starling.@handleLostContext == "true");
			// check debug setting for forced software rendering
			var renderer:String = _model.config.data.debug.@forceSoftwareRendering == "true" ? "software" : "auto";
			// init starling with our main Game class
			_starling = new Starling(GameController, stage, null, null, renderer);
			// set anti aliasing based on config value
			_starling.antiAliasing = int(_model.config.data.starling.@antiAliasing);
			// store reference to stage in model
			_model.stage = _starling.stage;
			// start the game engine
			_starling.start();
			// check if we're debugging and use the miner
			if(_model.config.data.debug.@miner == "true")
			{	
				addChild(new TheMiner());
			}
		}
	}
}