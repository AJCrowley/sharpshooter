package ca.revolve.sharpshooter.elements
{
	import ca.revolve.sharpshooter.constants.FileConstants;
	import ca.revolve.sharpshooter.events.PopupEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.ExternalCommand;
	import ca.revolve.utils.Singleton;
	
	import starling.display.DisplayObject;

	public class ScoreScreen extends PopupScreen
	{
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		private var medals:Vector.<XML>;
		//private var awardedBadges:Vector.<XML>;
		private var score:Score;
		private var scoreSubmitted:Boolean = false; // track to avoid double calls
		
		public function ScoreScreen(xml:XML)
		{
			// position as defined in XML input
			x = xml.@x;
			y = xml.@y;
			// initialize score object
			score = new Score();
			// set background property, superclass will take care of loading
			background = xml.@background;
			// when background has loaded
			addEventListener
			(
				PopupEvent.BACKGROUND_LOADED,
				function(event:PopupEvent):void
				{
					// load global images
					loadImages(xml.images[0]);
					addEventListener
					(
						PopupEvent.IMAGES_LOADED,
						function(event:PopupEvent):void
						{
							// add our text fields
							addTextField(xml.scoreLabel, xml.scoreLabel.@x, xml.scoreLabel.@y, xml.scoreLabel.@width, xml.scoreLabel.@height, xml.scoreLabel.@fontSize, uint("0x" + xml.scoreLabel.@colour), xml.scoreLabel.@align, (xml.scoreLabel.@bold == true));
							addTextField(xml.medalLabel, xml.medalLabel.@x, xml.medalLabel.@y, xml.medalLabel.@width, xml.medalLabel.@height, xml.medalLabel.@fontSize, uint("0x" + xml.medalLabel.@colour), xml.medalLabel.@align, (xml.medalLabel.@bold == true));
							addTextField(xml.badgeLabel, xml.badgeLabel.@x, xml.badgeLabel.@y, xml.badgeLabel.@width, xml.badgeLabel.@height, xml.badgeLabel.@fontSize, uint("0x" + xml.badgeLabel.@colour), xml.badgeLabel.@align, (xml.badgeLabel.@bold == true));
							addTextField(String(_model.currentScene.score), xml.scoreText.@x, xml.scoreText.@y, xml.scoreText.@width, xml.scoreText.@height, xml.scoreText.@fontSize, uint("0x" + xml.scoreText.@colour), xml.scoreText.@align, (xml.badgeLabel.@bold == true));
							// do we gots buttons?
							if(xml.buttons.button.length() > 0)
							{
								// loop through them
								for each(var button:XML in xml.buttons.button)
								{
									// and add each one
									addButton(button.@image, button.@x, button.@y, button.@action, button.@id, button.@downState, button.@disabledState);
								}
								addEventListener(PopupEvent.POPUP_BUTTON_CLICK, popupButtonClicked);
							}
							if(xml.medals.medal.length() > 0)
							{
								// add them to a vector one at a time
								medals = new Vector.<XML>();
								for(var i:int = xml.medals.medal.length(); i > 0; i--)
								{
									medals.push(xml.medals.medal[i - 1][0]);
								}
								// load greyed out medals
								if(xml.medals.length() > 0)
								{
									for each(medal in xml.medals.medal)
									{
										addImage(medal.@imageoff, medal.@x, medal.@y);
									}
								}
								// load greyed out badges
								if(xml.badges.length() > 0)
								{
									for each(var badge:XML in xml.badges.badge)
									{
										addImage(badge.@imageoff, badge.@x, badge.@y);
									}
								}
								// get awarded badges
								score.badges = _model.currentScene.badges.getAwardedBadges();
								// and add badges
								for(i = xml.badges.badge.length(); i > 0; i--)
								{
									// is this in our vector of awarded badges?
									if(score.badges.indexOf(String(xml.badges.badge[i - 1][0].@id)) > -1)
									{
										// put the image up
										addImage(xml.badges.badge[i - 1].@image, xml.badges.badge[i - 1].@x, xml.badges.badge[i - 1].@y, xml.@fadeTime);
									}
								}
								// loop through medals again
								for each(var medal:XML in xml.medals.medal)
								{
									// enough points?
									if(_model.currentScene.score >= medal.@points)
									{
										// yep, mark level as completed so we can progress to next level
										_model.currentScene.completed = true;
										// and fade in the medal
										addImage(medal.@image, medal.@x, medal.@y, xml.@fadeTime);
									}
								}
								// were requirements for completion met?
								if(_model.currentScene.completed)
								{
									// was this the last stage?
									if(_model.currentSceneIndex == _model.config.data.scenes.scene.length() - 1)
									{
										// yep, game over header
										addTextField(xml.headerText.complete, xml.headerText.@x, xml.headerText.@y, xml.headerText.@width, xml.headerText.@height, xml.headerText.@fontSize, uint("0x" + xml.headerText.@colour), "center", (xml.headerText.@bold == true));
									}
									else
									{
										// no, use winning header
										addTextField(xml.headerText.pass, xml.headerText.@x, xml.headerText.@y, xml.headerText.@width, xml.headerText.@height, xml.headerText.@fontSize, uint("0x" + xml.headerText.@colour), "center", (xml.headerText.@bold == true));
									}
								}
								else
								{
									// nope, fail header
									addTextField(xml.headerText.fail, xml.headerText.@x, xml.headerText.@y, xml.headerText.@width, xml.headerText.@height, xml.headerText.@fontSize, uint("0x" + xml.headerText.@colour), "center", (xml.headerText.@bold == true));
									// and disable next button
									for each(var pButton:PopupButton in buttons)
									{
										if(pButton.id == "next")
										{
											pButton.disabled = true;
											break;
										}
									}
								}
							}
							score.stage = _model.currentSceneIndex;
							score.points = _model.currentScene.score;
							score.sessionID = _model.sessionID;
							submitScore();
							/*if(_model.currentScene.completed)
							{
								addTextField(xml.headerText.pass, xml.headerText.@x, xml.headerText.@y, xml.headerText.@width, xml.headerText.@height, xml.headerText.@fontSize, uint("0x" + xml.headerText.@colour), "center", (xml.headerText.@bold == true));
							}
							else
							{
								addTextField(xml.headerText.fail, xml.headerText.@x, xml.headerText.@y, xml.headerText.@width, xml.headerText.@height, xml.headerText.@fontSize, uint("0x" + xml.headerText.@colour), "center", (xml.headerText.@bold == true));
							}*/
							dispatchEvent(new PopupEvent(PopupEvent.POPUP_READY));
						}
					);
				}
			);
		}
		
		private function popupButtonClicked(event:PopupEvent):void
		{
			// pass on other button commands to JavaScript
			ExternalCommand.call(ExternalCommand.CLIENT_COMMAND, event.action);
		}
		
		private function submitScore(event:PopupEvent = null):void
		{
			if(!scoreSubmitted)
			{
				scoreSubmitted = true
				score.submit();
			}
		}
	}
}