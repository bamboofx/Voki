/**
* ...
 * @author David Segal
* @version 0.1
* @date 12.03.2007
* 
*/

package com.voki.vhss.playback
{	
	import com.adobe.crypto.MD5;
	import com.oddcast.assets.structures.*;
	import com.oddcast.event.*;
	import com.oddcast.host.api.*;
	import com.oddcast.utils.ErrorReportingLoader;
	
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	
	import com.voki.vhss.Constants;
	import com.voki.vhss.events.AssetEvent;
	import com.voki.vhss.util.ExpressionMap;

	public class VSHostHolder extends AssetHolder 
	{
		private const move_range_3d:Number = 1.8;
		private var engine_holder:EngineHolder;
		private var active_host_data:HostStruct;
		private var loading_host_data:HostStruct;
		private var active_engine_api:Object;
		private var Engine3d:Class;  // reference to the instance of the 3d Engine class;
		private var is_frozen:Boolean = false;
		private var timer_audio_progress:Timer;
		
		public function VSHostHolder():void
		{
			super();
			setType("host");
			active_host_data = new HostStruct();
			engine_holder = new EngineHolder();
			engine_holder.addEventListener(AssetEvent.ASSET_INIT, e_engineLoaded);
		}

		private function engineReady():void
		{
			switch (loading_host_data.type) {
				case HostStruct.HOST_3D:
					var t_eng:LoadedAssetStruct = loading_host_data.engine;
					//try this to get the document class
					//Engine3d = Object(t_eng.loader.content).constructor; 
					//
					try 
					{
						if (t_eng.loader.contentLoaderInfo.applicationDomain.hasDefinition("__main__4editor"))
						{
							//----trace("HostHolder :::  use __main__4editor");
							Engine3d = t_eng.loader.contentLoaderInfo.applicationDomain.getDefinition("__main__4editor") as Class;
						}
						else 
						{
							//----trace("HostHolder :::  use __main__4host");
							Engine3d = t_eng.loader.contentLoaderInfo.applicationDomain.getDefinition("__main__4host") as Class;							
						}
					}
					catch ($error:ReferenceError)
					{
						//----trace("ERROR ::: HostHolder :: Engine class does not exist!!!!!!!!!!!!!!  ");
					}
					loadHost3d();
					break;
				default:
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, true, "OC Error: Host is not a known type. type: "+loading_host_data.type));
					//----trace("HostHolder :::  engine ready :: type unknown  :: " + loading_host_data.type);
				
			}
			if (active_engine_api == null) active_engine_api = getEngineAPI(loading_host_data);
			dispatchEvent(new VHSSEvent(VHSSEvent.ENGINE_LOADED));
			//trace("HostHolder ::: engine ready ::: type: " + active_eng_data.type+" add listeners ");
		}
		
		private function getEngineAPI(asset:HostStruct):Object
		{
			if (!asset) 
				return null;
			
			if (asset.type == HostStruct.HOST_3D)
				return asset.host_container.getAPI();
			
			return null;
		}
		
		private function loadHost3d():void
		{
			//----trace("HostHolder ::: loadHost3d ::: ");
			//f
			var t_hs:HostStruct = loading_host_data;
			t_hs.host_container = MovieClip(new Engine3d());
			t_hs.host_container.init(t_hs.host_container);
			if (Constants.USE_3D_OFFSET)
			{
				t_hs.host_container.x = Constants.X_OFFSET_3D;
				t_hs.host_container.y = Constants.Y_OFFSET_3D;
				t_hs.host_container.scaleX = t_hs.host_container.scaleY += Constants.SCALE_OFFSET_3D * .01;
			}
			var t_api:Object = t_hs.host_container.getAPI();
			t_api.allowRender(false, true);
			t_api.addEventListener(EngineEvent.CONFIG_DONE, e_configDone_3d);
			t_api.addEventListener(EngineEvent.TALK_ENDED, e_talkEnded);
			t_api.addEventListener(EngineEvent.TALK_STARTED, e_talkStarted);
			t_api.addEventListener(EngineEvent.MODEL_LOAD_ERROR, e_modelLoadError);
			t_api.addEventListener(EngineEvent.AUDIO_ERROR, e_audioError);
		}
		
		private function dispatchAudioProgress($percent:Number):void
		{
			//----trace("HOST HOLDER ---- audio progress interval " + $percent);
			dispatchEvent(new VHSSEvent(VHSSEvent.AUDIO_PROGRESS, { percent : int($percent*100) } ));
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call("VHSS_Command", "vh_audioProgress", int($percent*100));
				}
				catch ($e:Error)
				{
					//----trace("HostHolder -- ExternalInterface audioProgress error");
				}
			}
		}
	
		private function deactivateLastHost():void
		{
			//----trace("HOST HOLDER DEACTIVATE LAST HOST");
			if (active_host_data.host_container != null)
			{
				freeze();
				removeChild(active_host_data.host_container);
			}
		}
		
		// Public API
		
		public function getActiveEngineAPI():Object //IEngineAPI
		{
			return active_engine_api;
		}
		
		public function sayAudio($url:String, $start:Number = 0):void
		{
			//----trace("HOST HOLDER ---- say audio ---- url --- " + $url);
			active_engine_api.say($url, $start);
		}
		
		public function saySilent($seconds:Number):void
		{
			active_engine_api.saySilent($seconds);
		}
		
		public function freeze():void
		{
			//----trace("HOST HOLDER FREEZE");
			active_engine_api.freeze();
			is_frozen = true;
		}
		
		public function resume():void
		{
			//----trace("HOST HOLDER RESUME");
			active_engine_api.resume();
			is_frozen = false;
		}
		
		public function stopSpeech():void
		{
			if (active_engine_api)
				active_engine_api.stopSpeech();
		}
		
		public function sayMultiple($maudio:Array):void
		{
			//----trace("HOST HOLDER __ Say Multiple");
			active_engine_api.sayMultiple($maudio);
		}
		
		public function setPhoneme($phoneme:String):void
		{
			active_engine_api.setPhoneme($phoneme);
		}
		
		public function setFacialExpById($id:Number, $duration:Number, $intensity:Number, $attack:Number, $decay:Number):void
		{
			if (active_host_data.type == HostStruct.HOST_3D)
			{
				active_engine_api.clearExpressionList();
				if ($id > 0)
				{
					var t_exp:String = ExpressionMap.exp_ar[$id];
					if (t_exp != null && t_exp.length > 0)
					{
						var t_dur:Number = ($duration == -1) ? 1000 : $duration;
						if ($attack == 0) $attack = Math.min(Constants.EXP_AD_MAX, Math.floor(t_dur * Constants.EXP_AD_PERCENT));
						if ($decay == 0) $decay = Math.min(Constants.EXP_AD_MAX, Math.floor(t_dur * Constants.EXP_AD_PERCENT));
						active_engine_api.setExpression(t_exp, $intensity, -1, $duration, $attack, $decay);
					}
				}
			}
		}
		
		public function setFacialExpByString($str:String, $duration:Number, $intensity:Number = 1, $attack:Number = 0, $decay:Number = 0):void
		{
			if (active_host_data.type == HostStruct.HOST_3D)
			{
				active_engine_api.clearExpressionList();
				var t_dur:Number = ($duration == -1) ? 1000 : $duration;
				if ($attack == 0) $attack = Math.min(Constants.EXP_AD_MAX, Math.floor(t_dur * Constants.EXP_AD_PERCENT));
				if ($decay == 0) $decay = Math.min(Constants.EXP_AD_MAX, Math.floor(t_dur * Constants.EXP_AD_PERCENT));
				active_engine_api.setExpression($str, $intensity, -1, $duration, $attack, $decay);
			}
		}
		
		public function followCursor(mode:Number):void
		{
			//----trace("API -- follow Cursor "+$mode+"   active_engine_api.followCursor "+active_engine_api.followCursor);
			if (active_engine_api)
				active_engine_api.followCursor(mode);
		}
		
		public function recenter():void
		{
			if (active_engine_api)
				active_engine_api.recenter();
		}
		
		public function setGaze(degrees:Number, duration:Number, radius:Number):void
		{
			if (degrees == 0)
				degrees = 360;
			if (active_engine_api)
				active_engine_api.setGaze(degrees, duration, radius);
		}
		
		public function setColor(part:String, color:uint):void
		{
			if (active_engine_api)
				active_engine_api.setColor(part, color);
		}
		
		public function setLookSpeed(speed:String):void
		{
			if (active_engine_api)
				active_engine_api.setLookSpeed(speed);
		}

		public function setRandomMovement(haltMotion:String):void
		{
			if (active_engine_api)
				active_engine_api.randomMovement(!(haltMotion == "0"));
		}
		
		public function setRandomMovementParameters(frequency:Number, radius:Number):void
		{
			try {
				active_engine_api.setRandomMovementParameters(frequency, radius);
			} catch(error:*) { }
		}
		
		public function setSpeechMovement(amp:Number):void
		{
			try {
				active_engine_api.setEditValue(API_Constant.ADVANCED, EditLabel.F_SPEECH_HEADMOVE_AMPLITUDE, amp, 0);
			} catch (error:*) {
				trace("ERROR -- setSpeechMovement");
			}
		}
		
		/**
		 * Forwards volume calls down to loaded engines.
		 * @param	$vol	Range between [0, 1]
		 */
		public function setVolume(value:Number):void
		{
			try {
				if (active_host_data.type == HostStruct.HOST_3D)
					value *= Constants.VOLUME_RANGE_3D.max;
				else if (active_host_data.type == HostStruct.HOST_2D)
					value *= Constants.VOLUME_RANGE_2D.max;
				
				active_engine_api.setHostVolume(value);
			} catch (error:*) { }
		}
		
		/*public function getCharacterSound():Sound
		{
			return active_engine_api.getEngineSound();
		}
	
		public function getCharacterSoundChannel():SoundChannel
		{
			return active_engine_api.getEngineSoundChannel();
		}*/
		
		//Internal API
		public function getIsFrozen():Boolean
		{
			return is_frozen;
		}
		
		public override function displayAsset(asset:LoadedAssetStruct):void	
		{
			if (!asset) return;
			deactivateLastHost();
			active_host_data = HostStruct(asset);
			active_engine_api = getEngineAPI(active_host_data);
			addChild(active_host_data.host_container);
			if (active_host_data.type == HostStruct.HOST_3D) {
				active_engine_api.allowRender(true, true);
			} else {
				active_engine_api.setActiveModel(active_host_data.model_ptr);
			}
			resume();	
		}
		
		public override function loadAsset($asset:LoadedAssetStruct):void
		{
			loading_host_data = HostStruct($asset);
			var t_hs:HostStruct = HostStruct($asset);
			var _h_index:String = escape(t_hs.id.toString()+t_hs.url);
			//trace("HOSTHOLDER -- "+active_host_data);
			if (active_host_data == null || engine_holder.getLoadedAsset(t_hs.engine.id.toString()+t_hs.engine.url) == null) // engine is not loaded
			{
				stack[_h_index] = t_hs;
				engine_holder.loadAsset(t_hs.engine);
			}
			else if (stack[_h_index] != null)  // host and engine have already been loaded
			{
				var t_shs:HostStruct = stack[_h_index];
				loading_host_data.display_obj = t_shs.display_obj;
				loading_host_data.model_ptr = t_shs.model_ptr;
				loading_host_data.host_container = t_shs.host_container;
				loading_host_data.loader = t_shs.loader;
				dispatchEvent(new AssetEvent(AssetEvent.ASSET_INIT, loading_host_data));
				dispatchEvent(new VHSSEvent(VHSSEvent.CONFIG_DONE, loading_host_data));
			}
			else // engine is loaded but host is not
			{
				loading_host_data.engine = EngineStruct(engine_holder.getLoadedAsset(t_hs.engine.id.toString()+t_hs.engine.url));
				stack[_h_index] = t_hs;
				loadHost3d() 
			}
		}
				
		public function setProgressInterval($progressInterval:Number):void
		{
			var _n:Number = Math.floor($progressInterval);
			//trace("HOST HOLDER ---- set audio progress interval "+$ev.data.progressInterval+"   n: "+_n+"   (timer_audio_progress == null) "+(timer_audio_progress == null)+" (_n > 0 ) "+ (_n > 0) );
			if (_n > 0 && timer_audio_progress == null)
			{
				//trace("HOST HOLDER ---- set audio progress interval ");
				timer_audio_progress = new Timer(_n * 1000);
				timer_audio_progress.addEventListener(TimerEvent.TIMER, e_audioProgressInterval);
			}
			else if (_n < 1)
			{
				try 
				{
					timer_audio_progress.stop();
					timer_audio_progress.removeEventListener(TimerEvent.TIMER, e_audioProgressInterval);
					timer_audio_progress = null;
				}
				catch(err:Error)
				{
					//----trace("HOST HOLDER :: Set Progresss interval  ::  :: nothing to remove ::: "+err.toString());
				}
			}
		}
		
		/*
		 * Event Handlers
		 */
		// API Events

		// Timer Event Handlers
		private function e_audioProgressInterval($ev:TimerEvent):void
		{
			var _n:Number = active_engine_api.getCurrentAudioProgress();
			dispatchAudioProgress(_n);
		}
		
		private function e_audioProgressComplete($ev:TimerEvent):void
		{

		}
		
		// Engine Holder event
		private function e_engineLoaded($ev:AssetEvent):void
		{
			engineReady();
		}
		
		// Host Event Handlers
		private function e_audioEnded($ev:*):void
		{
			dispatchEvent(new VHSSEvent(VHSSEvent.AUDIO_ENDED));
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call("VHSS_Command", "vh_audioEnded");
				}
				catch ($e:Error)
				{
					//----trace("HostHolder -- ExternalInterface talkEnded error");
				}
			}
		}
		
		private function e_audioStarted($ev:*):void
		{
			var vhss_event:VHSSEvent = new VHSSEvent(VHSSEvent.AUDIO_STARTED);
			try
			{
				vhss_event.data = {"sound_channel":active_engine_api.getEngineSoundChannel(), "sound":active_engine_api.getEngineSound()};	
			}
			catch (error:Error)
			{
				vhss_event.data = {"sound_channel":new SoundChannel(), "sound":new Sound()};	
			}
			dispatchEvent(vhss_event);
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call("VHSS_Command", "vh_audioStarted");
				}
				catch ($e:Error)
				{
					//----trace("HostHolder -- ExternalInterface talkEnded error");
				}
			}
		}
		
		private function e_audioError($ev:*):void
		{
			var t_error_loader:ErrorReportingLoader = new ErrorReportingLoader();
			var t_str:String = "";
			try
			{
				t_str = $ev.data as String;
				var t_ar:Array = t_str.split(" ");
				for (var i:int = 0; i < t_ar.length; ++i)
				{
					if (String(t_ar[i]).indexOf(".mp3") != -1)
					{
						t_str = String(t_ar[i]);
						break;
					}
				}
			}
			catch (error:Error)
			{
				
			}
			t_error_loader.report("audio_error", t_str);
			dispatchEvent(new VHSSEvent(VHSSEvent.AUDIO_ERROR));
		}
		
		private function e_modelLoadError($ev:*):void
		{
			var t_error_loader:ErrorReportingLoader = new ErrorReportingLoader();
			t_error_loader.report("model_load_error");
			dispatchEvent(new VHSSEvent(VHSSEvent.MODEL_LOAD_ERROR));
		}
		
		private function e_accessoryLoadError($ev:EngineEvent):void
		{
			try
			{
				dispatchEvent(new VHSSEvent(VHSSEvent.ACCESSORY_LOAD_ERROR));
			}
			catch ($e:*){}
		}
		
		private function e_talkEnded($ev:*):void
		{
			//----trace("HOST HOLDER --- TALK ENDED EVENT HANDLER");
			if (timer_audio_progress != null)
			{
				timer_audio_progress.stop();
				dispatchAudioProgress(1);
			}
			//dispatchEvent(new EngineEvent(EngineEvent.TALK_ENDED));
			dispatchEvent(new VHSSEvent(VHSSEvent.TALK_ENDED));
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call("VHSS_Command", "vh_talkEnded");
				}
				catch ($e:Error)
				{
					//----trace("HostHolder -- ExternalInterface talkEnded error");
				}
			}
		}
		
		private function e_talkStarted($ev:*):void
		{
			//----trace("HOST HOLDER  ---  TALK STARTED  timer == null:: "+(timer_audio_progress == null));
			is_frozen = false;
			if (timer_audio_progress != null) 
			{
				timer_audio_progress.start();
			}
			var _vhss_event:VHSSEvent = new VHSSEvent(VHSSEvent.TALK_STARTED);
			try
			{
				_vhss_event.data = $ev.data;
			}
			catch (error:Error){}
			dispatchEvent(_vhss_event);
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call("VHSS_Command", "vh_talkStarted");
				}
				catch ($e:Error)
				{
					//----trace("HostHolder -- ExternalInterface talkStarted error");
				}
			}
		}
		
		private function e_configDone_2d($ev:*):void
		{
			var t_hs:HostStruct = loading_host_data;
			t_hs.model_ptr = MovieClip($ev.data);
			var t_api:MovieClip = MovieClip(getEngineAPI(loading_host_data));
			if (t_hs.cs != null && t_hs.cs.length > 0) 
			{
				t_api.configFromCS(t_hs.cs);
			}
			try
			{
				if (this.stage == null)
				{
					t_api.setMouseStage(this.parent);
				}
				else
				{
					t_api.setMouseStage(this.stage);
				}
				
			}
			catch (error:Error)
			{
				
			}
			dispatchEvent(new AssetEvent(AssetEvent.ASSET_INIT, loading_host_data));
			dispatchEvent(new VHSSEvent(VHSSEvent.CONFIG_DONE, loading_host_data));
		}
		
		private function e_configDone_3d($ev:*):void
		{
			//----trace("Host Holder :: CONFIG_DONE 3D !!!!!!!");
			var t_api:Object = getEngineAPI(loading_host_data);
			t_api.addEventListener(EngineEventStrings.PROCESSING_STARTED, e_processingStarted);
			t_api.addEventListener(EngineEventStrings.PROCESSING_ENDED, e_processingEnded);
			t_api.loadURL(loading_host_data.url, EditLabel.U_HEAD, API_Constant.UNDO_FLAGS_NONE);
		}
		
		private function e_processingStarted($ev:*):void
		{
			//trace("Host Holder :: processingStarted !!!!!!!");
		}
		
		private function e_processingEnded($ev:*):void
		{
			var t_api:Object = getEngineAPI(loading_host_data);
			t_api.setFaceMoveRange(move_range_3d);
			dispatchEvent(new AssetEvent(AssetEvent.ASSET_INIT, loading_host_data));
			dispatchEvent(new VHSSEvent(VHSSEvent.CONFIG_DONE, loading_host_data));
		}
		
		//Destructor
		public override function destroy():void
		{
			if (stack)
			{
				//trace("Host Holder -- destroy");
				for each (var t_obj:Object in stack)
	        	{
	        		//trace("Host Holder -- destroy - stack obj - "+t_obj);
	        		if (t_obj != null && t_obj is HostStruct)
	        		{
	        			var t_hs:HostStruct = HostStruct(t_obj);
	        			var t_eng_api:Object;
	        			if  (t_hs.type == HostStruct.HOST_2D)
	        			{
	        				t_eng_api = getEngineAPI(t_hs);
	        				if (t_eng_api != null)
	        				{
	        					var t_api:MovieClip = MovieClip(t_eng_api);
	        					//trace("Host Holder -- destroy 2d host -- destroy is a ::  "+t_api.destroy+" --  is a ::  "+t_api.recenter);
								t_api.removeEventListener(EngineEvent.CONFIG_DONE, e_configDone_2d);
								t_api.removeEventListener(EngineEvent.TALK_ENDED, e_talkEnded);
								t_api.removeEventListener(EngineEvent.TALK_STARTED, e_talkStarted);
								t_api.removeEventListener(EngineEvent.AUDIO_ENDED, e_audioEnded);
								t_api.removeEventListener(EngineEvent.AUDIO_STARTED, e_audioStarted);
								t_api.removeEventListener(EngineEvent.AUDIO_ERROR, e_audioError);
								t_api.removeEventListener(EngineEvent.MODEL_LOAD_ERROR, e_modelLoadError);
	        				}
	        			}
	        			else if (t_hs.type == HostStruct.HOST_3D)
	        			{
	        				t_eng_api = getEngineAPI(t_hs);
	        				if (t_eng_api != null)
	        				{
	        					//trace("Host Holder -- destroy 3d host -- destroy is a ::  "+t_api.destroy);
	        					t_eng_api.removeEventListener(EngineEventStrings.PROCESSING_STARTED, e_processingStarted);
								t_eng_api.removeEventListener(EngineEventStrings.PROCESSING_ENDED, e_processingEnded);
								t_eng_api.removeEventListener(EngineEvent.CONFIG_DONE, e_configDone_3d);
								t_eng_api.removeEventListener(EngineEvent.TALK_ENDED, e_talkEnded);
								t_eng_api.removeEventListener(EngineEvent.TALK_STARTED, e_talkStarted);
								t_eng_api.removeEventListener(EngineEvent.AUDIO_ERROR, e_audioError);
								t_eng_api.removeEventListener(EngineEvent.MODEL_LOAD_ERROR, e_modelLoadError);
	        				}
	        			}
	        			if (t_hs.loader != null)
	        			{
	        				if (t_hs.loader.contentLoaderInfo)
	        				{
		        				var t_cli:LoaderInfo = t_hs.loader.contentLoaderInfo;
								t_cli.removeEventListener(Event.INIT, e_initHandler);
								t_cli.removeEventListener(HTTPStatusEvent.HTTP_STATUS, e_httpStatusHandler);
								t_cli.removeEventListener(Event.COMPLETE, e_completeHandler);
								t_cli.removeEventListener(IOErrorEvent.IO_ERROR, e_ioErrorHandler);
								t_cli.removeEventListener(Event.OPEN, e_openHandler);
								t_cli.removeEventListener(ProgressEvent.PROGRESS, e_progressHandler);
								t_cli.removeEventListener(Event.UNLOAD, e_unLoadHandler);
	        				}
							t_hs.loader.unload();
							t_hs.loader = null;
	        			}
						t_hs.destroy();
	        		}
	        	}
	        }
        	if (engine_holder != null)
			{
				engine_holder.removeEventListener(AssetEvent.ASSET_INIT, e_engineLoaded);
				engine_holder.destroy();
				engine_holder = null;
			}
			if (timer_audio_progress != null)
			{
				timer_audio_progress.stop();
				timer_audio_progress.removeEventListener(TimerEvent.TIMER, e_audioProgressInterval);
				timer_audio_progress = null;
			}
			active_host_data = null;
			loading_host_data = null;
			active_engine_api = null;
			Engine3d = null;
        	while(this.numChildren > 0) removeChildAt(0);
		}
	}
}