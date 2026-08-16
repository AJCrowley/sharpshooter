package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.events.SoundEvent;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import starling.events.EventDispatcher;
	
	// create custom sound subclass so we can associate IDs with sounds
	public class Sound extends flash.media.Sound
	{
		// id to identify the sound
		public var id:String;
		// use our own dispatcher, superclass uses Flash EventDispatcher, we want Starling
		public var dispatcher:EventDispatcher = new EventDispatcher();
		// default to full volume
		public var volume:Number = 1;
		// default to centre balace
		public var balance:Number = 0.5;
		// default to play once
		public var loop:Boolean = false;
		// auto play?
		public var autoPlay:Boolean = true;
		// flag to indicate loaded status
		private var _loaded:Boolean = false;
		// track if already playing
		private var _playing:Boolean = false;
		
		public function Sound(id:String, stream:URLRequest=null, context:SoundLoaderContext=null, autoPlay:Boolean = false)
		{
			// set id
			this.id = id;
			// auto play?
			this.autoPlay = autoPlay;
			// call superclass constructor
			super(stream, context);
			// listen for load complete
			super.addEventListener
			(
				Event.COMPLETE,
				function(event:Event):void
				{
					// set our internal loaded flag
					_loaded = true;
					// and dispatch event so anyone else who cares will know
					dispatcher.dispatchEvent(new SoundEvent(SoundEvent.LOADED));
				}
			);
		}
		
		// use getter, our loaded flag should be read only
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		// override play to track autoplaying tracks already started
		override public function play(startTime:Number=0, loops:int=0, sndTransform:SoundTransform=null):SoundChannel
		{
			var result:SoundChannel;
			// check we're not already playing
			if(!_playing)
			{
				// mark track as playing
				if(autoPlay)
				{
					_playing = true;
				}
				// and pass to superclass
				result = super.play(startTime, loops, sndTransform);
			}
			return result;
		}
	}
}