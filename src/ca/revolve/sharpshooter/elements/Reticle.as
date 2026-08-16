package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.events.AimEvent;
	import ca.revolve.sharpshooter.events.SpriteEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.ImageLoader;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.events.ImageLoaderEvent;
	
	import flash.geom.Point;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;

	public class Reticle extends SpriteBase
	{
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// power image section of reticle
		private var powerImage:String;
		// movieclip to store power image in
		private var powerMC:MovieClip;
		// texture manager
		private var textureManager:TextureManager;
		// origin (center point to rotate around)
		private var origin:Point;
		private var originalY:Number;
		private var originalHeight:Number;
		
		public function Reticle(xml:XML)
		{
			// superclass constructor
			super(xml);
			// get path to power image from XML
			powerImage = xml.@powerMeter;
			// set origin from XML
			origin = new Point(xml.@centerX, xml.@centerY);
			// listen for load complete to start loading lower meter
			addEventListener(SpriteEvent.LOADED, loadPowerMeter);
		}
		
		private function loadPowerMeter(event:Event = null):void
		{
			// use imageloader to get power image
			var imageLoader:ImageLoader = new ImageLoader(_model.currentScene.currentPath + powerImage);
			// listen for load complete
			imageLoader.addEventListener
			(
				ImageLoaderEvent.LOADED,
				function(event:ImageLoaderEvent):void
				{
					// instantiate texture manager
					textureManager = new TextureManager(event.bitmap, xml);
					// mark as loaded
					loaded = true;
					// create movieclip from power image texture
					powerMC = textureManager.getMovieClip("powerMeter", frameRate);
					// set origin based on position
					powerMC.x = _mc.x - origin.x;
					// get top point of movieclip
					originalY = _mc.y - powerMC.height - origin.y;
					// get height of clip
					originalHeight = powerMC.height;
					// set Y from stored top point
					powerMC.y = originalY;
					// add clip to stage
					me.addChild(powerMC);
				}
			);
		}
		
		public function updateAim(event:AimEvent):void
		{
			// set angle of rotation from shot data
			rotation = -1 * (event.shot.angle * Math.PI / 180);
			// move top of power image based upon scale
			powerMC.y = originalY + ((1 - event.shot.power) * originalHeight);
			// set scale of power image based upon shot power
			powerMC.scaleY = event.shot.power;
		}
		
		public function showReticle(event:AimEvent = null):void
		{
			// fade reticle in on 0.5 second tween
			var tween:Tween = new Tween(me, 0.5, Transitions.LINEAR);
			tween.fadeTo(1);
			// add to juggler to animate
			Starling.juggler.add(tween);
		}
		
		public function hideReticle(event:AimEvent = null):void
		{
			// fade reticle out on 0.5 second tween
			var tween:Tween = new Tween(me, 0.5, Transitions.LINEAR);
			tween.fadeTo(0);
			// add to juggler to animate
			Starling.juggler.add(tween);
		}
		
		override protected function layoutSprite(event:Event = null):void
		{
			// call superclass layoutSprite
			super.layoutSprite(event);
			// set our pivot points based upon defined origin
			_mc.pivotX = origin.x;
			_mc.pivotY = origin.y;
		}
		
		override public function dispose():void
		{
			textureManager.dispose();
			powerMC.dispose();
			super.dispose();
		}
	}
}