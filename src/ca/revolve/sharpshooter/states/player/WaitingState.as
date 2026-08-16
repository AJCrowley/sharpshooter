package ca.revolve.sharpshooter.states.player
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.states.StateBase;
	
	public class WaitingState extends StateBase
	{
		public function WaitingState(startListener:Boolean=false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.SHOOT);
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.WAIT;
		}
	}
}