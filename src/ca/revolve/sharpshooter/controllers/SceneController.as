package ca.revolve.sharpshooter.controllers
{
	import ca.revolve.sharpshooter.collections.Actors;
	import ca.revolve.sharpshooter.collections.Badges;
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.elements.Actor;
	import ca.revolve.sharpshooter.elements.HitArea;
	import ca.revolve.sharpshooter.elements.InstructionScreen;
	import ca.revolve.sharpshooter.elements.Player;
	import ca.revolve.sharpshooter.elements.Puck;
	import ca.revolve.sharpshooter.elements.Shot;
	import ca.revolve.sharpshooter.events.PlayerEvent;
	import ca.revolve.sharpshooter.events.PopupEvent;
	import ca.revolve.sharpshooter.events.PuckEvent;
	import ca.revolve.sharpshooter.events.SceneEvent;
	import ca.revolve.sharpshooter.events.ScoreEvent;
	import ca.revolve.sharpshooter.events.SoundEvent;
	import ca.revolve.sharpshooter.events.SpriteEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.ExternalCommand;
	import ca.revolve.utils.FileTools;
	import ca.revolve.utils.ImageLoader;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.XMLLoader;
	import ca.revolve.utils.events.ImageLoaderEvent;
	import ca.revolve.utils.events.XMLLoaderEvent;
	
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	public class SceneController extends Sprite
	{
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// the background image for our scene
		private var backdrop:Texture;
		// player object
		private var player:Player;
		// all actors (interactive objects) in our scene
		private var actors:Actors;
		// hitboxes not attached to actors, usually used for the borders of our scene
		private var hitboxes:Vector.<HitArea>;
		// sound controller for this scene
		private var soundController:SoundController;
		// loadchain - call functions synchronously and in sequence
		private var loadChain:Vector.<Function>;
		// instruction screen
		private var instructions:InstructionScreen;
		
		// directory containing scene files
		public var currentPath:String = "";
		// min shot power
		public var minPower:Number;
		// max shot power
		public var maxPower:Number;
		// allowed shot angle range
		public var angleRange:uint;
		// XML definition of scene
		public var sceneXML:XML;
		// the shot
		public var shot:Shot = new Shot();
		// shots on this stage
		public var numShots:uint;
		// score for this stage
		public var score:int = 0;
		// badges object
		public var badges:Badges = new Badges();
		// level completed
		public var completed:Boolean = false;
		// actors to place under puck in layering
		private var actorsUnder:Vector.<XML>;
		
		public function SceneController(xmlPath:String)
		{
			_model.currentScene = this; // store reference to this scene in the model
			loadChain = new Vector.<Function>; // init loadchain
			// add function call sequence to loadchain
			loadChain.push(getInstructions);
			loadChain.push(loadSounds);
			loadChain.push(loadHitBoxes);
			loadChain.push(loadPlayer);
			loadChain.push(loadActors);
			loadChain.push(loadPuck);
			loadChain.push(loadActors);
			// set event listeners
			addEventListener(SceneEvent.LOADCHAIN_NEXT, loadChainNextHandler); // set handlers for loadchain
			currentPath = FileTools.getPath(xmlPath);
			var xmlLoader:XMLLoader = new XMLLoader(xmlPath); // load scene XML
			xmlLoader.addEventListener(XMLLoaderEvent.LOADED, parseXML, false, 0, true);
		}
		
		private function parseXML(event:XMLLoaderEvent):void
		{
			sceneXML = event.target.data; // store loaded data
			// let client know we're loading a new stage
			ExternalCommand.call(ExternalCommand.CLIENT_COMMAND, ExternalCommand.LOADING + "," + sceneXML.@title);
			minPower = sceneXML.@minPower; // set min power for shot
			maxPower = sceneXML.@maxPower; // set max power for shot
			angleRange = sceneXML.@angleRange; // set angle range for shot
			numShots = sceneXML.@numShots; // number of shots on this stage
			var imageLoader:ImageLoader = new ImageLoader(currentPath + sceneXML.@backdrop); // set up backdrop loader
			imageLoader.addEventListener(ImageLoaderEvent.LOADED, addImage, false, 0, true); // listen for image loaded event for backdrop
		}
		
		private function getInstructions(event:SceneEvent = null):void
		{
			// do we have instructions?
			if(sceneXML.instructions.length() > 0)
			{
				// yep, create instructions instance
				instructions = new InstructionScreen(sceneXML.instructions[0]);
				// and show them when ready
				instructions.addEventListener(PopupEvent.POPUP_READY, showInstructions);
			}
			else
			{
				// no, just start the scene
				startScene();
			}
			// call next item in loadchain
			dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT));
		}
		
		private function showInstructions(event:PopupEvent):void
		{
			// instructions ready, add them to stage
			addChild(instructions);
			// and listen for them to be closed
			instructions.addEventListener
			(
				PopupEvent.POPUP_DISMISS,
				function(event:PopupEvent):void
				{
					// instructions closed, start the scene
					startScene();
				}
			);
		}
		
		private function addImage(event:ImageLoaderEvent):void
		{
			backdrop = Texture.fromBitmap(event.bitmap); // create texture from loaded backdrop
			addChild(new Image(backdrop)); // and add the texture to the scene
			dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT)); // fire event to let everyone know our backdrop is loaded
		}
		
		private function loadChainNextHandler(event:SceneEvent):void
		{
			if(loadChain.length == 0) // is loadchain empty?
			{
				removeEventListener(SceneEvent.LOADCHAIN_NEXT, loadChainNextHandler);
				dispatchEvent(new SceneEvent(SceneEvent.LAYOUT_COMPLETE)); // let everyone know we're done
			}
			else
			{
				var next:Function = loadChain.pop(); // pop next function in chain off the stack
				next(event); // and call it
			}
		}
		
		private function loadPlayer(event:SceneEvent):void
		{
			player = new Player(sceneXML.actors.player[0]); // create player instance from XML
			player.addEventListener(PlayerEvent.LOADED, addPlayer); // listen for load complete
		}
		
		private function addPlayer(event:SpriteEvent):void
		{
			event.target.removeEventListener(PlayerEvent.LOADED, addPlayer);
			addChild(event.target as Player); // add to stage
			dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT)); // notify loadchain that we're done
		}
		
		private function loadPuck(event:SceneEvent):void
		{
			_model.puck = new Puck(sceneXML.actors.puck[0]);
			_model.puck.addEventListener(SpriteEvent.LOADED, addPuck); // listen for load complete
			_model.puck.addEventListener
			(
				PuckEvent.END_SHOT,
				endShot
			);
		}
		
		private function addPuck(event:SpriteEvent):void
		{
			_model.puck.removeEventListener(SpriteEvent.LOADED, addPuck);
			addChild(_model.puck); // add to stage
			dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT)); // notify loadchain that we're done
		}
		private function loadActors(event:SceneEvent):void
		{
			// assume first run
			var firstRun:Boolean = true;			
			if(!actors)
			{
				// init collection
				actors = new Actors(); // initialize actors container
			}
			else
			{
				firstRun = false;
			}
			var currentActorCount:uint = actors.actors.length;
			for each(var actorXML:XML in sceneXML.actors.actor) // loop through each actor definition in our XML
			{
				if((actorXML.@under == "true" && firstRun) || (!firstRun && actorXML.@under != true))
				{
					var actor:Actor = new Actor(actorXML); // initialize actor with XML
					actor.addEventListener(SpriteEvent.LOADED, checkActorsLoaded); // set event listener for once the actor is loaded
					actor.addEventListener(SoundEvent.PLAY_SOUND, playSound);
					// listen for score events
					actor.addEventListener
					(
						ScoreEvent.SCORE,
						function(event:ScoreEvent):void
						{
							score += event.points; // keep track of points
							dispatchEvent(event); // pass the event up
						}
					);
					actors.push(actor);
				}
			}
			// did we not load any actors?
			if(actors.actors.length == currentActorCount)
			{
				// nope, let everyone know we're done
				dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT));
			}
		}
		
		private function endShot(event:PuckEvent):void
		{
			// wait 3 seconds and call for scene reset
			setTimeout
			(
				function(event:Event = null):void
				{
					_model.shotCount++;
					dispatchEvent(new SceneEvent(SceneEvent.RESET_SCENE)); // trigger scene reset
				},
				_model.config.data.scenes.@endShotWaitTime
			);
		}
				
		private function checkActorsLoaded(event:SpriteEvent):void
		{
			event.target.removeEventListener(SpriteEvent.LOADED, checkActorsLoaded);
			var loadComplete:Boolean = true; // var to tell if all actors are loaded, default to true
			for each(var actor:Actor in actors.actors)
			{
				if(!actor.loaded) // and if an actor isn't loaded yet
				{
					loadComplete = false; // set it back to false
					break; // and quit this loop
				}
			}
			if(loadComplete)
			{
				for each(actor in actors.actors) // loop through all actors
				{
					// check that we haven't already been added to the stage
					if(!actor.onStage)
					{
						addChild(actor); // add the actor to our scene
						actor.onStage = true; // make note that we're on stage
					}
				}
				dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT)); // and let everyone know that our scene has been laid out
			}
		}
		
		private function loadHitBoxes(event:SceneEvent = null):void
		{
			hitboxes = new Vector.<HitArea>; // init vector
			for each(var hitboxXML:XML in sceneXML.hitBoxes.hitBox) // loop through all hitboxes
			{
				var hitBox:HitArea = new HitArea(hitboxXML); // create hitbox from xml
				addChild(hitBox.mc); // add hitbox to stage
				// if we're in debug mode, show hit area
				if(_model.config.data.debug.@showHitAreas == "true")
				{
					addChild(hitBox.displayMC);
				}
				hitBox.listenForCollisions();
				hitBox.addEventListener(SoundEvent.PLAY_SOUND, playSound);
				hitboxes.push(hitBox); // add to hitboxes vector
			}
			dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT));
		}
		
		private function playSound(event:SoundEvent):void
		{
			soundController.play(event.id);
		}
		
		private function loadSounds(event:SceneEvent = null):void
		{
			// do we have sounds to load?
			if(sceneXML.sounds.sound.length() > 0)
			{
				// create sound controller instance from XML
				soundController = new SoundController(sceneXML.sounds.sound);
				// listen for bank to fully preload
				soundController.addEventListener(SoundEvent.BANK_LOADED, bankLoaded);
			}
			else
			{
				// call next in load chain
				dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT));
			}
		}
		
		private function bankLoaded(event:SoundEvent):void
		{
			soundController.removeEventListener(SoundEvent.BANK_LOADED, bankLoaded);
			// call next in load chain
			dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT));
		}
		
		private function startScene(event:SceneEvent = null):void
		{
			// add listeners for touch (mouse) events
			_model.stage.addEventListener
			(
				TouchEvent.TOUCH,
				function(event:TouchEvent):void
				{
					switch(event.touches[0].phase)
					{
						case TouchPhase.HOVER:
							// do nothing
							break;
						
						case TouchPhase.BEGAN:
							// if we're not pressing a button
							if(!_model.buttonPressing)
							{
								// set aim mode
								player.startAim(event);
							}							
							break;
						
						case TouchPhase.MOVED:
							// do nothing
							break;
						
						case TouchPhase.ENDED:
							// if we're not pressing a button
							if(!_model.buttonPressing)
							{
								// take shot
								player.stateMachine.setState(StateConstants.SHOOT);
							}
							break;
					}
				}
			);
			// listen for shot event from player, this will sync to animation
			player.addEventListener
			(
				PuckEvent.SHOT,
				takeShot
			);
			// let our scene controller know that we've initialized
			dispatchEvent(new SceneEvent(SceneEvent.LOADCHAIN_NEXT));
		}
		
		private function takeShot(event:PuckEvent):void
		{
			// pass shot object on to puck
			_model.puck.shoot(event.shot);
			// play the shot sound
			if(sceneXML.actors.player.@shotsound.length() > 0)
			{
				soundController.play(sceneXML.actors.player.@shotsound);
			}
			dispatchEvent(new SceneEvent(SceneEvent.SHOT));
		}
		
		override public function dispose():void
		{
			// stop hitbox listeners
			for each(var hitBox:HitArea in hitboxes)
			{
				hitBox.stopListening();
				hitBox.dispose();
			}
			// clear load chain
			for each(var func:Function in loadChain)
			{
				func = null;
			}
			if(soundController)
			{
				soundController.dispose();
			}
			for each(var actor:XML in actorsUnder)
			{
				actor = null;
			}
			actorsUnder = null;
			player.dispose();
			actors.dispose();
			actors = null;
			backdrop.dispose();
			backdrop.base.dispose();
			backdrop = null;
			removeChildren(0, -1, true);
			Starling.juggler.purge();
			removeFromParent(false);
			super.dispose();
		}
		
		public function reset(event:Event = null):void
		{
			// loop through actors
			for each(var actor:Actor in actors.actors)
			{
				// and call reset
				actor.reset();
			}
			for each(var hitBox:HitArea in hitboxes)
			{
				hitBox.reset();
			}
			shot = new Shot();
			// reset player
			player.reset();
			// reset puck properties
			_model.puck.resetPuck(new Point(sceneXML.actors.puck[0].@x, sceneXML.actors.puck[0].@y));
		}
	}
}