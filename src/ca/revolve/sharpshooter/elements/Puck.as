package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.PuckEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.sharpshooter.states.puck.MovingState;
	import ca.revolve.sharpshooter.states.puck.StillState;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.TrigTool;
	import ca.revolve.utils.events.XMLLoaderEvent;
	
	import flash.geom.Point;

	public class Puck extends SpriteBase
	{
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// friction determines rate at which puck slows
		private var friction:Number;
		// momentum factor is a multiplier for speed
		private var momentumFactor:Number;
		private var movingState:MovingState = new MovingState();
		// angle of travel of puck
		private var _angle:Number;
		// momentum of our puck
		private var _momentum:Point = new Point(0, 0);
		
		// flag to stop end of play event from firing when we're just paused
		public var  isDelayed:Boolean = false;
		
		public function Puck(actorXML:XML)
		{
			// superclass constructor
			super(actorXML);
			// add states
			stateMachine.addState(new StillState());
			stateMachine.addState(movingState);
			// set default state
			stateMachine.setState(StateConstants.STILL);
		}
		
		override protected function parseXML(event:XMLLoaderEvent):void
		{
			// call superclass's parseXML
			super.parseXML(event);
			// set friction value from XML
			friction = xml.@friction;
			// set momentum factor value from XML
			momentumFactor = xml.@momentumFactor;
		}
		
		public function shoot(shot:Shot):void
		{
			// switch to moving state
			stateMachine.setState(StateConstants.MOVING);
			// apply angle from shot object
			_angle = shot.angle;
			// get tangent to calculate x/y ratio from angle
			var ratio:Number = Math.tan(TrigTool.deg2rad(shot.angle));
			// impart shot momentum from tangent with factor applied
			_momentum.x = (shot.power * ratio) * momentumFactor;
			_momentum.y = shot.power * momentumFactor + (1 - shot.power);
			// listen for updates from our state object
			movingState.addEventListener(PuckEvent.MOVE, updatePuck);
		}
		
		public function get speed():Number
		{
			// get absolute speed at which puck is currently traveling
			return Math.abs(_momentum.x) + Math.abs(_momentum.y);
		}
		
		public function get angle():Number
		{
			// angle of travel for puck, this is never updated from original shot, regardless of deflections etc
			return _angle;
		}
		
		private function updatePuck(event:PuckEvent):void
		{
			// move puck according to momentum
			x -= _momentum.x;
			y -= _momentum.y;
			// update momentum for friction
			_momentum.x *= friction;
			_momentum.y *= friction;
			// update scale of puck
			updateScale();
			// if puck has nearly stopped moving, gone of stage, and isn't just delayed
			if(((speed < 0.2) || (x < -_model.puck.width || x > _model.stage.stageWidth || y < 0 || y > _model.stage.stageHeight)) && !isDelayed)
			{
				// stop listening for puck updates
				movingState.removeEventListener(PuckEvent.MOVE, updatePuck);
				// set state to still
				stateMachine.setState(StateConstants.STILL);
				// notify system that shot is over
				dispatchEvent(new PuckEvent(PuckEvent.END_SHOT));
			}
		}
		
		public function resetPuck(pos:Point):void
		{
			// kill momentum
			_momentum = new Point(0, 0);
			// reset position
			position = pos;
			// reset scale
			updateScale();
			// make sure we're visible
			visible = true;
			// call superclass
			super.reset();
		}
		
		public function get momentum():Point
		{
			return _momentum;
		}
		
		public function set momentum(newMomentum:Point):void
		{
			// update our angle tracker
			_angle = TrigTool.rad2deg(Math.atan2(newMomentum.x, newMomentum.y));
			// apply new momentum
			_momentum = newMomentum;
		}
		
		// setter for position, can now be set with a point, rather than separate x/y
		public function set position(position:Point):void
		{
			x = position.x;
			y = position.y;
		}
		
		// getter for position
		public function get position():Point
		{
			return new Point(x, y);
		}
	}
}