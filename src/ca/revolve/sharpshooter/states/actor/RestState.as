package ca.revolve.sharpshooter.states.actor
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.states.StateBase;
	
	public class RestState extends StateBase
	{
		public function RestState(startListener:Boolean = false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.ACTION);
			fromStates.push(StateConstants.IDLE);
			fromStates.push(StateConstants.AIM);
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.REST;
		}
	}
}