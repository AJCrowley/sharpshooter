package ca.revolve.sharpshooter.states.puck
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.PuckEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.sharpshooter.states.StateBase;
	import ca.revolve.utils.Singleton;
	
	import starling.events.Event;
	
	public class MovingState extends StateBase
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		
		public function MovingState(startListener:Boolean=false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.STILL);
		}
		
		override public function enter(event:Event=null):void
		{
			// add frame listener
			_model.stage.addEventListener(Event.ENTER_FRAME, updatePuck);
		}
		
		override public function exit(event:Event=null):void
		{
			// remove frame listener
			_model.stage.removeEventListener(Event.ENTER_FRAME, updatePuck);
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.MOVING;
		}
		
		private function updatePuck(event:Event):void
		{
			// let everyone know it's time for the puck to move
			dispatchEvent(new PuckEvent(PuckEvent.MOVE));
		}
	}
}