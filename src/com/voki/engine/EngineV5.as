/*
Author: Jonathan Achai
Date: 1/15/2008

Description:
AS3 version of 2.5D characters (based upon conversion of EngineV3)

Legend:
!!! atention
??? open question
--- removed

To Do:
1. Types can be optimized using int and uint instead of Number

* Engine loads the model *

loadModel(mcRef:DisplayObjectContainer,url:String)
(if root.parameters has oh=url then call loadModel (null,oh))

only PLAYER API
custom events

replace numbers with int and uint where applicable

*/

package com.voki.engine
{
	import com.adobe.crypto.MD5;
	import com.oddcast.event.EngineEvent;
	import com.oddcast.host.morph.lipsync.TimedInstantVisemes;
	import com.oddcast.host.morph.lipsync.TimedVisemes;
	import com.oddcast.host.morph.mouth.PhonemeOddcast17;
	import com.oddcast.net.LC_Simple;
	import com.oddcast.utils.MemoryTracer;
	import com.oddcast.vhost.ConfigString;
	import com.oddcast.vhost.OHUrlParser;
	import com.oddcast.vhost.VHostConfigController;
	import com.oddcast.vhost.engine.IEngineAPI;
	import com.voki.engine.Engine5Sound;
	import com.voki.engine.events.ModelBuilderEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	public dynamic class EngineV5 extends MovieClip implements com.oddcast.vhost.engine.IEngineAPI
	{
		private var vCtrl:VHostConfigController;//VHostConfigEngineController;
		private var _bIsFrozen:Boolean = false;
		private var _timerAnimation:Timer;
		private var _nAnimationFPS:Number;
		private var _nAudioFPS:Number;
		
		private var vCtrlMap:Array;
		//handle local connection
		private var lc:LC_Simple;		
		private var _bUsingLC:Boolean;
		private var _mouseController:MouseController;
		private var _arrAppDomains:Array;
		private var _arrModelOrigPosition:Array;
		private var _sCurrentModelUrl:String;
		private var _sOHParamUrl:String;
		
		private var _loaderModel:Loader;
		
		
		//interface.as vars
		private var _nLast_posx:Number;
		private var _nLast_posy:Number;
		private var _nNewTarget:Number;
		private var _nLook_x:Number;
		private var _nLook_y:Number;		
		//main.as vars
		private var _mcPropfront:MovieClip,_mcPropback:MovieClip, _mcNeck:MovieClip;
		private var _mcBackhair:MovieClip, _mcHairback:MovieClip, _mcBackhairhalves:MovieClip, _mcBackhairl:MovieClip, _mcBackhairr:MovieClip;
		private var _b_moving_to_mouse:Boolean, _bIsGazing:Boolean;
		private var _nXBound:Number, _nYBound:Number;
		private var _nCrack:Number, _nSpeed:Number, _nBreathspeed:Number, _nBreathSign:Number;
		private var _nEyes_scale:Number, _nNose_scale:Number, _nMouth_scale:Number;
		private var _nDiff:Number, _nFaceLX:Number, _nFaceRX:Number, _nFaceLY:Number, _nFaceRY:Number, _nHeadY:Number;
		private var _nInit_maxX:Number, _nMinX:Number, _nMaxY:Number, _nMaxX:Number, _nMinY:Number;
		private var _nEyeLX:Number, _nEyeRX:Number, _nEyebLX:Number, _nEyeLY:Number, _nEyeRY:Number, _nEyebLY:Number, _nEyeX:Number, _nEyeY:Number, _nEyeTX:Number, _nEyeTY:Number;
		private var _nEyeCenterX:Number;
		private var _nBrowLX:Number, _nBrowRX:Number, _nNoseX:Number, _nNoseY:Number, _nMouthX:Number, _nBrowLY:Number, _nBrowRY:Number, _nMouthY:Number;
		private var _nHairRX:Number, _nHairLX:Number, _nHairLY:Number, _nHairRY:Number, _nHairBX:Number, _nNeckH:Number;		
		private var _bMouseMode:Boolean;
		private var _nPupil_Scale:Number;
		private var _mcJawMoverr:MovieClip, _mcJawMoverl:MovieClip;
		private var _oConfigObj:Object;
		private var _nDdx:Number, _nDdy:Number;				
		private var _nLookDur:Number ,_nLookRad:Number, _uintLookDeg:uint,_nLookEnd:Number;
		private var _nGaze_speed:Number;
		private var _bStopRandom:Boolean = false;
		//private var _bIsRecenter:Boolean;
		//private var _bResting:Boolean;
		private var _nBreath:Number = 0;
		//private var _nNeckzoom:Number;
		private var _uintBreathCount:uint = 0;
		//anim.as vars
		private var _nTbrowframe:Number = 5, _nBrowframe:Number = 5;
		private var _bDoThrust:Boolean;
		private var _nMousex:Number ,_nMousey:Number;
		private var _nTx:Number = 0, _nTy:Number = 0, _nTtx:Number = 0, _nBx:Number = 0;
		private var _nTilt:Number;
		private var _nYb:Number = 0, _nY:Number, _nYmult:Number, _nYl:Number, _nYz:Number;
		private var _nXmult:Number, _nX:Number, _nXz:Number, _nXr:Number, _nXl:Number;
		private var _nSr:Number, _nSl:Number;
		private var _nScalecompensation:Number;
		private var _nEb:Number, _nMoveheady:Number;
		private var _nJj:Number, _nJjJaw:Number;
		private var _nEyeheight:Number, _nEyeYY:Number, _nEyeXl:Number, _nEyeXr:Number;
		private var _nLastthrust:Number = 0;
		//eyes.as vars
		private var _nCt:Number, _nTt:Number, _nBr:Number, _nDif:Number;
		private var _bInBlink:Boolean = false;
		private var _nEyeCounter:Number = 0;
		private var _idle_count:int = 0;
		
		//engineLoader.as vars
		private var _nLoadCount:Number;
		//other flags
		private var _bIsAutoPhotoModel:Boolean;
		private var _nDoAnimationCalled:Number = 0;
		private var _bRestrictHeadShaking:Boolean;
		
		private var _bTalkingFlag:Boolean = false;
		//private var _nMoveDelta:Number;		
		
		//engine movieclip elements	
		private var sound_engine:Engine5Sound;				
		private var _mcHost:MovieClip;
		private var _mcModel:MovieClip;	
		private var _mcMouth:MovieClip;
		
		public var breathe:Function;	
		public var breathSaver:Function;
		
		//instant lip sync
		private var _lastPhoneme:String;
		private var _updatingMouth:Boolean = false;
		private var _instantMouthTimer:Timer;
		
		private var _block_eye_blink:Boolean = false;
		
		
		public function setMouthPath(mc:MovieClip):void
		{
			_mcMouth = mc;
			_mcModel.mouthMC = _mcMouth;
		};	    
		
		
		private var _modelBuilder:ModelBuilder;
		private var _sOHUrl:String;		
		private var _apiModel:*;		
		private var _docModel:DisplayObjectContainer;
		private var _sOHCS:String;
		
		//private var _model:Model;
		
		public function EngineV5()
		{
			// output -o "V:\char.oddcast.com\engines\engineV5.03.27.09.swf"
			// output dev -o "V:\char.oddcast.com\engines\engineV5.03.27.09_DEV.swf"	
			// output -o "C:\video_package\vhss_media_2d\engine_expV5.03.27.09.swf"	
			//trace("ENGINE V5 -- ", EngineV5Constants.VERSION_INFO);
			//HaxePhonemes.init(this);
			//_sOHParamUrl = this.loaderInfo.parameters.oh;			
			_sOHParamUrl = 'http://content.oddcast.com/char/oh/616/51408/6000/6019/0/0/801/302/0/0/0/ohv2.swf';//?cs=320a0a4:840907:c42e6a6:681c124:0:101:101:101:101:101:1:10:0:0';
			//http://content.oddcast.com/char/engines/engineV5.03.27.09.swf?oh=http://content.oddcast.com/char/oh/616/51408/6002/6019/0/0/801/302/0/0/0/ohv2.swf?cs=320a0a4:840907:c42e6a6:681c124:0:101:101:101:101:101:1:10:0:0
			_sOHParamUrl = 'assets/ohv2.swf';

			////trace("EngineV5 -::- EngineV5 "+EngineV5Constants.VERSION_INFO+", ver="+EngineV5Constants.VERSION);			
			_arrAppDomains = new Array();
			_arrModelOrigPosition = new Array();						
			vCtrlMap = new Array();
			vCtrlMap["hyscale"] = "height";
			vCtrlMap["hxscale"] = "width";
			vCtrlMap["mscale"] = "mouth";
			vCtrlMap["nscale"] = "nose";
			vCtrlMap["bscale"] = "body";							
			breathe = _breathe;
			tracer = new TextField();
			//addChild(tracer);
			tracer.width = 500;//stage.stageWidth;
			tracer.height = 800;//stage.stageHeight;
			tracer.textColor = 0xff0000;
			
			log('starting up');
//			this.loaderInfo.addEventListener(Event.COMPLETE,start);		
//			this.loaderInfo.addEventListener(Event.UNLOAD,onEngineUnload);
//			this.loaderInfo.addEventListener(Event.REMOVED_FROM_STAGE,onEngineUnload);
			sound_engine = new Engine5Sound();
			sound_engine.addEventListener(EngineEvent.AUDIO_DOWNLOAD_START,speechDownloadStarted);
			sound_engine.addEventListener(EngineEvent.AUDIO_ENDED,audioDone);
			sound_engine.addEventListener(EngineEvent.AUDIO_STARTED,audioStarted);
			sound_engine.addEventListener(EngineEvent.WORD_ENDED,wordEnded);
			sound_engine.addEventListener(EngineEvent.AUDIO_ERROR,audioError);			
			sound_engine.addEventListener(EngineEvent.NEW_MOUTH_FRAME,OnSpeechEvent);
			sound_engine.addEventListener(EngineEvent.SMILE, smile);
			sound_engine.addEventListener(EngineEvent.TALK_ENDED,doneTalking);
			sound_engine.addEventListener(EngineEvent.TALK_STARTED,talkStarted);						
			try
			{
				Security.allowDomain("*");
			}catch($e:*){
			 
			}
			
			start(new Event('start'));
		}
				
		public function log(message:String):void
		{
			tracer.htmlText += '\r '+message;
		}
		private var tracer:TextField;
		
		protected function validate():Boolean
		{
			return true; //  remove for export and comment next line!!!!
			return(this.loaderInfo.url.indexOf("oddcast.com") != -1);
		}
		
		private function start(evt:Event):void
		{	
			if (validate())
			{
				////trace("ENGINE VALIDATE");
				_nAnimationFPS = EngineV5Constants.DEFAULT_FPS;
				_nAudioFPS = EngineV5Constants.AUDIO_FPS;
				_mouseController = new MouseController(this);
				
				_timerAnimation = new Timer(Math.round(1000/_nAnimationFPS));
				
				
				//if lc_name is passed to the engine then initialize local connection with outside (is it needed???)
				var lcName:String = null;//this.loaderInfo.parameters.lc_name;						
				if (lcName)
				{				
					lc = new LC_Simple(lcName,"*");
					lc.addListener(this);
					_bUsingLC = true;
				}
				
				sound_engine.setEngine(this);				
				//loadModel("AS3Host.swf"); //remove for release !!!
				//loadModel("AS3Host_Dana.swf");
				////trace("EngineV5::start _sOHParamUrl="+_sOHParamUrl)
				if (_sOHParamUrl!=null)
				{
					loadModel(_sOHParamUrl);
				}
			}
			else
			{
//				init = null;
//				loadModel = null;
//				sound_engine = null;
			}
		}
		
		private function init():void
		{
			
			////trace("_apiModel.getConfig()="+unescape(_apiModel.getConfig()));
			////trace("EngineV5::init() _sOHCS="+_sOHCS+", "+(_sOHCS is String));
			if (_sOHCS is String)
			{
				if (_sOHCS.length>0)
				{
					////trace("EngineV5::init() Config from cs="+_sOHCS);
					ConfigHost(ConfigString.createConfigObj(_sOHCS));
				}
			}
			else if (_apiModel.getConfig().length>0)
			{
				
				var tempConfStr:String = unescape(_apiModel.getConfig());
				////trace("EngineV5::init() *** Config from conf_str="+tempConfStr);
				configFromString(tempConfStr);
			}
			else 
			{
				////trace("EngineV5::init() Config new Object");
				ConfigHost(new Object());
			}		
			initAnimationNumbers();
		}
		
		//Player API
		//******************************************************
		
		/**
		 * Sets the volume of the host during speech for all current audios and all audios to be played in the future.
		 */
		public function setHostVolume(v:Number):void
		{
			sound_engine.setVolume(v);
		}
		
		//loadModel - loads the as3 model swf inside doc or itself (engine is a movieclip)
		public function loadModel(url:String,doc:DisplayObjectContainer = null):void
		{
			log('loading model');
			////trace("EngineV5::loadModel "+url);
			_sCurrentModelUrl = MD5.hash(url);
			_sOHUrl = url;			
			////trace("_arrAppDomains["+_sCurrentModelUrl+"]= new ApplicationDomain currentDomain="+ApplicationDomain.currentDomain);
			_arrAppDomains[_sCurrentModelUrl] = ApplicationDomain.currentDomain;
			_arrModelOrigPosition[_sCurrentModelUrl] = new Object();
			_docModel = doc;
			_loaderModel = new Loader();
			_loaderModel.contentLoaderInfo.parentSandboxBridge = this;
			var swfUrl:String = url;
			var req:URLRequest = new URLRequest(swfUrl);			
			var ldrContext:LoaderContext = new LoaderContext(false, _arrAppDomains[_sCurrentModelUrl], null);
			_loaderModel.contentLoaderInfo.addEventListener(Event.COMPLETE, modelLoaded);
			_loaderModel.load(req, ldrContext);			
		}
		//returns the percentage loaded of the model as a Number between 0 and 1
		public function modelPercentLoaded():Number {
			if (_loaderModel == null) return(1);
			else return(_loaderModel.contentLoaderInfo.bytesLoaded / _loaderModel.contentLoaderInfo.bytesTotal);
		}
		//freeze - pauses animation and sound
		public function freeze(eyesOpen:Boolean = false):void
		{
			_bIsFrozen = true;			
			sound_engine.freeze();
			animationInterval("stop");		
			_mouseController.stopMouseFollow();
			if (eyesOpen)
			{
				eyeBlink(true); //open eyes
			}
			var t_hair_ar:Array	= _modelBuilder.getHairAnimations();
			for each (var o:Object in t_hair_ar)
			{
				controlHairParts(MovieClip(o), false, true);
			}		
		}
		//resume - resumes animation and sound (when paused)
		public function resume():void
		{
			_bIsFrozen = false;
			////trace("EngineV3::resume "+sound_engine.resume);
			sound_engine.resume();
			animationInterval("start");	
			_mouseController.startMouseFollow();
			var t_hair_ar:Array	= _modelBuilder.getHairAnimations();
			for each (var o:Object in t_hair_ar)
			{
				//MovieClip(o).play();
				controlHairParts(MovieClip(o), true, true);
			}		
		}
		
		private function controlHairParts($do:DisplayObjectContainer, $play:Boolean, $skip:Boolean = false):void
		{
			////trace("CONTROL HAIR PARTS -- ");
			if (!$skip && $do is MovieClip && MovieClip($do).totalFrames > 1)
			{
				($play) ? MovieClip($do).play() : MovieClip($do).stop();
			}
			for (var i:int = 0; i < $do.numChildren; ++i)
			{
				if ($do.getChildAt(i) is DisplayObjectContainer) controlHairParts($do.getChildAt(i) as DisplayObjectContainer, $play);
			}
			
		}
		
		
		//setColor - sets color of colorable elements
		public function setColor(s:String,n:uint):void
		{			
			vCtrl.setHexColor(s,n);
		}
		//stopSpeech - stops audio playback
		public function stopSpeech():void
		{
			sound_engine.stopSound();
			//this.sound_engine.stopSound();
		}
		//say - plays an audio
		public function say(url:String, sec:Number=0):void
		{		
			////trace("EngineV3::_setMouthPath accMouth.totalframes="+host.mouth.acc_mouth._totalframes+", aa there?"+(host.mouth.acc_mouth.aa)+", lipsMC there? "+(host.mouth.acc_mouth.lips));				
			if (url.length>0)
			{		
				//sound_engine.singleSound(tt,_tin,emoArr);
				sound_engine.say(url,sec);
				_b_moving_to_mouse = false;				
			}
		}
		//saySilent - move lips randomly
		public function saySilent(sec:Number):void
		{
			//sound_engine.startBlabbing(t);
			sound_engine.saySilent(sec);
			sound_engine.addEventListener(EngineEvent.SAY_SILENT_ENDED, e_silentDone); 
			if (_mcMouth is MovieClip && _mcMouth.anim_mouth is MovieClip) _mcMouth.anim_mouth.gotoAndStop(1);
			if (_mcMouth is MovieClip && _mcMouth.anim_talking_mouth is MovieClip) _mcMouth.anim_talking_mouth.play();
			_b_moving_to_mouse = false;
		}
		
		public function sayNoAutoStart(url:String, start:Number):void
		{
			sound_engine.sayNoAutoStart(url, start);
		}
		
		//saySilent finished
		private function e_silentDone($e:EngineEvent):void
		{
			sound_engine.removeEventListener(EngineEvent.SAY_SILENT_ENDED, e_silentDone);
			if (_mcMouth is MovieClip && _mcMouth.anim_mouth is MovieClip) _mcMouth.anim_mouth.play();
			if (_mcMouth is MovieClip && _mcMouth.anim_talking_mouth is MovieClip) _mcMouth.anim_talking_mouth.gotoAndStop(1);
		}
		
		//followCursor - turns mouse follow on/off
		public function followCursor(b:Boolean):void
		{
			////trace("EngineV5::FollowCursor "+b+", _bIsGazing: "+_bIsGazing)
			setMouseMode(b);
			if (!_bIsGazing)
			{
				recenter();
			}
		}
		//setGaze - makes the model look in a certian direction
		public function setGaze(angle:uint,sec:Number,rad:Number,pageOrigin:Boolean=false):void
		{			
			if (pageOrigin && (isGazing() || !isFollowingCursor()))
			{
				return;
			}
			////trace("EngineV3::setGaze orig values="+_deg+","+_dur+","+_rad);
			_uintLookDeg = angle;
			_nLookDur = sec;
			_nLookRad = rad;									
			gazeHere();
		}		
		//setLookSpeed - changes gazing speed
		public function setLookSpeed(speedIndex:uint):void		
		{
			switch(speedIndex){
				case 0:
					_nGaze_speed = 8;
					break;
				case 1:
					_nGaze_speed = 4;
					break;
				case 2:
					_nGaze_speed = 2;
					break;
				default:
					_nGaze_speed = 8;
			}
		}
		//randomMovement - sets random movement state
		public function randomMovement(b:Boolean):void		
		{
			////trace("ENGINE V5 - randommovement  ___ boolean: "+b);
			if(!b){
				_bStopRandom = true;								
				breathSaver = breathe;
				breathe = null;				
			}else{
				if (_bStopRandom)
				{
					_bStopRandom = false;
				}
				if (breathe==null)
				{
					breathe = breathSaver;
				}				
			}
		}
		//recenter - move model back to base position
		public function recenter():void
		{
			////trace("EngineV5::recenter set _b_moving_to_mouse to false -- "+sound_engine.isBusy());
			_b_moving_to_mouse = false;
			//if (!sound_engine.isBusy())//false /*!sound_engine.busy*/)
			//{
			_nDdx = _nDdy = 0;				
			//}
			//_bIsRecenter = false;			
			//moveToTarget();
		}
		//setFPS - sets the speed of animation interval
		public function setFPS(fps:Number,isEvent:Boolean):void
		{
			var ratio:Number = _nAnimationFPS/_nAudioFPS;
			_nAudioFPS = fps;
			_nAnimationFPS = _nAudioFPS*ratio;				
			animationInterval("stop");
			animationInterval("start");			
		}				
		
		//setMouthFrame - move mouth to specified frame
		public function setMouthFrame(frame:uint):void
		{
			////trace("EngineV5 :: setMouthFrame "+frame+", _mcMouth="+_mcMouth.name+", _mcMouth.parnet="+_mcMouth.parent.name);
			//eyeBlink(true);
			//eyeBlink = function(b:Boolean):void{//trace("CALLED NEW EYE BLINK");}
			if (frame == 0) frame = 1;
			
			if (frame<EngineV5Constants.MOUTH_FRAMES)
			{				
				
				_mcMouth.lips.gotoAndStop(frame);
				if (_mcMouth.tt is MovieClip)
				{
					_mcMouth.tt.gotoAndStop(frame);
				}
				if (_mcHost.facer is MovieClip && MovieClip(_mcHost.facer).totalFrames > 1)
				{
					MovieClip(_mcHost.facer).gotoAndStop(frame);
				}
				if (_mcHost.facel is MovieClip && MovieClip(_mcHost.facel).totalFrames > 1)
				{
					MovieClip(_mcHost.facel).gotoAndStop(frame);
				}
			}
			//sound_engine.MouthAndJawGotoAndStop(in_num);			
		}
		
		public function getModelAnimations():Array
		{
			return _modelBuilder.getModelAnimations();
		}
		
		public function setPhoneme($phoneme:String):void
		{
			////trace("ENGINE V5 :: SET PHONEME :: phoneme: =" + $phoneme);
			if (!_updatingMouth && _lastPhoneme != $phoneme)
			{
				_lastPhoneme = $phoneme;
				if (_instantMouthTimer == null)
				{
					_instantMouthTimer = new Timer(1, 1);
					_instantMouthTimer.addEventListener(TimerEvent.TIMER, onUpdateMouthFrame);
				}
				_instantMouthTimer.start();
			}
		}
		
		private function onUpdateMouthFrame(event:TimerEvent):void
		{
			var phonemes:PhonemeOddcast17 = new PhonemeOddcast17("Oddcast17");
			phonemes.load(null);
			var visemes:TimedInstantVisemes = new TimedInstantVisemes();
			visemes.addToSyncData(_lastPhoneme, TimedVisemes.MIN_ENERGY_LEVEL, TimedVisemes.MAX_ENERGY_LEVEL, TimedVisemes.POWER_LEVEL);
			var f:int = phonemes.getMouthFrame(null, visemes.findCurrentTarget(0, null));
			////trace("ENGINE V5 :::: onUpdateMouthFrame : : Frame: " + f+ "  phoneme: " + _lastPhoneme);// +"  rt_mouthInterval: " + rt_mouthInterval);
			setMouthFrame(f);
			event.updateAfterEvent();
		}
		
		public function configFromCS(cs:String):void
		{
			ConfigHost(ConfigString.createConfigObj(cs));
		}
		
		public function setActiveModel(model:MovieClip):Boolean
		{			
			if (model.host is MovieClip)
			{
				_mcModel = model;		
				_bIsAutoPhotoModel = _mcModel.isAutoPhoto;
				_sCurrentModelUrl = _mcModel.urlId;				
				_mcHost = _mcModel.host;				
				_mcMouth = _mcModel.mouthMC;
				doMain(true);
				doAnimation();
				vCtrl = _mcModel.controller;
				////trace("switch "+vCtrl.getId());
				//vCtrl = _mcModel.controller;
				//vCtrl.init(_mcModel);
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function getCurrentAudioProgress():Number
		{
			return sound_engine.getCurrentSpeechProgress();
		}
		//Editor API
		//******************************************************
		
		public function getOHUrl(incompatTypeArr:Array=null):String
		{
			var tmpObj:Object = vCtrl.getOHObj();
			
			var oh:String = OHUrlParser.getFilteredOHString( vCtrl.getOHObj(),incompatTypeArr);
			return 'oh/'+oh+"ohv2.swf?cs="+getConfigString();			
		}
		
		//getConfigString - returns the configstring in oh format with colons
		public function getConfigString():String
		{			
			var configMapArr:Array = ConfigString.getMap();
			var l:Number = configMapArr.length;
			var s:String = "";
			
			for(var i:Number=0;i<l;++i)
			{
				var val:String
				////trace("EngineV5::getConfigString - " + configMapArr[i].type);
				if (configMapArr[i].type=="color")
				{					
					
					var transObj:Object = vCtrl.getColor(configMapArr[i].name);		
					if (transObj==null) val = "";
					else val = ConfigString.createHex(transObj.rb, transObj.gb, transObj.bb).toString(16);										
				}
				else if (configMapArr[i].name.indexOf("scale")>=0)
				{
					val = vCtrl.getScale(vCtrlMap[configMapArr[i].name]).toString();								
				}
				else if (configMapArr[i].name=="age")
				{				
					val = vCtrl.getAgeFrame().toString();
				}
				else //only alpha's left
				{			
					var alphaArr:Array = vCtrl.getAlphaSections();
					val = (alphaArr[configMapArr[i].name]*100).toString();
				}				
				s+=val+":";
				
			}
			var retStr:String = validateConfigString(s);
			return retStr;		
		}		
		
		//Engine public methods
		//******************************************************
		
		//this method enables the engine to receive mouse events from a different object (e.g. transparent button over the model)
		public function setMouseStage(iObj:InteractiveObject):void
		{
			_mouseController.setMouseStage(iObj);
		}
		
		//enableMemoryProfiler - displays memory usage of flash player (inlcuding the application which loaded)								
		public function enableMemoryProfiler(mc:DisplayObjectContainer):void
		{
			var mt:MemoryTracer = new MemoryTracer(2000,true,mc);
		}
		
		//getFPS - returns fps of the engine
		public function getFPS():Number
		{
			return _nAnimationFPS;
		}
		
		public function getAudioFPS():Number
		{
			return _nAudioFPS;
		}
		
		//setMouseFollow - called from MouseController ???
		public function setMouseFollow(b:Boolean):void
		{
			////trace("EngineV5::setMouseFollow b: "+b+", _bTalkingFlag: "+_bTalkingFlag);
			if (b && _bTalkingFlag)  //sound_engine.isBusy())//false/* sound_engine.busy*/)
			{
				return;
			}
			_b_moving_to_mouse = b;
			//if (!_b_moving_to_mouse) _bIsRecenter = true;
		}
		
		//isFollowingCursor - reutrns the mouse follow state
		public function isFollowingCursor():Boolean		
		{
			return _bMouseMode;
		}
		//setFaceMoveRange - ???
		public function setFaceMoveRange(range:Number):void
		{
			this["YNoseScaleFactor"] = range;
		}
		
		//isGazing - returns the gazing status
		public function isGazing():Boolean
		{
			return _bIsGazing;
		}
		//lookCount - checks if gazing state should end
		public function lookCount():void //used to be getLookCount 
		{
			if (_bTalkingFlag)//sound_engine.isBusy())//false/*sound_engine.busy*/)
			{
				_bIsGazing = false;
			}
			else if (_bIsGazing && _nLookEnd<getTimer())
			{				
				//if (!_bMouseMode)
				//{
				recenter();
				//}
				_bIsGazing = false;
			}
		}
		//getModelMousePosition - returns the mouse position
		public function getModelMousePosition():Point
		{
			var p:Point = new Point
			p.x = _mcModel.mouseX;
			p.y = _mcModel.mouseY;
			return p;
		}
		//getModel - returns a reference to the model movieclip
		public function getModel():MovieClip
		{
			return _mcModel;
		}
		
		//smile - move to mouth's smiling frame
		public function smile(evt:EngineEvent):void
		{
			////trace("EngineV5::smile "+evt.data);
			if (!evt.data)
			{
				unsmile();
			}
			else
			{
				//setMouthFrame(12);
			}
			//sound_engine.MouthAndJawGotoAndStop(12);
			
			//_mcHost.mouth.gotoAndStop(12);
			//host.mouth.gotoAndStop(12);
			////trace("EngineV3::_smile");
		}
		//unsmile - move to mouth's base frame
		public function unsmile():void
		{
			//setMouthFrame(1);
			//sound_engine.MouthAndJawGotoAndStop(1);
			
			//_mcHost.mouth.gotoAndStop(1);
			////trace("EngineV3::_unsmile");
		}
		
		public function getMouthVersion():Number
		{
			return _mcMouth.version;
			//return _modelBuilder.getMouthVersion();
		}
		
		public function getMaxAgeFrames():uint
		{
			return EngineV5Constants.AGE_FRAMES
		}
		
		public function getConfigController():VHostConfigController
		{
			return vCtrl;
		}
		
		public function getModelVar($param:String):String
		{
			return _modelBuilder.getModelVar($param);
		}
		
		//Event Handlers
		//******************************************************
		//onEngineUnload - triggered when engine is removed/unloaded. stops the timer (is it needed??? legacy of AS2)		
		private function onEngineUnload(evt:Event):void
		{
			_timerAnimation.stop();						
		}
		public function get model():* {
			return _docModel;
		}
		//modelLoaded - triggered when model is loaded. calls _modelBuilder which puts all the model library items together
		private function modelLoaded(evt:Event):void
		{			
			log('modelLoaded');
			////trace("EngineV5 -:-:- modelLoaded :: hasDefinition Boot_ebc5c5: " + _loaderModel.contentLoaderInfo.applicationDomain.hasDefinition("Boot_ebc5c5"));
			/* if (_loaderModel.contentLoaderInfo.applicationDomain.hasDefinition("Boot_ebc5c5"))
			{
			var t_host_class:Class = _loaderModel.contentLoaderInfo.applicationDomain.getDefinition("Boot_ebc5c5");
			var t_proto:* = t_host_class.prototype;
			t_proto.destroy = function():*
			{
			//trace("ENGINE -- Destroy from Boot_ebc5c5 prototype :: class name:: " + getQualifiedClassName(this));
			var aproto : * = Array.prototype;
			Math["isFinite"] = null;
			Math["isNaN"] = null;
			aproto.copy = null;
			aproto.insert = null;
			aproto.remove = null;
			aproto.iterator = null;
			//var boot:Class = getQualifiedClassName(this) as Class;
			////trace("ENGINE -- boot class:: "+boot);
			//boot.prototype = null;
			//Xml.unload();
			}
			} */
			
			_loaderModel.contentLoaderInfo.removeEventListener(Event.COMPLETE, modelLoaded);
			_loaderModel.addEventListener(Event.ADDED, function(e:Event):void{
				//trace("added in blah");//trace(e);
			});
			//_sOHCS = LoaderInfo(evt.target.loader.contentLoaderInfo).parameters.cs; //configuration string from cs query parameter						
			
			//VOKITODO  this will need to be passed in some how
			_sOHCS = '320a0a4:840907:c42e6a6:681c124:0:101:101:101:101:101:1:10:0:0';//_loaderModel.contentLoaderInfo.parameters.cs; //configuration string from cs query parameter						
			
				
			//_sOHCS = "1a68b07:2876ac7:143a3a6:c546a7:0:101:101:88:101:88:1:65.625:0";
			//get the model API (defined in haXe class)								
			
			//log("_arrAppDomains["+_sCurrentModelUrl+"] parentDomain="+_arrAppDomains[_sCurrentModelUrl]);
			var apiClass:Class = _arrAppDomains[_sCurrentModelUrl].getDefinition("API") as Class;			
			//log('modelLoaded: preApiClass');
			//var apiClass:Class = _loaderModel.contentLoaderInfo.applicationDomain.getDefinition("API") as Class;	
			//log('modelLoaded: apiClass: '+apiClass);
			_apiModel = new apiClass();								
			_modelBuilder = new ModelBuilder(_apiModel,_loaderModel.contentLoaderInfo.applicationDomain);//_arrAppDomains[_sCurrentModelUrl]);						
			_modelBuilder.addEventListener(ModelBuilderEvent.MODEL_READY,modelReady);
			_modelBuilder.addEventListener(ModelBuilderEvent.MODEL_ERROR,modelLoadError);
			
			var modelClass:Class = _arrAppDomains[_sCurrentModelUrl].getDefinition("Model") as Class;	
			//var modelClass:Class = _loaderModel.contentLoaderInfo.applicationDomain.getDefinition("Model") as Class;	
			//_docModel = _loaderModel.content as MovieClip;
			_docModel = _docModel==null?this:_docModel; 						
			
			var firstModelInEngine:Boolean = _mcModel == null						
			_mcModel = _modelBuilder.build(_docModel, new modelClass());	
			if (firstModelInEngine)
			{
				try
				{
					
					////trace("ENGINE v5 --  ACCESS THE STAGE "+_mcModel.stage);
					/*
					var i:*;
					for (i in _mcModel.stage)
					{
					//trace("\tENGINE v5 stage "+i);
					}
					//trace("ENGINE v5 ");
					for (i in _mcModel)
					{
					//trace("\tENGINE v5 model "+i);
					}
					//trace("ENGINE v5 ");
					for (i in _mcModel.parent)
					{
					//trace("\tENGINE v5 parent "+i);
					}
					//trace("ENGINE v5 ");
					for each(i in _mcModel.parent.parent)
					{
					//trace("\tENGINE v5 parent.parent "+i);
					}
					//trace("ENGINE v5 ");
					*/
					_mouseController.setMouseStage(_mcModel.stage);
				}
				catch($e:Error)
				{
					////trace("ENGINE v5 -- CANNOT ACCESS THE STAGE");
					_mouseController.setMouseStage(_mcModel);
				}
			}
			_mcModel.urlId = _sCurrentModelUrl;
			
		}		
		
		private function modelLoadError(evt:ModelBuilderEvent):void
		{
			dispatchEvent(new EngineEvent(EngineEvent.MODEL_LOAD_ERROR,evt.data));
		}
		
		/*
		private function drillAsset($do:DisplayObject):void
		{
		for each(var inner_do:* in $do)
		{
		if (inner_do is DisplayObject)
		{
		//trace("DRILLING - "+DisplayObject(inner_do).name);
		drillAsset(DisplayObject(inner_do));
		}
		
		}
		}
		*/
		private var _myHost:*;
		//modelReady - triggered by _modelBuilder when model is ready for use by engine
		private function modelReady(evt:ModelBuilderEvent):void
		{
			
			////trace("EngineV5::modelReady");	
			_modelBuilder.removeEventListener(ModelBuilderEvent.MODEL_READY,modelReady);
			_mcHost = _mcModel.host;
			_mcMouth = evt.data.mouth;
			_mcMouth.version = _modelBuilder.getMouthVersion();			
			//is autophoto? only if it has the pupil_Scale model var
			_bIsAutoPhotoModel = _modelBuilder.getModelVar("pupil_Scale")!=undefined || evt.data.autophoto;			
			////trace("EngineV5::modelLoaded _bIssAutoPhotoModel="+_bIsAutoPhotoModel+" pupil_Scale="+_modelBuilder.getModelVar("pupil_Scale"));				
			_mcModel.isAutoPhoto = _bIsAutoPhotoModel;
			_mcModel.mouthMC = _mcMouth;
			
			_mcMouth.gotoAndStop(1);
			_mcHost.gotoAndStop(1);
			_mcHost.eyel.gotoAndStop(1);
			_mcHost.eyer.gotoAndStop(1);
			_mcHost.facel.gotoAndStop(1);
			_mcHost.facer.gotoAndStop(1);
			_mcModel.backhair.gotoAndStop(1);
			_mcModel.body.gotoAndStop(1);
			_mcModel.body.neck.gotoAndStop(1);
			//drillAsset(_mcModel.mouthMC);	
			//since some models weren't created with case senesitivity in mind we need to point also to common movieclip
			//naming errors
			//trace("EngineV5::modelReady _mcHost is MovieClip="+(_mcHost is MovieClip));
			
			//fix for missing parts of the host (to ignore such errors)
			var mcHostInnerMovieclips:Array = new Array("facel","facer","eyel","eyer","browl","browr","nose","hairl","hair_r");
			for each (var inner_mc_name:String in mcHostInnerMovieclips)
			{
				var t_exists:Boolean = false;
				for each(var inner_mc:* in _mcHost)
				{
					var t_name:String = MovieClip(inner_mc).name.toLowerCase();
					////trace(" ------ clip name: "+t_name+"  str: "+inner_mc_name);
					if (t_name == inner_mc_name) 
					{
						t_exists = true;
						break;
					}
					
				}
				//var dObj:DisplayObject = _mcHost.getChildByName(inner_mc_name);
				if (!t_exists)
				{			
					////trace("EngineV5::add missing movieclip "+inner_mc_name);		
					_mcHost[inner_mc_name] = new MovieClip();
					_mcHost[inner_mc_name].notReal = true;
				}
			}
			if (!(_mcModel.backhair is MovieClip))
			{
				_mcModel.backhair = new MovieClip();
				_mcModel.backhair.notReal = true;
			}
			if (!(_mcModel.body is MovieClip))
			{
				_mcModel.body = new MovieClip();
				_mcModel.body.notReal = true;
			}
			if (!(_mcModel.body.neck is MovieClip))
			{
				_mcModel.body.neck = new MovieClip();
				_mcModel.body.neck.notReal = true;
			}
			if (!(_mcHost.eyel is MovieClip)) _mcHost.eyel = _mcHost.eyeL;	
			if (!(_mcHost.eyel is MovieClip)) _mcHost.eyer = _mcHost.eyeR;			
			//initiliaze the configController
			//vCtrl = new VHostConfigEngineController();		
			vCtrl = new VHostConfigController();
			vCtrl.setEngine(this);		
			//need an actual oh url in order to prepopulate this array			
			vCtrl.setInitialAccessories(OHUrlParser.getOHObject(_sOHUrl));
			vCtrl.init(_mcModel);						
			_mcModel.controller = vCtrl;				
			
			doMain();
			//engine is ready => configDone
			////trace("EngineV5::modelReady dispatching "+EngineEvent.CONFIG_DONE);
			dispatchEvent(new EngineEvent(EngineEvent.CONFIG_DONE,_mcModel));
			talk(); //in case there's a voice parameter in the config / url				
		}
		//talkStarted - triggered when speech starts
		private function talkStarted(evt:EngineEvent):void
		{
			_bTalkingFlag = true;
			recenter();
			////trace("EngineV5::dispatch EngineEvent.TALK_STARTED");
			//moveToTarget();
			//onSpeechEvent();
			if (_mcMouth is MovieClip && _mcMouth.anim_mouth is MovieClip) _mcMouth.anim_mouth.gotoAndStop(1);
			if (_mcMouth is MovieClip && _mcMouth.anim_talking_mouth is MovieClip) _mcMouth.anim_talking_mouth.play();
			broadcastUsingLC("talkStarted",this);
			dispatchEvent(evt);						
		}
		//wordEnded - triggered when a silent gap has been detected (usually a word)
		private function wordEnded(evt:EngineEvent):void
		{
			////trace("EngineV5::dispatch EngineEvent.WORD_ENDED");
			broadcastUsingLC("wordEnded");
			dispatchEvent(new EngineEvent(EngineEvent.WORD_ENDED,new Object()));						
		}		
		//doneTalking - triggered when all audios in queue finished playing
		private function doneTalking(evt:EngineEvent):void
		{
			////trace("EngineV5::dispatch EngineEvent.TALK_ENDED");
			if (_mcMouth is MovieClip && _mcMouth.anim_mouth is MovieClip) _mcMouth.anim_mouth.play();
			if (_mcMouth is MovieClip && _mcMouth.anim_talking_mouth is MovieClip) _mcMouth.anim_talking_mouth.gotoAndStop(1);
			broadcastUsingLC("talkEnded");
			dispatchEvent(new EngineEvent(EngineEvent.TALK_ENDED,new Object()));	
			_bTalkingFlag = false;
			recenter();
			//_nMoveDelta = 0.5;						
		}
		//audioDone - triggered when an audio finishes playing
		private function audioDone(evt:EngineEvent):void
		{						
			////trace("EngineV5::dispatch EngineEvent.AUDIO_ENDED");
			broadcastUsingLC("audioDone");
			dispatchEvent(new EngineEvent(EngineEvent.AUDIO_ENDED,new Object()));							
		}		
		//audioStarted - triggered when an audio starts playing
		private function audioStarted(evt:EngineEvent):void
		{	
			//_bDoThrust		
			////trace("EngineV5::dispatch EngineEvent.AUDIO_STARTED");
			broadcastUsingLC("audioStarted");
			dispatchEvent(evt);				
		}
		//speechDownloadStarted - triggered when a download request has been made
		private function speechDownloadStarted(evt:EngineEvent):void
		{		
			broadcastUsingLC("speechDownloadStarted",evt.data);
			dispatchEvent(new EngineEvent(EngineEvent.AUDIO_DOWNLOAD_START,evt.data));			
		}
		//audioError - triggered when an error has been detected with the audio request
		private function audioError(evt:EngineEvent):void
		{
			//var err:Error = evt.data as Error;
			broadcastUsingLC("audioError", evt.data);
			var t_err:EngineEvent = new EngineEvent(EngineEvent.AUDIO_ERROR, evt.data);
			//trace("EngineV5 :: dispatch EngineEvent.AUDIO_ERROR "+t_err.toString());
			dispatchEvent(t_err);
		}
		
		//Engine Utilities
		//******************************************************
		//broadcastUsingLC - sends an event using localConnection
		private function broadcastUsingLC(fname:String,arr:*=null):void
		{
			if (_bUsingLC)
			{				
				if (arr is MovieClip)
				{
					lc.lc_send(fname);
				}
				else
				{
					lc.lc_send(fname,arr);
				}
			}
		}
		//random - simulates old AS2 random function
		private function random(i:Number):int
		{			
			var ret:int = Math.floor(Math.random()*Math.floor(i))	 		
			return ret;
		}
		
		private function round(i:Number,decimalplaces:uint):Number
		{
			var multi:uint = Math.pow(10,decimalplaces);
			var ret:Number = Math.round(multi*i)/multi;			
			return ret;
		}
		
		//animationInterval - starts/stops model animations
		private function animationInterval(action:String):void
		{
			switch(action)
			{
				case "start":
					var timerInt:int = Math.floor(1000/_nAnimationFPS);
					_timerAnimation.delay = timerInt;
					_timerAnimation.addEventListener(TimerEvent.TIMER,doAnimationInterval);
					_timerAnimation.start();					
					break;
				case "stop":
					_timerAnimation.stop();				
					break;
			}
		}		
		
		//validateConfigString - makes sure the configString is valid
		private function validateConfigString(s:String):String
		{
			var arr:Array = s.split(":");
			for (var i:String in arr)
			{				
				if (arr[i]=="NaN" || arr[i]=="undefined" || arr[i]=="" || arr[i]==undefined)
				{
					arr[i] = "0";				
				}
			}
			var ret:String = arr.join(":");					
			return ret;
		}
		//talk - if voice is embeded inside model's map play it
		private function talk():void
		{
			if (_modelBuilder.getModelVar("voice") is String)
			{
				var s:String = _modelBuilder.getModelVar("voice");
				if (s.length>0)
				{
					say(s);
				}
			}
		}
		//loadParentParam - sets more properties to the engine
		private function loadParentParam(param:String, defaultValue:*):void
		{										
			//this[param] = isNaN(this[param])?defaultValue:isNaN(parseFloat_modelBuilder.getModelVar(param))?defaultValue:_modelBuilder.getModelVar(param);			
			if (_modelBuilder.getModelVar(param)==null || _modelBuilder.getModelVar(param)==undefined)
			{
				this[param] = defaultValue;
			}
			else
			{
				this[param] = _modelBuilder.getModelVar(param);
			}
			//this[param] = ?defaultValue:_modelBuilder.getModelVar(param);
			
			//this[param] = isNaN(this[param])?defaultValue:
		}
		//checkModelRestrictions - checks model map if any restriction code should be applied
		private function checkModelRestrictions():void
		{
			//allow turning off breathing in the model fla:
			////trace("ENGINE V5 - breathe " + _modelBuilder.getHostVar("breathe")+" doanim: "+_modelBuilder.getHostVar("doAnimation"))
			if (_modelBuilder.getHostVar("breathe") is String)
			{
				if (_modelBuilder.getHostVar("breathe")=="null")
				{
					////trace("EngineV5::checkModelRestrictions host.breathe==null->true")
					breathe = null;
				}
			}
			
			//allow restriction on head movement
			if (_modelBuilder.getHostVar("xBound") is String)
			{
				
				_nXBound = Number(_modelBuilder.getHostVar("xBound"));	
				////trace("EngineV5::checkModelRestrictions host.xBound="+_nXBound);
			}
			
			if (_modelBuilder.getHostVar("yBound") is String)
			{
				
				_nYBound = Number(_modelBuilder.getHostVar("yBound"));	
				////trace("EngineV5::checkModelRestrictions host.yBound="+_nYBound);
			}
			
			//allow restriction on eye movement
			if (_modelBuilder.getHostVar("eyeMaxX") is String)
			{
				
				this["eyeMaxX"] = Number(_modelBuilder.getHostVar("eyeMaxX"));	
				////trace("EngineV5::checkModelRestrictions host.eyeMaxX="+this["eyeMaxX"]);
			}
			
			if (_modelBuilder.getHostVar("eyeMaxY") is String)
			{
				
				this["eyeMaxY"] = Number(_modelBuilder.getHostVar("eyeMaxY"));	
				////trace("EngineV5::checkModelRestrictions host.eyeMaxY="+this["eyeMaxY"]);
			}
			
			if (_modelBuilder.getHostVar("eyeFactorX") is String)
			{
				
				this["eyeFactorX"] = Number(_modelBuilder.getHostVar("eyeFactorX"));	
				////trace("EngineV5::checkModelRestrictions host.eyeFactorX="+this["eyeFactorX"]);
			}
			
			if (_modelBuilder.getHostVar("eyeFactorY") is String)
			{
				
				this["eyeFactorY"] = Number(_modelBuilder.getHostVar("eyeFactorY"));	
				////trace("EngineV5::checkModelRestrictions host.eyeFactorY="+this["eyeFactorY"]);
			}
			
			//allow no head movement at all
			if (_modelBuilder.getHostVar("animateAtInterval") is String)
			{
				animationInterval("stop");			
				////trace("EngineV5::checkModelRestrictions turn off animations (animateAtInterval)");				
			}
			
			//restrictHeadShaking
			if (_modelBuilder.getHostVar("doAnimation") is String)
			{
				_bRestrictHeadShaking = true;
				////trace("EngineV5::checkModelRestrictions doAnimation func found restrictHeadShaking=true");				
			}									
			
			//restict mouse following
			//restrictHeadShaking
			if (_modelBuilder.getHostVar("disableMouthFollow") is String)
			{
				_bMouseMode = false;
				////trace("EngineV5::checkModelRestrictions disableMouthFollow func found");				
			}			
		}
		//configFromString - config model from old style string "eyesR=0&eyesG=0&eyesB=0"
		private function configFromString(_strin:String):void
		{
			var t_conf:Object = new Object();	
			_strin = unescape(_strin);
			var tmp_ar:Array = _strin.split("&");
			for (var x:int = 0; x<tmp_ar.length; ++x){
				var tmp_ar2:Array = tmp_ar[x].split("=");
				t_conf[tmp_ar2[0]] = tmp_ar2[1];		
			}
			ConfigHost(t_conf);
		}
		//ConfigHost - config model from object
		private function ConfigHost(configObj:Object):void
		{
			////trace("EngineV5::ConfigHost");		
			var configMap:Array = ConfigString.getMap();
			var l:uint = configMap.length;
			for (var i:uint=0;i<l;++i)
			{				
				var cObjName:String = configMap[i].name;
				////trace("EngineV5::ConfigHost "+cObjName);
				if (configMap[i].type=="color")
				{
					if (configObj[cObjName+"R"]!=undefined)
					{
						var to:Object = {rb:configObj[cObjName+"R"],gb:configObj[cObjName+"G"],bb:configObj[cObjName+"B"]};
						ConfigString.addColorValue(cObjName,configObj[cObjName+"R"],configObj[cObjName+"G"],configObj[cObjName+"B"]);					
						trace("EngineV5::ConfigHost "+cObjName+", to={"+to.rb+","+to.gb+","+to.bb+"}");
						vCtrl.setColor(cObjName,to);					
					}
					
				}
				else if (cObjName.indexOf("scale")>=0)
				{
					////trace("EngineV3::ConfigHost "+cObjName+"-->"+configObj[cObjName].length);
					if (configObj[cObjName] != undefined && configObj[cObjName].length != 0)
					{
						vCtrl.setScaleVal(vCtrlMap[cObjName],configObj[cObjName]);					
					}
				}
				else if (cObjName=="age")
				{
					var ageFrame:Number = configObj[cObjName]/EngineV5Constants.AGE_FRAMES;
					////trace("ageFrame="+ageFrame+", isNan? ="+isNaN(ageFrame));
					vCtrl.setAge(isNaN(ageFrame)?0:ageFrame);
				}
				else if (configObj[cObjName]>=0)
				{
					////trace("EngineV5::ConfigHost calling setAlpha on "+cObjName+" origValue="+configObj[cObjName]+", /100="+configObj[cObjName]/100);
					vCtrl.setAlpha(cObjName,configObj[cObjName]/100);
				}
			}
			if (configObj.voice is String)
			{
				if (configObj.voice.length>0)
				{
					recenter();
					say(configObj.voice);
				}
			}
		}
		
		//setMouseMode - turns mouth follow on/off temporarily (for talking)
		private function setMouseMode(_mode:Boolean):void
		{
			////trace("EngineV5::_setMouseMode "+_mode)
			_bMouseMode = _mode;
			setMouseFollow(_mode);
		}
		
		//Animation specific functions
		//******************************************************
		//resumeLook - removed---
		/*
		private function resumeLook():void
		{
		lookAt(_nLast_posx,_nLast_posy);
		}
		*/
		//lookAt - removed---
		/*
		private function lookAt(posx:Number,posy:Number):void
		{
		if (!_nLast_posx || !_nLast_posx)
		{
		return;
		}
		_nLast_posx = posx;
		_nLast_posx = posy;
		var p:Object = 
		{
		x:_mcHost.browl.x,
		y:_mcHost.browr.y
		}
		localToGlobal(p);
		setLookTarget(posx-p.x,posy-p.y);
		_nNewTarget = 1;
		}
		*/
		//look - removed---
		/*
		private function look():void
		{
		setLookTarget(_nLook_x,_nLook_y);
		moveToTarget();
		}
		*/
		
		//initAnimationNumbers - initializing some animation variables
		private function initAnimationNumbers():void
		{
			////trace("EngineV5::initAnimationNumbers")
			_nDdx = _nDdy = _nTy = _nTx = _nTilt = _nTtx = _nY = _nYb = _nYmult = _nXmult = _nBx = _nX = _nXz = _nXr = _nXl = _nSl = _nSr = 
				_nYz = _nYl = _nEb = _nEyeCounter = 0;		
			_nDif = _nAnimationFPS;// - Math.round(_nAnimationFPS/3);
			_nBr = EngineV5Constants.BLINK_RATE * _nAnimationFPS;			
		}
		
		//doMain - initialize animation related variables etc.
		private function doMain(calledFromSetActive:Boolean = false):void
		{
			_mcHost.gotoAndStop(1);
			
			//trace("EngineV5::doMain()");
			_mcPropfront = _mcModel.prop_front;
			_mcPropback = _mcModel.prop_front;
			_mcNeck = _mcModel.body.neck;
			_mcBackhair = _mcModel.backhair;
			_mcHairback = _mcModel.hairback;
			_mcBackhairhalves = _mcModel.backhairhalves;
			if (_mcModel.backhairhalves!=undefined) //not sure what to do about this 1010 error
			{
				_mcBackhairl = _mcModel.backhairhalves.backhairl;
				_mcBackhairr = _mcModel.backhairhalves.backhairr;
			}
			
			_b_moving_to_mouse = false;
			_bIsGazing = false; //used to be 0
			_nXBound = EngineV5Constants.ANIM_X_BOUND;//300;
			_nYBound = EngineV5Constants.ANIM_Y_BOUND;//100;
			_nCrack = EngineV5Constants.ANIM_CRACK;//0.5;
			_nSpeed = EngineV5Constants.ANIM_SPEED;//8;
			_nBreathspeed = EngineV5Constants.ANIM_BREATH_RATIO;//0.5;
			_nBreathSign = EngineV5Constants.ANIM_BREATH_SIGN;//1;						
			_nEyes_scale = EngineV5Constants.ANIM_DEFAULT_SCALE;//100;
			_nNose_scale = EngineV5Constants.ANIM_DEFAULT_SCALE;//100;
			_nMouth_scale = EngineV5Constants.ANIM_DEFAULT_SCALE;//100;
			_nDiff = EngineV5Constants.ANIM_DIFF;//1;
			
			
			
			if (_arrModelOrigPosition[_sCurrentModelUrl]._nFaceLX!=undefined)
			{
				//trace("*********** model "+_sCurrentModelUrl+" original positions applied");
				_mcHost.facel.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nFaceLX;
				_mcHost.facer.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nFaceRX;
				_mcHost.facel.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nFaceLY;
				_mcHost.facer.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nFaceRY;
				_mcHost.y				=_arrModelOrigPosition[_sCurrentModelUrl]._nHeadY;
				
				_mcHost.eyel.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nEyeLX;
				_mcHost.eyer.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nEyeRX;
				if (!_bIsAutoPhotoModel)
				{
					_mcHost.eyel.ball.x		=_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLX;
					_mcHost.eyel.ball.y		=_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLY;	
				}
				else
				{
					_mcHost.eyel.ballMC.x		=_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLX;
					_mcHost.eyel.ballMC.y		=_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLY;
				}
				
				_mcHost.eyel.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nEyeLY;
				_mcHost.eyer.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nEyeRY;
				
				
				_mcHost.browl.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nBrowLX;
				_mcHost.browr.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nBrowRX;
				_mcHost.nose.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nNoseX;
				_mcHost.nose.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nNoseY;
				_mcHost.mouth.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nMouthX;
				_mcHost.browl.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nBrowLY;
				_mcHost.browr.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nBrowRY;
				_mcHost.mouth.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nMouthY;
				_mcHost.hairl.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nHairLX;
				_mcHost.hair_r.x		=_arrModelOrigPosition[_sCurrentModelUrl]._nHairRX;
				_mcHost.hairl.y			=_arrModelOrigPosition[_sCurrentModelUrl]._nHairLY;
				_mcHost.hair_r.y		=_arrModelOrigPosition[_sCurrentModelUrl]._nHairRY;
				_mcBackhair.x			=_arrModelOrigPosition[_sCurrentModelUrl]._nHairBX;
				_mcNeck.scaleY			=_arrModelOrigPosition[_sCurrentModelUrl]._nNeckH;										
			}
			else
			{
				////trace("*********** model "+_sCurrentModelUrl+" original positions saved");
				_arrModelOrigPosition[_sCurrentModelUrl]._nFaceLX	=_mcHost.facel.x;
				_arrModelOrigPosition[_sCurrentModelUrl]._nFaceRX	=_mcHost.facer.x;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nFaceLY	=_mcHost.facel.y;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nFaceRY	=_mcHost.facer.y;
				_arrModelOrigPosition[_sCurrentModelUrl]._nHeadY	=_mcHost.y;	
				
				_arrModelOrigPosition[_sCurrentModelUrl]._nEyeLX	=_mcHost.eyel.x;
				_arrModelOrigPosition[_sCurrentModelUrl]._nEyeRX	=_mcHost.eyer.x;
				if (!_bIsAutoPhotoModel)
				{
					if (_mcHost.eyel.ball == null) _mcHost.eyel.ball = new MovieClip();
					if (_mcHost.eyer.ball == null) _mcHost.eyer.ball = new MovieClip();
					_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLX	=_mcHost.eyel.ball.x;
					_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLY	=_mcHost.eyel.ball.y;
				}
				else
				{
					if (_mcHost.eyel.ballMC == null) _mcHost.eyel.ball = new MovieClip();
					if (_mcHost.eyer.ballMC == null) _mcHost.eye.ball = new MovieClip();
					_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLX	=_mcHost.eyel.ballMC.x;
					_arrModelOrigPosition[_sCurrentModelUrl]._nEyebLY	=_mcHost.eyel.ballMC.y;
				}
				
				_arrModelOrigPosition[_sCurrentModelUrl]._nEyeLY	=_mcHost.eyel.y;
				_arrModelOrigPosition[_sCurrentModelUrl]._nEyeRY	=_mcHost.eyer.y;
				
				
				for(var i:uint=0; i<EngineV5Constants.POSSIBLY_MISSING_MODEL_MCS.length;++i)
				{
					if (!(_mcHost[EngineV5Constants.POSSIBLY_MISSING_MODEL_MCS[i]] is MovieClip))
					{
						////trace("EngineV5::doMain "+EngineV5Constants.POSSIBLY_MISSING_MODEL_MCS[i]+" movieclip is missing");
						_mcHost[EngineV5Constants.POSSIBLY_MISSING_MODEL_MCS[i]] = new MovieClip;
					}
				}
				
				_arrModelOrigPosition[_sCurrentModelUrl]._nBrowLX	=_mcHost.browl.x;
				_arrModelOrigPosition[_sCurrentModelUrl]._nBrowRX	=_mcHost.browr.x;
				_arrModelOrigPosition[_sCurrentModelUrl]._nNoseX	=_mcHost.nose.x;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nNoseY	=_mcHost.nose.y;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nMouthX	=_mcHost.mouth.x;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nBrowLY	=_mcHost.browl.y;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nBrowRY	=_mcHost.browr.y;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nMouthY	=_mcHost.mouth.y;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nHairLX	=_mcHost.hairl.x;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nHairRX	=_mcHost.hair_r.x;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nHairLY	=_mcHost.hairl.y;
				_arrModelOrigPosition[_sCurrentModelUrl]._nHairRY	=_mcHost.hair_r.y;	
				_arrModelOrigPosition[_sCurrentModelUrl]._nHairBX	=_mcBackhair.x;
				_arrModelOrigPosition[_sCurrentModelUrl]._nNeckH	=_mcNeck.scaleY;			
			}   
			
			_nFaceLX = _mcHost.facel.x;
			_nFaceRX = _mcHost.facer.x;
			_nFaceLY = _mcHost.facel.y;
			_nFaceRY = _mcHost.facer.y;
			_nHeadY = _mcHost.y;
			
			_nEyeLX = _mcHost.eyel.x;
			_nEyeRX = _mcHost.eyer.x;
			if (!_bIsAutoPhotoModel)
			{
				_nEyebLX = _mcHost.eyel.ball.x;	
				_nEyebLY = _mcHost.eyel.ball.y;
			}
			else
			{
				_nEyebLX = _mcHost.eyel.ballMC.x;	
				_nEyebLY = _mcHost.eyel.ballMC.y;
			}
			
			_nEyeLY = _mcHost.eyel.y;
			_nEyeRY = _mcHost.eyer.y;
			
			
			_nBrowLX = _mcHost.browl.x;
			_nBrowRX = _mcHost.browr.x;
			_nNoseX = _mcHost.nose.x;
			_nNoseY = _mcHost.nose.y;
			_nMouthX = _mcHost.mouth.x;
			_nBrowLY = _mcHost.browl.y;
			_nBrowRY = _mcHost.browr.y;
			_nMouthY = _mcHost.mouth.y;
			_nHairLX = _mcHost.hairl.x;
			_nHairRX = _mcHost.hair_r.x;
			_nHairLY = _mcHost.hairl.y;
			_nHairRY = _mcHost.hair_r.y;
			_nHairBX = _mcBackhair.x;
			_nNeckH = _mcNeck.scaleY;			
			
			_mcJawMoverr = _mcHost.facer;
			_mcJawMoverl = _mcHost.facel;			
			
			_nInit_maxX = _nMaxX = EngineV5Constants.ANIM_MAX_X;//27;
			_nMinX = EngineV5Constants.ANIM_MIN_X;//20;
			_nMaxY = EngineV5Constants.ANIM_MAX_Y;//6;
			_nMinY = EngineV5Constants.ANIM_MIN_Y;//0;
			
			_nEyeX = 0;
			_nEyeY = 0;
			_nEyeTX = 0;
			_nEyeTY = 0;
			
			_nEyeCenterX = EngineV5Constants.ANIM_EYE_CENTER;//31;			
			//this["EyeScaling"] = 0;	//???			
			
			
			
			_mouseController.startMouseFollow();
			////trace("ENGINE V5 - do main breathe: "+	breathe);		
			if (breathe!=null) breathe();			
			_bMouseMode = true;
			if (!calledFromSetActive)
			{
				init();			
			}			
			
			//autophoto models parameters
			loadParentParam("em", EngineV5Constants.AP_ANIM_EM)
			loadParentParam("EyeMovementRatio",EngineV5Constants.AP_ANIM_EM_RATIO);   //try .60
			loadParentParam("MouthMovementRatio",EngineV5Constants.AP_ANIM_MM_RATIO);  //try .85
			loadParentParam("BrowMovementRatio",EngineV5Constants.AP_ANIM_BM_RATIO);   //try .85
			loadParentParam("WhiteLineCompensation",EngineV5Constants.AP_ANIM_WHITE_LINE_COMPENSATION);  //try to set as near to one without showing white crack line
			loadParentParam("WhiteLinePixelCompensation",EngineV5Constants.AP_ANIM_WHITE_LIVE_PIXEL_COMPENSATION);  //try 0.125 and set above to 1; requires face halfs to be origined on zero.
			loadParentParam("ReciprocalScaling",EngineV5Constants.AP_ANIM_RECIPROCAL_SCALING); //set to true for a  "better" way of scaling the face halfs
			loadParentParam("EyeScaling", EngineV5Constants.AP_ANIM_EYE_SCALING);
			loadParentParam("RestrictTotalTurning", EngineV5Constants.AP_ANIM_RESTRICT_TURNING);
			loadParentParam("XScaleFactor", EngineV5Constants.AP_ANIM_XSCALE_FACTOR);
			loadParentParam("BackHairXDampen", EngineV5Constants.AP_ANIM_BACK_HAIR_X_DAMPEN);
			loadParentParam("BackHairRotationDampen",EngineV5Constants.AP_ANIM_BACK_HAIR_ROTATION_DAMPEN);
			
			loadParentParam("YOverallFactor", EngineV5Constants.AP_ANIM_Y_OVERALL_FACTOR);
			loadParentParam("YHeadMoveFactor", EngineV5Constants.AP_ANIM_Y_HEAD_MOVE_FACTOR);
			loadParentParam("YScaleFactor", EngineV5Constants.AP_ANIM_YSCALE_FACTOR);
			loadParentParam("YFeatureMovementFactor", EngineV5Constants.AP_ANIM_Y_FEATURE_MOVE_FACTOR);
			loadParentParam("YEyeMovementRatio", EngineV5Constants.AP_ANIM_Y_EM_RATIO);
			loadParentParam("YBrowMovementRatio", EngineV5Constants.AP_ANIM_Y_BM_RATIO);
			loadParentParam("YNoseMovementRatio", EngineV5Constants.AP_ANIM_Y_NM_RATIO);
			loadParentParam("YMouthMovementRatio", EngineV5Constants.AP_ANIM_Y_MM_RATIO);
			loadParentParam("YNoseScaleFactor", EngineV5Constants.AP_ANIM_Y_NOSE_SCALE_RATIO);
			loadParentParam("NoseRotationFactor",EngineV5Constants.AP_ANIM_NOSE_ROTATION_FACTOR);
			loadParentParam("YeyeScale", EngineV5Constants.AP_ANIM_Y_EYE_SCALE);
			
			loadParentParam("eyeMaxX",EngineV5Constants.AP_ANIM_EYE_MAX_X);
			loadParentParam("eyeMaxY",EngineV5Constants.AP_ANIM_EYE_MAX_Y);
			loadParentParam("eyeFactorX",EngineV5Constants.AP_ANIM_EYE_X_FACTOR);
			loadParentParam("eyeFactorY",EngineV5Constants.AP_ANIM_EYE_Y_FACTOR);
			loadParentParam("ellipticalEyeMovement", EngineV5Constants.AP_ANIM_EYE_ELLIPTIC_MOVE);
			loadParentParam("eyeGlintMovement", EngineV5Constants.AP_ANIM_EYE_GLINT_MOVE);
			loadParentParam("pupil_Scale", EngineV5Constants.AP_ANIM_EYE_PUPIL_SCALE);			
			_nPupil_Scale= Number(_modelBuilder.getModelVar('pupil_Scale'))/100;//			
			_nPupil_Scale*= EngineV5Constants.AP_ANIM_EYE_PUPIL/EngineV5Constants.AP_ANIM_EYE_PUPIL_SCALE;//;//85/60;
			if (_mcHost.eyer.ballMC is MovieClip)
			{
				if (_mcHost.eyer.ballMC.glintMC is MovieClip)
				{		
					////trace("EngineV5::doMain _nPupil_Scale="+_nPupil_Scale)
					_mcHost.eyel.ballMC.scaleX = _mcHost.eyel.ballMC.scaleY = _mcHost.eyer.ballMC.scaleX = _mcHost.eyer.ballMC.scaleY = _nPupil_Scale;				
					
				}
			}
			
			loadParentParam("glassesFactor",EngineV5Constants.AP_ANIM_GLASSES_FACTOR);
			loadParentParam("l_glassesScale",EngineV5Constants.AP_ANIM_GLASSES_LEFT_SCALE);
			loadParentParam("r_glassesScale",EngineV5Constants.AP_ANIM_GLASSES_RIGHT_SCALE);
			loadParentParam("l_glassesPos",EngineV5Constants.AP_ANIM_GLASSES_LEFT_POS);
			loadParentParam("r_glassesPos",EngineV5Constants.AP_ANIM_GLASSES_RIGHT_POS);
			loadParentParam("yOffsetEyes",EngineV5Constants.AP_ANIM_GLASSES_Y_EYES_OFFSET);			
			
			
			
			//trace("doMain::_mcHost is MovieClip: "+_mcHost is MovieClip);
			if (!_bIsFrozen)
			{				
				animationInterval("start");	
			}
			else
			{
				doAnimation();
				_mouseController.stopMouseFollow();	
			}
			checkModelRestrictions();
			
			
			
		}
		//doAnimationInterval - the heart-beat of model animations
		private function doAnimationInterval(evt:TimerEvent):void
		{
			doAnimation();
			if (!_block_eye_blink)
				eyeBlink();
			//evt.updateAfterEvent();
		}
		
		//gazeHere - gazes to where setGaze defined
		private function gazeHere():void
		{
			////trace("EngineV5::gazeHere Math.floor(_nLookDur)="+Math.floor(_nLookDur)+", _uintLookDeg="+_uintLookDeg);
			if (!_bTalkingFlag && Math.floor(_nLookDur)>0 && _uintLookDeg>=0)
			{
				var radius:Number = (Number(_nLookRad)>100 || isNaN(_nLookRad)) ? _nYBound : Number(_nLookRad);
				if (radius < 0) radius =0;
				
				var radians:Number = ((_uintLookDeg+270)%360)*(Math.PI/180);				
				var _xpos:Number = Math.cos(radians)*(radius*3);
				var _ypos:Number = Math.sin(radians)*radius;
				setLookTarget(_xpos, _ypos);
				_nLookEnd = getTimer()+(_nLookDur*1000);
				_bIsGazing = true;
				//moveToTarget();
				if (!isNaN(_nGaze_speed))
				{
					_nSpeed = _nGaze_speed;
				}				
			}
		}
		//setLookTarget - sets a new look target
		private function setLookTarget(xpos:Number,ypos:Number):void
		{
			_nDdx = Math.max(-_nXBound,Math.min(_nXBound,xpos*2));
			_nDdy = Math.max(-_nYBound,Math.min(_nYBound,ypos*2));			
		}
		
		/*
		private function moveToTarget():void
		{
		//doAnimation();		
		}
		
		
		public function mouseMoved():void
		{
		
		//remove me
		if (_bResting && _b_moving_to_mouse)
		{
		////trace("calling moveToTarget");
		moveToTarget();
		}
		}
		*/
		
		//thrustRandom - look randomly
		private function thrustRandom():void
		{		
			if (_bTalkingFlag)
			{	
				setLookTarget(((random(_nYBound*2) - _nYBound))*EngineV5Constants.HEAD_X_MOVEMENT_DURING_SPEECH_RATIO, ((random(_nYBound*2) - _nYBound))*EngineV5Constants.HEAD_Y_MOVEMENT_DURING_SPEECH_RATIO);
			}
			//moveToTarget();
		}
		
		private function _breathe():void
		{
			////trace("ENGINE V5 ::_breathe "+_nBreath);
			if (_nBreath>5)
			{
				_nBreathSign = (_bTalkingFlag) ? -1 : -0.5;
			}
			else if (_nBreath<0)
			{
				_nBreathSign = (_bTalkingFlag) ? 1 : 0.5;
			}
			
			_nBreath += _nBreathspeed*_nBreathSign;
			//_nNeckzoom = 100 + _nBreath;
			_mcNeck.scaleY = _nNeckH + (_nBreath/100);			
		}
		
		/*
		private function _loopback():void
		{
		if (host._currentframe == 6)
		{
		moveToTarget();
		}
		}
		
		
		private function _setEmotion(emoId:Number):void
		{
		emotion.emote(emoId);
		}
		*/
		
		//doAnimation - make model look 2.5D
		private function doAnimation():void
		{		
			//trace("_mcHost is MovieClip: "+_mcHost is MovieClip);
			_mcHost.gotoAndStop(2);
			////trace("do anim x: "+_nDdx+"  y: "+_nDdy+" _idle_count:: "+_idle_count);
			/* if (_nDdx == 0 && _nDdy == 0)	
			{
			
			if (++_idle_count >= EngineV5Constants.ANIM_CYCLES_UNTIL_RANDOM)
			{
			_bDoThrust = true;
			_idle_count = 0;
			}
			}
			else
			{
			_idle_count = 0;
			} */
			////trace("ENGINE V5 ::doAnimation _thrust: "+_bDoThrust+"  _b_moving_to_mouse: "+_b_moving_to_mouse+", _bIsGazing: "+_bIsGazing+", _bIsFrozen: "+_bIsFrozen +", _bMouseMode: "+_bMouseMode);			
			//breathing moved here:
			if (_uintBreathCount++ > 2)
			{
				_uintBreathCount = 0;
				////trace("ENGINE V5 - doanim breathe: "+	breathe);
				if (breathe != null) breathe();
			}
			if (_bIsGazing)
			{
				lookCount();
			}
			//_bResting = false; 
			////trace("DO ANIM :::: moving_to_mouse: "+_b_moving_to_mouse+" !isgazing: "+(!_bIsGazing)+" !_bisfrozen: "+(!_bIsFrozen));	
			if (_bDoThrust && !_bStopRandom)//&& !_bIsRecenter ) 
			{
				////trace("ENGINE V5 ++++++++ do thrust!!!!!!!!!!!!!!");
				thrustRandom();
				_bDoThrust = false;				
			}
			else if (_b_moving_to_mouse && !_bIsGazing && !_bIsFrozen)
			{
				////trace("ENGINE V5 ++++++++  OTHER!!!!!!!!!!!!!!");
				_nMousex = _mcHost.mouseX;
				_nMousey = _mcHost.eyer.mouseY;
				////trace("EngineV5::doAnimation _nMousex="+_nMousex+", _nMousey="+_nMousey);
				_nDdy = (Math.abs(_nMousey)>_nYBound/2)? ((_nMousey>0)? _nYBound : -_nYBound) : _nMousey*2 + Number(this["yOffsetEyes"]);
				_nDdx = (Math.abs(_nMousex)>_nXBound/2)? ((_nMousex>0)? _nXBound : -_nXBound) : _nMousex*2;								
				////trace("EngineV5::doAnimation mousex="+_nMousex+", mousey="+_nMousey+", ddy="+_nDdy+", ddx="+_nDdx ); 	
			}
			
			
			_nTy = _nDdy / 10;
			_nTx = _nDdx / 5;
			_nTilt = (_nDdy*_nDdx) / 4000;
			_nTtx = _nTx + _nCrack*(random(10)<3? (random(11)-5) : 0);
			_nMinX = (_nTtx-_nBx) / _nSpeed;
			_nTy = Math.max(Math.min(_nTy,5),-3);
			_nMinY = (_nTy - _nYb) / _nSpeed;
			_nYb = _nYb + _nMinY;
			_nY = _nYb;
			_nYmult = (_nY<0)?-Number(this["YOverallFactor"]):Number(this["YOverallFactor"]);
			_nY = Math.min(Math.abs(_nY),_nMaxY);
			
			////trace("do Anim  Math.abs(_nMinX): "+Math.abs(_nMinX)+" _nDiff: "+_nDiff+" Math.abs(_nMinY): "+Math.abs(_nMinY)+" this.diff/4: "+(_nDiff/4));
			
			// this condition denotes that very little movement is occurring
			if (Math.abs(_nMinX) < _nDiff && Math.abs(_nMinY) < _nDiff/4)			
			{
				////trace("\ndoAnimation :: Math.abs(this.minX) < this.diff && Math.abs(this.minY) < this.diff/4");
				/*if (!_bIsGazing && !_b_moving_to_mouse)
				{
				_bIsRecenter = true;
				//_nDiff = 1;
				_nDdy = 0;
				_nDdx = 0;
				
				////trace("    c1");
				//_bResting = true;
				}
				else*/
				if (_bRestrictHeadShaking)
				{
//					return;
				}	
				//else //if (_bMouseMode)
				//{
				////trace("    c2");			
				//_bIsRecenter = true;
				//_nDiff = 1;
				//_nDdy = 0;
				//_nDdx = 0;					
				//}
				/*
				else if (_bIsRecenter)
				{
				//trace("    c3");
				//set from host to stop head shaking in photoreal hosts
				if (_bRestrictHeadShaking)
				{
				return;
				}
				////trace("----------------- set RECENTER false_______"); 
				_bIsRecenter = false;
				_bResting = true;					
				}
				*/
			}
			////trace("EngineV5::doAnimation 2");
			_nBx += _nMinX;
			_nXmult = (_nBx<0)?-1:1;
			
			_nX = Math.min(Math.abs(_nBx),_nMaxX);
			_nXz = _nMaxX - (_nMaxX-_nX) * (_nMaxX - _nX) / _nMaxX;
			_nXz *= Number(this["RestrictTotalTurning"]);
			
			if (_nXmult>=0)
			{
				_nXr = _nXz * Number(this["WhiteLineCompensation"]);//* 0.8;
				_nXl = _nXz;
			}
			else
			{
				_nXl = -_nXz * Number(this["WhiteLineCompensation"]);//* 0.8;
				_nXr = -_nXz;
				_nXz = - _nXz;
			}			
			
			//this gets rid of the white line - with only minimal (half pixel) overlap
			//set to WhiteLinePixelCompensation to 0.125 via template
			_nXl += Number(this["WhiteLinePixelCompensation"]);
			_nXr -= Number(this["WhiteLinePixelCompensation"]);
			////trace("EngineV5::doAnimation _nXl="+_nXl+", _nXr="+_nXr);
			////trace("EngineV5::doAnimation 3");
			
			_mcHost.facel.x = _nXl + _nFaceLX;
			
			if (_mcHost.lMaskGlassesMC is MovieClip)
			{
				_mcHost.lMaskGlassesMC.x = _mcHost.facel.x;
			}
			
			_mcHost.facer.x = _nXr+_nFaceRX;
			
			////trace("EngineV5::doAnimation 1 _mcHost.facel.x="+_mcHost.facel.x+", _mcHost.facer.x="+_mcHost.facer.x);
			
			if (_mcHost.rMaskGlassesMC is MovieClip)
			{
				_mcHost.rMaskGlassesMC.x = _mcHost.facer.x;
			}
			
			
			if(Number(this["l_glassesPos"])!=0){				
				if(Number(this["r_glassesPos"])!=0)
				{	//take the average					
					this["l_glassesPos"] = Number(this["l_glassesPos"]) + Number(this["r_glassesPos"]);
					this["l_glassesPos"] *= 0.5;
				}
				_mcHost.lMaskGlassesMC.y -= Number(this["l_glassesPos"]);
				_mcHost.rMaskGlassesMC.y -= Number(this["l_glassesPos"]);
				this["l_glassesPos"] = 0;
			}
			////trace('EngineV5::doAnimation Number(this["em"])='+Number(this["em"]));
			_mcHost.hairl.x            = (_nXl + _nHairLX);
			_mcHost.hair_r.x           = (_nXr + _nHairRX);		
			_mcHost.eyel.x             = (_nXl * Number(this["em"]) * Number(this["EyeMovementRatio"])+ _nEyeLX);
			_mcHost.eyer.x             = (_nXr * Number(this["em"]) * Number(this["EyeMovementRatio"]) + _nEyeRX);
			_mcHost.browl.x            = (_nXl * Number(this["em"]) * Number(this["BrowMovementRatio"])+ _nBrowLX);
			_mcHost.browr.x            = (_nXr * Number(this["em"]) * Number(this["BrowMovementRatio"])+ _nBrowRX);
			_mcHost.nose.x             = (_nXz * Number(this["em"]) + _nNoseX);
			_mcHost.mouth.x            = (_nXz * Number(this["em"]) * Number(this["MouthMovementRatio"]) + _nMouthX);
			////trace("EngineV4::doAnimation 6");
			_mcBackhair.x = _nHairBX - (_nXl/Number(this["BackHairXDampen"]));// + this.tilt;//( ( this.tilt < 0) ?((this.xl < 0)? this.tilt : -this.tilt ) : 0);
			_nSl = 100 + (_nXl*Number(this["XScaleFactor"])/_nMaxX);			
			if(this["ReciprocalScaling"])
			{
				_nSr = 10000/_nSl;
			}
			else
			{
				_nSr = 100 - (_nXr * Number(this["XScaleFactor"]) / _nMaxX);
			}
			////trace("EngineV4::doAnimation 7");
			_mcHost.facel.scaleX = _mcHost.hairl.scaleX =_nSl/100;
			_mcHost.hair_r.scaleX = _mcHost.facer.scaleX = _nSr/100;
			
			////trace('EnginveV5::Number(this["glassesFactor"])='+Number(this["glassesFactor"]));
			//AutoPhoto glasses 
			if(Number(this["glassesFactor"])>0)
			{
				_mcHost.rMaskGlassesMC.scaleX = Number(this["r_glassesScale"])* _mcHost.facer.scaleX;
				_mcHost.lMaskGlassesMC.scaleX = Number(this["l_glassesScale"])* _mcHost.facel.scaleX;
				
				_mcHost.rMaskGlassesMC.glassesr.scaleX = Math.pow(1/_mcHost.facer.scaleX, Number(this["glassesFactor"]));
				_mcHost.lMaskGlassesMC.glassesl.scaleX = Math.pow(1/_mcHost.facel.scaleX, Number(this["glassesFactor"]));					
			}
			////trace("EngineV4::doAnimation 8");
			if (_mcHairback is MovieClip)
			{
				_mcHairback.scaleX = (_nSl+_nSr)/2/100;	
			}			
			if(!isNaN(_nEyeCenterX))
			{
				
				_mcHost.browl.scaleX = _mcHost.eyel.scaleX        =  (((_nSl-100)*Number(this["EyeScaling"]))+100)/100;
				_nScalecompensation = (_mcHost.eyel.scaleX-1)*_nEyeCenterX;								
				
				_mcHost.eyel.x += _nScalecompensation;
				
				_nScalecompensation = (_mcHost.eyel.scaleX - 1) * (_mcHost.browl.x+_nEyeCenterX);
				_mcHost.browl.x +=  _nScalecompensation;
				
				_mcHost.browr.scaleX = _mcHost.eyer.scaleX        =  (((_nSr-100)*Number(this["EyeScaling"]))+100)/100;
				_nScalecompensation = (_mcHost.eyer.scaleX - 1) * _nEyeCenterX;
				_mcHost.eyer.x -= _nScalecompensation;
				_nScalecompensation = (_mcHost.eyer.scaleX - 1) * (-_mcHost.browr.x+_nEyeCenterX);
				_mcHost.browr.x -=  _nScalecompensation;
			}
			////trace("EngineV4::doAnimation 9");
			////trace("**** _nY="+_nY+", _nMaxY="+_nMaxY);
			_nYz = _nY * ((_nY / _nMaxY)-2);
			////trace("**** _nYz="+_nYz+", _nYmult="+_nYmult);
			_nYl = _nYz * _nYmult;			
			_mcHost.y = _nHeadY - (_nYl*Number(this["YHeadMoveFactor"]));			
			_nMoveheady = _nYb;
			_nEb = (_nYl * Number(this["YFeatureMovementFactor"]));
			////trace("EngineV5::doAnimation _nYl="+_nYl+", _nEb="+_nEb+',this["YEyeMovementRatio"]='+this["YEyeMovementRatio"]+', this["YScaleFactor"]='+this["YScaleFactor"]);
			_mcHost.eyel.y         =  _nEyeLY - (_nYl + _nEb * Number(this["YEyeMovementRatio"]) * Number(this["YScaleFactor"])/8)  ;//2
			_mcHost.eyer.y         =  _nEyeRY - (_nYl + _nEb * Number(this["YEyeMovementRatio"]) * Number(this["YScaleFactor"])/8)  ;//2
			_mcHost.browl.y        =  _nBrowLY - (_nYl + _nEb * Number(this["YBrowMovementRatio"]) * Number(this["YScaleFactor"])/8 )  ;//1
			_mcHost.browr.y        =  _nBrowRY - (_nYl + _nEb * Number(this["YBrowMovementRatio"]) * Number(this["YScaleFactor"])/8 )  ;//1
			_mcHost.nose.y         =  _nNoseY - (_nYl + _nEb * Number(this["YNoseMovementRatio"]) * Number(this["YScaleFactor"])/8);//* 2 );//(this.nose._yscale  - 100) / 10 +
			_mcHost.mouth.y        =  _nMouthY - (_nYl + _nEb  * Number(this["YMouthMovementRatio"]) * Number(this["YScaleFactor"])/8);//* 2 );//(this.mouth._yscale - 100) / 20 +
			////trace("EngineV4::doAnimation 11");
			////trace("**** _nYl="+_nYl+', this["YScaleFactor"]='+this["YScaleFactor"]+", _nMaxY="+_nMaxY);
			_nJj = 100 - _nYl * Number(this["YScaleFactor"]) / _nMaxY;
			////trace("***** _nJj="+_nJj);
			_mcHost.facel.scaleY       = _nJj/100;
			_mcHost.facer.scaleY       = _nJj/100;
			_mcHost.hairl.scaleY       = _nJj/100;
			_mcHost.hair_r.scaleY      = _nJj/100;	
			
			if(_mcJawMoverr!=_mcHost.facer)
			{
				//shrink the jaw;
				_nJjJaw = 100*100/_nJj; //this compensates for the face scaling,
				_mcHost.mouth.scaleY = _nJjJaw/100;
				_nJjJaw *= 100/_nJj;			   //then reduces scales the jaw itself
				//parent is used to prevent interefence with jaw movement scaling
				_mcJawMoverr.parent.scaleY = _nJjJaw/100;
				_mcJawMoverl.parent.scaleY = _nJjJaw/100;				
			}	
			////trace("EngineV4::doAnimation 12");
			_mcHost.nose.scaleY			= (100 - Math.min(1,(_nYl * Number(this["YScaleFactor"]) * Number(this["YNoseScaleFactor"]) /(8* _nMaxY))))/100;	
			_nEyeheight					= 100 - (Math.abs(_nYz)*Number(this["YeyeScale"]));
			_mcHost.eyel.scaleY 		= _nEyeheight/100; 
			_mcHost.eyer.scaleY        = _nEyeheight/100;			
			//jake's nose tilting
			//{
			_mcHost.nose.rotation = -(_nSl - 100) * Number(this["NoseRotationFactor"]);
			//}
			
			_mcHost.rotation += (_nTilt - _mcHost.rotation) / 4;	
			
			_mcBackhair.rotation=_mcHost.rotation/Number(this["BackHairRotationDampen"]);
			
			if (_mcHairback is MovieClip)
			{
				_mcHairback.rotation=_mcHost.rotation;
			}
			
			if (!_bTalkingFlag)		//Logic to move the eyes when NOT talking
			{
				_nEyeTX = _nDdx/Number(this["eyeFactorX"]);
				_nEyeTY = _nDdy/Number(this["eyeFactorY"]);
				_nEyeX = _nEyeX + (_nEyeTX - _nEyeX)/3
				_nEyeY = _nEyeY + (_nEyeTY - _nEyeY)/3
				_nEyeXl = _nEyeX - (_nXl / 7);
				_nEyeXr = _nEyeX - (_nXr / 7);
				
				_nEyeX = isNaN(_nEyeX)?0:_nEyeX;
				_nEyeY = isNaN(_nEyeY)?0:_nEyeY;
				
				if (_nEyeXl<-Number(this["eyeMaxX"]))
				{
					_nEyeXl = -Number(this["eyeMaxX"]);
				}
				
				if (_nEyeXl>Number(this["eyeMaxX"]))
				{
					_nEyeXl = Number(this["eyeMaxX"]);
				}
				
				if (_nEyeXr<-Number(this["eyeMaxX"]))
				{
					_nEyeXr = -Number(this["eyeMaxX"]);
				}
				
				if (_nEyeXr>Number(this["eyeMaxX"]))
				{
					_nEyeXr = Number(this["eyeMaxX"]);
				}
				
				_nEyeYY =   ((Math.abs(_nEyeY - _nYl) > Number(this["eyeMaxY"])) ? ( ((_nEyeY - _nYl) > 0) ? Number(this["eyeMaxY"]) : -Number(this["eyeMaxY"])) : (_nEyeY - _nYl));
				////trace("EngineV4::doAnimation 14");
				if(Number(this["ellipticalEyeMovement"])>0)
				{
					//the bounds of the eye movement need to be oval rather than square - Jake
					//equation of ellipse (x - h)^2 / a^2  + (y - k)^2 / b^2 = 1 
					//h = k = 0 as elliplse is at origin
					//so x^2 / a^2  + y^2 / b^2 = 1 
					var a2:Number = Number(this["eyeMaxX"]) * Number(this["eyeMaxX"]);
					var b2:Number = Number(this["eyeMaxY"]) * Number(this["eyeMaxY"]);
					var x2:Number = _nEyeXl*_nEyeXl;
					var y2:Number = _nEyeYY*_nEyeYY;
					var lengthSqr:Number = x2/a2 + y2/b2;
					
					if(lengthSqr > 1)
					{
						var normalize:Number = Math.sqrt(lengthSqr); //not sure this is mathmatically correct				
						_nEyeXl /= normalize;
						_nEyeYY /= normalize;
					}
				}
				////trace("**** _nEyebLY="+_nEyebLY+", _nEyeYY="+_nEyeYY);
				_nEyebLY = isNaN(_nEyebLY)?0:_nEyebLY
				_nEyeYY += _nEyebLY;
				////trace("host.eyel.ballMC="+host.eyel.ballMC);
				////trace("EngineV4::doAnimation 15");
				if(_mcHost.eyel.ballMC is MovieClip)
				{
					_nEyebLX = isNaN(_nEyebLX)?0:_nEyebLX;
					
					////trace("this.eyeXr="+this.eyeXr+", this.eyebLX="+this.eyebLX+", model.l_iris_x="+model.l_iris_x+", this.eyeYY="+this.eyeYY+", model.l_iris_y="+model.l_iris_y);
					
					_mcHost.eyel.ballMC.x    =  Number(_nEyeXr + _nEyebLX + Number(_modelBuilder.getModelVar("l_iris_x")));					
					_mcHost.eyer.ballMC.x    =  Number(_nEyeXl + _nEyebLX + Number(_modelBuilder.getModelVar("r_iris_x")));
					////trace("_mcHost.eyel.ballMC.x="+_mcHost.eyel.ballMC.x+',  _nEyeXr + _nEyebLX + _modelBuilder.getModelVar("l_iris_x")='+( _nEyeXr + _nEyebLX + _modelBuilder.getModelVar("l_iris_x")));//_mcHost.eyer.ballMC.x="+_mcHost.eyer.ballMC.x+',  _modelBuilder.getModelVar("l_iris_x")='+ _modelBuilder.getModelVar("l_iris_x"));
					_mcHost.eyer.ballMC.y    =  Number(_nEyeYY + Number(_modelBuilder.getModelVar("r_iris_y")));
					_mcHost.eyel.ballMC.y    =  Number(_nEyeYY + Number(_modelBuilder.getModelVar("l_iris_y")));
					
					if(_mcHost.eyer.ballMC.glintMC is MovieClip)
					{
						//the glint wants to move in the opposite direction to the parent iris				
						//first grab its initial position
						if(this["eyerGlintXpos"] == undefined && this["eyeGlintMovement"] > 0)
						{
							this["eyerGlintXpos"] = _mcHost.eyer.ballMC.glintMC.x;
							this["eyerGlintYpos"] = _mcHost.eyer.ballMC.glintMC.y;
						}				
						_mcHost.eyel.ballMC.glintMC.x = 
							_mcHost.eyer.ballMC.glintMC.x = Number(this["eyerGlintXpos"]) - _nEyeXr/Number(this["eyeGlintMovement"]);				
						_mcHost.eyel.ballMC.glintMC.y = 
							_mcHost.eyer.ballMC.glintMC.y = Number(this["eyerGlintYpos"]) - _nEyeYY/Number(this["eyeGlintMovement"]);								
					}						
				}
				else
				{
					////trace("this.eyeXr="+this.eyeXr+", this.eyebLX="+this.eyebLX);
					_mcHost.eyel.ball.x    = -_nEyeXr + _nEyebLX;
					_mcHost.eyer.ball.x    =  _nEyeXl + _nEyebLX;
					_mcHost.eyer.ball.y    =  _nEyeYY;
					_mcHost.eyel.ball.y    =  _nEyeYY;
				}
			}
			else //Logic to move the eyes during talking
			{		
				if(_mcHost.eyel.ballMC is MovieClip)
				{
					_mcHost.eyel.ballMC.x =  Number(-(_nXl/ 7)+ Number(_modelBuilder.getModelVar("l_iris_x")));
					_mcHost.eyer.ballMC.x =  Number(-(_nXl/ 7)+ Number(_modelBuilder.getModelVar("r_iris_x")));
					_mcHost.eyer.ballMC.y  = Number(_modelBuilder.getModelVar("r_iris_y"));
					_mcHost.eyel.ballMC.y =  Number(_modelBuilder.getModelVar("l_iris_y"));
					////trace("eyel.ballMC.x="+_mcHost.eyel.ballMC.x+", eyel.ballMC.y="+_mcHost.eyel.ballMC.y);
					////trace("ballMC.x="+_mcHost.eyel.ballMC.x+", ballMC.y="+_mcHost.eyel.ballMC.y+" -(_nXl/ 7)="+(-(_nXl/ 7))+' Number(_modelBuilder.getModelVar("l_iris_x"))='+(Number(_modelBuilder.getModelVar("l_iris_x"))));
				}else{
					////trace("this.xl="+this.xl);
					_mcHost.eyel.ball.x =  (_nXl / 7);
					_mcHost.eyer.ball.x =  -(_nXl / 7);
					_mcHost.eyer.ball.y  = _mcHost.eyel.ball.y =  0  ;
				}
				////trace("EngineV4::doAnimation 18");
				_nEyeTX = 0;
				_nEyeX = 0;
				_nEyeTY = 0;
				_nEyeY = 0;				
			}
			
			////trace("doAnimation var profile");
			//_nBx,_nXz,_mcHost.eyel.x,_mcHost.rotation,_nEyeYY
			////trace(_nBx+","+_nXz+","+_mcHost.eyel.x+","+_mcHost.rotation+","+_nEyeYY);
		}// END OF DOANIM
		
		//OnSpeechEvent - event triggered by audio events does some brow animation
		private function OnSpeechEvent(evt:EngineEvent):void
		{
			////trace("SPEECH EVENT!!!!!!!!!!");
			////trace("OnSpeechEvent::setting _bDoThrust="+_bDoThrust+", _nLastthrust="+_nLastthrust+", sound_engine.isNewWord()="+sound_engine.isNewWord());
			
			if (evt.data.hasOwnProperty("audioEnded"))			
			{
				setMouthFrame(evt.data.f);//goto mouth frame
				_nBrowframe = 1;	
			}
			else
			{
				setMouthFrame(evt.data as uint);//goto mouth frame
				if (sound_engine.isNewWord() || (!_bDoThrust && _nLastthrust>EngineV5Constants.HEAD_NEW_GAZE_DURING_SPEECH_COUNT)) 
				{					
					////trace("SPEECH EVENT --- do thrust");
					_nLastthrust=random(6);
					_bDoThrust=true;
				}			
				_nLastthrust++;
				
				if (sound_engine.isNewWord()) {
					if (random(10)<=4)       
						_nTbrowframe=5;
					else if (random(10)>3) 
						_nTbrowframe=10;
					else
						_nTbrowframe=1;
				}	
				
				_nBrowframe += (_nTbrowframe-_nBrowframe)/3;				
				if (Math.abs(_nTbrowframe - _nBrowframe)<0.5) _nBrowframe=_nTbrowframe;			
				_nBrowframe = Math.floor(_nBrowframe);
			}			
			////trace("**** sound_engine.isNewWord() ="+sound_engine.isNewWord()+", _bDoThrust="+_bDoThrust+", _nLastthrust="+_nLastthrust);
			////trace("OnSpeechEvent::_nBrowframe="+_nBrowframe+" sound_engine.isNewWord()="+sound_engine.isNewWord());								
			if (_mcHost.browl.shading is MovieClip)
			{
				_mcHost.browl.shading.gotoAndStop((_nBrowframe));
			}
			if (_mcHost.browr.shading is MovieClip)
			{
				_mcHost.browr.shading.gotoAndStop((_nBrowframe));
			}
			//animate the brow of non-emo host
			if (_mcHost.browl.hair is MovieClip)
			{
				
				_mcHost.browl.hair.gotoAndStop((_nBrowframe));
			}
			if (_mcHost.browr.hair is MovieClip)
			{
				_mcHost.browr.hair.gotoAndStop((_nBrowframe));			
			}
			//added to animate the brow of the emo host
			if (_mcHost.browl.brow_hair is MovieClip)
			{
				_mcHost.browl.brow_hair.hair.gotoAndStop((_nBrowframe));
			}
			if (_mcHost.browr.brow_hair is MovieClip)
			{
				_mcHost.browr.brow_hair.hair.gotoAndStop((_nBrowframe));
			}			
		}		
		
		//eyeBlink - make the eyes blink from time to time
		public function eyeBlink(openEyes:Boolean = false):void
		{
			//trace("EngineV5::eyeBlink ");
			if (isNaN(_nBr))
			{
				_nDif = _nAnimationFPS;// - Math.round(_nAnimationFPS/3);
				_nBr = EngineV5Constants.BLINK_RATE * _nAnimationFPS;
				////trace("EngineV5::setting _nBr="+_nBr+", and _nDif="+_nAnimationFPS);
			}						
			var sockRMC:MovieClip;
			var sockLMC:MovieClip;
			if (_mcHost.eyer.sock is MovieClip)
			{
				sockRMC = _mcHost.eyer.sock;
				sockLMC = _mcHost.eyel.sock;
			}
			else if (_mcHost.eyer.socket is MovieClip)
			{
				sockRMC = _mcHost.eyer.socket.socket_skin;
				sockLMC = _mcHost.eyel.socket.socket_skin;
			}
			if (!_bIsFrozen && !_bStopRandom && !openEyes)
			{
				if (currentSocketFrame == 2/*sockRMC.currentFrame==3*/)
				{
					//trace("----------------- eyeBlink sockRMC.currentFrame == 3 -> gotoAndStop(1)");						
					setSocketImagesVisibleByIndex(0);//sockRMC.gotoAndStop(1);					
					//sockLMC.gotoAndStop(1);					
				}
				else if (_nEyeCounter++ == _nBr || _bInBlink)
				{
					//trace("EngineV5::eyeBlink sockRMC.currentFrame<3 _nEyeCounter="+_nEyeCounter+", _nBr="+_nBr);
					if (currentSocketFrame == 1/*sockRMC.currentFrame==2*/)
					{
						_bInBlink = false;					
					}
					else
					{
						_bInBlink = true;										
					}					
					_nEyeCounter = random(_nDif);
					setSocketImagesVisibleByIndex(currentSocketFrame+1);//sockRMC.gotoAndStop(sockRMC.currentFrame+1);
					//sockLMC.gotoAndStop(sockLMC.currentFrame+1);					
				}
			}
			else
			{
				////trace("EngineV5::eyeBlink 3");
				setSocketImagesVisibleByIndex(0);////sockRMC.gotoAndStop(1);
				//sockLMC.gotoAndStop(1);
			}
		}
		
		public function getEngineSound():Sound
		{
			return sound_engine.getEngineSound();
		}
		
		public function getEngineSoundChannel():SoundChannel
		{
			return sound_engine.getEngineSoundChannel();
		}
		
		private var socketImagesR:Array = [];
		private var socketImagesL:Array = [];
		private var currentSocketFrame:int;
		private var totalSocketFrames:int;
		public function initForAcceleratedVideo(onComplete:Function = null):void
		{
			////trace("ENGINE --- INIT FOR VIDEO");
			//			_block_eye_blink = true;
			
			var socketR:MovieClip = _mcHost.eyer.sock ? _mcHost.eyer.sock : _mcHost.eyer.socket.socket_skin;
			var socketL:MovieClip = _mcHost.eyel.sock ? _mcHost.eyel.sock : _mcHost.eyel.socket.socket_skin;
			totalSocketFrames = socketR.totalFrames;
			
			var i:int = 1; // start at 1 because frames are not 0 based
			addEventListener(Event.ENTER_FRAME, onNextSocketFrame);
			
			/**
			 * Runs through all socket blink frames and captures them into bitmap data
			 */
			function onNextSocketFrame(event:Event):void
			{
				socketImagesR.push(mimicSocketFrameWithBitmap(socketR));
				socketImagesL.push(mimicSocketFrameWithBitmap(socketL));
				
				// no more frames to capture
				if (++i > socketR.totalFrames) {
					removeEventListener(Event.ENTER_FRAME, onNextSocketFrame);
					socketR.parent.removeChild(socketR);
					socketL.parent.removeChild(socketL);
					setSocketImagesVisibleByIndex(0);
					if (onComplete != null) {
						onComplete();
					}
				} else { // go to the next eye frame
					socketR.gotoAndStop(i);
					socketL.gotoAndStop(i);
				}
			}
			
			/**
			 * Adds a bitmap containing bitmap data capture of the socket's current frame, appearing exactly as socket currently does (position, scale, etc)
			 */
			function mimicSocketFrameWithBitmap(socket:DisplayObject):Bitmap
			{
				var bounds:Rectangle = socket.getBounds(socket);
				var capture:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x000000);
				bounds = socket.getBounds(socket.parent);
				var shift:Point = new Point(socket.x - bounds.x, socket.y - bounds.y);
				var matrix:Matrix = new Matrix();
				matrix.translate(shift.x, shift.y);
				capture.draw(socket, matrix);
				var socketBitmap:Bitmap = new Bitmap(capture, "auto", true);
				socketBitmap.scaleX = socketR.scaleX;
				socketBitmap.scaleY = socketR.scaleY;
				socketBitmap.x = bounds.x;
				socketBitmap.y = bounds.y;
				socket.parent.addChild(socketBitmap);
				return socketBitmap;
			}
		}
		
		public function forceEyeBlink(doBlink:Boolean = false):void
		{
			
			if (doBlink) {
				// start blinking from first frame, adding a listener to handle the blink sequence
				addEventListener(Event.ENTER_FRAME, onSocketUpdateEnterFrame);
				setSocketImagesVisibleByIndex(0);
			}
		}
		private function setSocketImagesVisibleByIndex(index:int):void
		{
			currentSocketFrame = index;
			for (var i:int = 0; i < socketImagesR.length; i++) {
				if (i == index) {
					socketImagesR[i].visible = true;
					socketImagesL[i].visible = true;
				} else {
					socketImagesR[i].visible = false;
					socketImagesL[i].visible = false;
				}
			}
		}
		private function onSocketUpdateEnterFrame(event:Event):void
		{
			if (++currentSocketFrame >= totalSocketFrames) {
				removeEventListener(Event.ENTER_FRAME, onSocketUpdateEnterFrame);
				currentSocketFrame = 0;
			}
			//trace("current socket frame", currentSocketFrame);
			setSocketImagesVisibleByIndex(currentSocketFrame);
		}
		
		public function destroy():void
		{
			//trace("(( ENGINE DESTROY ))");
			this.loaderInfo.removeEventListener(Event.COMPLETE, start);		
			this.loaderInfo.removeEventListener(Event.UNLOAD, onEngineUnload);
			this.loaderInfo.removeEventListener(Event.REMOVED_FROM_STAGE, onEngineUnload);
			if (_instantMouthTimer != null)
			{
				//trace("	ENGINE DESTROY INSTANT MOUTH TIMER");
				_instantMouthTimer.removeEventListener(TimerEvent.TIMER, onUpdateMouthFrame); 
				_instantMouthTimer.stop();
				_instantMouthTimer = null;
			}
			if (_timerAnimation != null)
			{
				//trace("	ENGINE DESTROY TIMER ANIMATION");
				_timerAnimation.removeEventListener(TimerEvent.TIMER, doAnimationInterval);
				_timerAnimation.stop();
				_timerAnimation = null;
			}
			if (sound_engine != null)
			{
				//trace("	ENGINE DESTROY SOUND ENGINE");
				sound_engine.destroy();
				sound_engine.removeEventListener(EngineEvent.AUDIO_DOWNLOAD_START, speechDownloadStarted);
				sound_engine.removeEventListener(EngineEvent.AUDIO_ENDED, audioDone);
				sound_engine.removeEventListener(EngineEvent.AUDIO_STARTED, audioStarted);
				sound_engine.removeEventListener(EngineEvent.WORD_ENDED, wordEnded);
				sound_engine.removeEventListener(EngineEvent.AUDIO_ERROR, audioError);			
				sound_engine.removeEventListener(EngineEvent.NEW_MOUTH_FRAME, OnSpeechEvent);
				sound_engine.removeEventListener(EngineEvent.SMILE, smile);
				sound_engine.removeEventListener(EngineEvent.TALK_ENDED, doneTalking);
				sound_engine.removeEventListener(EngineEvent.TALK_STARTED, talkStarted);
				sound_engine.removeEventListener(EngineEvent.SAY_SILENT_ENDED, e_silentDone);
			}
			if (_loaderModel != null)
			{
				//trace("	ENGINE DESTROY LOADER MODEL");
				//MovieClip(_loaderModel.content).destroy();
				_loaderModel.unload();
				_loaderModel.contentLoaderInfo.removeEventListener(Event.COMPLETE, modelLoaded);
				_loaderModel = null;
			}
			if (_modelBuilder != null)
			{
				//trace("	ENGINE DESTROY MOUTH BUILDER");
				_modelBuilder.destroy();
				_modelBuilder.removeEventListener(ModelBuilderEvent.MODEL_READY,modelReady);
				_modelBuilder.removeEventListener(ModelBuilderEvent.MODEL_ERROR,modelLoadError);
				_modelBuilder = null;
			}
			if (_mouseController != null)
			{
				//trace("	ENGINE DESTROY MOUSE CONTROLLER");
				_mouseController.destroy();
				_mouseController = null;
			}
			if (vCtrl)
			{
				vCtrl.destroy();
				vCtrl = null;
			}
			if (vCtrlMap)
			{
				vCtrlMap = null;	
			}
		}
	}
}