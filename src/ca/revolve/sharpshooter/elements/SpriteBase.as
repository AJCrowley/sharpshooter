package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.constants.FileConstants;
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.AnimationEvent;
	import ca.revolve.sharpshooter.events.CollisionEvent;
	import ca.revolve.sharpshooter.events.ScoreEvent;
	import ca.revolve.sharpshooter.events.SoundEvent;
	import ca.revolve.sharpshooter.events.SpriteEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.sharpshooter.states.StateMachine;
	import ca.revolve.utils.ImageLoader;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.XMLLoader;
	import ca.revolve.utils.events.ImageLoaderEvent;
	import ca.revolve.utils.events.XMLLoaderEvent;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;

	public class SpriteBase extends Sprite
	{
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// do we want to scale this object as it gets further from the bottom of the screen?
		private var autoPerspective:Boolean = false;
		// animation queue
		private var animationSequence:AnimationSequence;
		// texture manager
		private var textureManager:TextureManager;
		// track path
		private var path:String = FileConstants.ASSETS_DIR;
		
		// loop in idle state?
		protected var idleLoop:Boolean = true;
		// xml definition of object
		protected var xml:XML;
		// reference to self to use in out-of-scope functions
		protected var me:SpriteBase;
		// visible movieclip of sprite
		protected var _mc:MovieClip;
		
		// store hit areas in a vector
		public var hitAreas:Vector.<HitArea> = new Vector.<HitArea>;
		// state controller
		public var stateMachine:StateMachine = new StateMachine();
		// frame rate
		public var frameRate:uint = 0;
		// flag to indicate loaded status of sprite
		public var loaded:Boolean = false;
		
		public function SpriteBase(spriteXML:XML)
		{
			// store reference to self
			me = this;
			// get frameRate from XML
			frameRate = spriteXML.@framerate;
			// check if loop is set in XML
			if(spriteXML.@loop.length() > 0)
			{
				// if it is, set whether to loop in idle state accordingly
				idleLoop = (spriteXML.@loop == "true");
			}
			// set position from xml
			x = spriteXML.@x;
			y = spriteXML.@y;
			// set scale from xml
			scaleX = scaleY = spriteXML.@scale;
			// set autoPerspective from XML
			autoPerspective = (spriteXML.@autoPerspective == "true");
			// calculate path
			if(_model.currentScene)
			{
				path = _model.currentScene.currentPath;
			}
			// create loader from our sprite sheet XML
			var xmlLoader:XMLLoader = new XMLLoader(path + spriteXML.@file);
			// and listen for load complete
			xmlLoader.addEventListener(XMLLoaderEvent.LOADED, parseXML);
		}
		
		protected function parseXML(event:XMLLoaderEvent):void
		{
			// get XML from event result
			xml = event.currentTarget.data;
			// load image as defined in XML
			var imageLoader:ImageLoader = new ImageLoader(path + xml.@imagePath);
			// listen for image loaded
			imageLoader.addEventListener
			(
				ImageLoaderEvent.LOADED,
				function(event:ImageLoaderEvent):void
				{
					textureManager = new TextureManager(event.bitmap, xml);
					// flag sprite as loaded
					loaded = true;
					// get our movieclip
					_mc = textureManager.getMovieClip(StateConstants.IDLE, frameRate);
					// listen for when clip is added to stage
					_mc.addEventListener(Event.ADDED_TO_STAGE, layoutSprite);
					// add to stage
					me.addChild(_mc);
					// check that hitAreas are defined
					if(xml.hitAreas.length() > 0)
					{
						// create single instance, we can reuse this
						var hitArea:HitArea;
						for each(var hitXML:XML in xml.hitAreas.hitArea)
						{
							// create hit area instance from xml
							hitArea = new HitArea(hitXML);
							// if debug mode is set to show hit areas
							if(_model.config.data.debug.@showHitAreas == "true")
							{
								// show them!
								addChild(hitArea.displayMC);
							}
							// sync hit area position to my position
							hitArea.mc.x = me.x;
							hitArea.mc.y = me.y;
							// add me to current scene
							_model.currentScene.addChild(hitArea.mc);
							// listen for any animate triggers
							hitArea.addEventListener(AnimationEvent.ANIMATE, animationHandler);
							// listen for collisions
							hitArea.addEventListener
							(
								CollisionEvent.COLLISION,
								function(event:CollisionEvent):void
								{
									// set state to hit
									stateMachine.setState(StateConstants.REST);
								}
							);
							// listen for sound events
							hitArea.addEventListener
							(
								SoundEvent.PLAY_SOUND,
								function(event:SoundEvent):void
								{
									// pass it up the chain
									dispatchEvent(event);
								}
							);
							// listen for score events
							hitArea.addEventListener
							(
								ScoreEvent.SCORE,
								function(event:ScoreEvent):void
								{
									dispatchEvent(event); // pass the event up
								}
							);
							// add hitarea to vector
							hitAreas.push(hitArea);
						}
					}
					// set whether or not to loop in idle state
					_mc.loop = idleLoop;
					// let everyone know we're loaded
					dispatchEvent(new SpriteEvent(SpriteEvent.LOADED));
				}
			);
		}
		
		private function animationHandler(event:AnimationEvent):void
		{
			// get sequence object from event
			animationSequence = event.sequence;
			// listen for completion of an animation
			addEventListener(SpriteEvent.ANIMATION_COMPLETE, nextAnimation);
			// check whether this is first animation
			if(animationSequence)
			{
				if(animationSequence.currentIndex == 0)
				{
					// call first animation in our queue
					nextAnimation();
				}
			}
		}
		
		private function nextAnimation(event:SpriteEvent = null):void
		{
			// default to this being last animation in sequence
			var lastInSequence:Boolean = true;
			// check that our sequence actually exists
			if(animationSequence)
			{
				// determine if this actually is the last animation in sequence
				lastInSequence = !(animationSequence.currentIndex < animationSequence.animations.length - 1);
				// and apply it, if it's the last one, set to loop if it should do so
				changeCostume(animationSequence.animations[animationSequence.currentIndex], (lastInSequence && animationSequence.loop));
			}
			if(lastInSequence)
			{
				// last animation is done, let's stop listening for this
				removeEventListener(SpriteEvent.ANIMATION_COMPLETE, nextAnimation);
			}
			else
			{
				// more to go, increment the current index
				animationSequence.currentIndex++;
			}
		}
		
		protected function layoutSprite(event:Event = null):void
		{
			// set perspective
			updateScale();
			// apply smoothing to clip
			_mc.smoothing = TextureSmoothing.TRILINEAR;
			// if we're animated (ie framerate higher than 0)
			if(frameRate > 0)
			{
				// add us to the juggler
				Starling.juggler.add(_mc);
			}
		}
		
		public function changeCostume(newCostume:String, loop:Boolean = false):void
		{
			// remove old costume from the juggler
			Starling.juggler.remove(_mc);
			// remove clip from the stage
			removeChild(_mc);
			_mc = textureManager.getMovieClip(newCostume, frameRate);
			// loop if we're supposed to
			_mc.loop = loop;
			// if we're not looping, we might care when the animation ends
			if(!loop)
			{
				_mc.addEventListener
				(
					Event.COMPLETE,
					function(event:Event):void
					{
						// so just fire an event to let everyone know that the animation is done
						dispatchEvent(new SpriteEvent(SpriteEvent.ANIMATION_COMPLETE));
					}
				);
			}
			// add new clip to stage
			addChild(_mc);
			// and call layout to apply any pespective/smoothing/juggling
			layoutSprite();
		}
		
		public function updateScale():void
		{
			// are we in autoperspective mode?
			if(autoPerspective)
			{
				// update the sprite scale based on our distance from bottom of the screen
				scaleX = scaleY = Math.max((1 - ((1 / _model.stage.stageHeight) * (_model.stage.stageHeight - y))), 0.2);
				// loop through hit areas and update scale
				for each(var hitArea:HitArea in hitAreas)
				{
					hitArea.mc.scaleX = hitArea.mc.scaleY = scaleX;
				}
			}
		}
		
		public function reset():void
		{
			// if there's an animation sequence
			if(animationSequence)
			{
				// reset the index
				animationSequence.currentIndex = 0;
			}
			// loop through hit areas
			for each(var hitArea:HitArea in hitAreas)
			{
				// and reset
				hitArea.reset();
			}
		}
		
		override public function dispose():void
		{
			// dispose of superclass
			super.dispose();
			// is texturemanager defined?
			if(textureManager)
			{
				// dispose of it properly
				textureManager.dispose();
			}
			// remove all children
			this.removeChildren(0, -1, true);
			// remove self
			removeFromParent(false);
		}
	}
}