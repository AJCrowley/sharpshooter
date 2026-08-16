package ca.revolve.sharpshooter.states.player
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.PlayerEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.sharpshooter.states.StateBase;
	import ca.revolve.utils.Singleton;
	
	import starling.events.Event;
	
	public class ShootState extends StateBase
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		
		public function ShootState(startListener:Boolean = false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.AIM);
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.SHOOT;
		}
		
		override public function enter(event:Event=null):void
		{
			// let everyone know we've entered shooting state
			dispatchEvent(new PlayerEvent(PlayerEvent.SHOOTING));
		}
	}
}