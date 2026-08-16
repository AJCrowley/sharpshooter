package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.SpriteEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.sharpshooter.states.actor.ActionState;
	import ca.revolve.sharpshooter.states.actor.IdleState;
	import ca.revolve.sharpshooter.states.actor.RestState;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.events.XMLLoaderEvent;

	public class Actor extends SpriteBase
	{
		// store an identifier for this actor
		public var id:String;
		// create instance of IdleState
		public var idleState:IdleState = new IdleState();
		// track if we're added to stage
		public var onStage:Boolean = false;
		
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// create instance of ActionState
		private var actionState:ActionState = new ActionState();
		
		public function Actor(xml:XML)
		{
			// set our ID
			this.id = xml.@id;
			// call superclass constructor
			super(xml);
			// add default states for actor
			stateMachine.addState(idleState);
			stateMachine.addState(actionState);
			stateMachine.addState(new RestState());
			// set state to Idle
			stateMachine.setState(StateConstants.IDLE);
			// listen for reset
			idleState.addEventListener(SpriteEvent.RESET, resetCostume);
		}
		
		override protected function parseXML(event:XMLLoaderEvent):void
		{
			// listen for sprite loaded
			addEventListener(SpriteEvent.LOADED, startListener);
			// call superclass function
			super.parseXML(event);
		}
		
		private function startListener(event:SpriteEvent):void
		{
			// this is a one time event, remove the listener
			removeEventListener(SpriteEvent.LOADED, startListener);
			// do we have any hit areas defined?
			if(hitAreas.length > 0)
			{
				// if so, loop through hit areas and start listening for collisions
				for each(var hitArea:HitArea in hitAreas)
				{
					hitArea.listenForCollisions();
				}
			}
		}
		
		override public function reset():void
		{
			// reset state to idle
			stateMachine.setState(StateConstants.IDLE);
			// and pass call up to superclass
			super.reset();
		}
		
		override public function dispose():void
		{
			for each(var hitArea:HitArea in hitAreas)
			{
				// stop hit area listeners
				hitArea.stopListening();
				// and dispose
				hitArea.dispose();
			}
			// stop listeneing for reset
			idleState.removeEventListener(SpriteEvent.RESET, resetCostume);
			// lose children
			removeChildren(0, -1, true);
			// pass dispose up the chain
			super.dispose();
		}
		
		private function resetCostume(event:SpriteEvent):void
		{
			changeCostume(StateConstants.IDLE, idleLoop);
		}
	}
}