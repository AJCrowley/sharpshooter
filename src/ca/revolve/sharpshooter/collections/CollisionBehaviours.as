package ca.revolve.sharpshooter.collections
{
	import ca.revolve.sharpshooter.behaviours.CollisionBehaviour;
	import ca.revolve.sharpshooter.behaviours.CollisionVariable;
	import ca.revolve.sharpshooter.events.AnimationEvent;
	import ca.revolve.sharpshooter.events.CollisionEvent;
	import ca.revolve.sharpshooter.events.CollisionVariableEvent;
	import ca.revolve.sharpshooter.events.ScoreEvent;
	import ca.revolve.sharpshooter.events.SoundEvent;
	
	import starling.events.EventDispatcher;

	public class CollisionBehaviours extends EventDispatcher
	{
		// collision variables
		private var variables:Array;
		
		// vector of all our behaviours
		private var behaviours:Vector.<CollisionBehaviour>;
		
		public function CollisionBehaviours()
		{
			// initialize our vector
			behaviours = new Vector.<CollisionBehaviour>;
		}
		
		public function execute():void
		{
			for each(var behaviour:CollisionBehaviour in behaviours)
			{
				// execute each in sequence, pass variables down for testing
				behaviour.execute(variables);
			}
		}
		
		public function load(xml:XMLList):void
		{
			// loop through behaviours defined in XML
			for each(var behaviourXML:XML in xml.behaviour)
			{
				// create instance
				var behaviour:CollisionBehaviour = new CollisionBehaviour();
				// listen for var definitions
				behaviour.addEventListener
				(
					CollisionVariableEvent.DEFINE,
					function(event:CollisionVariableEvent):void
					{
						// instantiate array if necessary
						if(!variables)
						{
							variables = new Array();
						}
						// index variable in array
						variables[event.collisionVariable.name] = event.collisionVariable;
					}
				);
				// listen for var sets
				behaviour.addEventListener
				(
					CollisionVariableEvent.SET,
					function(event:CollisionVariableEvent):void
					{
						variables[event.collisionVariable.name].value = event.collisionVariable.value;
					}
				);
				// load behaviour properties from XML
				behaviour.load(behaviourXML);
				// listen for animation event on behaviour
				behaviour.addEventListener(AnimationEvent.ANIMATE, triggerAnimation);
				// listen for collision
				behaviour.addEventListener
				(
					CollisionEvent.COLLISION,
					function(event:CollisionEvent):void
					{
						// pass event up the chain
						dispatchEvent(event);
					}
				);
				// listen for sound event
				behaviour.addEventListener
				(
					SoundEvent.PLAY_SOUND,
					function(event:SoundEvent):void
					{
						// pass it up the chain
						dispatchEvent(event);
					}
				);
				// listen for score events
				behaviour.addEventListener
				(
					ScoreEvent.SCORE,
					function(event:ScoreEvent):void
					{
						dispatchEvent(event);
					}
				);
				// add behaviour to our vector
				behaviours.push(behaviour);
			}
		}
		
		private function triggerAnimation(event:AnimationEvent):void
		{
			// fire an event to tell animation to play
			dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATE, event.sequence));
		}
		
		public function reset():void
		{
			// loop through variables
			for each(var variable:CollisionVariable in variables)
			{
				// null out any set values
				variable.value = null;
			}
		}
	}
}