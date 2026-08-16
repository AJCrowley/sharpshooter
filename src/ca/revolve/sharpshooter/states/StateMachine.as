package ca.revolve.sharpshooter.states
{
	import ca.revolve.sharpshooter.events.StateEvent;
	import ca.revolve.sharpshooter.interfaces.IState;
	
	import starling.events.EventDispatcher;

	public class StateMachine extends EventDispatcher
	{
		// vector of all our states in this machine
		private var _states:Vector.<IState>;
		// current state
		private var _state:IState;
		
		public function StateMachine()
		{
			// initialize empty vector for states
			_states = new Vector.<IState>;
		}
		
		public function addState(state:StateBase):void
		{
			// check that state doesn't already exist
			if(!getState(state.id))
			{
				// add listeners for enter, exit, and changed
				state.addEventListener(StateEvent.STATE_ENTER, stateEventHandler);
				state.addEventListener(StateEvent.STATE_EXIT, stateEventHandler);
				state.addEventListener(StateEvent.STATE_CHANGED, stateEventHandler);
				// push state into vector
				_states.push(state);
			}
		}
		
		private function stateEventHandler(event:StateEvent):void
		{
			// something has happened, just pass it on
			dispatchEvent(event);
		}
		
		public function setState(stateId:String):void
		{
			// get handle on our new state
			var newState:StateBase = getState(stateId) as StateBase;
			// if we didn't find it
			if(!newState)
			{
				// error out
				throw(new Error("State '" + stateId + "' not found"));
			}
			// do we already have a state?
			if(_state)
			{
				// check that our new state is allowed to transition from the old state
				if(newState.fromStates.indexOf(_state.id) >= 0)
				{
					// exit current state
					_state.exit();
					// set state to new state
					_state = newState;
					// fire state enter
					_state.enter();
				}
			}
			else
			{
				// no state to transition from, just set the state
				_state = newState;
				// and fire enter
				_state.enter();
			}
		}
		
		public function get currentState():IState
		{
			// return a handle to the current state
			return _state;
		}
		
		private function getState(stateId:String):IState
		{
			var state:IState;
			// loop through states vector
			for each(var checkState:IState in _states)
			{
				// does our ID match?
				if(stateId == checkState.id)
				{
					// yep, get a handle on that state
					state = checkState;
					break;
				}
			}
			// return state, will be null if wasn't found in preceeding for loop
			return state;
		}
	}
}