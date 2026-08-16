package ca.revolve.sharpshooter.states.puck
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.states.StateBase;
	
	public class StillState extends StateBase
	{
		public function StillState(startListener:Boolean=false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.MOVING);
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.STILL;
		}
	}
}