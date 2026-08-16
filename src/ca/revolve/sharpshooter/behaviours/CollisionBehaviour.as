// This is the AS3 implementation of Collision Behaviours as defined in hitArea XML
package ca.revolve.sharpshooter.behaviours
{
	import ca.revolve.sharpshooter.collections.Badges;
	import ca.revolve.sharpshooter.elements.AnimationSequence;
	import ca.revolve.sharpshooter.elements.Badge;
	import ca.revolve.sharpshooter.events.AnimationEvent;
	import ca.revolve.sharpshooter.events.CollisionEvent;
	import ca.revolve.sharpshooter.events.CollisionVariableEvent;
	import ca.revolve.sharpshooter.events.PuckEvent;
	import ca.revolve.sharpshooter.events.ScoreEvent;
	import ca.revolve.sharpshooter.events.SoundEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.Singleton;
	
	import starling.events.EventDispatcher;

	public class CollisionBehaviour extends EventDispatcher
	{
		private var id:String;
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel; // get model
		private var condition:CollisionCondition;
		private var puckBehaviour:PuckBehaviour;
		private var animation:AnimationSequence;
		private var sound:String;
		//private var badges:Vector.<Badge> = new Vector.<Badge>();
		private var badges:Badges = new Badges();
		private var varReqs:Array;
		private var points:uint = 0;
		
		public function load(xml:XML):void
		{
			// set ID
			id = xml.@id;
			// if puck behaviour is defined
			if(xml.puck[0])
			{
				// create instance of it from XML
				puckBehaviour = new PuckBehaviour(xml.puck[0]);
			}
			// does this behaviour have any animations associated with it?
			if(xml.animations[0])
			{
				// create AnimationSequence from XML
				animation = new AnimationSequence(xml.animations[0]);
			}
			// is this a scoring object?
			if(xml.points[0])
			{
				points = xml.points[0];
			}
			// any sounds associated with this behaviour?
			if(xml.sound[0])
			{
				sound = xml.sound[0];
			}
			// any badges associated with this behaviour?
			if(xml.badges[0])
			{
				//badge = xml.badge[0];
				var badge:Badge;
				for each(var badgeXML:XML in xml.badges.badge)
				{
					badge = new Badge();
					badge.id = badgeXML;
					badge.behaviour = id;
					_model.currentScene.badges.badges.push(badge);
					badges.badges.push(badge);
				}
			}
			// any vars to be set in this collision
			for each(var variable:XML in xml.variable)
			{
				// instantiate array if necessary
				if(!varReqs)
				{
					varReqs = new Array();
				}
				// push value to associative array
				varReqs.push(new CollisionVariable(variable.@name, null, null, variable.@value));
			}
			// create any defined conditions on this behaviour
			condition = new CollisionCondition(xml.conditions[0]);
			// listen for variable events
			condition.addEventListener
			(
				CollisionVariableEvent.DEFINE,
				function(event:CollisionVariableEvent):void
				{
					// just pass this one up the chain
					dispatchEvent(event);
				}
			);
			condition.setupVars();
		}
		
		public function execute(variables:Array = null):void
		{
			// have all conditions been met?
			if(condition.test(variables))
			{
				// set any vars
				for each(var varReq:CollisionVariable in varReqs)
				{
					dispatchEvent(new CollisionVariableEvent(CollisionVariableEvent.SET, false, varReq));
				}
				// notify everyone else of collision
				dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION));
				// do we have a puck behaviour?
				if(puckBehaviour)
				{
					// listen for when the behaviour is complete and run any defined animation sequences
					puckBehaviour.addEventListener(PuckEvent.BEHAVIOUR_APPLIED, dispatchAnimation);
					// and execute the behaviour
					puckBehaviour.execute();
				}
				// do we have a badge?
				if(badges.length > 0)
				{
					// go through each badge
					for each(var badge:Badge in badges.badges)
					{
						// find matching badge in scene
						for each(var sceneBadge:Badge in _model.currentScene.badges.badges)
						{
							if(sceneBadge == badge)
							{
								// we have a match, mark as activated
								sceneBadge.activated = true;
								break;
							}
						}
					}
				}
				// any animations defined?
				if(animation)
				{
					// just run them now, since we're not waiting for any puck behaviours to execute
					dispatchAnimation();
				}
				// if we have a sound
				if(sound)
				{
					// send notification to play sound
					dispatchEvent(new SoundEvent(SoundEvent.PLAY_SOUND, sound));
				}
				if(points)
				{
					// increase score!
					dispatchEvent(new ScoreEvent(ScoreEvent.SCORE, false, points));
				}
			}
		}
		
		private function dispatchAnimation(event:PuckEvent = null):void
		{
			// is there a puck behaviour?
			if(puckBehaviour)
			{
				// does it still have an event listener
				if(puckBehaviour.hasEventListener(PuckEvent.BEHAVIOUR_APPLIED))
				{
					// clean up the listener
					puckBehaviour.removeEventListener(PuckEvent.BEHAVIOUR_APPLIED, dispatchAnimation);
				}
			}
			// dispatch event telling animations to run
			dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATE, animation));
		}
	}
}