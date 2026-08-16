package ca.revolve.sharpshooter.states.player
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.elements.Shot;
	import ca.revolve.sharpshooter.events.AimEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.sharpshooter.states.StateBase;
	import ca.revolve.utils.Singleton;
	
	import flash.ui.Mouse;
	
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class AimState extends StateBase
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		private var reverseAim:int = 1;
		
		public function AimState(startListener:Boolean=false)
		{
			// call superclass constructor
			super(startListener);
			// set allowable states to transition from
			fromStates.push(StateConstants.WAIT);
			// check if we're in reverse aim mode
			if(_model.config.data.scenes.@reverseAim == "true")
			{
				reverseAim = -1;
			}
		}
		
		override public function get id():String
		{
			// set ID
			return StateConstants.AIM;
		}
		
		override public function enter(event:Event = null):void
		{
			// add touch listener
			_model.stage.addEventListener(TouchEvent.TOUCH, updateAim);
			// hide the mouse pointer
			Mouse.hide();
			// fire event to let everyone know we're in aim mode
			dispatchEvent(new AimEvent(AimEvent.INIT));
		}
		
		override public function exit(event:Event=null):void
		{
			// kill the touch listener
			_model.stage.removeEventListener(TouchEvent.TOUCH, updateAim);
			// show the mouse pointer
			Mouse.show();
		}

		public function updateAim(event:TouchEvent = null):void
		{
			// check that we've actually received a touch event
			if(event)
			{
				// is it a MOVED event?
				if((event.touches[0].phase == TouchPhase.MOVED) || (event.touches[0].phase == TouchPhase.BEGAN))
				{
					// set shot angle
					var angle:Number = (Math.max(Math.min(event.touches[0].globalX - (_model.stage.stageWidth / 2), (_model.config.data.aim.@hrange / 2)), ((_model.config.data.aim.@hrange / 2) * -1)) / (_model.config.data.aim.@hrange / 2)) * _model.currentScene.angleRange * reverseAim;
					// set shot power
					var power:Number = _model.currentScene.minPower + ((Math.min(Math.max(event.touches[0].globalY - ((_model.stage.stageHeight - _model.config.data.aim.@vrange) / 2), 0), _model.config.data.aim.@vrange) / _model.config.data.aim.@vrange) * (_model.currentScene.maxPower - _model.currentScene.minPower));
					// send event to let everyone know our updated shot metrics
					dispatchEvent(new AimEvent(AimEvent.AIM, new Shot(angle, power)));
				}
			}
		}
	}
}