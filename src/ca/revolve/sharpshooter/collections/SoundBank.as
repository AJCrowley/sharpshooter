package ca.revolve.sharpshooter.collections
{
	import ca.revolve.sharpshooter.elements.Sound;
	import ca.revolve.sharpshooter.events.SoundEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.Singleton;
	
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import starling.events.EventDispatcher;

	public class SoundBank extends EventDispatcher
	{
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// vector of all sounds
		private var _sounds:Vector.<Sound>;
		// array to store ids in associative mode
		private var _ids:Array;
		// internal flag to indicate all sounds queued to load
		private var _allSoundsQueued:Boolean = false;
		// track channel for autoplay sounds
		private var channel:SoundChannel;
		
		public function SoundBank(soundsXML:XMLList)
		{
			// initialize vectors and arrays in the constructor
			_sounds = new Vector.<Sound>;
			_ids = new Array();
			// parse input xml
			for each(var soundXML:XML in soundsXML)
			{
				// create instance of sound class with passed ID and path to file
				var sound:Sound = new Sound(soundXML.@id, new URLRequest(_model.currentScene.currentPath + soundXML.@file), null, (soundXML.@play == "true"));
				// does if have a loop property?
				if(soundXML.@loop.length() > 0)
				{
					// set it
					sound.loop = (soundXML.@loop == "true");
				}
				// volume property?
				if(soundXML.@vol.length() > 0)
				{
					// set it
					sound.volume = soundXML.@vol;
				}
				// balance property?
				if(soundXML.@bal.length() > 0)
				{
					// set it
					sound.balance = soundXML.@bal;
				}
				// listen for sound load complete
				sound.dispatcher.addEventListener(SoundEvent.LOADED, checkLoaded);
				// push sound to vector
				_sounds.push(sound);
				// store index in associative array by ID
				_ids[sound.id] = _sounds.length - 1;
			}
			// we're done with the loop, no more sounds to load
			_allSoundsQueued = true;
		}
		
		private function checkLoaded(event:SoundEvent):void
		{
			// default flag to all loaded
			var loaded:Boolean = true;
			// loop through all sounds
			for each(var sound:Sound in _sounds)
			{
				// if not loaded
				if(!sound.loaded)
				{
					// not all sounds have been loaded, exit loop
					loaded = false;
					break;
				}
				else
				{
					// start autoplaying?
					if(sound.autoPlay)
					{
						// get a channel to play it on
						channel = new SoundChannel();
						// apply any volume and balance set in the sound
						var transform:SoundTransform = new SoundTransform(sound.volume, sound.balance);
						// and play the sound;
						channel = sound.play(0, (sound.loop ? int.MAX_VALUE : 0));
						// apply transform to channel
						if(channel)
						{
							channel.soundTransform = transform;
						}
					}
				}
			}
			// if nothing has come back unloaded, and all of our sounds have been queued
			if(loaded && _allSoundsQueued)
			{
				// broadcast event to announce we're good to go
				dispatchEvent(new SoundEvent(SoundEvent.BANK_LOADED));
			}
		}
		
		public function pop():Sound
		{
			// pop one off our vector
			return _sounds.pop();
		}
		
		public function sound(id:String):Sound
		{
			// retrieve sound by ID from our associative array
			return _sounds[_ids[id]];
		}
		
		public function get sounds():Vector.<Sound>
		{
			// return all sounds
			return _sounds;
		}
		
		public function dipose():void
		{
			// if internal channel has been instantiated
			if(channel)
			{
				// kill whatever it's playing
				channel.stop();
				// and null it
				channel = null;
			}
			for each(var sound:Sound in _sounds)
			{
				sound = null;
			}
			_sounds = null;
		}
	}
}