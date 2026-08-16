package ca.revolve.utils.events
{
	import flash.display.Bitmap;
	import flash.events.ProgressEvent;

	public class ImageLoaderEvent extends ProgressEvent
	{
		public static const LOADED:String = "imageLoaded";
		public static const PROGRESS:String = "imageProgress";
		public static const INIT:String = "imageInit";
		
		public var bitmap:Bitmap;
		public var percentLoaded:uint = 0;
		public var url:String;
		
		public function ImageLoaderEvent(type:String, image:Bitmap = null, pctLoaded:uint = 0, bubbles:Boolean = false, cancelable:Boolean = false, imagePath:String = null)
		{
			super(type, bubbles, cancelable);
			url = imagePath;
			percentLoaded = pctLoaded;
			bitmap = image;
		}
	}
}