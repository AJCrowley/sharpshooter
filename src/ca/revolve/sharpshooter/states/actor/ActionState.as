package ca.revolve.sharpshooter.states.actor
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.states.StateBase;
	
	public class ActionState extends StateBase
	{
		public function ActionState(startListener:Boolean = false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.IDLE);
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.ACTION;
		}
	}
}