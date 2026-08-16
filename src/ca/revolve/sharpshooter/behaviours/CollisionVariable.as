package ca.revolve.sharpshooter.behaviours
{
	public class CollisionVariable
	{
		// identifier
		public var name:String;
		// assigned value
		public var value:String;
		// required value
		public var reqValue:String;
		// test operator
		public var operator:String;
		
		public function CollisionVariable(name:String, reqValue:String = null, operator:String = null, value:String = null)
		{
			this.name = name;
			if(reqValue)
			{
				this.reqValue = reqValue;
			}
			if(operator)
			{
				this.operator = operator;
			}
			if(value)
			{
				this.value = value;
			}
		}
		
		public function test():Boolean
		{
			// perform test based upon operator
			switch(operator)
			{
				case "=":
					return (value == reqValue);
					break;
				
				case "!":
					return (value != reqValue);
					break;
				
				case ">":
					return (value > reqValue);
					break;
				
				case "<":
					return (value < reqValue);
					break;
			}
			// this should never happen, but default to false
			return false;
		}
	}
}