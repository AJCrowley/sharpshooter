package ca.revolve.utils
{
	import ca.revolve.utils.events.XMLLoaderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.xml.XMLDocument;

	public class XMLLoader extends XMLDocument implements IEventDispatcher
	{
		private var _dispatcher:EventDispatcher;
			
		public var xmlLoaded:Boolean = false; // flag to track if XML is loaded
		public var data:XML; // data container
		
		public function XMLLoader(xmlPath:String)
		{
			// set dispatcher reference to self
			_dispatcher = new EventDispatcher(this);
			// maintain object reference to self
			var xmlLoader:XMLLoader = this;
			// create loader
			var loader:URLLoader = new URLLoader;
			loader.addEventListener
			(
				Event.COMPLETE,
				function(event:Event):void
				{
					// config file loaded, populate data
					xmlLoader.data = new XML(event.target.data);
					// send notification that load has completed
					xmlLoader.dispatchEvent(new XMLLoaderEvent(XMLLoaderEvent.LOADED));
					// set flag to indicate config loaded
					xmlLoaded = true;
				}
			);
			// make call to load XML
			loader.load(new URLRequest(xmlPath));
		}
		
		/* Required functions to implement IEventDispatcher */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			this._dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return this._dispatcher.dispatchEvent(event)
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return this._dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			this._dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return this._dispatcher.willTrigger(type);
		}
	}
}