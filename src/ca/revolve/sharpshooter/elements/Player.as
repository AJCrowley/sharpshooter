package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.constants.StateConstants;
	import ca.revolve.sharpshooter.events.AimEvent;
	import ca.revolve.sharpshooter.events.PlayerEvent;
	import ca.revolve.sharpshooter.events.PuckEvent;
	import ca.revolve.sharpshooter.events.SpriteEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.sharpshooter.states.player.AimState;
	import ca.revolve.sharpshooter.states.player.ShootState;
	import ca.revolve.sharpshooter.states.player.WaitingState;
	import ca.revolve.utils.Singleton;
	
	import flash.utils.setTimeout;
	
	import starling.events.TouchEvent;

	public class Player extends SpriteBase
	{
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		private var shootState:ShootState = new ShootState();
		private var reticle:Reticle;
		private var aimState:AimState = new AimState(true);
		private var shot:Shot = new Shot();
		private var shotDelay:uint = 0;
		
		public function Player(xml:XML)
		{
			// superclass constructor
			super(xml);
			// add states
			stateMachine.addState(new WaitingState());
			stateMachine.addState(aimState);
			stateMachine.addState(shootState);
			// set default state to wait
			stateMachine.setState(StateConstants.WAIT);
			// listen for aim init event
			aimState.addEventListener(AimEvent.INIT, initAim);
			// listen for aim update event
			aimState.addEventListener(AimEvent.AIM, updateAim);
			// create reticle instance from XML
			reticle = new Reticle(_model.currentScene.sceneXML.actors.reticle[0]);
			// listen for reticle to finish loading
			reticle.addEventListener(SpriteEvent.LOADED, addReticle);
			// listen for player shooting event
			shootState.addEventListener(PlayerEvent.SHOOTING, prepareShot);
			// define which frame of animation to impart momentum to the puck
			shotDelay = xml.@shotdelay;
		}
		
		private function initAim(event:AimEvent):void
		{
			// show aiming reticle
			reticle.showReticle();
		}
		
		private function updateAim(event:AimEvent):void
		{
			// if event object contains shot
			if(event.shot)
			{
				// update our stored shot data
				shot = event.shot;
			}
			// update the reticle
			reticle.updateAim(event);
		}
		
		private function addReticle(event:SpriteEvent):void
		{
			// make completely transparent
			reticle.alpha = 0;
			// add reticle to stage under other sprites
			addChildAt(reticle, 0);
			// trigger event to let everyone know we're loaded
			dispatchEvent(new SpriteEvent(PlayerEvent.LOADED));
		}
		
		private function prepareShot(event:PlayerEvent):void
		{
			// change costume to shot animation
			changeCostume(StateConstants.ACTION);
			// listen for animation complete
			addEventListener(SpriteEvent.ANIMATION_COMPLETE, endAction);
			// hide the aiming reticle
			reticle.hideReticle();
			// set delay timer for shot
			setTimeout(makeShot, shotDelay);
		}
		
		private function makeShot():void
		{
			dispatchEvent(new PuckEvent(PuckEvent.SHOT, shot));
		}
		
		private function endAction(event:SpriteEvent):void
		{
			// shooting animation has finished, go to resting animation
			changeCostume(StateConstants.REST, true);
		}
		
		public function startAim(event:TouchEvent = null):void
		{
			stateMachine.setState(StateConstants.AIM);
			aimState.updateAim(event);
		}
		
		override public function reset():void
		{
			// reset state
			stateMachine.setState(StateConstants.WAIT);
			// reset shot
			shot = new Shot();
			// call superclass reset
			super.reset();
		}
		
		override public function dispose():void
		{
			aimState.removeEventListener(AimEvent.INIT, initAim);
			aimState.removeEventListener(AimEvent.AIM, updateAim);
			reticle.removeEventListener(SpriteEvent.LOADED, addReticle);
			shootState.removeEventListener(PlayerEvent.SHOOTING, prepareShot);
			reticle.dispose();
			super.dispose();
		}
	}
}