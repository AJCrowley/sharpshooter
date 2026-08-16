package ca.revolve.sharpshooter.behaviours
{
	import ca.revolve.sharpshooter.constants.PuckModifierConstants;
	import ca.revolve.sharpshooter.events.PuckEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.TrigTool;
	
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class PuckBehaviour extends EventDispatcher
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		private var modifier:String;
		private var x:Number;
		private var y:Number;
		private var xPos:Number;
		private var yPos:Number;
		private var posTime:Number;
		private var easing:String;
		private var power:Number;
		private var angle:Number;
		private var newMomentum:Point;
		private var delay:uint;
		private var delayCounter:uint = 0;
		private var vanish:Boolean = false;
		
		public function PuckBehaviour(xml:XML)
		{
			// get modifier type, must be as defined in PuckModifierConstants
			modifier = xml.@modifier;
			// test for presence of x (horizontal momentum) in XML, apply to var if set 
			if(xml.@x.length() > 0)
			{
				x = xml.@x;
			}
			// test for presence of y (vertical momentum) in XML, apply to var if set
			if(xml.@y.length() > 0)
			{
				y = xml.@y;
			}
			// test for presence of xPos (horizontal position) in XML, apply to var if set
			if(xml.@xPos.length() > 0)
			{
				xPos = xml.@xPos;
			}
			// test for presence of x (vertical position) in XML, apply to var if set
			if(xml.@yPos.length() > 0)
			{
				yPos = xml.@yPos;
			}
			// test for presence of posTime (time in seconds to animate to any set xPos/yPos) in XML, apply to var if set
			if(xml.@posTime.length() > 0)
			{
				posTime = xml.@posTime;
			}
			// test for presence of animation easing in XML, apply to var if set, must match one of the constants in Transitions class
			if(xml.@easing.length() > 0)
			{
				easing = xml.@easing;
			}
			// test for presence of power (overall speed, only applies in percent mode) in XML, apply to var if set
			if(xml.@power.length() > 0)
			{
				power = xml.@power;
			}
			// test for presence of angle of puck movement (only applies in absolute mode) in XML, apply to var if set
			if(xml.@angle.length() > 0)
			{
				angle = xml.@angle;
			}
			// test for presence of delay (frames to wait before applying new momentum) in XML, apply to var if set
			if(xml.@delay.length() > 0)
			{
				delay = xml.@delay;
			}
			// test for presence of vanish (hide puck) in XML, apply to var if set
			if(xml.@vanish.length() > 0)
			{
				vanish = (xml.@vanish == "true");
			}
		}
		
		public function execute():void
		{
			var newPos:Point = new Point();
			newMomentum = new Point();
			// default updated puck momentum to current puck momentum
			newMomentum.x = _model.puck.momentum.x;
			newMomentum.y = _model.puck.momentum.y;
			// check what kind of modifier we're using
			switch(modifier)
			{
				// modify by percentage
				case PuckModifierConstants.PERCENTAGE:
					// if x is set, make new x momentum relevant percentage
					if(!isNaN(x))
					{
						newMomentum.x *= (x / 100);
					}
					// if y is set, make new y momentum relevant percentage
					if(!isNaN(y))
					{
						newMomentum.y *= (y / 100);
					}
					// if power is set, make new x and y momentum relevant percentage power increase
					if(!isNaN(power))
					{
						newMomentum.x *= (power / 100);
						newMomentum.y *= (power / 100);
					}
					break;
				// modify by absolute value
				case PuckModifierConstants.ABSOLUTE:
					// if x is set, set new x momentum to relvant value
					if(!isNaN(x))
					{
						newMomentum.x = x;
					}
					// if y is set, set new y momentum to relvant value
					if(!isNaN(y))
					{
						newMomentum.y = y;
					}
					// if angle is set, set angle to relvant value
					if(!isNaN(angle))
					{
						newMomentum.x = (_model.puck.speed * Math.tan(TrigTool.deg2rad(angle)));
						newMomentum.y = _model.puck.speed - newMomentum.x;
					}
					break;
			}
			// if position has changed, set newPos values, else default to current position
			if(!isNaN(xPos))
			{
				newPos.x = xPos;
			}
			else
			{
				newPos.x = _model.puck.x;
			}
			if(!isNaN(yPos))
			{
				newPos.y = yPos;
			}
			else
			{
				newPos.y = _model.puck.y;
			}
			// do we want to hide the puck?
			_model.puck.visible = !vanish;
			// if the position of the puck has changed
			if(!((newPos.x == _model.puck.x) && (newPos.y == _model.puck.y)))
			{
				// create a tween on the puck
				var tween:Tween = new Tween(_model.puck, posTime, easing);
				// tween to new xPos and yPos values
				tween.animate("x", newPos.x);
				tween.animate("y", newPos.y);
				// fire setMomentum function upon animation complete
				tween.onComplete = setMomentum;
				// add to juggler to animate
				Starling.juggler.add(tween);
			}
			else
			{
				// no animation, no need to wait, just apply the new momentum
				setMomentum();
			}
		}
			
		private function setMomentum(event:Event = null):void
		{
			// is there a delay defined?
			if(delay)
			{
				// set delayed flag on puck so it doesn't fire "stopped" event when we stop it
				_model.puck.isDelayed = true;
				// remove all momentum from puck
				_model.puck.momentum.x = 0;
				_model.puck.momentum.y = 0;
				// set delay
				setTimeout(applyMomentum, delay);
			}
			else
			{
				// no delay, just set the new momentum
				_model.puck.momentum = newMomentum;
			}
			// fire an event to alert system that this behaviour has been applied
			dispatchEvent(new PuckEvent(PuckEvent.BEHAVIOUR_APPLIED));
		}
		
		private function applyMomentum():void
		{
			// give puck momentum
			_model.puck.momentum = newMomentum;
			// remove the isDelayed flag from puck so "stopped" event will fire correctly when puck stops
			_model.puck.isDelayed = false;
		}
	}
}