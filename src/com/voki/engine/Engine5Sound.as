package com.voki.engine
{
	import com.oddcast.audio.Speech;
	import com.oddcast.event.EngineEvent;
	import com.oddcast.event.SpeechEvent;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	//import emotion;
	//import AudioMCListener;
	public class Engine5Sound extends EventDispatcher
	{		
		private var _bBusy:Boolean;
		private var _bReallyBusy:Boolean;
		private var _uintSpeechLoaded:uint;		
		private var _uintLoadTotal:uint;
		private var _intSafeToPlay:int;
		private var _uintTrailerCount:uint;
		private var _arrAudios:Array;
		private var _speechCurrent:Speech;
		
		private var _arrSeq:Array;
		private var _intSeqIndex:int;
		
		private var _bDone:Boolean;
		private var _bNewWord:Boolean;
		private var _bLastCycleIsNewWord:Boolean;
		private var _iCycleCounter:int = 0;				
		
		private var lip2to1Map:Array;
		private var _nMouthVersion:Number;
		private var _nLipVersion:Number;
		
		private var _engineRef:EngineV5;
		private var _timer:Timer;
		private var _timerSilent:Timer;
		private var _silentEndTime:Number;
		private var _volume	:Number = 1;
		
		private var _bResumeSilent:Boolean;
		private var _bResume:Boolean;
		private var _bTalkStartedCalled:Boolean;
		private var _bSaySilent:Boolean;
		private var tempSpeech:Speech;
		private var _bSampleRateFixNeeded:Boolean = false;
		
		function Engine5Sound()
		{			
			//trace("ENGINE v5 --  SOUND");
			var t_ver:String = Capabilities.version;//  Capabilities.version;
			var t_ver_ar:Array = t_ver.split(" ")[1].split(",");
			//trace("t_ver_ar[0]="+t_ver_ar[0]+", (t_ver_ar[2]="+t_ver_ar[2]+", t_ver_ar[2]="+t_ver_ar[2]);
			if (t_ver_ar[0] == "9" && (t_ver_ar[2] == "115" || t_ver_ar[2] == "124"))
			{
				_bSampleRateFixNeeded = true;
			}
			
			_bBusy = false;
			_bReallyBusy = false;			
			_uintSpeechLoaded = 0;
			_uintLoadTotal = 0;
			_intSafeToPlay = 0;
			
			_uintTrailerCount = 0;
			
			_arrAudios = new Array();
			_speechCurrent = null;
			
			_arrSeq = new Array();
			_intSeqIndex = -1;
			_bDone = true;
			
			lip2to1Map = new Array(0,1,2,3,4,5,6,5,8,9,10,1,9,9,8,5);
			_timer = new Timer(EngineV5Constants.ENGINE_SOUND_UPDATE_INTERVAL);
			_timer.addEventListener(TimerEvent.TIMER,timerHandler);
			_timerSilent = new Timer(1000/EngineV5Constants.AUDIO_FPS);
			_timerSilent.addEventListener(TimerEvent.TIMER,randomLipMove);
			_timerSilent.addEventListener(TimerEvent.TIMER_COMPLETE,onSaySilentEnded);
			
		}
		
		public function getEngineSound():Sound
		{
			return _speechCurrent.sound
		}
		
		public function getEngineSoundChannel():SoundChannel
		{
			return _speechCurrent.soundChannel;
		}
		
		public function setEngine(engine:EngineV5):void
		{
			_engineRef = engine;
		}
		
		public function setMouthVersion(ver:Number):void
		{
			_nMouthVersion = ver;
		}
		
		public function freeze():void
		{
			if (_timer.running)
			{
				if (_speechCurrent!=null)
				{
					_speechCurrent.pause();
				}
				_timer.stop();
				_bResume = true;
			}
			
			if (_timerSilent.running)
			{
				_timerSilent.stop();
				_bResumeSilent = true;
			}
		}
		
		public function resume():void
		{
			if (_bResume)
			{
				if (_speechCurrent!=null)
				{
					_speechCurrent.resume();
				}
				_timer.start()
				_bResume = false;
			}
			if (_bResumeSilent)
			{
				_bResumeSilent = false;
			}
		}
		public function setVolume(value:Number):void
		{
			_volume = value;
			for each (var speech:Speech in _arrAudios) {
				//speech.setVolume(value);
			}
		}
		public function getVolume():Number
		{
			return _volume;
		}
		public function stopSound():void
		{
			/*
			while(_arrSeq.length>0)
			{
			_arrSeq.pop();
			}
			*/	
			_arrSeq = new Array();
			_uintLoadTotal = 0;
			_uintSpeechLoaded = 0;
			_intSafeToPlay = 0;
			_intSeqIndex = -1;
			_bBusy = false;
			_bReallyBusy = false;		
			_bDone = true;
			
			if (_timerSilent.running)
			{
				_timerSilent.stop();
				onSaySilentEnded();
				_bSaySilent = false;
			}
			if (_timer.running)
			{
				if (_speechCurrent!=null)
				{
					_speechCurrent.stop();					
				}
				_timer.stop();
				
			}
			_bTalkStartedCalled = false;
			if (_speechCurrent!=null)
			{
				_speechCurrent = null;
				dispatchEvent(new EngineEvent(EngineEvent.TALK_ENDED,new Object()));
				dispatchEvent(new EngineEvent(EngineEvent.SMILE,false));			
				
			}
			
		}
		
		public function sayNoAutoStart(url:String, sec:Number = 0):void
		{
			
		}
		
		public function say(url:String, sec:Number = 0, no_start:Boolean = false):void
		{
			if (_timerSilent.running)
			{
				_timerSilent.stop();
				_bSaySilent = false;
			}
			//trace("EngineV5::Engine5Sound::say 1"+url+","+sec);
			var loadingNeeded:Boolean = false;
			if (_arrAudios[escape(url)]==undefined)
			{		
				tempSpeech = new Speech(url,_engineRef.getAudioFPS());
//				if ("setVolume" in tempSpeech)
//					tempSpeech.setVolume(_volume); // maintain previously set volume
				tempSpeech.setSampleRateDiffRatio(_bSampleRateFixNeeded?EngineV5Constants.ENGINE_SOUND_SAMPLE_RATE_RATIO:1);				
				tempSpeech.addEventListener(SpeechEvent.SPEECH_LOADED,speechLoaded);
				tempSpeech.addEventListener(SpeechEvent.SPEECH_LOAD_ERROR,speechLoadError);
				tempSpeech.addEventListener(SpeechEvent.SPEECH_ERROR,speechError);
				tempSpeech.addEventListener(SpeechEvent.SPEECH_STARTED,speechStarted);
				tempSpeech.addEventListener(SpeechEvent.SPEECH_ENDED,speechEnded);				
				tempSpeech.addEventListener(SpeechEvent.SPEECH_NEW_WORD,speechNewWord);
				_arrAudios[escape(url)] = tempSpeech;
				loadingNeeded = true;
				/*
				var t_url_1:String = _engineRef.loaderInfo.url
				t_url_1 = t_url_1.substring(t_url_1.indexOf("://")+3, t_url_1.indexOf("/", t_url_1.indexOf("://")+3));
				var t_url_2:String = unescape(url);
				t_url_2 = t_url_2.substring(t_url_2.indexOf("://")+3, t_url_2.indexOf("/", t_url_2.indexOf("://")+3));
				if (t_url_1 == t_url_2) tempSpeech.setCheckPolicyFile(false);
				*/
				tempSpeech.load();
			}
			else /*if (Speech(_arrAudios[escape(url)]).isLoaded())*/ //not needed 
			{
				_uintSpeechLoaded++;
			}			
			_arrSeq.push({id:escape(url),offset:sec});			
			_uintLoadTotal++;
			if (loadingNeeded)
			{
				dispatchEvent(new EngineEvent(EngineEvent.SMILE,true));
				dispatchEvent(new EngineEvent(EngineEvent.AUDIO_DOWNLOAD_START,_arrAudios[escape(url)]));
			}			
			_bBusy = true;
			_bDone = false;
			if (!_timer.running)
			{
				_uintTrailerCount = 0;
				_timer.start();
			}
		}
		
		public function saySilent(sec:uint):void
		{
			_silentEndTime = (sec * 1000) + getTimer();
			_timerSilent.reset();
			
			_timerSilent.repeatCount = sec*EngineV5Constants.AUDIO_FPS;			
			_bSaySilent = true;
			_bBusy = true;
			_bReallyBusy = true;
			_bDone = false;
			
			_timerSilent.start();
		}
		
		public function isBusy():Boolean
		{
			return _bBusy;
		}
		
		public function isNewWord():Boolean
		{
			if (_bSaySilent)
			{
				return Math.random()<EngineV5Constants.ENGINE_SOUND_WORD_END_PERCENT;
			}
			else
			{
				return _bNewWord;
			}
		}
		
		public function getCurrentSpeechProgress():Number
		{
			if (_speechCurrent!=null)
			{
				return _speechCurrent.getPlayedPercent();
			}
			else
			{
				return 1;
			}
		}
		
		private function randomLipMove(evt:TimerEvent):void
		{
			if (getTimer() < _silentEndTime)
			{
				var rndMouthFrame:uint = Math.floor(Math.random()*(_nMouthVersion>=2?EngineV5Constants.MOUTH_FRAMES:EngineV5Constants.MOUTH_FRAMES_OLD));
				rndMouthFrame = rndMouthFrame==0?1:rndMouthFrame;
				dispatchEvent(new EngineEvent(EngineEvent.NEW_MOUTH_FRAME,rndMouthFrame));
				//trace("ENGINE V5 :: randomLipMove " + _timerSilent.currentCount);
			}
			else
			{
				//trace("ENGINE V5 -- end with timer");
				_timerSilent.stop();
				_bSaySilent = false;
				onSaySilentEnded();
			}
			
		}
		
		private function stopRandomLipMove():void
		{
			_timerSilent.stop();
		}
		
		private function onSaySilentEnded(evt:TimerEvent = null):void
		{
			///trace("ENGINE V5 -- onsaysilentended");
			_bBusy = false;
			_bReallyBusy = false;		
			_bDone = true;
			//dispatchEvent(new EngineEvent(EngineEvent.SMILE,false));
			//trace("ENGINE5Sound ----------- SAY SILENT DONE");
			dispatchEvent(new EngineEvent(EngineEvent.SAY_SILENT_ENDED));
			dispatchEvent(new EngineEvent(EngineEvent.NEW_MOUTH_FRAME,_engineRef.getMouthVersion()>=2?17:1));
		}
		
		private function timerHandler(evt:TimerEvent):void
		{			
			//trace("Engine5Sound::timerHandler trailer="+_uintTrailerCount+", _bBusy="+_bBusy+", _bDone="+_bDone);
			//trace("ENGINE v5 ::timerHandler:: busy: "+_bBusy);
			_iCycleCounter++;
			if (_bDone)
			{
				_timer.stop();
				return;
			}
			
			if (!_bBusy)
			{
				_bReallyBusy = false;
				switch(_uintTrailerCount++)
				{
					case 5:
						_bTalkStartedCalled = false;
						dispatchEvent(new EngineEvent(EngineEvent.TALK_ENDED,new Object()));
						dispatchEvent(new EngineEvent(EngineEvent.NEW_MOUTH_FRAME,_engineRef.getMouthVersion()>=2?17:1));
						break;
					case 10:
						dispatchEvent(new EngineEvent(EngineEvent.SMILE,false));
						break;
					case 15:
						_bDone = true;
						break;
				}
				return;
			}	
			//trace("TimerHandler::_uintSpeechLoaded="+_uintSpeechLoaded+", _uintLoadTotal="+_uintLoadTotal);		
			if (_uintSpeechLoaded==_uintLoadTotal)
			{
				_intSafeToPlay = _uintLoadTotal;
			}
			
			if (_intSeqIndex >= (_intSafeToPlay-1) && _speechCurrent==null)
			{
				if (_intSeqIndex>=(_uintLoadTotal-1))
				{
					_bBusy = false
				}
				return;
			}			
			
			if (_speechCurrent==null)
			{
				//trace("LINE 331 -- call next in seq");
				nextInSequence();
			}
			
			if (!_bReallyBusy)
			{
				_bReallyBusy = true;
				//dispatchEvent(new EngineEvent(EngineEvent.TALK_STARTED,new Object()));
			}	
			var currentLipFrame:int
			if (_speechCurrent!=null)
			{				
				currentLipFrame = _speechCurrent.getLipFrame();
				//trace("SOUND ENGINE -- set lip frame::: "+currentLipFrame);
			}
			else
			{
				currentLipFrame = -1;
				//trace("SOUND ENGINE -- auto set lip to -1!!!");
			}
			//trace("Engine5::Engine5Sound::timerHander currentLipFrame="+currentLipFrame);
			if (currentLipFrame==-1)
			{
				//if (_speechCurrent!=null) _speechCurrent.resetSoundState();
				//dispatchEvent(new EngineEvent(EngineEvent.AUDIO_ENDED,new Object()));
				//dispatchEvent(new EngineEvent(EngineEvent.SMILE,true));
				//evt.updateAfterEvent();
				//trace("LINE 355 -- call next in seq  _speechCurrent: "+_speechCurrent);
				if (!nextInSequence())
				{					
					//dispatchEvent(new EngineEvent(EngineEvent.SMILE,false));
					return;
				}
				
			}
			else
			{
				var frameNum:int = getMouthFrame(currentLipFrame+1);
				//trace("getMouthFrame(currentLipFrame)="+frameNum);
				dispatchEvent(new EngineEvent(EngineEvent.NEW_MOUTH_FRAME,frameNum));
				
				//_engineRef.setMouthFrame(frameNum);
				_bNewWord = _speechCurrent.isNewWord()
				
				if (_bLastCycleIsNewWord && _bNewWord)
				{
					_bNewWord = false;
				}
				else
				{
					_bLastCycleIsNewWord = _bNewWord;
				}		
				//trace("EngineSound::_iCycleCounter="+_iCycleCounter);		
				//evt.updateAfterEvent();
			}			
		}
		
		private function nextInSequence():Boolean
		{		
			_iCycleCounter = 0;				
			if (_speechCurrent!=null)
			{			
				//_speechCurrent.removeEventListener(SpeechEvent.SPEECH_LOADED,speechLoaded);
				//_speechCurrent.removeEventListener(SpeechEvent.SPEECH_LOAD_ERROR,speechLoadError);
				//_speechCurrent.removeEventListener(SpeechEvent.SPEECH_STARTED,speechStarted);
				//_speechCurrent.removeEventListener(SpeechEvent.SPEECH_ENDED,speechEnded);				
				//_speechCurrent.removeEventListener(SpeechEvent.SPEECH_NEW_WORD,speechNewWord);
			}
			//trace("nextInSequence() before test _intSeqIndex="+_intSeqIndex);
			
			if (_intSeqIndex>=(_intSafeToPlay-1))
			{			
				_speechCurrent = null;
				//dispatchEvent(new EngineEvent(EngineEvent.SMILE,false));
				return false;
			}
			_intSeqIndex++;
			//trace("nextInSequence() after test _intSeqIndex="+_intSeqIndex);
			//trace("EngineV5::Engine5Sound nextInSequence _intSeqIndex="+_intSeqIndex)
			
			/*
			if (_intSeqIndex==0)
			{			
			_bTalkStartedCalled = false;
			
			}
			*/
			_speechCurrent = _arrAudios[_arrSeq[_intSeqIndex].id];
			//trace("nextInSequence() _speech current: "+_speechCurrent);		
			_speechCurrent.play(_arrSeq[_intSeqIndex].offset);			
			return true;
		}
		
		private function getMouthFrame(n:uint):uint
		{
			var lipVer:Number = _speechCurrent.getLipVersion();
			var mouthVer:Number = _engineRef.getMouthVersion();
			if (lipVer>=2 && mouthVer!=2)
			{
				return lip2to1Map[n];
			}
			else
			{
				return n;
			}
		}
		
		private function speechLoaded(evt:SpeechEvent):void
		{
			
			var loadedSpeech:Speech = Speech(evt.data);
			//trace("ENGINE v5 - - speech loaded "+loadedSpeech.getURL()+"   _uintSpeechLoaded: "+_uintSpeechLoaded+" _uintLoadTotal: "+_uintLoadTotal);
			//trace("speechLoaded "+loadedSpeech.getURL());
			//_arrAudios[escape(loadedSpeech.getURL())] = loadedSpeech;
			_uintSpeechLoaded++;
			/*
			if (_uintSpeechLoaded == _uintLoadTotal)
			{
			startSequence();
			}
			*/
		}
		
		private function speechLoadError(evt:SpeechEvent):void
		{
			dispatchEvent(new EngineEvent(EngineEvent.AUDIO_ERROR, evt.data)); //data is an error object
			var t_error:Array = String(evt.data).split(" ");
			for (var i:int = 0; i < t_error.length; ++i)
			{
				if (String(t_error[i]).indexOf(".mp3") != 0)
				{
					_arrAudios[escape(t_error[i])] = undefined;
				}
			}
			//trace("LINE 455 -- call next in seq");
			nextInSequence();
		}
		
		private function speechError(evt:SpeechEvent):void
		{
			dispatchEvent(new EngineEvent(EngineEvent.AUDIO_ERROR, evt.data)); //data is an error object
			var t_error:Array = String(evt.data).split(" ");
			for (var i:int = 0; i < t_error.length; ++i)
			{
				if (String(t_error[i]).indexOf(".mp3") != 0)
				{
					_arrAudios[escape(t_error[i])] = undefined;
				}
			}
			//trace("LINE 362 -- call next in seq");
			nextInSequence();
		}
		
		private function speechStarted(evt:SpeechEvent):void
		{
			//trace("EngineV5::Engine5Sound speechStarted _bTalkStartedCalled="+_bTalkStartedCalled)
			if (!_bTalkStartedCalled)
			{
				_bTalkStartedCalled = true;
				//_bNewWord = true;
				dispatchEvent(new EngineEvent(EngineEvent.TALK_STARTED,new Object()));
			}
			dispatchEvent(new EngineEvent(EngineEvent.AUDIO_STARTED,evt.data));
		}
		
		private function speechEnded(evt:SpeechEvent):void
		{			
			_uintTrailerCount = 0;
			dispatchEvent(new EngineEvent(EngineEvent.AUDIO_ENDED,evt.data));	
			//dispatchEvent(new EngineEvent(EngineEvent.NEW_MOUTH_FRAME,_engineRef.getMouthVersion()>=2?17:1));		
			dispatchEvent(new EngineEvent(EngineEvent.NEW_MOUTH_FRAME,{f:_engineRef.getMouthVersion()>=2?17:1,audioEnded:true}));
			//dispatchEvent(new EngineEvent(EngineEvent.SMILE,false));
		}
		
		private function speechNewWord(evt:SpeechEvent):void
		{
			dispatchEvent(new EngineEvent(EngineEvent.WORD_ENDED,evt.data));
		}
		
		public function destroy():void
		{
			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER,timerHandler);
			}
			if (_timerSilent)
			{
				_timerSilent.stop();
				_timerSilent.removeEventListener(TimerEvent.TIMER,randomLipMove);
				_timerSilent.removeEventListener(TimerEvent.TIMER_COMPLETE,onSaySilentEnded);
			}
			if (tempSpeech)
			{
				tempSpeech.removeEventListener(SpeechEvent.SPEECH_LOADED,speechLoaded);
				tempSpeech.removeEventListener(SpeechEvent.SPEECH_LOAD_ERROR,speechLoadError);
				tempSpeech.removeEventListener(SpeechEvent.SPEECH_ERROR,speechError);
				tempSpeech.removeEventListener(SpeechEvent.SPEECH_STARTED,speechStarted);
				tempSpeech.removeEventListener(SpeechEvent.SPEECH_ENDED,speechEnded);				
				tempSpeech.removeEventListener(SpeechEvent.SPEECH_NEW_WORD,speechNewWord)
			}
		}
	}
}