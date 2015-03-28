/**
* ...
* @author Dave Segal
* @version 0.1
* @date 02.19.08
*/

package com.voki.vhss.api {
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	public class JSInterface {
		
		private static var dispatcher:EventDispatcher;
		
		
		// Dispatcher methods
		
		/*
		public static function addEventListener($type:String, $listener:Function, $useCapture:Boolean = false, $priority:int = 0, $useWeakRef:Boolean = false):void
		{
			if (dispatcher == null) dispatcher = new EventDispatcher();
			dispatcher.addEventListener($type, $listener, $useCapture, $priority, $useWeakRef);
		}
		
		public static function removeEventListener($type:String, $listener:Function, $useCapture:Boolean = false):void
		{
			if (dispatcher == null) return;
			dispatcher.removeEventListener($type, $listener, $useCapture);
		}
		
		public static function dispatchEvent($ev:Event):void
		{
			if (dispatcher == null) return;
			dispatcher.dispatchEvent($ev);
		}
		*/
		
		
		public static function initJSAPI(_vhss:*):void //_vhss:VHSSPlayerV5
		{
			//trace("API DISPATCHER ::: available: "+ExternalInterface.available);
			if (ExternalInterface.available)
			{
				try
				{
					//trace("API DISPATCHER ::: add callback start");
					ExternalInterface.addCallback("setStatus", _vhss.setStatus);
					ExternalInterface.addCallback("setBackground", _vhss.setBackground);
					ExternalInterface.addCallback("setColor", _vhss.setColor);
					ExternalInterface.addCallback("setLink", _vhss.setLink);
					ExternalInterface.addCallback("is3D", _vhss.is3D);
					
					ExternalInterface.addCallback("followCursor", _vhss.followCursor);
					ExternalInterface.addCallback("freezeToggle", _vhss.freezeToggle);
					ExternalInterface.addCallback("recenter", _vhss.recenter);
					ExternalInterface.addCallback("setFacialExpression", _vhss.setFacialExpression);
					ExternalInterface.addCallback("setGaze", _vhss.setGaze);
					//ExternalInterface.addCallback("setGazeFromPage", $v.setGazeFromPage);
					
					ExternalInterface.addCallback("loadAudio", _vhss.loadAudio);
					ExternalInterface.addCallback("loadText", _vhss.loadText);
					ExternalInterface.addCallback("sayAudio", _vhss.sayAudio);
					ExternalInterface.addCallback("sayAudioExported", sayAudioExported); // added a layer between js and _vhss to bridge the difference between the interfaces
					ExternalInterface.addCallback("sayText", _vhss.sayText);
					ExternalInterface.addCallback("sayTextExported", sayTextExported); // added a layer between js and _vhss to bridge the difference between the interfaces
					ExternalInterface.addCallback("sayAIResponse", _vhss.sayAIResponse);
					ExternalInterface.addCallback("setPlayerVolume", _vhss.setPlayerVolume);
					ExternalInterface.addCallback("sayByUrl", _vhss.sayByUrl);
					ExternalInterface.addCallback("saySilent", _vhss.saySilent);
					ExternalInterface.addCallback("sayMultiple", _vhss.sayMultiple);
					ExternalInterface.addCallback("setPhoneme", _vhss.setPhoneme);
					ExternalInterface.addCallback("stopSpeech", _vhss.stopSpeech);
					ExternalInterface.addCallback("replay", _vhss.replay);
					
					ExternalInterface.addCallback("gotoNextScene", _vhss.gotoNextScene);
					ExternalInterface.addCallback("gotoPrevScene", _vhss.gotoPrevScene);
					ExternalInterface.addCallback("gotoScene", _vhss.gotoScene);
					ExternalInterface.addCallback("loadScene", _vhss.loadScene);
					ExternalInterface.addCallback("loadShow", _vhss.loadShow);
					ExternalInterface.addCallback("setNextSceneIndex", _vhss.setNextSceneIndex);
					ExternalInterface.addCallback("preloadNextScene", _vhss.preloadNextScene);
					ExternalInterface.addCallback("preloadScene", _vhss.preloadScene);
					ExternalInterface.addCallback("setIdleMovement", _vhss.setIdleMovement);
					//trace("API DISPATCHER ::: add callback end");
					//ExternalInterface.addCallback("setPhoneme", ;
					
					function sayAudioExported($name:String, $account:String = '', $start:Number = 0):void
					{
						_vhss.sayAudioExported($name, $start);
					}
					
					function sayTextExported($text:String, $voice:String, $lang:String, $engine:String, $origin:String = "", $fx_type:String = "", $fx_level:String = ""):void
					{
						_vhss.sayTextExported($text, $voice, $lang, $engine, $fx_type, $fx_level, $origin);
					}
				}
				catch (error:SecurityError)
				{
					trace("API DISPATCHER ::: SecurityError occurred: " + error.message);
				}
				catch (error:Error)
				{
					trace("API DISPATCHER ::: An Error occurred: " + error.message);
				}
			}
			else 
			{
				trace("API DISPATCHER ::: External Interface not available");
			}
			/*			
			if (ExternalInterface.available) {
                try {
                    output.appendText("Adding callback...\n");
                    ExternalInterface.addCallback("sendToActionScript", receivedFromJavaScript);
                    if (checkJavaScriptReady()) {
                        output.appendText("JavaScript is ready.\n");
                    } else {
                        output.appendText("JavaScript is not ready, creating timer.\n");
                        var readyTimer:Timer = new Timer(100, 0);
                        readyTimer.addEventListener(TimerEvent.TIMER, timerHandler);
                        readyTimer.start();
                    }
                } catch (error:SecurityError) {
                    output.appendText("A SecurityError occurred: " + error.message + "\n");
                } catch (error:Error) {
                    output.appendText("An Error occurred: " + error.message + "\n");
                }
			}
            } else {
                output.appendText("External interface is not available for this container.");
            }*/
		}
		
		// API methods
	//	public static function setPhoneme($phoneme:String):void
		//{
			//trace("API DISPATCHER --- setPhoneme: " + $phoneme);
			//dispatchEvent(new APIEvent(APIEvent.SET_PHONEME, {phoneme:$phoneme}));
		//}
		
		//public static function setStatus($interrupt:Number, $progressInterval:Number, $gazeSpeed:Number, $randomMoves:Number):void
		//{
			//dispatchEvent(new APIEvent(APIEvent.SET_INTERRUPT, { interrupt:$interrupt } ));
			//dispatchEvent(new APIEvent(APIEvent.SET_PROGRESS_INTERVAL, { progressInterval:$progressInterval } ));
			//dispatchEvent(new APIEvent(APIEvent.SET_GAZE_SPEED, { gazeSpeed:$gazeSpeed } ));
			//dispatchEvent(new APIEvent(APIEvent.SET_RANDOM_MOVEMENT, { randomMoves:$randomMoves } ));
			//dispatchEvent(new APIEvent(APIEvent.SET_STATUS, {interrupt:$interrupt, progressInterval:$progressInterval, gazeSpeed:$gazeSpeed, randomMoves:$randomMoves}));
		//}
		
		/*
		public static function onAudioProgress($percent:Number):void
		{
			dispatchEvent(new APIEvent(APIEvent.AUDIO_PROGRESS, { percent:$percent } ));
		}
		*/		
	}
}