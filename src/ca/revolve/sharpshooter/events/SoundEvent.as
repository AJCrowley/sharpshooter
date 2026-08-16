package ca.revolve.sharpshooter.events
{
	import starling.events.Event;
	
	public class SoundEvent extends Event
	{
		public static const LOADED:String = "soundLoaded";
		public static const BANK_LOADED:String = "soundBankLoaded";
		public static const SOUND_COMPLETE:String = "soundComplete";
		public static const PLAY_SOUND:String = "soundPlay";
		
		public var id:String;
		
		public function SoundEvent(type:String, id:String = null, bubbles:Boolean = false)
		{
			this.id = id;
			super(type, bubbles);
		}
	}
}