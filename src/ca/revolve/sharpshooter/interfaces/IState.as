package ca.revolve.sharpshooter.interfaces
{
	import starling.events.Event;
	
	// define interface for IState
	public interface IState
	{
		function get id():String;
		function enter(event:Event = null):void;
		function update(event:Event = null):void;
		function exit(event:Event = null):void;
	}
}