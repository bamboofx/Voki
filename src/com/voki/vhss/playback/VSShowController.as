/**
* ...
* @author David Segal
* @version 0.1
* @date 12.03.2007
* 
*/

package com.voki.vhss.playback 
{	
	import com.oddcast.assets.structures.*;
	import com.oddcast.audio.CachedTTS;
	import com.oddcast.event.*;
	import com.pagodaflash.net.XHRLoader;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	import com.voki.vhss.Constants;
	import com.voki.vhss.api.*;
	import com.voki.vhss.api.requests.*;
	import com.voki.vhss.events.*;
	import com.voki.vhss.reports.VHSSPlayerTracker;
	import com.voki.vhss.structures.*;
	import com.voki.vhss.util.BadWordFilter;

	public class VSShowController extends Sprite
	{	
		private static const STATUS_LOADED:String = "loaded";
		private static const STATUS_LOADING:String = "loading";
		private static const STATUS_PRELOADING:String = "preloading";
		
		private var show_data:SlideShowStruct;
		private var scene_data:SceneStruct;
		private var host_data:HostStruct;
		private var bg_data:BackgroundStruct;

		private var loader_holder:AssetHolder;
		private var watermark_holder:AssetHolder;
		private var host_holder:HostHolder;
		private var masked_items_holder:Sprite;
		private var skin_holder:SkinHolder;
		private var link_data:LinkStruct;
		private var link_timer:Timer;
		private var is_interrupt:Boolean = false;
		private var is_speaking:Boolean = false;
		private var assets_to_load:int;
		private var audio_by_name:AudioRequestQueue;
		private var bg_by_name:BGRequester;
		private var ai_by_php:AIRequester;
		private var lead_sender:LeadSender;
		private var scene_volume:Number = 1;
		private var scene_volume_before_mute:Number = 1;
		private var vhss_shared_object:VHSSSharedObject;
		private var is_auto_advance:Boolean = false;
		//private var gaze_ctrl:GazeController;
		private var bad_word_filter:BadWordFilter;
		//private var comm_component_btn:CommCompButton;
		
		private var loading_status:String = STATUS_LOADED;

		private var auto_adv_timer:Timer;

		private var active_scene_index:int = -1;
		private var next_index_from_api:int = -1;
		private var preload_scene_index:int;
		private var bg_color:Number;
		
		public function VSShowController($show:SlideShowStruct, $bgcolor:Number = 0xffffff):void
		{
			bad_word_filter = new BadWordFilter($show.account_id);
			show_data = $show;
			if (show_data.account_id != null && show_data.show_id != null && Constants.EMBED_ID != null) {
				vhss_shared_object = new VHSSSharedObject(show_data.account_id, show_data.show_id, Constants.EMBED_ID);
			}
			masked_items_holder = new Sprite();
			addChild(masked_items_holder);
			
			host_holder = new HostHolder();
			host_holder.addEventListener(VHSSEvent.AUDIO_ENDED, e_dispatchEvent);
			host_holder.addEventListener(VHSSEvent.AUDIO_STARTED, e_dispatchEvent);
			host_holder.addEventListener(VHSSEvent.TALK_ENDED, e_talkEnded);
			host_holder.addEventListener(VHSSEvent.TALK_STARTED, e_talkStarted);
			host_holder.addEventListener(VHSSEvent.CONFIG_DONE, e_dispatchEvent);
			host_holder.addEventListener(VHSSEvent.ENGINE_LOADED, e_dispatchEvent);
			host_holder.addEventListener(VHSSEvent.MODEL_LOAD_ERROR, e_dispatchEvent);
			host_holder.addEventListener(VHSSEvent.AUDIO_ERROR, e_dispatchEvent);
			host_holder.addEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
			//gaze_ctrl = new GazeController(host_holder);
			masked_items_holder.addChild(host_holder);
			skin_holder = new SkinHolder();
			configureSkinListeners();
			addChild(skin_holder);
		}
	
		private function configureSkinListeners():void
		{
			skin_holder.addEventListener(SkinEvent.PLAY, e_skinPlay);
			skin_holder.addEventListener(SkinEvent.MUTE, e_skinMute);
			skin_holder.addEventListener(SkinEvent.SAY_AI, e_skinSayAI);
			skin_holder.addEventListener(SkinEvent.SAY_FAQ, e_skinSayFAQ);
			skin_holder.addEventListener(SkinEvent.SEND_LEAD, e_skinLeadSend);
			skin_holder.addEventListener(SkinEvent.PAUSE, e_skinPause);
			skin_holder.addEventListener(SkinEvent.UNMUTE, e_skinUnmute);
			skin_holder.addEventListener(SkinEvent.VOLUME_CHANGE, e_skinVolume);
			skin_holder.addEventListener(SkinEvent.NEXT, e_skinNext);
			skin_holder.addEventListener(SkinEvent.PREV, e_skinPrev);
			
			skin_holder.addEventListener(SkinEvent.LEAD_ERROR, e_skinLeadAudio);
			skin_holder.addEventListener(SkinEvent.LEAD_SUCCESS, e_skinLeadAudio);
			
			skin_holder.addEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
		}
		
		private function assetLoaded():void
		{
			--assets_to_load;
			//trace("ShowController :: assetLoaded :: assets_to_load: " + assets_to_load);
			if (assets_to_load == 0) { // assetLoaded gets called later on by bg holder if setBackground/loadBG is called, thus assets_to_load will be < 0 and in this case you should not continue as is the case with the initial loading of assets (only when assets_to_load == 0 should you continue) maybe a better solution is to use a different event handler for bgs loaded afer initial setup so this same method doesn't get called and rely on such specific logic/treatment of the int value assets_to_load
				if (Constants.IS_FILTERED) {
					bad_word_filter.load(onBadWordsLoaded, _onBadWordsError);
				} else {
					onBadWordsLoaded();
				}
				
				function onBadWordsLoaded():void
				{
					if (loading_status == STATUS_PRELOADING) {
						try {
							ExternalInterface.call("VHSS_Command", "vh_scenePreloaded", (preload_scene_index + 1));
						} catch ($e:Error) {
							//----trace("EXTERNAL INTERFACE ERROR");
						}
						
						dispatchEvent(new VHSSEvent(VHSSEvent.SCENE_PRELOADED, { scene_number:preload_scene_index + 1 }));
						loading_status = STATUS_LOADED;
					} else {
						if (loader_holder != null) {
							removeChild(loader_holder);
							loader_holder = null;
						}
						stopSpeech();
						host_holder.displayAsset(scene_data.host);
						host_holder.followCursor(scene_data.mouse_follow);
						try {
							if (stage != null) {
								//gaze_ctrl.setStageReference(stage);
								//gaze_ctrl.followInPage(scene_data.mouse_follow == 4);
							}
						} catch (e:Error) {
						}
						
						host_holder.x = scene_data.host_x;
						host_holder.y = scene_data.host_y;
						host_holder.visible = scene_data.host_visible;
						host_holder.scaleX = host_holder.scaleY = scene_data.host_scale * .01;
						if (scene_data.host_exp) {
							host_holder.setFacialExpByString(scene_data.host_exp, -1, scene_data.host_exp_intensity);
						}
						if (scene_data.skin) {
							skin_holder.displayAsset(scene_data.skin);
							setSkinFeatures();
						}
						loading_status = STATUS_LOADED;
						if(show_data.volume > -1) {
							var vol:Number = show_data.volume / Constants.VOLUME_RANGE_PLAYER.max;
							show_data.volume = -1;
							setVolume(vol);
						}
						startScene();
					}
				}
			}
		}
	
		private function startScene():void
		{
			VHSSPlayerTracker.event("sv", scene_data.id);
			//----trace("ShowController  -   dispatch event " + VHSSEvent.SCENE_LOADED+"  tracker url: "+show_data.track_url+"  is null: "+(show_data.track_url != null));
			trace("VHSS dispatching SCENE_LOADED");
			dispatchEvent(new VHSSEvent(VHSSEvent.SCENE_LOADED, { scene_number:active_scene_index + 1 } ));
			setVolume(scene_volume);
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call("VHSS_Command", "vh_sceneLoaded", (active_scene_index + 1) );
				}
				catch ($e:Error)
				{
					//----trace("EXTERNAL INTERFACE ERROR");
				}
			}
			if (scene_data.play_mode.indexOf("click") != -1 && !Constants.SUPPRESS_PLAY_ON_CLICK)
			{
				host_holder.addEventListener(MouseEvent.CLICK, e_playOnClick);
			}
			if (!Constants.SUPPRESS_PLAY_ON_LOAD)
			{
				if (scene_data.play_mode.indexOf("load") != -1)
				{
					if (isPlayable()) saySceneAudio();
				}
				if (scene_data.play_mode.indexOf("ro") != -1)
				{
					host_holder.addEventListener(MouseEvent.ROLL_OVER, e_playOnRO);
				}
			}
			else
			{
				sceneComplete();
			}
		}
		
		private function isPlayable():Boolean
		{
			if (vhss_shared_object != null && show_data.scenes.length == 1)
			{
				try
				{
					return vhss_shared_object.isPlayable(scene_data.audio.id.toString(), scene_data.playback_limit, scene_data.playback_interval);
				}
				catch ($e:Error)
				{
					return true;
				}
			}
			return true;
		}
	
		private function sceneComplete():void
		{
			//----trace("ShowController ---- sceneComplete    auto advance: " + is_auto_advance+"  active_scene_index: "+active_scene_index+" show_data.scenes.length: "+show_data.scenes.length);
			dispatchEvent(new VHSSEvent(VHSSEvent.SCENE_PLAYBACK_COMPLETE));
			if (is_auto_advance && (next_index_from_api > -1 || active_scene_index < show_data.scenes.length-1))
			{
				auto_adv_timer = new Timer(scene_data.advance_delay * 1000, 1);
				auto_adv_timer.addEventListener(TimerEvent.TIMER_COMPLETE, e_onAutoAdvance);
				auto_adv_timer.start();
			}
		}
		
		private function setMute($b:Boolean):void
		{
			if ($b)
				scene_volume_before_mute = scene_volume;
			setVolume($b ? 0 : scene_volume_before_mute, false);
		}
		
		private function createAudioRequester():void
		{
			audio_by_name = new AudioRequestQueue();
			audio_by_name.addEventListener(APIEvent.SAY_AUDIO_URL, e_audioURLReady);
			audio_by_name.addEventListener(APIEvent.AUDIO_CACHED, e_audioCached);
		}
		
		private function resume():void
		{
			host_holder.resume();
			if (is_speaking) skin_holder.activatePauseButton();
		}
		
		private function pause():void
		{
			host_holder.freeze();
			if (is_speaking) skin_holder.activatePlayButton();
		}
		
		private function setSkinFeatures():void
		{
			if (watermark_holder != null)
			{
				var t_obj:Object = skin_holder.getWatermarkPosition();
				if (t_obj.x != null) watermark_holder.x = t_obj.x;
				if (t_obj.y != null) watermark_holder.y = t_obj.y;
				watermark_holder.visible = (t_obj.x != null && t_obj.x > 0);
			}
			if (skin_holder.getSkinMask() != null)
			{
				masked_items_holder.mask = skin_holder.getSkinMask();
			} 
			else
			{
				masked_items_holder.mask = null;
			}
			if (scene_data.skin_conf != null) skin_holder.configureSkin(scene_data.skin_conf);
		}
		
		private function setAutoLink():void
		{
			if (link_data.auto_delay > 0)
			{
				link_timer = new Timer(link_data.auto_delay, 1);
				link_timer.addEventListener(TimerEvent.TIMER_COMPLETE, e_openSceneLink);
				link_timer.start();
			}
			else
			{
				e_openSceneLink();
			}
		}
		
		//Internal API Functions
		public function init():void
		{
			if (show_data) {
				var watermarkStatus:int = 3; // 3 - there is no watermark or loader url
				if (show_data.watermark_url != null) {
					watermark_holder = new AssetHolder("watermark");
					addChild(watermark_holder);
					watermark_holder.visible = false;
					watermark_holder.addEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
					watermark_holder.loadAsset(new LoadedAssetStruct(show_data.watermark_url, 0, "watermark"));
					watermarkStatus = 1; // 1 - there is a watermark
				} else if (show_data.loader_url) {
					watermarkStatus = 2; // 2 - there is no watermark but there is a loader url
				}
				
				// set cookie related to watermark/custom watermark with loader/no watermark value
				setTimeout(function():void{ setWatermarkCookie(watermarkStatus); }, 1000);
				
				if (show_data.loader_url != null) {
					loader_holder = new AssetHolder("loader");
					addChild(loader_holder);
					loader_holder.addEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
					loader_holder.loadAsset(new LoadedAssetStruct(show_data.loader_url, 0, "loader"));
				} else {
					displayScene();
					startTracker();
				}
			} else {
				throw new Error("Missing data for scene or show. Please make sure you are using a valid index.");
			}
			
			/*if (Constants.ONLINE && Constants.PLAYER_DOMAIN.indexOf("dev.oddcast.com") != -1)
			{
				comm_component_btn = new CommCompButton();
				comm_component_btn.addEventListener(MouseEvent.CLICK, e_launchCommComponent);
				addChild(comm_component_btn);
			}*/
		}
		
		private function setWatermarkCookie(watermarkStatus:int):void
		{
			var vars:URLVariables = new URLVariables();
			vars.internalmode = Constants.INTERNAL_MODE;
			vars.watermark = watermarkStatus;
			var url:String = Constants.SITEPAL_BASE + Constants.SET_COOKIE_PHP + "?" + vars.toString();
			var watermarkLoader:URLLoader = new URLLoader();
			watermarkLoader.addEventListener(Event.COMPLETE, onWatermarkComplete);
			watermarkLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onWatermarkSecurityError);
			watermarkLoader.load(new URLRequest(url));
			
			function onWatermarkComplete(event:Event):void
			{
				watermarkLoader.removeEventListener(Event.COMPLETE, onWatermarkComplete);
				watermarkLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onWatermarkSecurityError);
			}
			function onWatermarkSecurityError(event:SecurityErrorEvent):void
			{
				watermarkLoader.removeEventListener(Event.COMPLETE, onWatermarkComplete);
				watermarkLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onWatermarkSecurityError);
			}
		}
		
		public function displayScene($num:int = 0):void
		{
			//trace("ShowController  --::::-- displayScene  "+$num+" loading_status: "+loading_status);
			if ($num >= 0 && $num <= show_data.scenes.length-1 && $num != active_scene_index && loading_status == STATUS_LOADED)
			{
				loading_status = STATUS_LOADING;
				active_scene_index = $num;
				scene_data = SceneStruct(show_data.scenes[$num]);
				is_auto_advance = (scene_data.auto_advance && !Constants.SUPPRESS_AUTO_ADV);
				assets_to_load = scene_data.assets_to_load;
				if (scene_data.host)
					loadHost(HostStruct(scene_data.host));
				if (scene_data.skin)
					loadSkin(SkinStruct(scene_data.skin));
				setLink(scene_data.link);
			}
		}
		
		public function preloadScene($num:int):void
		{
			if ($num >= 0 && $num <= show_data.scenes.length-1 && loading_status == STATUS_LOADED)
			{
				loading_status = STATUS_PRELOADING;
				preload_scene_index = $num;
				var t_scene_data:SceneStruct = SceneStruct(show_data.scenes[$num]);
				assets_to_load = t_scene_data.assets_to_load;
				loadHost(HostStruct(t_scene_data.host));
				if (t_scene_data.skin != null) loadSkin(SkinStruct(t_scene_data.skin));
			}
		}
		
		public function saySceneAudio():void
		{
			if (scene_data.audio != null && scene_data.audio.url != null) 
			{
				sayAudio(scene_data.audio.url);
			}
			else
			{
				skin_holder.activatePlayButton();
				dispatchEvent(new VHSSEvent(VHSSEvent.SCENE_PLAYBACK_COMPLETE));
			}
		}
		
		public function startTracker():void
		{
			if (show_data.track_url != null)
			{	
				var _track_obj:Object = new Object();
				if (show_data.scenes.length == 1)
				{
					_track_obj["scn"] = SceneStruct(show_data.scenes[0]).id;
				}
				_track_obj["apt"] = "v";
				_track_obj["acc"] = show_data.account_id;
				_track_obj["emb"] = Constants.TRACKING_EMBED_ID;
				if (show_data.show_id.length > 0) _track_obj["shw"] = show_data.show_id;
				if (Constants.PAGE_DOMAIN != null) _track_obj["dom"] = Constants.PAGE_DOMAIN;
				try
				{
					_track_obj["skn"] = scene_data.skin.id;
				}
				catch ($err:Error)
				{
					//----trace("NO SKIN IN THIS SCENE - " + $err.message);
				}
				//trace("VHSS INIT TRACKER : "+show_data.track_url+" Constants.SUPRESS_TRACKING: "+Constants.SUPRESS_TRACKING);
				if (show_data.track_url != null && show_data.track_url.length() > 0 && !Constants.SUPPRESS_TRACKING)
				{
					//trace("VHSS INIT TRACKER!!!!!!!!!!!");
					VHSSPlayerTracker.initTracker(show_data.track_url, _track_obj, this.loaderInfo);
					VHSSPlayerTracker.event("fver", null, 0, Constants.FLASH_PLAYER_VERSION);
					
				}		
			}
		}
		
		public function getActiveEngineAPI():Object
		{
			return host_holder.getActiveEngineAPI();
		}
		
		public function setHostPosition($xpos:int, $ypos:int, $scale:int):void
		{
			host_holder.x = $xpos;
			host_holder.y = $ypos;
			host_holder.scaleX = host_holder.scaleY = $scale * .01;
		}
		
		public function getHostHolder():HostHolder
		{
			return host_holder;
		}
		
		public function getBGHolder():BackgroundHolder
		{
			return null;
		}
		
		public function setSkinConfig($xml:XML):void
		{
			scene_data.skin_conf = $xml;
			setSkinFeatures();
			//skin_holder.configureSkin(scene_data.skin_conf);
		}
		
		public function filterTTS($str:String, $lang:String):String
		{
			return (bad_word_filter != null && Constants.IS_FILTERED && bad_word_filter.isReady) ? bad_word_filter.filter($str, $lang) : $str;
		}
		
		public function setSceneAudio($as:AudioStruct):void
		{
			scene_data.audio = $as;
		}
		
		//Public API Functions
		public function freezeToggle():void
		{
			if (host_holder.getIsFrozen()) 
			{
				resume();
			}
			else 
			{
				pause();
			}
		}
		
		public function followCursor($mode:Number):void
		{
			//----trace("ShowController - follow cursor - "+$mode);
			host_holder.followCursor($mode);
			//gaze_ctrl.followInPage($mode == 2);
		}
		
		public function setGaze($degrees:Number, $duration:Number, $radius:Number = 100, $page_req:Number = 0):void
		{
			/*if (gaze_ctrl)
			{
				if ($page_req == 1)
				{
					gaze_ctrl.setGazePage($degrees, $duration, $radius);
				}
				else
				{
					gaze_ctrl.setGazeUser($degrees, $duration, $radius);
				}	
			}*/
		}
		
		public function setFacialExpression($id:*, $duration:Number, $intensity:Number, $attack:Number, $decay:Number):void
		{
			
			if (isNaN($id))
			{
				host_holder.setFacialExpByString(String($id), $duration, $intensity, $attack, $decay);
			}
			else
			{
				host_holder.setFacialExpById(Number($id), $duration, $intensity, $attack, $decay);
			}
			
		}
		
		public function sayAudio($url:String, $start:Number=0):void
		{
			resume();
			if (is_interrupt)
			{
				stopSpeech();
			}
			host_holder.sayAudio($url, $start);
		}
		
		public function sayText(_request:APITTSRequest):void
		{
			CachedTTS.setDomain(Constants.TTS_DOMAIN);
			if (Constants.IS_FILTERED && !(_request is APIAIRequest)) _request.name = filterTTS(_request.name, _request.lang);
			var t_url:String = CachedTTS.getTTSURL(_request.name, parseInt(_request.voice), parseInt(_request.lang), parseInt(_request.engine), _request.fx_type, parseInt(_request.fx_level));
			var event_str:String = ((_request.engine.length < 2) ? "0"+ _request.engine : _request.engine) + ((_request.lang.length < 2) ? "0"+ _request.lang : _request.lang) + ((_request.voice.length < 2) ? "0"+ _request.voice : _request.voice);
			VHSSPlayerTracker.event("actts", scene_data.id, 0, event_str);
			//----trace("SHOW CONTROLLER -- saytext  url: "+t_url);
			sayAudio(t_url);
		}
		
		public function sayAIResponse($req:APIAIRequest):void
		{
			//----trace("SHOW CONTROLLER ---- SAY AI RESPONSE");
			if (ai_by_php == null) 
			{
				ai_by_php = new AIRequester();
				ai_by_php.addEventListener(APIEvent.AI_COMPLETE, e_aiComplete);
			}
			$req.account_id = show_data.account_id;
			$req.ai_engine_id = show_data.ai_engine_id
			ai_by_php.load($req);
		}

		public function sayMultiple($audios:Array):void 
		{
			host_holder.sayMultiple($audios);
		}
		
		public function sayByNameExported($req:APIAudioRequest):void
		{
			//----trace("SHOWCONTROLLER -- SBNExp name: "+$req.name+"  acc "+show_data.account_id);
			if (audio_by_name == null) createAudioRequester();
			sayByName($req);
		}
		
		public function sayByName($req:APIAudioRequest):void
		{
			//----trace("SHOWCONTROLLER -- SBN name: "+$req.name);
			if (audio_by_name == null) createAudioRequester();
			$req.account_id = show_data.account_id;
			audio_by_name.load($req);
		}
		
		/**
		 * Sets volume on engines and skins.
		 * @param	$vol	Range between [0, 1]
		 */
		public function setVolume($vol:Number, updateSlider:Boolean = true):void
		{
			//----trace("SHOW CONTROLLER -- SET VOLUME "+$vol);
			scene_volume = $vol;
			host_holder.setVolume($vol);
			if (updateSlider)
				skin_holder.setVolumeSlider($vol);
		}
		
		public function setBackground($req:APIRequest):void
		{
			if (bg_by_name == null)
			{
				bg_by_name = new BGRequester();
				bg_by_name.addEventListener(APIEvent.BG_URL, e_bgUrlReady);
			}
			$req.account_id = show_data.account_id;
			bg_by_name.load($req);
		}
		
		public function setColor($part:String, $color:uint):void
		{
			host_holder.setColor($part, $color);
		}
		
		public function loadHost($as:HostStruct, $display:Boolean = false):void
		{
			if ($display)
			{
				host_holder.addEventListener(AssetEvent.ASSET_INIT, e_displayImmediately, false, 1);
			}
			host_holder.loadAsset($as);
		}
		
		public function gotoNextScene():void
		{
			//----trace("VHSS V5 - showController - gotoNextScene -- ");
			if (auto_adv_timer != null)
			{
				auto_adv_timer.stop();
				auto_adv_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_onAutoAdvance);
			}
			is_auto_advance = false;
			stopSpeech();
			(next_index_from_api != -1) ? displayScene(next_index_from_api) : displayScene(active_scene_index + 1);
			next_index_from_api = -1;
		}
		
		public function preloadNextScene():void
		{
			preloadScene(active_scene_index + 1);
		}
		
		public function gotoPrevScene():void
		{
			if (auto_adv_timer != null)
			{
				auto_adv_timer.stop();
				auto_adv_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_onAutoAdvance);
			}
			is_auto_advance = false;
			stopSpeech();
			displayScene(active_scene_index - 1);
		}
		
		public function gotoScene($scene_num:int):void
		{
			displayScene($scene_num - 1);
		}
		
		public function setNextSceneIndex($scene:int):void
		{
			next_index_from_api = $scene - 1;
		}
		
		public function stopSpeech():void
		{
			host_holder.stopSpeech();
			skin_holder.activatePlayButton();
		}
		
		public function replay($force_replay:Boolean):void
		{
			if ($force_replay || isPlayable())
			{
				saySceneAudio();
			}
		}
		
		public function setInterrupt($interrupt:Number):void
		{
			is_interrupt = ($interrupt == 1);
		}
		
		public function loadBg($bs:BackgroundStruct, $display:Boolean = false, transform:Object = null):void{}
		
		public function setBackgroundTransform(transform:Object):void{}

		public function setLookSpeed($sp:String):void
		{
			host_holder.setLookSpeed($sp);
		}

		public function setRandomMovement($haltMotion:String):void
		{
			host_holder.setRandomMovement($haltMotion);
		}
		
		public function setSpeechMovement(amp:Number):void
		{
			host_holder.setSpeechMovement(amp);
		}
		
		private function loadSkin($ss:SkinStruct, $display:Boolean = false):void
		{
			//----trace("SHOW CONTROLLER -------------load skin");
			if ($display)
			{
				skin_holder.addEventListener(AssetEvent.ASSET_INIT, e_displayImmediately, false, 1);
			}
			skin_holder.loadAsset($ss);
		}
		
		public function loadSkinFromAPI($ss:SkinStruct, $display:Boolean = false):void
		{
			for (var i:int = 0; i < show_data.scenes.length; ++i) {
				if (SceneStruct(show_data.scenes[i]).skin) {
					--SceneStruct(show_data.scenes[i]).assets_to_load;
				}
				SceneStruct(show_data.scenes[i]).skin = $ss;
			}
			loadSkin($ss, $display);
		}
		
		public function setLink($ls:LinkStruct):void
		{
			if (link_data == null || $ls == null)
			{
				link_data = $ls;
			}
			else
			{
				link_data.url = $ls.url;
				if ($ls.target != null) link_data.target = $ls.target;
			}
			if (link_timer != null)
			{
				link_timer.stop();
				link_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_openSceneLink);
			}
			if (link_data != null && link_data.is_button_launch)
			{
				masked_items_holder.addEventListener(MouseEvent.CLICK, e_openSceneLink);
			}
			else 
			{
				masked_items_holder.removeEventListener(MouseEvent.CLICK, e_openSceneLink);
			}
		}

		public function getShowXML():XML
		{
			return show_data.show_xml;
		}
		
		public function getAudioUrl():String
		{
			//----trace("SHOW CONTROLLER ::: getAudioUrl :: " + (scene_data.audio == null));
			return (scene_data.audio != null && scene_data.audio.url != null) ? scene_data.audio.url : null;
		}
		
		public function displayBgFrame(offset:Number = 0):void{}
		
		public function setRandomMovementParameters(frequency:Number, radius:Number):void
		{
			host_holder.setRandomMovementParameters(frequency, radius);
		}
		
		/*public function getCharacterSound():Sound
		{
			return host_holder.getCharacterSound();
		}
		
		public function getCharacterSoundChannel():SoundChannel
		{
			return host_holder.getCharacterSoundChannel();
		}
		*/
		//Events
		//API Events
		private function e_audioURLReady($ev:APIEvent):void
		{
			var t_aud_req:APIAudioRequest = APIAudioRequest($ev.data);
			sayAudio(t_aud_req.url, t_aud_req.start_time);
		}
		
		private function e_audioCached($ev:APIEvent):void
		{
			//----trace("API -- SHOW CONTROLLER audio loaded "+$ev.data.toString());
			try
			{
				ExternalInterface.call("VHSS_Command", "vh_audioLoaded", APIAudioRequest($ev.data).name );
			}
			catch ($e:Error)
			{
				//----trace("EXTERNAL INTERFACE ERROR");
			}
			var t_ve:VHSSEvent = new VHSSEvent(VHSSEvent.AUDIO_LOADED);
			t_ve.data = APIAudioRequest($ev.data).name
			dispatchEvent(t_ve);
		}
		
		private function e_bgUrlReady($ev:APIEvent):void{}
		
		private function e_aiComplete($ev:APIEvent):void
		{
			var t_ai_resp:AIResponse = $ev.data as AIResponse;
			stopSpeech(); // AI IS ALWAYS INTERRUPT MODE
			if (t_ai_resp.url != null && t_ai_resp.url.length > 1)
			{
				sayAudio(t_ai_resp.url);
			}
			else
			{
				sayText(t_ai_resp.ai_request);
			}
			var t_resp:String = (t_ai_resp.display_text.length > 0) ? t_ai_resp.display_text : t_ai_resp.ai_request.name;
			skin_holder.setAIResponse(t_resp);
			dispatchEvent($ev);
		}
		
		private function _onBadWordsLoaded():void
		{
			assetLoaded();
		}
		private function _onBadWordsError():void
		{
			throw new Error("Configuration indicated that bad words should be filtered, but bad words xml was not able to load from url:" + bad_word_filter.wordsXmlUrl);
		}
		//AssetEvent
		private function e_assetLoaded($ev:AssetEvent):void
		{
			//trace("ShowController :: assetLoaded "+ $ev.data+" type: "+$ev.data.type);
			var t_las:LoadedAssetStruct = LoadedAssetStruct($ev.data);
			if (t_las.loader != null && t_las.loader.contentLoaderInfo.contentType == "application/x-shockwave-flash") {
				if (t_las.loader.contentLoaderInfo.swfVersion < 9) {
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, true, "SWF version "+t_las.loader.contentLoaderInfo.swfVersion+" url: "+t_las.loader.contentLoaderInfo.url));
				} 
			}
			if ($ev.data is BackgroundStruct) {
				assetLoaded();
				//----trace("SHOWCONTROLLER --  dispatch BG_LOADED--");
				dispatchEvent(new VHSSEvent(VHSSEvent.BG_LOADED));
			} else if ($ev.data is SkinStruct) {
				assetLoaded();
				dispatchEvent(new VHSSEvent(VHSSEvent.SKIN_LOADED));
			} else if ($ev.data is HostStruct) {
				assetLoaded();
			} else if ($ev.data.type == "loader") {
				try {
					var t_mc:MovieClip = MovieClip(LoadedAssetStruct($ev.data).display_obj).loadingAnim.bg;
					if(bg_color == -1) {
						t_mc.alpha = 0;
					} else {
						var t_ct:ColorTransform = new ColorTransform();
						t_ct.color = bg_color;
						t_mc.transform.colorTransform = t_ct;
					}
				}
				catch ($e:Error) {
				}
				loader_holder.displayAsset(t_las);
				loader_holder.removeEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
				displayScene();
				startTracker();
			} else if ($ev.data.type == "watermark") {
				watermark_holder.displayAsset(t_las);
				watermark_holder.removeEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
			}
		}
		
		private function e_displayImmediately($ev:AssetEvent):void
		{
			if ($ev.data is SkinStruct)
			{
				if ($ev.data.url == null) masked_items_holder.mask = null;
				skin_holder.displayAsset(SkinStruct($ev.data));
				skin_holder.removeEventListener(AssetEvent.ASSET_INIT, e_displayImmediately);
			}	
			else if ($ev.data is HostStruct)
			{
				host_holder.displayAsset(HostStruct($ev.data));
				host_holder.removeEventListener(AssetEvent.ASSET_INIT, e_displayImmediately);
			}
		}
		
		
		// Host Events
		private function e_dispatchEvent($ev:VHSSEvent):void
		{
			dispatchEvent($ev);
		}
		
		private function e_talkStarted($ev:VHSSEvent):void
		{
			//----trace("ShowController +++++ talk started ");
			is_speaking = true;
			VHSSPlayerTracker.event("ap", scene_data.id);
			skin_holder.activatePauseButton();
			dispatchEvent($ev);
			if (link_data != null && link_data.is_start_launch) setAutoLink();
		}
		
		private function e_talkEnded($ev:VHSSEvent):void
		{
			//trace("ShowController ++++ TALK ENDED EVENT HANDLER  status:: ");
			is_speaking = false;
			VHSSPlayerTracker.event("ae", scene_data.id);
			skin_holder.activatePlayButton();
			sceneComplete();
			dispatchEvent($ev);
			if (link_data != null && link_data.is_end_launch) setAutoLink();
		}
		
		//private function e_engineReady($ev:VHSSEvent):void
		//{
		//	dispatchEvent($ev);
		//}
		
		// BG Events
		private function e_playbackComplete($ev:Event):void
		{
			//trace("ShowController ++++ BG PLAYBACK COMPLETE  is speaking: "+is_speaking);
			if (!is_speaking)
			{
				skin_holder.activatePlayButton();
				sceneComplete();
			}
		}
		
		// Auto Advance Timer Event
		private function e_onAutoAdvance($ev:TimerEvent):void
		{
			
			gotoNextScene();
		}
		
		// Mouse Event
		private function e_openSceneLink($ev:Event = null):void
		{
			navigateToURL(new URLRequest(link_data.url), link_data.target);
			if (link_timer != null)
			{
				link_timer.stop();
				link_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_openSceneLink);
			}
		}
		
		private function e_playOnClick($ev:MouseEvent):void
		{
			//----trace("SHOWCONTROLLER -- play on click --- is_speaking: "+is_speaking+"  frozen: "+host_holder.getIsFrozen());
			if (is_speaking)
			{
				freezeToggle();
			}
			else
			{
				saySceneAudio();
			}
		}
		
		private function e_playOnRO($ev:MouseEvent):void
		{
			//----trace("SHOWCONTROLLER -- play on ro --- "); 
			host_holder.removeEventListener(MouseEvent.ROLL_OVER, e_playOnRO);
			saySceneAudio();
		}
		
		
		
		// Skin Events
		private function e_skinPlay($ev:*):void
		{
			//----trace("Show Controller --- skin event " + $ev.type +"   obj: " + $ev.obj);
			if (!is_speaking)
			{
				saySceneAudio();
			}
			else
			{
				resume();
			}
			VHSSPlayerTracker.event("uipl", scene_data.id);

		}
		
		private function e_skinNext($ev:SkinEvent):void
		{
			//----trace("SHOW CONTROLLER -- skin next");
			gotoNextScene();
		}
		
		private function e_skinPrev($ev:SkinEvent):void
		{
			gotoPrevScene();
		}
		
		private function e_skinPause($ev:*):void
		{
			//----trace("Show Controller --- skin event " + $ev.type +"   obj: " + $ev.obj);
			pause();
			VHSSPlayerTracker.event("uips", scene_data.id);
		}
		
		private function e_skinMute($ev:*):void
		{
			//----trace("Show Controller --- skin event " + $ev.type +"   obj: " + $ev.obj);
			setMute(true);
			VHSSPlayerTracker.event("uim", scene_data.id);
		}
		
		private function e_skinUnmute($ev:*):void
		{
			//----trace("Show Controller --- skin event " + $ev.type +"   obj: " + $ev.obj);
			setMute(false);
			VHSSPlayerTracker.event("uium", scene_data.id);
		}
		
		private function e_skinVolume($ev:*):void
		{
			trace("skin volume");
			setVolume($ev.obj);
		}
		
		private function e_skinSayAI($ev:*):void
		{	
			if (String($ev.obj.text).length > 0 && $ev.obj.voice > 0 && $ev.obj.lang > 0 && $ev.obj.engine > 0)
			{
				if (this.loaderInfo.url.indexOf("oddcast") != -1 && Constants.IS_AI_ENABLED)
				{
					VHSSPlayerTracker.event("uiai", scene_data.id);
					var t_ai_req:APIAIRequest = new APIAIRequest($ev.obj.text, $ev.obj.voice, $ev.obj.lang, $ev.obj.engine, $ev.obj.bot);
					sayAIResponse(t_ai_req);
				}
			}
		}
		
		private function e_skinSayFAQ($ev:*):void
		{
			//----trace("Show Controller --- skin event " + $ev.type +"   obj: " + $ev.obj);
			stopSpeech();
			VHSSPlayerTracker.event("uifaq", scene_data.id);
			var t_audio_url:String = (String($ev.obj).indexOf("http") == 0) ? String($ev.obj) : show_data.content_dom + String($ev.obj);
			sayAudio(t_audio_url);
		}
		
		private function e_skinLeadSend($ev:*):void
		{
			//----trace("Show Controller (:::) skin event " + $ev.type +"   obj: " + $ev.obj);
			VHSSPlayerTracker.event("uild", scene_data.id);
			lead_sender = new LeadSender();
			lead_sender.addEventListener(DataLoaderEvent.ON_DATA_READY, e_leadSent);
			lead_sender.sendLead($ev.obj, show_data, scene_data);
		}
		
		private function e_leadSent($ev:DataLoaderEvent):void
		{
			//----trace("Show Controller --- skin event " + $ev.type +"   data: " + $ev.data.data);
			lead_sender.removeEventListener(DataLoaderEvent.ON_DATA_READY, e_leadSent);
			var t_xml:XML = XML($ev.data.data);
			skin_holder.setLeadResponse(t_xml.name() == "OK");
		}
		
		private function e_skinLeadAudio($ev:SkinEvent):void
		{
			//----trace("Show Controller --- skin event  skin audio: " + $ev.type +"   obj: " + $ev.obj);
			stopSpeech();
			var t_audio_url:String = (String($ev.obj).indexOf("http") == 0) ? String($ev.obj) : show_data.content_dom + String($ev.obj);
			sayAudio(t_audio_url);
		}
		/*
		private function e_launchCommComponent($ev:MouseEvent):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("window.open", Constants.COMM_WINDOW+"?accid="+show_data.account_id+"&showid="+show_data.show_id, "win", "height=275,width=400,toolbar=no,scrollbars=no,resizable=no,status=no,titlebar=no"); 
			}
			else
			{
				navigateToURL(new URLRequest(Constants.COMM_WINDOW+"?accid="+show_data.account_id+"&showid="+show_data.show_id), "_blank");
			}
			
		}*/

		// Destructor
		public function destroy():void
		{
			removeAllDOCs(this);
			masked_items_holder.removeEventListener(MouseEvent.CLICK, e_openSceneLink);
			host_holder.removeEventListener(MouseEvent.CLICK, e_playOnClick);
			host_holder.removeEventListener(MouseEvent.ROLL_OVER, e_playOnRO);
			//removeEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
			if (host_holder != null)
			{
				//trace("Show - destroy - host_holder");
				host_holder.stopSpeech();
				host_holder.removeEventListener(VHSSEvent.AUDIO_ENDED, e_dispatchEvent);
				host_holder.removeEventListener(VHSSEvent.AUDIO_STARTED, e_dispatchEvent);
				host_holder.removeEventListener(VHSSEvent.TALK_ENDED, e_talkEnded);
				host_holder.removeEventListener(VHSSEvent.TALK_STARTED, e_talkStarted);
				host_holder.removeEventListener(VHSSEvent.CONFIG_DONE, e_dispatchEvent);
				host_holder.removeEventListener(VHSSEvent.ENGINE_LOADED, e_dispatchEvent);
				host_holder.removeEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
				host_holder.removeEventListener(VHSSEvent.MODEL_LOAD_ERROR, e_dispatchEvent);
				host_holder.removeEventListener(AssetEvent.ASSET_INIT, e_displayImmediately);
				host_holder.removeEventListener(VHSSEvent.AUDIO_ERROR, e_dispatchEvent);
				try
				{
					host_holder.destroy();
				}
				catch ($e:*){}
			}
			if (skin_holder != null)
			{
				//trace("Show - destroy - skin_holder");
				skin_holder.removeEventListener(SkinEvent.PLAY, e_skinPlay);
				skin_holder.removeEventListener(SkinEvent.MUTE, e_skinMute);
				skin_holder.removeEventListener(SkinEvent.SAY_AI, e_skinSayAI);
				skin_holder.removeEventListener(SkinEvent.SAY_FAQ, e_skinSayFAQ);
				skin_holder.removeEventListener(SkinEvent.SEND_LEAD, e_skinLeadSend);
				skin_holder.removeEventListener(SkinEvent.PAUSE, e_skinPause);
				skin_holder.removeEventListener(SkinEvent.UNMUTE, e_skinUnmute);
				skin_holder.removeEventListener(SkinEvent.VOLUME_CHANGE, e_skinVolume);
				skin_holder.removeEventListener(SkinEvent.NEXT, e_skinNext);
				skin_holder.removeEventListener(SkinEvent.PREV, e_skinPrev);
				skin_holder.removeEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
				skin_holder.removeEventListener(SkinEvent.LEAD_ERROR, e_skinLeadAudio);
				skin_holder.removeEventListener(SkinEvent.LEAD_SUCCESS, e_skinLeadAudio);
				skin_holder.removeEventListener(AssetEvent.ASSET_INIT, e_displayImmediately);
				try
				{
					skin_holder.destroy();	
				}
				catch ($e:*){}
				skin_holder = null;
				//trace("SKIN DESTRUCTOR DONE");
			}
			if (loader_holder != null)
			{
				//trace("Show - destroy - loader_holder");
				loader_holder.removeEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
			}
			if (auto_adv_timer != null)
			{
				//trace("Show - destroy - auto_adv_timer");
				auto_adv_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_onAutoAdvance);
				auto_adv_timer = null
			}
			if (audio_by_name != null)
			{
				//trace("Show - destroy - audio_by_name");
				audio_by_name.removeEventListener(APIEvent.SAY_AUDIO_URL, e_audioURLReady);
				audio_by_name.removeEventListener(APIEvent.AUDIO_CACHED, e_audioCached);
			}
			if (ai_by_php != null)
			{
				//trace("Show - destroy - ai_by_php");
				ai_by_php.removeEventListener(APIEvent.AI_COMPLETE, e_aiComplete);
				ai_by_php = null;
			}
			if (bg_by_name != null)
			{
				//trace("Show - destroy - bg_by_php");
				bg_by_name.removeEventListener(APIEvent.BG_URL, e_bgUrlReady);
				bg_by_name = null;
			}
			if (lead_sender != null)
			{
				//trace("Show - destroy - lead_sender_php");
				lead_sender.removeEventListener(DataLoaderEvent.ON_DATA_READY, e_leadSent);
				lead_sender = null;
			}
			/*if (gaze_ctrl != null)
			{
				//trace("Show - destroy - gaze_ctrl");
				gaze_ctrl.destroy();
				gaze_ctrl = null;
			}*/
			if (link_timer != null)
			{
				//trace("Show - destroy - link_timer");
				link_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_openSceneLink);
				link_timer = null;
			}
			if (bad_word_filter != null)
			{
				//trace("Show - destroy - bad_word_filter");
				bad_word_filter.destroy();
				bad_word_filter = null;
			}
			/*if (comm_component_btn != null)
			{
				//trace("Show - destroy - com_component_btn");
				comm_component_btn.removeEventListener(MouseEvent.CLICK, e_launchCommComponent);
				comm_component_btn = null;
			}*/
			if (watermark_holder != null)
			{
				//trace("Show - destroy - watermark_holder");
				watermark_holder.removeEventListener(AssetEvent.ASSET_INIT, e_assetLoaded);
				try
				{
					watermark_holder.destroy();
				}
				catch ($e:*){}
				watermark_holder = null;
			}
			show_data = null;
			scene_data = null;
			host_data = null;
			bg_data = null;
			link_data = null;
			if (vhss_shared_object != null)
			{
				try
				{
					vhss_shared_object.destroy();
				}
				catch ($e:*){}
				vhss_shared_object = null;
			}
			
			//while(masked_items_holder.numChildren > 0) masked_items_holder.removeChildAt(0);
			//while(this.numChildren > 0) removeChildAt(0);
		}
		
		private function removeAllDOCs($doc:DisplayObjectContainer):void
		{
			trace("REMOVE ALL DOCS - SLIDESHOW");
			while ($doc.numChildren > 0)
			{
				if ($doc.getChildAt(0) is DisplayObjectContainer && DisplayObjectContainer($doc.getChildAt(0)).numChildren > 0)
				{
					removeAllDOCs(DisplayObjectContainer($doc.getChildAt(0)));
				}
				$doc.removeChildAt(0);
			}
		}
	}
}