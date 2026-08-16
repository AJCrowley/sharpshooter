package ca.revolve.sharpshooter.events
{
	import ca.revolve.sharpshooter.elements.Shot;
	
	import starling.events.Event;
	
	public class AimEvent extends Event
	{
		public static const AIM:String = "eventAim";
		public static const INIT:String = "eventAimInit";
		public static const SHOT:String = "eventAimShot";
		
		public var shot:Shot = new Shot();
		
		public function AimEvent(type:String, shot:Shot = null, bubbles:Boolean=false)
		{
			this.shot = shot;
			super(type, bubbles);
		}
	}
}