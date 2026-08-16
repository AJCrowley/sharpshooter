package ca.revolve.sharpshooter.states
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.StateEvent;
	import ca.revolve.sharpshooter.interfaces.IState;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.Singleton;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class StateBase extends EventDispatcher implements IState
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		private var startListener:Boolean;
		
		public var fromStates:Vector.<String> = new Vector.<String>;
		
		public function StateBase(startListener:Boolean = false)
		{
			this.startListener = startListener;
		}
		
		public function get id():String
		{
			return StateConstants.BASE;
		}
		
		public function enter(event:Event = null):void
		{
			// dispatch enter state event
			dispatchEvent(new StateEvent(StateEvent.STATE_ENTER, this.id));
			// do we want to listen on every frame?
			if(startListener)
			{
				// yes, set the listener
				_model.stage.addEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		public function update(event:Event = null):void
		{
		}
		
		public function exit(event:Event = null):void
		{
			// dispatch exit state event
			dispatchEvent(new StateEvent(StateEvent.STATE_EXIT, this.id));
		}
	}
}