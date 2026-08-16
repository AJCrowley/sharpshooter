package ca.revolve.sharpshooter.elements
{
	import starling.display.Button;
	import starling.textures.Texture;
	
	public class PopupButton extends Button
	{
		public var id:String;
		public var action:String;
		public var disabledState:Texture;
		private var _enabledState:Texture;
		
		public function PopupButton(upState:Texture, text:String="", id:String = null)
		{
			this.id = id;
			_enabledState = upState;
			super(upState, text, downState);
			super.scaleWhenDown = 1; // prevent shrinkage in downState
		}
		
		public function set disabled(state:Boolean):void
		{
			enabled = !state;
			if(disabledState)
			{
				upState = state ? disabledState : _enabledState;
			}
		}
	}
}