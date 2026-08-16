package ca.revolve.sharpshooter.controllers
{
	import ca.revolve.sharpshooter.collections.SoundBank;
	import ca.revolve.sharpshooter.elements.Sound;
	import ca.revolve.sharpshooter.events.SoundEvent;
	
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import starling.events.EventDispatcher;

	public class SoundController extends EventDispatcher
	{
		private var soundBank:SoundBank;
		
		public function SoundController(soundBankXML:XMLList)
		{
			// do we have sounds to load?
			if(soundBankXML.length() > 0)
			{
				// create soundbank from XML
				soundBank = new SoundBank(soundBankXML);
				// listen for bank to complete loading
				soundBank.addEventListener(SoundEvent.BANK_LOADED, bankLoaded);
			}
			else
			{
				// no, we're done here
				dispatchEvent(new SoundEvent(SoundEvent.BANK_LOADED));
			}
		}
		
		private function bankLoaded(event:SoundEvent):void
		{
			// pass the event on up
			dispatchEvent(event);
		}
		
		public function play(id:String):void
		{
			// get sound
			var sound:Sound = soundBank.sound(id);
			// get a channel to play it on
			var channel:SoundChannel = new SoundChannel();
			// apply any volume and balance set in the sound
			var transform:SoundTransform = new SoundTransform(sound.volume, sound.balance);
			if(channel)
			{
				// and play the sound
				channel = sound.play(0, (sound.loop ? int.MAX_VALUE : 0));
				// apply transform to channel
				channel.soundTransform = transform;
			}
			// listen for channel to complete sound
			channel.addEventListener
			(
				Event.SOUND_COMPLETE,
				function(event:Event):void
				{
					channel = null;
					// let everyone know that the sound has played
					dispatchEvent(new SoundEvent(SoundEvent.SOUND_COMPLETE));
				},
				false,
				0,
				true
			);
		}
		
		public function dispose():void
		{
			soundBank.dipose();
		}
	}
}