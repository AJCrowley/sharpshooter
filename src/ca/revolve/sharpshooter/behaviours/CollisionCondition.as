package ca.revolve.sharpshooter.behaviours
{
	import ca.revolve.sharpshooter.events.CollisionVariableEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.Singleton;
	
	import starling.events.EventDispatcher;

	public class CollisionCondition extends EventDispatcher
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		private var _xml:XML;
		
		public var minPower:Number;
		public var maxPower:Number;
		public var minAngle:Number;
		public var maxAngle:Number;
		//public var variables:Array;
		
		public function CollisionCondition(xml:XML)
		{
			// do we have any conditions?
			if(xml)
			{
				_xml = xml;
				// set min power requirement, Not A Number if not set
				minPower = xml.power.@min.length() == 0 ? NaN : xml.power.@min;
				// set max power requirement, Not A Number if not set
				maxPower = xml.power.@max.length() == 0 ? NaN : xml.power.@max;
				// set min angle requirement, Not A Number if not set
				minAngle = xml.angle.@min.length() == 0 ? NaN : xml.angle.@min;
				// set max angle requirement, Not A Number if not set
				maxAngle = xml.angle.@max.length() == 0 ? NaN : xml.angle.@max;
			}
		}
		
		public function setupVars():void
		{
			if(_xml)
			{
				// get variable requisites from xml
				for each(var variable:XML in _xml.variable)
				{
					// pass variable definition up event chain
					dispatchEvent(new CollisionVariableEvent(CollisionVariableEvent.DEFINE, false, new CollisionVariable(variable.@name, variable.@value, variable.@operator)));
				}
			}
		}
		
		public function test(variables:Array = null):Boolean
		{
			// is min power defined, and does our puck speed meet the criteria?
			if(minPower && _model.puck.speed < minPower)
			{
				// no, return false
				return false;
			}
			// is max power defined, and does our puck speed meet the criteria?
			if(maxPower && _model.puck.speed > maxPower)
			{
				// no, return false
				return false;
			}
			// is min angle defined, and does our puck speed meet the criteria?
			if(minAngle && _model.puck.angle < minAngle)
			{
				// no, return false
				return false;
			}
			// is max angle defined, and does our puck speed meet the criteria?
			if(maxAngle && _model.puck.angle > maxAngle)
			{
				// no, return false
				return false;
			}
			// if we have variables required
			if(variables)
			{
				// loop through each one
				for each(var variable:CollisionVariable in variables)
				{
					// if it doesn't test positive
					if(!variable.test())
					{
						// return false
						return false;
					}
				}
			}
			// nothing has returned false, all criteria have been met, return true
			return true;
		}
	}
}