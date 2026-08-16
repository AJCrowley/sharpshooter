package ca.revolve.sharpshooter.states.actor
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.SpriteEvent;
	import ca.revolve.sharpshooter.states.StateBase;
	
	import starling.events.Event;
	
	public class IdleState extends StateBase
	{
		public function IdleState(startListener:Boolean = false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.REST);
		}
		
		override public function enter(event:Event=null):void
		{
			dispatchEvent(new SpriteEvent(SpriteEvent.RESET));
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.IDLE;
		}
	}
}