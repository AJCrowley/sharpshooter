package ca.revolve.utils.events
{
	import flash.events.Event;

	public class ConfigEvent extends Event
	{
		public static const LOADED:String = "configLoaded";
		
		public function ConfigEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}