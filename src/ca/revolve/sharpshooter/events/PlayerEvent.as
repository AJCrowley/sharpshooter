package ca.revolve.sharpshooter.events
{
	import starling.events.Event;

	public class PlayerEvent extends Event
	{
		public static const SHOOTING:String = "playerShooting";
		public static const LOADED:String = "playerLoaded";
		
		public function PlayerEvent(type:String, bubbles:Boolean=false)
		{
			super(type, bubbles);
		}
	}
}