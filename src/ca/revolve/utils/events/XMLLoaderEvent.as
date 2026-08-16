package ca.revolve.utils.events
{
	import flash.events.Event;

	public class XMLLoaderEvent extends Event
	{
		public static const LOADED:String = "xmlLoaderLoaded";
		
		public function XMLLoaderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}