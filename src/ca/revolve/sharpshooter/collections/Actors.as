package ca.revolve.sharpshooter.collections
{
	import ca.revolve.sharpshooter.elements.Actor;

	public class Actors
	{
		// maintain a vector of all actors in the scene
		private var _actors:Vector.<Actor>;
		private var _ids:Array;
		
		public function Actors()
		{
			// initialize vectors and arrays in the constructor
			_actors = new Vector.<Actor>;
			_ids = new Array();
		}
		
		public function push(actor:Actor):void
		{
			// push actor to vector
			_actors.push(actor);
			// store index in associative array by ID
			_ids[actor.id] = _actors.length - 1;
		}
		
		public function pop():Actor
		{
			// pop one off our vector
			return _actors.pop();
		}
		
		public function getActor(id:String):Actor
		{
			// retrieve actor by ID from our associative array
			return _actors[_ids[id]];
		}
		
		public function get actors():Vector.<Actor>
		{
			// return all actors
			return _actors;
		}
		
		public function dispose():void
		{
			for each(var actor:Actor in _actors)
			{
				actor.dispose();
				actor = null;
			}
			for each(var id:String in _ids)
			{
				id = null;
			}
		}
	}
}