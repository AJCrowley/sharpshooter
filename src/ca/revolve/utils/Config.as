/*
XML Config class
kris.mccann@revolve.ca
to reference an attribute
	trace(config.data.path.to.element.@attribute);
to reference an element:
	trace(config.data.path.to.element);
*/


package ca.revolve.utils
{
	import ca.revolve.utils.events.ConfigEvent;
	import ca.revolve.utils.events.XMLLoaderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class Config extends Singleton implements IEventDispatcher
	{
		private var _xmlLoader:XMLLoader;
		private var _dispatcher:EventDispatcher;
		
		public function Config()
		{
			_dispatcher = new EventDispatcher(this);
		}
		
		public function loadConfig(configPath:String):void
		{
			// set reference to self
			var config:Config = this;
			_xmlLoader = new XMLLoader(configPath);
			_xmlLoader.addEventListener
			(
				XMLLoaderEvent.LOADED,
				function(event:Event):void
				{
					config.dispatchEvent(new ConfigEvent(ConfigEvent.LOADED));
				}
			);
		}
		
		public function get data():XML
		{
			return _xmlLoader.data;
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