package ca.revolve.sharpshooter.controllers
{
	import ca.revolve.sharpshooter.constants.FileConstants;
	import ca.revolve.sharpshooter.elements.PopupButton;
	import ca.revolve.sharpshooter.elements.ScoreScreen;
	import ca.revolve.sharpshooter.elements.Scoreboard;
	import ca.revolve.sharpshooter.elements.SpriteBase;
	import ca.revolve.sharpshooter.events.PopupEvent;
	import ca.revolve.sharpshooter.events.SceneEvent;
	import ca.revolve.sharpshooter.events.ScoreEvent;
	import ca.revolve.sharpshooter.events.SpriteEvent;
	import ca.revolve.sharpshooter.models.SharpshooterModel;
	import ca.revolve.utils.ExternalCommand;
	import ca.revolve.utils.ImageLoader;
	import ca.revolve.utils.Singleton;
	import ca.revolve.utils.XMLLoader;
	import ca.revolve.utils.events.ImageLoaderEvent;
	import ca.revolve.utils.events.XMLLoaderEvent;
	
	import flash.display.BitmapData;
	import flash.system.System;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	public class GameController extends Sprite
	{
		private static const GAME_READY:String = "gameReady";
		// get model instance
		private var _model:SharpshooterModel = Singleton.getInstance(SharpshooterModel) as SharpshooterModel;
		// shape to cover screen in "wipe"
		private var screenWiper:MovieClip;
		// scene controller
		private var scene:SceneController;
		// scoreboard!
		private var scoreboard:Scoreboard = new Scoreboard();
		// score screen
		private var scoreScreen:ScoreScreen;
		// loading animation
		private var loadingAnim:SpriteBase;
		// container for loading screen
		private var loadingScreen:Sprite = new Sprite();
		// textures for Exit button
		private var exitTexture:Texture;
		private var exitTextureDown:Texture;
		private var exitButton:PopupButton;
		
		public function GameController()
		{
			// add a listener for when this has been added to the stage
			//addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(GAME_READY, init);
			// get loading animation
			loadingAnim = new SpriteBase(_model.config.data.loadingAnimation[0]);
			loadingAnim.addEventListener
			(
				SpriteEvent.LOADED,
				function(event:SpriteEvent):void
				{
					var imageLoader:ImageLoader = new ImageLoader(FileConstants.ASSETS_DIR + _model.config.data.exitButton.@image);
					imageLoader.addEventListener
					(
						ImageLoaderEvent.LOADED,
						function(event:ImageLoaderEvent):void
						{
							// assign button texture
							exitTexture = Texture.fromBitmap(event.bitmap);
							// load downState
							imageLoader = new ImageLoader(FileConstants.ASSETS_DIR + _model.config.data.exitButton.@downState);
							imageLoader.addEventListener
							(
								ImageLoaderEvent.LOADED,
								function(event:ImageLoaderEvent):void
								{
									// assign downState texture
									exitTextureDown = Texture.fromBitmap(event.bitmap);
									// free up for garbage collection
									imageLoader = null;
									// instance button
									exitButton = new PopupButton(exitTexture);
									exitButton.downState = exitTextureDown;
									exitButton.x = _model.config.data.exitButton.@x;
									exitButton.y = _model.config.data.exitButton.@y;
									exitButton.action = _model.config.data.exitButton.@action;
									exitButton.addEventListener
									(
										TouchEvent.TOUCH,
										function(event:TouchEvent):void
										{
											switch(event.touches[0].phase)
											{
												case TouchPhase.BEGAN:
													_model.buttonPressing = true;
													break;
												
												case TouchPhase.ENDED:
													_model.buttonPressing = false;
													ExternalCommand.call(ExternalCommand.CLIENT_COMMAND, exitButton.action);
													break;
											}
										}
									);
									// get colour for our wiper
									var wiperColour:uint = uint(_model.config.data.scenes.@wipeColour);
									// draw our wiper
									var screenWipeGraphic:flash.display.Sprite = new flash.display.Sprite();
									// set colour for line and fill
									screenWipeGraphic.graphics.lineStyle(1, wiperColour, 1);
									screenWipeGraphic.graphics.beginFill(wiperColour, 1);
									// draw rectangle that's the same size as our stage
									screenWipeGraphic.graphics.moveTo(0, 0);
									screenWipeGraphic.graphics.lineTo(_model.stage.stageWidth, 0);
									screenWipeGraphic.graphics.lineTo(_model.stage.stageWidth, _model.stage.stageHeight);
									screenWipeGraphic.graphics.lineTo(0, _model.stage.stageHeight);
									// and stop drawing
									screenWipeGraphic.graphics.endFill();
									// create bitmap data object
									var bitmapData:BitmapData = new BitmapData(_model.stage.stageWidth, _model.stage.stageHeight, false, wiperColour);
									// draw a copy of our rect in the bitmapdata
									bitmapData.draw(screenWipeGraphic);
									// get texture object from bitmapdata
									var texture:Texture = Texture.fromBitmapData(bitmapData);
									// create empty vector for texture
									var textures:Vector.<Texture> = new Vector.<Texture>;
									// and add the texture
									textures.push(texture);
									// create movieclip from texture
									screenWiper = new MovieClip(textures, 0);
									// add scoreboard
									addChild(scoreboard);
									// add our wipe to the loading screen
									loadingScreen.addChild(screenWiper);
									// add our loading animation
									loadingScreen.addChild(loadingAnim);
									// add exit button to stage
									addChild(exitButton);
									// add loading screen to stage
									addChild(loadingScreen);
									dispatchEvent(new Event(GAME_READY));
								}
							);
						}
					);
				}
			);
		}
		
		private function init(event:Event = null):void
		{
			loadingAnim.alpha = 1;
			// create instance of scene
			scene = new SceneController(FileConstants.ASSETS_DIR + _model.config.data.scenes.scene[_model.currentSceneIndex].@file);
			// listen for when scene layout is complete
			scene.addEventListener
			(
				SceneEvent.LAYOUT_COMPLETE,
				function(event:SceneEvent):void
				{
					// add scene to our stage
					addChildAt(scene, 0);
					// reset scoreboard
					scoreboard.zeroPoints();
					// create tween to fade out the wipe
					var tween:Tween = new Tween(loadingScreen, Number(_model.config.data.scenes.@wipeTimeOut), _model.config.data.scenes.@wipeEasing);
					tween.onComplete = function():void
					{
						loadingScreen.y = _model.stage.height;
						loadingAnim.alpha = 0;
					}
					// and fade it out
					tween.fadeTo(0);
					// set shot counter
					scoreboard.initShotCounter(scene.numShots);
					// add it to the juggler to make it happen
					Starling.juggler.add(tween);
				}
			);
			scene.addEventListener
			(
				ScoreEvent.SCORE,
				function(event:ScoreEvent):void
				{
					scoreboard.applyPoints(event.points);
				}
			);
			scene.addEventListener
			(
				SceneEvent.SHOT,
				function(event:SceneEvent):void
				{
					scoreboard.decShotCounter();
				}
			);
			scene.addEventListener(SceneEvent.RESET_SCENE, resetScene); // reset scene
		}
		
		private function resetScene(event:SceneEvent = null):void
		{
			// create tween to fade in the wipe
			var tween:Tween = new Tween(loadingScreen, Number(_model.config.data.scenes.@wipeTimeIn), _model.config.data.scenes.@wipeEasing);
			// listen for completion of fade to reload our scene
			tween.onComplete = function():void
			{
				// was that our last shot?
				if(_model.shotCount > _model.currentScene.numShots - 1)
				{
					// compile XML for scoreboard
					var scoreXML:XML = _model.config.data.scoreScreen[0].copy();
					scoreXML[0].images.appendChild(_model.currentScene.sceneXML.scoreScreen.images.image);
					scoreXML[0].appendChild(_model.currentScene.sceneXML.scoreScreen.medals);
					scoreXML[0].appendChild(_model.currentScene.sceneXML.scoreScreen.badges);
					// let client know we're loading score screen
					ExternalCommand.call(ExternalCommand.CLIENT_COMMAND, ExternalCommand.SCORESCREEN + "," + _model.currentScene.sceneXML.@title);
					// create scoreboard instance
					scoreScreen = new ScoreScreen(scoreXML);
					// listen for scorescreen to be ready
					scoreScreen.addEventListener
					(
						PopupEvent.POPUP_READY,
						function(event:PopupEvent):void
						{
							// set alpha to 0
							scoreScreen.alpha = 0;
							// add to stage
							addChild(scoreScreen);
							// set tween to fade in
							var tween:Tween = new Tween(scoreScreen, 0.5, Transitions.LINEAR);
							// do the fade in
							tween.fadeTo(1);
							Starling.juggler.add(tween);
						}
					);
					// listen for scoreboard to be dismissed
					scoreScreen.addEventListener
					(
						PopupEvent.POPUP_DISMISS,
						function(event:PopupEvent):void
						{
							var gameOver:Boolean = false;
							// dispose properly
							scoreScreen.dispose();
							// kill scene
							scene.dispose();
							// remove from stage
							scene.removeFromParent(false);
							scene = null;
							removeChild(scene);
							// force garbage collection
							System.gc();
							// reset shot count
							_model.shotCount = 0;
							// check that requirements to progress to next level have been met
							if(_model.currentScene.completed)
							{
								// increment scene index
								_model.currentSceneIndex++;
								// have we gone past our last scene?
								if(_model.currentSceneIndex > _model.config.data.scenes.scene.length() - 1)
								{
									// check whether we loop or game over on completion of all scenes
									if(_model.config.data.scenes.@loop == "true")
									{
										// we're looping, reset the scene index
										_model.currentSceneIndex = 0;
									}
									else
									{
										// flag game over
										gameOver = true;
										// send command to signal game over
										ExternalCommand.call(ExternalCommand.CLIENT_COMMAND, ExternalCommand.GAME_OVER);
									}
								}
							}
							if(!gameOver)
							{
								init();
							}
						}
					);
				}
				else
				{
					scene.reset();
					tween = new Tween(loadingScreen, Number(_model.config.data.scenes.@wipeTimeOut), _model.config.data.scenes.@wipeEasing);
					tween.onComplete = function():void
					{
						loadingScreen.y = _model.stage.height;
					}
					// and fade it out
					tween.fadeTo(0);
					// add it to the juggler to make it happen
					Starling.juggler.add(tween);
				}
			}
			loadingScreen.y = 0;
			// and fade it in
			tween.fadeTo(1);
			// add it to the juggler to make it happen
			Starling.juggler.add(tween);
		}
	}
}