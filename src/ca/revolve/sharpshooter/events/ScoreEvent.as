package ca.revolve.sharpshooter.events
{
	import starling.events.Event;
	
	public class ScoreEvent extends Event
	{
		public static const LOADED:String = "scoreLoaded";
		public static const SCORE:String = "scorePoints";
		public static const RESET:String = "scoreReset";
		
		public var points:int = 0;
		
		public function ScoreEvent(type:String, bubbles:Boolean = false, points:int = 0)
		{
			this.points = points;
			super(type, bubbles);
		}
	}
}