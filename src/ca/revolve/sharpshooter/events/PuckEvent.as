package ca.revolve.sharpshooter.events
{
	import ca.revolve.sharpshooter.elements.Shot;
	
	import starling.events.Event;

	public class PuckEvent extends Event
	{
		public static const SHOT:String = "puckShot";
		public static const MOVE:String = "puckMove";
		public static const END_SHOT:String = "puckEnd";
		public static const BEHAVIOUR_APPLIED:String = "puckBehaviour";
		
		public var shot:Shot;
		
		public function PuckEvent(type:String, shot:Shot = null, bubbles:Boolean = false)
		{
			this.shot = shot;
			super(type, bubbles)
		}
	}
}