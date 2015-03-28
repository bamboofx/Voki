package com.voki.vhss {

	import com.oddcast.assets.structures.*;
	import com.oddcast.audio.CachedTTS;
	import com.oddcast.event.*;
	import com.oddcast.player.*;
	import com.oddcast.utils.ErrorReportingLoader;
	import com.oddcast.utils.ErrorReportingURLLoader;
	import com.oddcast.utils.XMLLoader;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import com.voki.vhss.api.*;
	import com.voki.vhss.api.requests.*;
	import com.voki.vhss.dataHandler.PlayerXMLHandler;
	import com.voki.vhss.dataHandler.VSPlayerXMLHandler;
	import com.voki.vhss.events.*;
	import com.voki.vhss.playback.*;
	import com.voki.vhss.structures.*;

	[SWF(width='400', height='300', backgroundColor='#ffffff', frameRate='12')]

	/**
	 * Dispatched with a successful response from sayAIResponse. The response is contained in the <code>data</code> parameter of the event.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.AI_RESPONSE
	 */
	[Event("vh_aiResponse", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched with a successful response from loadAudio. The name is contained in the <code>data</code> parameter of the event.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.AUDIO_LOADED
	 */
	[Event("vh_audioLoaded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched at the interval in the setStatus method. The percent loaded is contained in the <code>data</code> parameter of the event.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.AUDIO_PROGRESS
	 */
	[Event("vh_audioProgress", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when a audio is done. If the host is saying a sequence of audios the event will dispatch with the end of each audio.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.AUDIO_ENDED
	 */
	[Event("vh_audioEnded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when a audio starts. If the host is saying a sequence of audios the event will dispatch with the start of each audio.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.AUDIO_STARTED
	 */
	[Event("vh_audioStarted", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched with a successful call to <code>loadBackgroud</code>.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.BG_LOADED
	 */
	[Event("bg_loaded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when the host is loaded and ready for interaction.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.CONFIG_DONE
	 */
	[Event("config_done", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when the engine is successfully loaded.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.ENGINE_LOADED
	 */
	[Event("engine_loaded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when all elements of scene are loaded and displayed
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.SCENE_LOADED
	 */
	[Event("scene_loaded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when all elements of scene are preloaded.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.SCENE_PRELOADED
	 */
	[Event("scene_preloaded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched after successful call to <code>loadSkin</code>
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.SKIN_LOADED
	 */
	[Event("skin_loaded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when the host finishes speaking. If audios are queued the event is dispatched all audios in the queue are complete.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.TALK_ENDED
	 */
	[Event("talk_ended", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when the host starts speaking.
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.TALK_STARTED
	 */
	[Event("talk_started", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched after successful call to <code>loadText</code>
	 * 
	 * @eventType com.oddcast.event.VHSSEvent.TTS_LOADED
	 */
	[Event("tts_loaded", type="com.oddcast.event.VHSSEvent")]
	/**
	 * Dispatched when the player is ready to accept api calls
	 * 
	 * @eventType com.oddcast.event.VHSSEVENT.PLAYER_READY
	 */
	 [Event("player_ready", type="com.oddcast.event.VHSSEvent")]


	/**
	 * 
	 * 
	 * The document class of the VHSS v5 player.
	 */
	public class VideostarVHSSPlayer extends MovieClip implements IInternalPlayerAPI
	{		
		//-o "V:\vhost.dev.oddcast.com\vhss_v5.swf"
		
		//-o "C:\video_package\vhss_media_2d\vhss_v5_vid.swf"
		
		private static var allowed_domains:Array = new Array(
													"vhss-c.oddcast.com", 
													"vhss-a.oddcast.com", 
													"vhss.oddcast.com", 
													"www.oddcast.com", 
													"vhost.oddcast.com", 
													"vhost.staging.oddcast.com", 
													"www2.staging.oddcast.com", 
													"content.staging.oddcast.com", 
													"l-char.dev.oddcast.com", 
													"l-char.oddcast.com",
													"char.dev.oddcast.com",
													"char.oddcast.com",
													"vhss-vd.oddcast.com",
													"vhss-vs.oddcast.com"
													);
		private var flash_vars:Object;
		private var vhss_stage:Stage;
		private var show:VSShowController;
		private var tts_creator:CachedTTS;
		private var tts_cacher:CacheAudioQueue;
		private var load_xml_timer:Timer;
		private var context_menu:ContextMenu;
		private var cached_doc_req:CachedSceneStatus;
//		private var de_monster_dbg:MonsterDebugger; // NOTE: Dave's personal utility
		private var output_tf:TextField;
		private var show_domain_error:Boolean = true;

		
		//private var manager:IBrowserManager;
		
		//public static var debug_function:Function;
		
		/* public function setDebugFunction(fn:Function):void
		{
			debug_function = fn;
		} */
		
		public function VideostarVHSSPlayer()
		{
			try
			{
				Security.allowDomain("*");
			}catch($error:*)
			{
				traceTxt("VHSS V5 - ERROR - allowDomain restriction");
			}
//			de_monster_dbg = new MonsterDebugger(this); // NOTE: Dave's personal utility
			var t_time:String = Constants.VHSS_PLAYER_DATE;

			if (this.loaderInfo == null || this.loaderInfo.url == null)
			{
//				MonsterDebugger.trace(this, "VHSS V5 --- " + t_time + " listener  url " + this.loaderInfo.url+" dev version"); // NOTE: Dave's personal utility
				traceTxt("VHSS V5 --- " + t_time + " listener  url " + this.loaderInfo.url+" dev version");
				this.loaderInfo.addEventListener(Event.COMPLETE, init);
			}
			else
			{
//				MonsterDebugger.trace(this, "VHSS V5 --- " + t_time + " direct    url " + this.loaderInfo.url); // NOTE: Dave's personal utility
				traceTxt("VHSS V5 --- " + t_time + " direct    url " + this.loaderInfo.url);
				init();
			}
		}
		
		
		private function prog($e:ProgressEvent):void
		{
			//trace("PROGRESS --- "+$e.bytesLoaded+" of "+$e.bytesTotal);
		}
		
		/*private function onBrowserChange(event:BrowserChangeEvent):void
		{
			
		}*/
		
		private function _loadConfig():void
		{
			var _info:LoaderInfo = LoaderInfo(this.loaderInfo);
			// if config url passed in loader info parameters, use it, otherwise try the default vhss_config_url
			var configUrl:String;
			if (_info.parameters.config) {
				configUrl = _info.parameters.config;
			} else {
				// change Constants.VHSS_CONFIG_URL according to loaderInfo.url to reflect dev/shadow/live and ssl vs nonsecure
				configUrl = Constants.buildConfigUrl(_info.url);
			}
			var configLoader:URLLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, onConfigComplete);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, onConfigError);
			configLoader.addEventListener(IOErrorEvent.NETWORK_ERROR, onConfigError);
			configLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onConfigError);
			configLoader.load(new URLRequest(configUrl));
			
			function onConfigComplete(event:Event):void
			{
				configLoader.removeEventListener(Event.COMPLETE, onConfigComplete);
				configLoader.removeEventListener(IOErrorEvent.IO_ERROR, onConfigError);
				configLoader.removeEventListener(IOErrorEvent.NETWORK_ERROR, onConfigError);
				configLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onConfigError);
				
				Constants.parseConfiguration(new XML(event.target.data));
				_continueInit();
			}
			
			function onConfigError(event:Event):void
			{
				configLoader.removeEventListener(Event.COMPLETE, onConfigComplete);
				configLoader.removeEventListener(IOErrorEvent.IO_ERROR, onConfigError);
				configLoader.removeEventListener(IOErrorEvent.NETWORK_ERROR, onConfigError);
				configLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onConfigError);
				_continueInit(); // todo error out or something, for now we'll just let it continue since i haven't removed any of the old values from constants, so it will still work, just won't be as dynamic with the config xml
			}
		}
		private function init($e:Event = null):void
		{
			var _info:LoaderInfo = LoaderInfo(this.loaderInfo);
			_info.removeEventListener(Event.INIT, init);
			_loadConfig();
		}
		private function _continueInit():void
		{
			var _info:LoaderInfo = LoaderInfo(this.loaderInfo);
			Constants.PLAYER_CONTEXT = _info.url;
			try
			{
				context_menu = new ContextMenu();
				var t_cm_i:ContextMenuItem = new ContextMenuItem("VHSS player ver. " + Constants.VHSS_PLAYER_VERSION, true);
				context_menu.hideBuiltInItems();
				context_menu.customItems.push(t_cm_i);
				contextMenu = context_menu;
			}
			catch (error:Error){}
			Constants.FLASH_PLAYER_VERSION = Capabilities.version.split(" ")[1];
			var t_versions:Array = Capabilities.version.split(" ")[1].split(",");
			if(t_versions[0] == 9 && t_versions[2] < 115 && _info.url.indexOf("file")!= 0 && _info.loaderURL.indexOf("file") != 0)
			{
				showUpdateMessage();
			}
			else
			{
				var _isAvailable:Boolean = ExternalInterface.available;
				var _t_pd:String;
				var _t_ar:Array;
				if (_info.loaderURL != _info.url)
				{
					if (_info.loaderURL.indexOf("app:/") == 0)
					{
						
						Constants.PAGE_DOMAIN = _info.loaderURL.split("/").join("");
						Constants.TRACKING_EMBED_ID = "7";
					}
					else
					{
						_t_ar = _info.loaderURL.split("://");
						Constants.PAGE_DOMAIN = _t_ar[_t_ar.length - 1].split("/")[0].split(":")[0];
						Constants.TRACKING_EMBED_ID = "6";	
					}
					setErrorReportingVars(_info.loaderURL);
					traceTxt("VHSS V5 ---  page domain : "+Constants.PAGE_DOMAIN);
				}
				else if (_isAvailable)
				{
					try 
					{
						_t_pd = ExternalInterface.call("eval", "location.href");
					}
					catch ($err:Error)
					{
						//----trace("VHSS V5 --- ERROR CAN'T GET PLAYER DOMAIN");
					}
					if (_t_pd == null) _t_pd = "";
					_t_ar = _t_pd.split("://");
					Constants.PAGE_DOMAIN = _t_ar[_t_ar.length - 1].split("/")[0].split(":")[0];
					setErrorReportingVars(_t_pd);
					//trace("VHSS v5 -- js interface --- ");
					JSInterface.initJSAPI(this);
					traceTxt("VHSS v5 -- page domain : "+Constants.PAGE_DOMAIN);
				}
				
				vhss_stage = this.stage;
				flash_vars = _info.parameters;
				if (flash_vars["pageDomain"] != null) allowed_domains.push(flash_vars["pageDomain"]);
				if (Constants.PAGE_DOMAIN != null) allowed_domains.push(Constants.PAGE_DOMAIN);
				allowDomains(allowed_domains);
				if (flash_vars["emb"] != null) Constants.TRACKING_EMBED_ID = flash_vars["emb"];
				if (flash_vars != null && flash_vars["doc"] != null)
				{
					if (flash_vars["embedid"] != null)
					{
						Constants.EMBED_ID = flash_vars["embedid"];
					}
					if (_info.url.indexOf("oddcast.com/vhss") != -1)// && _info.url.indexOf("https") != 0)
					{
						cached_doc_req = new CachedSceneStatus(flash_vars["doc"]);
						cached_doc_req.addEventListener(Event.COMPLETE, e_gotSceneStatus);
					} 
					else
					{
						loadShowXML(flash_vars["doc"]);	
					}
				}
				else if (!Constants.SUPPRESS_EXPORT_XML)
				{
					load_xml_timer = new Timer(200, 1);
					load_xml_timer.addEventListener(TimerEvent.TIMER, loadLocalXML);
					load_xml_timer.start();
				}
			}
			dispatchEvent(new VHSSEvent(VHSSEvent.PLAYER_READY));
		}
		
		private function setErrorReportingVars(loading_str:String):void
		{
			try
			{
				ErrorReportingLoader.ERROR_REPORTING_ACTIVE = Constants.ERROR_REPORTING_ACTIVE;
				ErrorReportingURLLoader.ERROR_REPORTING_ACTIVE = Constants.ERROR_REPORTING_ACTIVE;
				if (Constants.ERROR_REPORTING_ACTIVE)
				{
					ErrorReportingLoader.PAGE_DOMAIN = loading_str;
					ErrorReportingURLLoader.PAGE_DOMAIN = loading_str;
					ErrorReportingURLLoader.PLAYER_URL = LoaderInfo(this.loaderInfo).url;
				}
				
			}
			catch (error:Error){}
		}
		
		private function loadLocalXML($te:TimerEvent = null):void
		{
			load_xml_timer.stop();
			var t_url:String = loaderInfo.url;
			t_url = t_url.split("\\").join("/"); // replace backslash with slash
			Constants.RELATIVE_URL = t_url.substring(0, t_url.lastIndexOf("/")+1);
			//----trace("VHSS -- NO DOC PARAMETER SET -||- use play scene "+loaderInfo.url);
			loadShowXML(Constants.RELATIVE_URL + Constants.EXPORT_XML);
		}
		
		private function allowDomains($in_ar:Array):void
		{
			for (var i:uint=0; i < $in_ar.length; i++)
			{
				try
				{
					Security.allowDomain($in_ar[i]);
					Security.allowInsecureDomain($in_ar[i]);
				}catch($error:*)
				{
					trace("ERROR - allowDomain restriction");
				}
			}
		}
		
		private function onShowXmlReady($xml:XML):void///$event:DataLoaderEvent):void
		{
			//trace("VHSS V5 --- Show xml Ready  swfversion ");//+this.loaderInfo.swfVersion);
			var t_alert:AlertEvent = XMLLoader.checkForAlertEvent();
			if (t_alert != null)
			{
				var t_str:String = "";
				if (t_alert.moreInfo != null && t_alert.moreInfo.details != null) t_str = t_alert.moreInfo.details;
				traceTxt("VHSS V5 xml error -- " + t_str);
				dispatchEvent(new VHSSEvent(VHSSEvent.PLAYER_XML_ERROR));
			}
			else
			{
				setShowXML($xml);
				startShow();
			}
		}
		
		protected function setShowListeners():void
		{
			show.addEventListener(VHSSEvent.SCENE_LOADED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.TALK_ENDED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.TALK_STARTED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.CONFIG_DONE, e_dispatchEvent);
			show.addEventListener(VHSSEvent.AUDIO_LOADED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.BG_LOADED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.SKIN_LOADED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.ENGINE_LOADED, e_dispatchEvent);
			show.addEventListener(APIEvent.AI_COMPLETE, e_aiResponse);
			show.addEventListener(VHSSEvent.SCENE_PRELOADED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.AUDIO_ENDED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.AUDIO_STARTED, e_dispatchEvent);
			show.addEventListener(VHSSEvent.MODEL_LOAD_ERROR, e_dispatchEvent);
			show.addEventListener(VHSSEvent.AUDIO_ERROR, e_dispatchEvent);
			show.addEventListener(VHSSEvent.SCENE_PLAYBACK_COMPLETE, e_dispatchEvent);
		}
		
		private function stopExpXMLTimer():void
		{
			if (load_xml_timer != null)
			{
				load_xml_timer.stop();
				load_xml_timer.removeEventListener(TimerEvent.TIMER, loadLocalXML);
			}
		}

		private function showUpdateMessage():void
		{
			var t_mc:MovieClip = new MovieClip();
			var tf_need_update:TextField = new TextField();
			var t_format:TextFormat = new TextFormat();
			addChild(t_mc);
			t_mc.addChild(tf_need_update);
			t_mc.graphics.beginFill(0xff00ff, 0);
			t_mc.graphics.drawRect(0, 0, 400, 300);
			t_mc.buttonMode = true;
			t_mc.useHandCursor = true;
			t_mc.mouseChildren = false;
			tf_need_update.htmlText = "<b>Flash version 9.0.115 or greater is required to view this content\n\n<font color='#0000FF'><u>Click here</u></font> to update to the latest version</b>";
			tf_need_update.width = 160;
			tf_need_update.height = 300;
			tf_need_update.antiAliasType = AntiAliasType.ADVANCED;
			tf_need_update.multiline = true;
			tf_need_update.wordWrap = true;
			tf_need_update.selectable = false;
			tf_need_update.autoSize = TextFieldAutoSize.CENTER;
			tf_need_update.x = 400/2 - tf_need_update.width/2;
			tf_need_update.y = 300/2 - tf_need_update.height/2;
			t_format.align = "center";
			t_format.size = 16;
			tf_need_update.setTextFormat(t_format);
			t_mc.addEventListener(MouseEvent.CLICK, e_updateFlash);
		}

		// Internal API
		// Stop the default xml from loading or force it to load immediately. There is a 200 ms window after the PLAYER_LOADED event to stop the default xml from loading.
		public function useDefaultXML($b:Boolean):void
		{
			if (!$b)
			{
				stopExpXMLTimer();
			}
			else
			{
				loadLocalXML();
			}
		}
		
		public function loadShowXML($in_doc:String):void
		{
			stopExpXMLTimer();
			XMLLoader.loadXML($in_doc, onShowXmlReady);
		}
		
		public function loadHost($host:HostStruct):void
		{
			//----trace("VHSS V4 --------- load host  id: " + $host.url);
			var _hs:HostStruct = new HostStruct($host.url,  $host.id, $host.type);
			if ($host.cs != null) _hs.cs = $host.cs;
			_hs.engine.url = $host.engine.url;
			_hs.engine.type = $host.engine.type;
			_hs.engine.id = $host.engine.id;
			show.loadHost(_hs, true);
		}
		
		public function initBlankShow():void
		{
			if (show == null)
			{ 
				show = new VSShowController(new SlideShowStruct());
				startShow();
			}
		}
		
		public function loadBackground($bg:BackgroundStruct):void
		{
			if ($bg == null) $bg = new BackgroundStruct();
			show.loadBg($bg, true);
		}
		public function loadBackgroundWithTransform(background:BackgroundStruct, transform:Object):void
		{
			if (!background)
				background = new BackgroundStruct();
			show.loadBg(background, true, transform);
		}
		
		public function loadSkin($skin:SkinStruct):void
		{
			if ($skin == null) $skin = new SkinStruct();
			show.loadSkinFromAPI($skin, true);
		}
		
		public function setSkinConfig($xml:XML):void
		{
			show.setSkinConfig($xml);
		}
		
		public function getShowXML():XML
		{
			return show.getShowXML();
		}
		
		public function getAudioUrl():String
		{
			return show.getAudioUrl();
		}
		
		public function setHostPosition($xpos:int, $ypos:int, $scale:int):void
		{
			show.setHostPosition($xpos, $ypos, $scale);
		}
		
		public function getActiveEngineAPI():Object
		{
			return show.getActiveEngineAPI();
		}
		
		public function getHostHolder():Sprite
		{
			return show.getHostHolder();
		}
		
		public function getBGHolder():Sprite
		{
			return show.getBGHolder();
		}
		
		public function setSceneAudio($as:AudioStruct):void
		{
			show.setSceneAudio($as);
		}
		
		public function setPlayerInitFlags($i:int):void
		{
			//trace("VHSS v5 -- setPlayerInitFlags -- value "+$i);
			if ($i & PlayerInitFlags.IGNORE_PLAY_ON_LOAD) Constants.SUPPRESS_PLAY_ON_LOAD = true;
			if ($i & PlayerInitFlags.TRACKING_OFF) Constants.SUPPRESS_TRACKING = true;
			if ($i & PlayerInitFlags.SUPPRESS_PLAY_ON_CLICK) Constants.SUPPRESS_PLAY_ON_CLICK = true;
			if ($i & PlayerInitFlags.SUPPRESS_EXPORT_XML)
			{
				Constants.SUPPRESS_EXPORT_XML = true;
				stopExpXMLTimer();
			}
			if ($i & PlayerInitFlags.SUPPRESS_3D_OFFSET) Constants.USE_3D_OFFSET = false;
			if ($i & PlayerInitFlags.SUPPRESS_LINKS) Constants.SUPPRESS_LINK = true;
			try
			{
				if ($i & PlayerInitFlags.SUPPRESS_AUTO_ADV) Constants.SUPPRESS_AUTO_ADV = true;
			}
			catch($e:*){}
		}
		
		public function setShowXML($xml:XML):void
		{
			if ($xml.name().toString().toUpperCase() == "ERROR")
			{
				var t_error_loader:Loader = new Loader();
				addChild(t_error_loader);
				t_error_loader.load(new URLRequest($xml.@URL));
				dispatchEvent(new VHSSEvent(VHSSEvent.PLAYER_DATA_ERROR, "VHSS PLAYER:: xml load error"));
			}
			else
			{
				var _xml_handler:VSPlayerXMLHandler = new VSPlayerXMLHandler($xml);
				if (_xml_handler.getErrorFile() == null)
				{
					var _ss_data:SlideShowStruct = _xml_handler.getShowData();
					if (flash_vars == null || flash_vars["bgcolor"] == null)
					{
						show = new VSShowController(_ss_data);
					}
					else
					{
						show = new VSShowController(_ss_data, flash_vars["bgcolor"]);
					}
				}
				else
				{
					var t_loader:Loader = new Loader();
					addChild(t_loader);
					t_loader.load(new URLRequest(_xml_handler.getErrorFile()));
					dispatchEvent(new VHSSEvent(VHSSEvent.PLAYER_DATA_ERROR, "VHSS PLAYER:: account error")); 
				}
			}	
		}
		
		public function set3DSceneSize($w:int, $h:int):void
		{
			//show.set3DSceneSize($w, $h);
		}
		
		public function startShow():void
		{
			//traceTxt("vhss v5 --- start show");
			if (show != null)
			{
				setShowListeners();
				addChild(show);
				show.init();
				//traceTxt("vhss v5 -- init done");
			}
			/*var tmp_mc:MovieClip = new MovieClip();
			tmp_mc.graphics.beginFill(0xff0000);
			tmp_mc.graphics.lineStyle(2, 0xff00ff);
			tmp_mc.graphics.drawCircle(0, 0, 100);
			this.addChild(tmp_mc);*/
		}
		
		public function displayBgFrame(offset:Number = 0):void
		{
			if (show != null)
			{
				show.displayBgFrame(offset);
			}
		}
		
		// ------------ PUBLIC API- 
		
		// FACIAL API ---
		public function followCursor($mode:Number):void
		{
			show.followCursor($mode);
		}
		
		public function freezeToggle():void
		{
			show.freezeToggle();
		}
		
		public function recenter():void
		{
			show.getHostHolder().recenter();
		}
		
		// deprecated because "setExpression" is reserved in IE
		public function setExpression($id:Number, $duration:Number, $intensity:Number = 100, $attack:Number = 0, $decay:Number = 0):void
		{
			setFacialExpression($id, $duration, $intensity, $attack, $decay)
		}
		
		public function setFacialExpression($id:*, $duration:Number, $intensity:Number = 100, $attack:Number = 0, $decay:Number = 0):void
		{
			//trace("VHSS-v5 setfacialExpression "+$id);
			if ($duration > 0)  $duration *= 1000;
			if (isNaN($intensity) || $intensity <= 0 || $intensity > 100) $intensity = 100;
			show.setFacialExpression($id, $duration, ($intensity/100), ($attack*1000), ($decay*1000));
		}
		
		public function setGaze($degrees:Number, $duration:Number, $radius:Number = 100, $page_req:Number = 0):void
		{
			//trace("SET GAZE -- deg: ");//+$degrees+" $dur: "+$duration+" $rad: "+$radius+" $page: "+$page_req+" (show): "+(show)+"  setgaze: "+(show.setGaze));
			if ($degrees == 0) $degrees = 360;
			if (show && $degrees && $duration) show.setGaze($degrees, $duration, $radius, $page_req);
		}
	
		public function setIdleMovement(frequency:int = 50, radius:int = 50):void
		{
			if (show)
			{
				if (frequency == 0 || radius == 0)
				{
					show.setRandomMovement("0");
				}
				else
				{
					show.setRandomMovement("1");
				}
				var freq:Number  = Math.min(Math.max(0, frequency), 100) * .01;
				var rad:Number = Math.min(Math.max(0, radius), 100) * .01;
				show.setRandomMovementParameters(freq, rad);
			}
		}
		
		public function setSpeechMovement(amp:int = 50):void
		{
			var _amp:Number = Math.max(Math.min(amp, 100), 0) * .01; 
			show.setSpeechMovement(_amp);
		}
		
		// --- FACIAL API
		
		// --- SCENE API
		public function setStatus($interrupt:Number = 0, $progressInterval:Number = 0, $gazeSpeed:Number = -1, $randomMoves:Number = -1):void
		{
			//----trace("VHSS PLAYER setStatus  interrupt: "+$interrupt+" progInt: "+$progressInterval+" gaze: "+$gazeSpeed+" rand: "+$randomMoves);			
			show.setInterrupt($interrupt);
			show.getHostHolder().setProgressInterval($progressInterval);
			if ($progressInterval > 0)
			{
				show.getHostHolder().addEventListener(VHSSEvent.AUDIO_PROGRESS, e_dispatchEvent);
			}
			else
			{
				show.getHostHolder().removeEventListener(VHSSEvent.AUDIO_PROGRESS, e_dispatchEvent);
			}
			if ($gazeSpeed == 0 || $gazeSpeed == 1 || $gazeSpeed == 2) show.setLookSpeed($gazeSpeed.toString());
			if ($randomMoves == 0 || $randomMoves == 1) show.setRandomMovement($randomMoves.toString());
		}
		
		public function setBackground($name:String):void
		{
			show.setBackground(new APIRequest($name));
		}
		
		public function setColor($part:String, $color:String):void
		{
			var _valid:Boolean = true;
			for (var i:int = 0; i < $color.length; ++i)
			{
				if (isNaN(parseInt($color.charAt(i), 16)))
				{
					_valid = false;
					break;
				}
			}
			if (_valid) show.setColor($part, parseInt($color, 16));
		}
		
		public function setLink($url:String, $target:String = "_blank"):void
		{
			var t_ls:LinkStruct = new LinkStruct();
			t_ls.url = $url;
			t_ls.target = $target;
			show.setLink(t_ls);
		}
		
		public function is3D():Boolean
		{
			//trace("VHSS V5 -- is3D!!!!!!!");
			try
			{
				var t_api:Object = show.getActiveEngineAPI();
				return (getQualifiedClassName(t_api) != "EngineV5");
			}
			catch (e:Error)
			{
				return false;
			}
			return false;
		}
		
		// --- SCENE API 

		
		// SPEECH API ---
		public function loadAudio($name:String):void
		{
			show.sayByName(new APIAudioRequest($name, 0, true));
		}
		
		public function loadText($text:String, $voice:String, $lang:String, $engine:String, $fx_type:String="", $fx_level:String="", $origin:String = ""):void
		{
			if ($text.length > 0 && $voice.length > 0 && $lang.length > 0 && $engine.length > 0)
			{
				if (this.loaderInfo.url.indexOf("oddcast") != -1 && Constants.IS_ENABLED_DOMAIN)
				{
					$text = unescape($text);
					CachedTTS.setDomain(Constants.TTS_DOMAIN);
					if (Constants.IS_FILTERED) $text = show.filterTTS($text, $lang);
					var t_url:String = CachedTTS.getTTSURL($text, parseInt($voice), parseInt($lang), parseInt($engine), $fx_type, parseInt($fx_level));
					if (tts_cacher == null)
					{
						tts_cacher = new CacheAudioQueue();
					}
					var t_req:APIAudioRequest = new APIAudioRequest($text, 0, true);
					t_req.url = t_url;
					tts_cacher.addEventListener(APIEvent.AUDIO_CACHED, e_ttsCached);
					tts_cacher.load(t_req);
				}
				else 
				{
					if (show_domain_error)
					{
						show_domain_error = false;
						try
						{
							ExternalInterface.call("vhssError", "The scene is embedded on a domain that is not enabled in your account.");
						}
						catch (error:Error){}
					}
					throw new Error("The scene is embedded on a domain that is not enabled in your account.");
				}
			}
		}
		
		public function sayAudio($name:String, $start:Number = 0):void
		{
			if (isNaN($start)) $start = 0;
			$start = Math.max($start, 0);
			show.sayByName(new APIAudioRequest($name, $start));
		}
		
		public function sayText($text:String, $voice:String, $lang:String, $engine:String, $fx_type:String="", $fx_level:String="", $origin:String = ""):void
		{
			//trace("VHSS PLAYER saytext domain: "+Constants.PAGE_DOMAIN+" api enabled: "+Constants.IS_ENABLED_DOMAIN+" text:: "+$text+" voice: "+$voice+" lang: "+$lang+" eng: "+$engine);
			$text = decodeURI($text);
			if ($text.length > 0 && $voice.length > 0 && $lang.length > 0 && $engine.length > 0)
			{
				if (this.loaderInfo.url.indexOf("oddcast") != -1 && Constants.IS_ENABLED_DOMAIN)
				{
					show.sayText(new APITTSRequest(unescape($text), $voice, $lang, $engine, $fx_type, $fx_level));
				}
				else 
				{
					
 					if (show_domain_error)
					{
						show_domain_error = false;
						try
						{
							ExternalInterface.call("vhssError", "The scene is embedded on a domain that is not enabled in your account.");
						}
						catch (error:Error){}
					}
					throw new Error("The scene is embedded on a domain that is not enabled in your account.");
				}
			}
		}
		
		public function sayAIResponse($text:String, $voice:String, $lang:String, $engine:String, $bot:String = "0", $fx_type:String="", $fx_level:String="", $origin:String = ""):void
		{
			$text = decodeURI($text);
			if ($text.length > 0 && $voice.length > 0 && $lang.length > 0 && $engine.length > 0)
			{
				if (this.loaderInfo.url.indexOf("oddcast") != -1 && Constants.IS_AI_ENABLED)
				{
					show.sayAIResponse(new APIAIRequest($text, $voice, $lang, $engine, $bot, $fx_type, $fx_level));
				}
			}
		}
		
		/**
		 * Sets the volume for all audios, hosts, and other sounds originating from the VHSSPlayer or its children engines.
		 * Does not interfere with or affect SoundMixer.soundTransform, in case Flash player global sound control is not desired.
		 * @param	$vol	Range between [0, 10]
		 */
		public function setPlayerVolume($vol:Number):void
		{
			$vol = Constants.VOLUME_RANGE_PLAYER.clamp($vol);//Math.max(0, Math.min(10, $vol));
			// now that we've allowed users to pass [0, 10], let's continue using normalized values in our code
			show.setVolume($vol / Constants.VOLUME_RANGE_PLAYER.max); // [0, 1]
		}
		
		public function sayTextExported($text:String, $voice:String, $lang:String, $engine:String, $fx_type:String = "", $fx_level:String = "", $origin:String = ""):void
		{
			$text = decodeURI($text);
			if ($text.length > 0 && $voice.length > 0 && $lang.length > 0 && $engine.length > 0)
			{
				if (Constants.IS_ENABLED_DOMAIN)
				{
					show.sayText(new APITTSRequest(unescape($text), $voice, $lang, $engine, $fx_type, $fx_level));
				}
				else 
				{
					if (show_domain_error)
					{
						show_domain_error = false;
						try
						{
							ExternalInterface.call("vhssError", "The scene is embedded on a domain that is not enabled in your account.");
						}
						catch (error:Error){}
					}
					throw new Error("The scene is embedded on a domain that is not enabled in your account.");
				}
			}
		}
		
		public function sayAudioExported($name:String, $start:Number = 0):void
		{
			//----trace("VHSS PLAYER  sayAudioExported name: "+$name);
			show.sayByNameExported(new APIAudioRequest($name, $start));
		}

		public function sayByUrl($url:String):void
		{
			show.sayAudio($url);
		}
		
		public function sayMultiple($audios:Array):void
		{
			show.sayMultiple($audios);
		}
		
		public function saySilent($seconds:Number):void
		{
			show.getHostHolder().saySilent($seconds);
		}
		
		public function setPhoneme($phoneme:String):void
		{
			show.getHostHolder().setPhoneme($phoneme);
		}
		
		public function stopSpeech():void
		{
			if (show)
			{
				show.stopSpeech();
			}
		}
		
		public function replay($force_replay:Number = 0):void
		{
			show.replay(($force_replay == 1));
		}
		/*
		public function getCharacterSound():Sound
		{
			return show.getCharacterSound();
		}
		
		public function getCharacterSoundChannel():SoundChannel
		{
			return show.getCharacterSoundChannel();
		}*/
		// --- SPEECH API
		
		// NAVIGATION API ---
		public function gotoPrevScene():void
		{
			show.gotoPrevScene();
		}
		
		public function gotoScene($scene:Object):void//$scene:uint):void
		{
			//----trace("VHSS Player -- gotoScene -- "+$scene);
			if (String($scene).indexOf("-") != -1)
			{
				var t_ar:Array = String($scene).split("-");
				var t_n1:uint = parseInt(t_ar[0]);
				var t_n2:uint = parseInt(t_ar[1]);
				var t_n3:Number = uint(Math.random()*(t_n2-t_n1+1))+t_n1;
				show.gotoScene(t_n3);
			}
			else
			{
				show.gotoScene(uint($scene));
			}
		}
			
		public function gotoNextScene():void
		{
			show.gotoNextScene();
		}
			public function preloadNextScene():void
		{
			show.preloadNextScene();
		}
		
		public function preloadScene($num:Number):void
		{
			show.preloadScene(int($num - 1));
		}
		
		public function setNextSceneIndex($scene:Object):void
		{
			//----trace("VHSS Player -- setNextSceneIndex -- "+$scene);
			if (String($scene).indexOf("-") != -1)
			{
				var t_ar:Array = String($scene).split("-");
				var t_n1:uint = parseInt(t_ar[0]);
				var t_n2:uint = parseInt(t_ar[1]);
				var t_n3:Number = uint(Math.random()*(t_n2-t_n1+1))+t_n1;
				show.setNextSceneIndex(t_n3);
			}
			else
			{
				show.setNextSceneIndex(uint($scene));
			}
		}
		
		public function loadScene($scene:int):void
		{
			//----trace("VHSS Player -- loadScene : "+$scene);
			if (flash_vars != null && flash_vars["doc"] != null)
			{
				//trace("DESTROY API START");
				show.destroy();
				//trace("DESTROY API  PART 1");
				//----trace("VHSS Player - loadScene -- "+flash_vars["doc"]+"/ind="+$scene);
				loadShowXML(flash_vars["doc"]+"/ind="+$scene);
				//trace("DESTROY API END");	
			}
		}
		
		public function loadShow($scene:int):void
		{
			loadScene($scene);
		}
		
		// --- NAVIGATION API
		// PUBLIC API ------------
		
		// Event Handlers
		private function e_gotSceneStatus($e:Event):void
		{
			loadShowXML(cached_doc_req.doc);
			cached_doc_req.removeEventListener(Event.COMPLETE, e_gotSceneStatus);
			cached_doc_req = null;
		}
		
		
		protected function e_dispatchEvent($e:VHSSEvent):void
		{
			//trace("VHSS PLAYER -- DISPATCH -- "+$e.toString());
			dispatchEvent($e);
		}
		
		protected function e_ttsCached($e:APIEvent):void
		{
			//----trace("VHSS PLAYER -- DISPATCH -- "+$e.toString());
			try
			{
				ExternalInterface.call("VHSS_Command", "vh_ttsLoaded", APIAudioRequest($e.data).name );
			}
			catch($e:Error)
			
			{
				//----trace("VHSS PLAYER -- ExternalInterface ERROR");
			}
			var t_ve:VHSSEvent = new VHSSEvent(VHSSEvent.TTS_LOADED);
			t_ve.data = APIAudioRequest($e.data).name;
			dispatchEvent(t_ve);
		}
		
		protected function e_aiResponse($e:APIEvent):void
		{
			var t_txt:String = (AIResponse($e.data).display_text.length > 0) ? escape(AIResponse($e.data).display_text) : escape(AIResponse($e.data).ai_request.name);
			//trace("VHSS V5 --- use display !!! "+ AIResponse($e.data).display_text.length);
			var t_tag:String = AIResponse($e.data).display_tag;
			if (t_tag != null && t_tag.length > 0) t_txt += "|"+t_tag;
			try
			{
				ExternalInterface.call("VHSS_Command", "vh_aiResponse", t_txt);
			}
			catch($e:Error)
			{
				//----trace("VHSS PLAYER -- ExternalInterface ERROR");
			}
			var t_ve:VHSSEvent = new VHSSEvent(VHSSEvent.AI_RESPONSE);
			t_ve.data = t_txt;
			dispatchEvent(t_ve); 
		}
		
		private function e_updateFlash($e:Event):void
		{
			//----trace("UPDATE LOADED");
			navigateToURL(new URLRequest("http://get.adobe.com/flashplayer/"), "_blank");
		}
		
		public function destroy():void
		{
			traceTxt("VHSS v5 -------- Destroy");
			this.loaderInfo.removeEventListener(Event.COMPLETE, init);
			if (load_xml_timer != null)
			{
				traceTxt("VHSS - destroy - load_xml_timer");
				load_xml_timer.removeEventListener(TimerEvent.TIMER, loadLocalXML);
			}
			if (tts_cacher != null)
			{
				traceTxt("VHSS - destroy - tts_cacher");
				tts_cacher.removeEventListener(APIEvent.AUDIO_CACHED, e_ttsCached);
			}
			if (cached_doc_req != null)
			{
				traceTxt("VHSS - destroy - cached_doc_req");
				cached_doc_req.removeEventListener(Event.COMPLETE, e_gotSceneStatus);
				cached_doc_req.destroy();
				cached_doc_req = null;
			}
			if (show != null)
			{
				traceTxt("VHSS - destroy - show");
				show.getHostHolder().removeEventListener(VHSSEvent.AUDIO_PROGRESS, e_dispatchEvent);
				show.destroy();
				show.removeEventListener(VHSSEvent.SCENE_LOADED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.TALK_ENDED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.TALK_STARTED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.CONFIG_DONE, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.AUDIO_LOADED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.BG_LOADED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.SKIN_LOADED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.ENGINE_LOADED, e_dispatchEvent);
				show.removeEventListener(APIEvent.AI_COMPLETE, e_aiResponse);
				show.removeEventListener(VHSSEvent.SCENE_PRELOADED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.AUDIO_ENDED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.AUDIO_STARTED, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.AUDIO_ERROR, e_dispatchEvent);
				show.removeEventListener(VHSSEvent.SCENE_PLAYBACK_COMPLETE, e_dispatchEvent);
				show = null;
				traceTxt("VHSS - destroy - show end");
			}
			XMLLoader.destroy();
		}
		
		public function setTextOutput(tf:TextField):void
		{
			//trace("vhss v5 -- set text field");
			output_tf = tf;
			//init();
		}
		
		private function traceTxt(str:String):void
		{
			if (output_tf) output_tf.appendText("\t-"+str+"\n");
			trace(str);
		}
	}
}
