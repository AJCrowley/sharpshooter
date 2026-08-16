/*
Image Loader class
kris.mccann@revolve.ca
Usage:
	var imageLoader:ImageLoader = new ImageLoader("path/image.png");
	imageLoader.addEventListener
	(
		ImageLoaderEvent.LOADED,
		function(event:ImageLoaderEvent):void
		{
			var bitmap:Bitmap = event.bitmap;
		}
	);
*/

package ca.revolve.utils
{
	import ca.revolve.utils.events.ImageLoaderEvent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class ImageLoader extends EventDispatcher
	{
		public function ImageLoader(imagePath:String)
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener // set up listener for load complete
			(
				Event.INIT,
				function(event:Event):void
				{
					dispatchEvent(new ImageLoaderEvent(ImageLoaderEvent.INIT, null)); // started
				}
			);
			loader.contentLoaderInfo.addEventListener // set up listener for load progress
			(
				ProgressEvent.PROGRESS,
				function(event:ProgressEvent):void
				{
					dispatchEvent(new ImageLoaderEvent(event.type, null, (100 / event.bytesTotal) * event.bytesLoaded, false, false, imagePath)); // dispatch custom event with calculated load percentage
				}
			);
			loader.contentLoaderInfo.addEventListener
			(
				Event.COMPLETE,
				function(event:Event):void
				{
					dispatchEvent(new ImageLoaderEvent(ImageLoaderEvent.LOADED, event.target.content, 100, false, false, imagePath)); // pass bitmap on to event
				}
			)
			loader.load(new URLRequest(imagePath)); // fire request
		}
	}
}