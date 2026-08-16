package ca.revolve.sharpshooter.events
{
	import starling.events.Event;

	public class PopupEvent extends Event
	{
		public static const POPUP_READY:String = "popupReady";
		public static const BACKGROUND_LOADED:String = "popupBgLoaded";
		public static const BUTTON_LOADED:String = "popupButtonLoaded";
		public static const POPUP_IMAGE_LOADED:String = "popupImageLoaded";
		public static const POPUP_MEDALS_LOADED:String = "popupMedalsLoaded";
		public static const POPUP_BADGES_LOADED:String = "popupBadgesLoaded";
		public static const POPUP_BUTTON_CLICK:String = "popupButtonClick";
		public static const POPUP_DISMISS:String = "popupDismiss";
		public static const IMAGES_LOADED:String = "imagesLoaded";
		
		public var action:String;
		
		public function PopupEvent(type:String, action:String = null, bubbles:Boolean=false)
		{
			this.action = action;
			super(type, bubbles);
		}
	}
}