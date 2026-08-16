package ca.revolve.sharpshooter.events
{
	import ca.revolve.sharpshooter.behaviours.CollisionVariable;
	
	import starling.events.Event;
	
	public class CollisionVariableEvent extends Event
	{
		public static const DEFINE:String = "collisionVarDefine";
		public static const SET:String = "collisionVarSet";
		
		public var collisionVariable:CollisionVariable;
		
		public function CollisionVariableEvent(type:String, bubbles:Boolean=false, collisionVariable:CollisionVariable = null)
		{
			this.collisionVariable = collisionVariable;
			super(type, bubbles);
		}
	}
}