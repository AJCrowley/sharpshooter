package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.collections.CollisionBehaviours;
	import ca.revolve.sharpshooter.events.AnimationEvent;
	import ca.revolve.sharpshooter.events.CollisionEvent;
	import ca.revolve.sharpshooter.events.ScoreEvent;
	import ca.revolve.sharpshooter.events.SoundEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.TrigTool;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	
	import ws.tink.display.HitTest;

	public class HitArea extends EventDispatcher
	{
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// movieclip of hit area
		private var _mc:MovieClip;
		// store hit area in texture
		private var _texture:Texture;
		// collection of behaviours for this hit area
		private var _behaviours:CollisionBehaviours = new CollisionBehaviours();
		// keep track of whether this collision has already happened
		private var triggered:Boolean = false;
		// is this a solid object? Do we want to prevent the puck from entering our hit area
		private var solid:Boolean = false;
		
		// movie clip for display of hit area in debug mode
		public var displayMC:MovieClip;
		// points that make up hit area polygon
		public var points:Vector.<Point>;
		// bitmap data of hit area (needed for collision detection)
		public var bitmapData:BitmapData;
		
		// constructor
		public function HitArea(hitAreaXML:XML)
		{
			// if solid is defined in xml
			if(hitAreaXML.@solid.length() > 0)
			{
				// set our solid property
				solid = hitAreaXML.@solid == "true";
			}
			// plot the hit area
			pointsFromXML(hitAreaXML);
		}
		
		private function detectCollisions(event:Event = null):void
		{
			// do we need to check?
			if(!triggered)
			{
				// are the points of our polygon defined and do we have a puck?
				if(points && _model.puck && _model.puck.hitAreas.length > 0)
				{
					// run hit test against puck
					if(HitTest.complexHitTestObject(_model.puck, _model.puck.hitAreas[0].bitmapData, mc, bitmapData))
					{
						// set flag to record that this has happened, unless we're a solid
						triggered = !solid;
						// as long as we're a solid and the puck is still in contact with the hit area
						while(solid && HitTest.complexHitTestObject(_model.puck, _model.puck.hitAreas[0].bitmapData, mc, bitmapData))
						{
							// var in which to store new calculated position
							var newPos:Point;
							// do we have more movement along y than x?
							if(_model.puck.momentum.y > _model.puck.momentum.x)
							{
								// back off by 1px on y, calculate X from tangent
								newPos = new Point(_model.puck.x + Math.tan(TrigTool.deg2rad(_model.puck.angle)), _model.puck.y + (_model.puck.momentum.y > 0 ? 1 : -1));
							}
							else
							{
								// back off by 1px on x, calculate y from 1/tangent
								newPos = new Point(_model.puck.x + (_model.puck.momentum.x > 0 ? 1 : -1), _model.puck.y + (1 / Math.tan(TrigTool.deg2rad(_model.puck.angle))));
							}
							// apply new calculated position and retest overlap
							_model.puck.position = newPos;
						}
						// execute all behaviours
						_behaviours.execute();
					}
				}
			}
		}
		
		public function listenForCollisions():void
		{
			// listen for collisions on every frame
			_model.stage.addEventListener(Event.ENTER_FRAME, detectCollisions);
			// listen for collisions
			_behaviours.addEventListener(CollisionEvent.COLLISION, collisionHandler);
			// listen for sound events
			_behaviours.addEventListener(SoundEvent.PLAY_SOUND, playSound);
			// listen for score events
			_behaviours.addEventListener
			(
				ScoreEvent.SCORE,
				function(event:ScoreEvent):void
				{
					dispatchEvent(event); // pass the event up
				}
			);
		}
		
		private function collisionHandler(event:CollisionEvent):void
		{
			// pass event up the chain
			dispatchEvent(event);
		}
		
		public function stopListening():void
		{
			// if we're listening
			if(_model.stage.hasEventListener(Event.ENTER_FRAME))
			{
				// remove listener for collisions on every frame
				_model.stage.removeEventListener(Event.ENTER_FRAME, detectCollisions);
			}
			// check if we're listening for collision from behaviours
			if(_behaviours.hasEventListener(CollisionEvent.COLLISION))
			{
				// and remove
				_behaviours.removeEventListener(CollisionEvent.COLLISION, collisionHandler);
			}
			// check if we're listening for sound events from behaviours
			if(_behaviours.hasEventListener(SoundEvent.PLAY_SOUND))
			{
				// and remove
				_behaviours.removeEventListener(SoundEvent.PLAY_SOUND, playSound);
			}
		}
		
		private function playSound(event:SoundEvent):void
		{
			dispatchEvent(event);
		}
		
		private function pointsFromXML(xml:XML):void
		{
			// initialize points vector
			points = new Vector.<Point>;
			// loop through all vertices defined in XML
			for each(var vertex:XML in xml.vertex)
			{
				// push to our points
				points.push(new Point(vertex.@x, vertex.@y));
			}
			// if we actually have points
			if(points.length > 0)
			{
				// plot the hit area
				plotHitArea();
			}
			// load up behaviours
			_behaviours.load(xml.behaviours);
			// listen for animation triggers from our behaviours
			_behaviours.addEventListener(AnimationEvent.ANIMATE, animationHandler);
		}
		
		private function animationHandler(event:AnimationEvent):void
		{
			// pass event on up the chain
			dispatchEvent(event);
		}
		
		private function plotHitArea():void
		{
			// create sprite for our shape
			var hitShape:flash.display.Sprite = new flash.display.Sprite();
			// default fill colour to black
			var fillColour:uint = 0x000000;
			// default fill alpha to lowest allowed
			//var fillAlpha:Number = 0.003922;
			var fillAlpha:Number = 1;
			// default line colour to black
			var lineColour:uint = 0x000000;
			// default line alpha to lowest allowed
			var lineAlpha:Number = 1;
			// are we showing hit areas for debugging?
			if(_model.config.data.debug.@showHitAreas)
			{
				// let's make the fill red and give it a 50% alpha so we can actually see it
				fillColour = 0xff0000;
				fillAlpha = 0.2;
				lineColour = 0xaa0000;
				lineAlpha = 0.4;
			}
			// give it a 1px outline, black, lowest allowed alpha
			hitShape.graphics.lineStyle(1, lineColour, lineAlpha);
			// give it a fill, red, 50% alpha
			hitShape.graphics.beginFill(fillColour, fillAlpha);
			// get starting point for shape
			var startPoint:Point = points.pop();
			// move graphics cursor to start point
			hitShape.graphics.moveTo(startPoint.x, startPoint.y);
			// default hit area width and height to 0
			var haWidth:uint = 0;
			var haHeight:uint = 0;
			// loop through all remaining points in polygon
			for each(var point:Point in points)
			{
				// move graphics cursor to point
				hitShape.graphics.lineTo(point.x, point.y);
				// if width or height are greater, update the stored value
				haWidth = haWidth > point.x ? haWidth : point.x;
				haHeight = haHeight > point.y ? haHeight : point.y;
			}
			// we're done drawing our outline, end the fill
			hitShape.graphics.endFill();
			// create bitmap, get dimensions from defined width and height, allow transparency, black
			bitmapData = new BitmapData(haWidth, haHeight, true, 0x000000);
			// draw a copy of our hit area shape in the bitmapdata
			bitmapData.draw(hitShape);
			// get texture object from bitmapdata
			_texture = Texture.fromBitmapData(bitmapData);
			// create empty vector for texture
			var textures:Vector.<Texture> = new Vector.<Texture>;
			// and add the texture
			textures.push(_texture);
			// create movieclip from texture
			_mc = new MovieClip(textures, 0);
			// and minimize alpha on the clip
			_mc.alpha = 0.003922;
			// are we showing hit areas in debug mode?
			if(_model.config.data.debug.@showHitAreas)
			{
				// create a copy of hit area clip to make visible
				displayMC = new MovieClip(textures, 0);
			}
		}
		
		public function get mc():MovieClip
		{
			return _mc;
		}
		
		public function reset():void
		{
			// reset behaviours
			_behaviours.reset();
			// reset triggered flag
			triggered = false;
		}
		
		public function dispose():void
		{
			_mc.removeFromParent(true);
			displayMC.removeFromParent(true);
			bitmapData.dispose();
			bitmapData = null;
			_texture.dispose();
			_texture = null;
		}
	}
}