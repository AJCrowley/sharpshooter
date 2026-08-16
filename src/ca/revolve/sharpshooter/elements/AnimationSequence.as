package ca.revolve.sharpshooter.elements
{
	import starling.events.EventDispatcher;

	public class AnimationSequence extends EventDispatcher
	{
		// vector of animation stack
		public var animations:Vector.<String> = new Vector.<String>;
		public var loop:Boolean = false;
		// store index of current animation
		public var currentIndex:uint = 0;
		
		public function AnimationSequence(xml:XML)
		{
			// loop through animations defined in input XML
			for each (var animation:String in xml.animation)
			{
				// push animation to our vector
				animations.push(animation);
			}
			// set loop as defined in XML
			loop = xml.@loop == "true";
		}
	}
}