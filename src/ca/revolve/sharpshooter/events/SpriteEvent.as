package ca.revolve.sharpshooter.events
{
	import ca.revolve.sharpshooter.elements.SpriteBase;
	
	import starling.events.Event;

	public class SpriteEvent extends Event
	{
		public static const LOADED:String = "spriteLoaded";
		public static const ANIMATION_COMPLETE:String = "spriteAnimationComplete";
		public static const START_ANIMATION:String = "spriteAnimationStart";
		public static const RESET:String = "spriteReset";
		
		public var sprite:SpriteBase;
		
		public function SpriteEvent(type:String, bubbles:Boolean = false, sprite:SpriteBase = null)
		{
			if(sprite)
			{
				this.sprite = sprite;
			}
			super(type, bubbles);
		}
	}
}