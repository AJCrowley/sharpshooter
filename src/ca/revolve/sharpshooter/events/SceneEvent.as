package ca.revolve.sharpshooter.events
{
	import starling.events.Event;
	
	public class SceneEvent extends Event
	{
		public static const LOADED:String = "sceneLoaded";
		public static const LOADCHAIN_NEXT:String = "sceneLoadChainNext";
		public static const LAYOUT_COMPLETE:String = "sceneLayoutComplete";
		public static const RESET_SCENE:String = "sceneReset";
		public static const SHOT:String = "sceneShot";
		
		public function SceneEvent(type:String, bubbles:Boolean = false)
		{
			super(type, bubbles);
		}
	}
}