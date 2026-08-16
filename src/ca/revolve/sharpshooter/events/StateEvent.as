package ca.revolve.sharpshooter.events
{
	import starling.events.Event;

	public class StateEvent extends Event
	{
		public static const STATE_CHANGED:String = "stateChanged";
		public static const STATE_ENTER:String = "stateEnter";
		public static const STATE_EXIT:String = "stateExit";
		
		public var eventId:String = "";
		
		public function StateEvent(type:String, eventId:String, bubbles:Boolean=false)
		{
			this.eventId = eventId;
			super(type, bubbles);
		}
	}
}