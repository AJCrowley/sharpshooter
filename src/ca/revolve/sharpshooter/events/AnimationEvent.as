package ca.revolve.sharpshooter.events
{
	import ca.revolve.sharpshooter.elements.AnimationSequence;
	
	import starling.events.Event;
	
	public class AnimationEvent extends Event
	{
		public static const ANIMATE:String = "eventAnimate";
		
		public var sequence:AnimationSequence;
		
		public function AnimationEvent(type:String, sequence:AnimationSequence, bubbles:Boolean=false)
		{
			this.sequence = sequence;
			super(type, bubbles);
		}
	}
}