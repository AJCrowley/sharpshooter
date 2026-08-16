package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.events.PopupEvent;
	
	public class InstructionScreen extends PopupScreen
	{
		public function InstructionScreen(xml:XML)
		{
			// set position from XML
			x = xml.@x;
			y = xml.@y;
			// load background from XML
			background = xml.@background;
			addEventListener
			(
				PopupEvent.BACKGROUND_LOADED,
				function(event:PopupEvent):void
				{
					// background loaded, load any other images
					loadImages(xml.images[0]);
					addEventListener
					(
						PopupEvent.IMAGES_LOADED,
						function(event:PopupEvent):void
						{
							// add content image
							addImage(xml.content.@image, xml.content.@x, xml.content.@y);
							// images loaded, add text fields
							addTextField(xml.headerText, xml.headerText.@x, xml.headerText.@y, xml.headerText.@width, xml.headerText.@height, xml.headerText.@fontSize, uint("0x" + xml.headerText.@colour), "center", (xml.headerText.@bold == true));
							addTextField(xml.bodyText, xml.bodyText.@x, xml.bodyText.@y, xml.bodyText.@width, xml.bodyText.@height, xml.bodyText.@fontSize, uint("0x" + xml.bodyText.@colour), "center", (xml.bodyText.@bold == true));
							// add button
							addButton(xml.button.@image, xml.button.@x, xml.button.@y, null, null, xml.button.@downState);
							// fire event so everyone knows we're ready
							dispatchEvent(new PopupEvent(PopupEvent.POPUP_READY));
						}
					);
					
					
					// fire event so everyone knows we're ready
					addEventListener
					(
						PopupEvent.BUTTON_LOADED,
						function(event:PopupEvent):void
						{
							dispatchEvent(new PopupEvent(PopupEvent.POPUP_READY));
						}
					);
				}
			);
		}
	}
}