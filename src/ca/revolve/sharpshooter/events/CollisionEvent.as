package ca.revolve.sharpshooter.events
{
	import starling.events.Event;
	
	public class CollisionEvent extends Event
	{
		public static const COLLISION:String = "collision";
		
		public function CollisionEvent(type:String, bubbles:Boolean=false)
		{
			super(type, bubbles);
		}
	}
}