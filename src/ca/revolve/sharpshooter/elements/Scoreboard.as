package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.constants.FileConstants;
	import ca.revolve.sharpshooter.events.ScoreEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.ImageLoader;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.events.ImageLoaderEvent;
	
	import flash.text.Font;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class Scoreboard extends Sprite
	{
		[Embed(source="assets/scoreboard.ttf", embedAsCFF="false", fontName="scoreboard")]
		private var ScoreFont:Class;
		
		private var imageLoader:ImageLoader;
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		private var background:Texture;
		private var puckImage:Texture;
		private var scoreText:TextField;
		private var scoreFont:Font = new ScoreFont();
		private var puckInstances:Vector.<Image> = new Vector.<Image>;
		
		public var shotCount:uint = 1;
		
		public var score:int = 0; 
		
		public function Scoreboard()
		{
			// set score text properties from config
			scoreText = new TextField(_model.config.data.scoreboard.scoreText.@width, _model.config.data.scoreboard.scoreText.@height, "0", scoreFont.fontName, _model.config.data.scoreboard.scoreText.@fontSize, uint("0x" + _model.config.data.scoreboard.scoreText.@colour), _model.config.data.scoreboard.scoreText.@bold);
			scoreText.x = _model.config.data.scoreboard.scoreText.@x;
			scoreText.y = _model.config.data.scoreboard.scoreText.@y;
			// set position from config
			x = _model.config.data.scoreboard.@x;
			y = _model.config.data.scoreboard.@y;
			imageLoader = new ImageLoader(FileConstants.ASSETS_DIR + _model.config.data.scoreboard.@image); // load shot counter
			imageLoader.addEventListener(ImageLoaderEvent.LOADED, display, false, 0, true); // listen for load complete with weak reference
		}
		
		public function applyPoints(points:int):void
		{
			// increment points
			score += points;
			// update text to reflect score
			scoreText.text = String(score);
		}
		
		public function zeroPoints():void
		{
			score = 0;
			scoreText.text = "0";
		}
		
		public function initShotCounter(shots:uint):void
		{
			// track shot count
			shotCount = shots;
			// image instance
			var puckInstance:Image;
			// position on x accordingly
			var currentX:uint = _model.config.data.scoreboard.shotCounter.@x;
			// for each remaining shot
			for(var counter:uint = 0; counter < shotCount; counter++)
			{
				// create image instance
				puckInstance = new Image(puckImage);
				// place correctly
				puckInstance.x = currentX;
				puckInstance.y = _model.config.data.scoreboard.shotCounter.@y;
				// push to our vector
				puckInstances.push(puckInstance);
				// and add to stage
				addChild(puckInstance);
				// decrement X so next image shows to the left
				currentX -= _model.config.data.scoreboard.shotCounter.@width;
			}
		}
		
		public function decShotCounter():void
		{
			// get image instance from vector
			var puckInstance:Image = puckInstances.pop();
			// set transition
			var tween:Tween = new Tween(puckInstance, Number(_model.config.data.scoreboard.shotCounter.@fadeTime), Transitions.LINEAR);
			tween.onComplete = function():void
			{
				// when transition complete, remove puck instance
				removeChild(puckInstance, true);
			}
			// fade to nothing
			tween.fadeTo(0);
			// and put it in the juggler
			Starling.juggler.add(tween);
		}
		
		private function display(event:ImageLoaderEvent):void
		{
			background = Texture.fromBitmap(event.bitmap); // create texture from image
			addChild(new Image(background)); // and add the texture
			addChild(scoreText);
			imageLoader = new ImageLoader(FileConstants.ASSETS_DIR + _model.config.data.scoreboard.shotCounter.@image);
			imageLoader.addEventListener(ImageLoaderEvent.LOADED, setCounterImage, false, 0, true); // listen for load complete with weak reference
		}
		
		private function setCounterImage(event:ImageLoaderEvent):void
		{
			puckImage = Texture.fromBitmap(event.bitmap); // create texture from image
			dispatchEvent(new ScoreEvent(ScoreEvent.LOADED));
		}
	}
}