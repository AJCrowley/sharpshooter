package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.constants.FileConstants;
	import ca.revolve.sharpshooter.events.PopupEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.ImageLoader;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.events.ImageLoaderEvent;
	
	import flash.text.Font;
	import flash.utils.Dictionary;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.VAlign;
	
	public class PopupScreen extends Sprite
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		
		[Embed(source="assets/popupfont.ttf", embedAsCFF="false", fontName="popupheader")]
		private var PopupFont:Class;
		
		private var images:Dictionary;
		private var imageLoader:ImageLoader;
		private var popupFont:Font = new PopupFont();
		private var textFields:Vector.<TextField>;
		protected var buttons:Vector.<PopupButton>;
		
		//private var images:Vector.<Image>;
		private var imageIndex:Vector.<XML>;
		private var currentImage:XML;
		
		public function PopupScreen()
		{
			super();
		}
		
		public function set background(url:String):void
		{
			imageLoader = new ImageLoader(FileConstants.ASSETS_DIR + url); // load background
			imageLoader.addEventListener(ImageLoaderEvent.LOADED, backgroundLoaded, false, 0, true); // listen for load complete with weak reference
		}
		
		private function backgroundLoaded(event:ImageLoaderEvent):void
		{
			// initialize dictionary if not already initialized
			if(!images)
			{
				images = new Dictionary(true);
			}
			// store image in dictionary
			images["bg"] = Texture.fromBitmap(event.bitmap);
			addChildAt(new Image(images["bg"]), 0); // and add the texture at the back
			dispatchEvent(new PopupEvent(PopupEvent.BACKGROUND_LOADED)); // notify that background is loaded
		}
		
		protected function loadImages(imagesXML:XML):void
		{
			// initialize dictionary if not already initialized
			if(!images)
			{
				images = new Dictionary(true);
			}
			// initialize XML index image
			imageIndex = new Vector.<XML>;
			// add each image from XML to index
			for each(var image:XML in imagesXML.image)
			{
				imageIndex.push(image);
			}
			// if we have no images
			if(imageIndex.length == 0)
			{
				// then we're done
				dispatchEvent(new PopupEvent(PopupEvent.IMAGES_LOADED));
			}
			// get first image from stack
			currentImage = imageIndex.pop();
			// load it
			imageLoader = new ImageLoader(FileConstants.ASSETS_DIR + currentImage.valueOf());
			// and listen for load complete
			imageLoader.addEventListener(ImageLoaderEvent.LOADED, loadNextImage);
		}
		
		private function loadNextImage(event:ImageLoaderEvent):void
		{
			// store image in dictionary
			images[String(currentImage.@id)] = Texture.fromBitmap(event.bitmap);
			// get next image from stack
			currentImage = imageIndex.pop();
			// still more to load?
			if(currentImage)
			{
				// queue it up
				imageLoader = new ImageLoader(FileConstants.ASSETS_DIR + currentImage.valueOf());
				// and listen
				imageLoader.addEventListener(ImageLoaderEvent.LOADED, loadNextImage);
			}
			else
			{
				// we're done, kill the listener
				imageLoader.removeEventListener(ImageLoaderEvent.LOADED, loadNextImage);
				// and let everyone know
				dispatchEvent(new PopupEvent(PopupEvent.IMAGES_LOADED));
			}
		}
		
		public function addTextField(text:String, x:uint = 0, y:uint = 0, width:uint = 0, height:uint = 0, fontSize:uint = 0, colour:uint = 0xffffff, align:String = "center", bold:Boolean = false):void
		{
			// initialize textfields vector if not already done
			if(!textFields)
			{
				textFields = new Vector.<TextField>();
			}
			// create textfield and set properties
			var textField:TextField = new TextField(width, height, text, popupFont.fontName, fontSize, colour, bold);
			textField.hAlign = align;
			textField.vAlign = starling.utils.VAlign.CENTER;
			textField.x = x;
			textField.y = y;
			// add it to the stage
			addChild(textField);
			// and maintain a reference in our vector
			textFields.push(textField);
		}
		
		public function addButton(upState:String, x:uint, y:uint, action:String = null, id:String = null, downState:String = null, disabledState:String = null):void
		{
			// initialize buttons vector if not already done
			if(!buttons)
			{
				buttons = new Vector.<PopupButton>();
			}
			var button:PopupButton = new PopupButton(images[upState]);
			button.id = id;
			if(downState)
			{
				button.downState = images[downState];
			}
			if(disabledState)
			{
				button.disabledState = images[disabledState];
			}
			if(button.action != "")
			{
				// set action
				button.action = action;
			}
			// set properties
			button.x = x;
			button.y = y;
			button.addEventListener(TouchEvent.TOUCH, buttonClickHandler);
			// maintain reference in our vector
			buttons.push(button);
			// add to stage
			addChild(button);
		}
		
		private function buttonClickHandler(event:TouchEvent):void
		{
			// touchevent received, check that it's ended (mouseup)
			if(event.touches[0].phase == TouchPhase.ENDED)
			{
				if((event.currentTarget as PopupButton).enabled)
				{
					// what action is assigned to the current button
					switch((event.currentTarget as PopupButton).action)
					{
						// no action, just dismiss
						case null:
							dismissPopup();
							break;
						
						// next stage
						case "next":
							dismissPopup();
							break;
						
						// replay stage
						case "replay":
							_model.currentScene.completed = false;
							dismissPopup();
							break;
						
						// other
						default:
							//pass it up the chain
							dispatchEvent(new PopupEvent(PopupEvent.POPUP_BUTTON_CLICK, (event.currentTarget as PopupButton).action));
							break;
					}
				}
			}
		}
		
		public function addImage(imageRef:String, x:uint, y:uint, fadeInTime:Number = 0):void
		{
			var image:Image = new Image(images[imageRef]);
			image.x = x;
			image.y = y;
			image.alpha = 0;
			// add it to the stage
			addChild(image);
			// set it to fade in
			var tween:Tween = new Tween(image, fadeInTime, Transitions.LINEAR);
			tween.onComplete = function():void
			{
				// fade done, let everyone know the image has been displayed
				dispatchEvent(new PopupEvent(PopupEvent.POPUP_IMAGE_LOADED));
			}
			tween.fadeTo(1);
			Starling.juggler.add(tween);
		}
		
		public function dismissPopup():void
		{
			// set fade out
			var tween:Tween = new Tween(this, 0.5, Transitions.LINEAR);
			tween.onComplete = function():void
			{
				// fire event to let everyone know the popup has been dismissed
				dispatchEvent(new PopupEvent(PopupEvent.POPUP_DISMISS));
				// and remove it from the display stack
				removeFromParent(true);
			}
			tween.fadeTo(0);
			Starling.juggler.add(tween);
		}
		
		override public function dispose():void
		{
			// do we have buttons?
			if(buttons)
			{
				// yep, let's just pop them from the vector until it's empty
				var button:Button = buttons.pop();
				while(button)
				{
					// and dispose of it properly
					button.dispose();
					button = buttons.pop();
				}
			}
			// null out buttons vector
			buttons = null;
			// do we have textfields?
			if(textFields)
			{
				// yep, let's just pop them from the vector until it's empty
				var textField:TextField = textFields.pop();
				while(textField)
				{
					textField.dispose();
					textField = textFields.pop();
				}
			}
			// null out textfields vector
			textFields = null;
			// do we have images?
			if(images)
			{
				for each(var texture:Texture in images)
				{
					texture.dispose();
				}
			}
			// null out images dictionary
			images = null;
			// lose children
			removeChildren(0, -1, true);
			// and call superclass dispose
			super.dispose();
		}
	}
}