package com.voki.player {
	import com.oddcast.assets.structures.AudioStruct;
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.EngineEvent;
	import com.oddcast.event.VHSSEvent;
	import com.oddcast.player.IInternalPlayerAPI;
	import com.oddcast.player.PlayerInitFlags;
	import com.oddcast.utils.MoveZoomUtil;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.vhost.ranges.RangeData;
	import com.voki.data.SPAudioList;
	import com.voki.data.SPBackgroundStruct;
	import com.voki.data.SPHostStruct;
	import com.voki.data.SPSkinStruct;
	import com.voki.data.SceneStruct;
	import com.voki.data.SessionVars;
	import com.voki.data.ShowStruct;
	import com.voki.data.SkinConfiguration;
	import com.voki.engine.EngineV5;
	import com.voki.processing.ASyncProcess;
	import com.voki.processing.ASyncProcessList;
	import com.voki.vhss.VHSSPlayerV5;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	/**
	 * ...
	 * @author Sam Myer
	 * @author Rob Gungor - 3/23/15
	 */
	public class PlayerController extends EventDispatcher {
		public var playerHolder:MovieClip;
		private var playerLoader:Loader;
		private var player:VHSSPlayerV5;
		private var curScene:SceneStruct;
		private var show:ShowStruct;
		private var isLoaded:Boolean = false;
		private var defaultEngine:EngineV5;
		private var showUrl:String;
		public var curSceneIndex:int = 1;
		
		private var _processList:ASyncProcessList;
		private var hostMoveZoom:MoveZoomUtil;
		
		private var charIdCounter:int = 0;
		private var modelCharIdArr:Array = new Array();
		
		public static const HOST_LOADED:String = "configDone";
		public static const HOST_INVISIBLE:String = "hostInvisible";
		public static const SCENE_LOADED:String = "sceneLoaded";
		public static const SKIN_LOADED:String = "skinLoaded";
		public static const SKIN_TYPE_CHANGED:String = "skinTypeChanged";
		public static const FREEZE_CLICKED:String = "playerFreezeClicked";
		public static const RESUME_CLICKED:String = "playerResumeClicked";
		public static const LOAD_ERROR:String = "playerAssetLoadError";
		
		public var loadModelInfo:Boolean = true;
		public var manualStopAudio:Boolean;
		private var loadingSkin:SPSkinStruct;
		private var manualLoadSkin:Boolean;
		
		public function PlayerController($playerHolder:MovieClip):void {
			playerHolder = $playerHolder;
			//defaultEngine = new EngineStruct("http://content.dev.oddcast.com/char/engines/engineV5.swf", 42, "2D");
			defaultEngine = new EngineV5();
			//playerHolder.addChild(defaultEngine);
			
			_processList = new ASyncProcessList();
		}
		
		public function get processList():ASyncProcessList {
			return(_processList);
		}
		
		public function init($showUrl:String):void {
			trace("SitepalV5::PlayerController::init showUrl="+$showUrl)
			showUrl = $showUrl;
			
			var url:String;
			//url= "http://content.dev.oddcast.com/vhss/vhss_v5.swf";
			url = SessionVars.playerURL;
			
			if (playerHolder.placeholder != null) playerHolder.removeChild(playerHolder.placeholder);
			
			//			playerLoader = new Loader();
			//			playerHolder.addChild(playerLoader);
			//			playerLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playerLoaded);
			//			var context:LoaderContext = new LoaderContext(false, new ApplicationDomain(),SecurityDomain.currentDomain);
			//			playerLoader.load(new URLRequest(url));
			playerLoaded(new Event(''));
		}
		
		
		private function playerLoaded(evt:Event):void {
			//playerLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playerLoaded);
			//player = (playerLoader.content) as IInternalPlayerAPI;
			//isLoaded = true;
			player = new VHSSPlayerV5();
			
			
			player.addEventListener(VHSSEvent.PLAYER_READY, vhss_ready)
			player.addEventListener(VHSSEvent.SCENE_LOADED, vhss_sceneLoaded);
			player.addEventListener(VHSSEvent.TALK_STARTED, vhss_talkStarted);
			player.addEventListener(VHSSEvent.TALK_ENDED, vhss_talkEnded);
			player.addEventListener(VHSSEvent.CONFIG_DONE, vhss_configDone);
			player.addEventListener(VHSSEvent.BG_LOADED, vhss_bgLoaded);
			player.addEventListener(VHSSEvent.SKIN_LOADED, vhss_skinLoaded);
			player.addEventListener(VHSSEvent.MODEL_LOAD_ERROR, vhss_modelLoadError);
			player.addEventListener(VHSSEvent.SCENE_PLAYBACK_COMPLETE, vhss_scenePlaybackComplete);
			player.addEventListener(VHSSEvent.PLAYER_DATA_ERROR, vhss_onDataError);
			player.addEventListener(VHSSEvent.AUDIO_ERROR, vhss_onAudioError);
			playerHolder.addChild(player);
			playerHolder.addChild(defaultEngine);
			
			//if (SessionVars.editorMode == "SceneEditor")
			//{
			playerHolder.addEventListener(MouseEvent.CLICK, playerClicked, true);
			//}
			//player.loadShowXML(showXML.toXMLString());			
			dispatchEvent(new Event(Event.INIT));
		}
		
		
		
		public function setPlayerInitFlags(flags:int):void
		{
			if (player != null)
			{
				player.setPlayerInitFlags(flags);
			}
		}
		
		private function vhss_ready(evt:VHSSEvent):void
		{
			player.setPlayerInitFlags(PlayerInitFlags.TRACKING_OFF | PlayerInitFlags.IGNORE_PLAY_ON_LOAD | PlayerInitFlags.SUPPRESS_EXPORT_XML | PlayerInitFlags.SUPPRESS_PLAY_ON_CLICK | PlayerInitFlags.SUPPRESS_LINKS | PlayerInitFlags.SUPPRESS_AUTO_ADV);			
			SessionVars.editorMode = "CharacterEditor";
			SessionVars.charEdit_engineUrl 	= "assets/engineV5.swf";
			SessionVars.charEdit_oh 		= "assets/ohv2.swf";//?cs=320a0a4:840907:c42e6a6:681c124:0:101:101:101:101:101:1:10:0:0";
			SessionVars.charEdit_pupId		= '5';
			SessionVars.charEdit_name 		= "";
			if (SessionVars.editorMode == "CharacterEditor")
			{
				
				var shs:SPHostStruct = new SPHostStruct(SessionVars.charEdit_oh, uint(SessionVars.charEdit_pupId), "", SessionVars.charEdit_name);
				//var hs:HostStruct = new HostStruct(SessionVars.charEdit_oh, uint(SessionVars.charEdit_charId),"host_2d");
				shs.engine = defaultEngine;//new EngineStruct(SessionVars.charEdit_engineUrl);
				show = new ShowStruct();				
				show.scene = new SceneStruct();
				curScene = show.scene;
				//				if (SessionVars.charEdit_oh.toLowerCase().indexOf("oa1")>=0)
				//				{
				//					shs.is3d = true;
				//					shs.type = "host_3d";
				//				}
				scene.model = shs;
				scene.model.isOwned = true;
				
				player.initBlankShow();
				player.loadHost(shs);	
				//TODO - this needs to happen after model is loaded
				show.scene.model.getInfoXML(onSceneLoaded);
			}
			else
			{				
				player.loadShowXML(showUrl);
			}
		}
		
		private function vhss_sceneLoaded(evt:Object):void {
			trace("evt.data="+evt.data);
			trace("evt="+evt);
			trace("evt.data.scene_number="+evt.data.scene_number);
			//curSceneIndex = int(evt.data.scene_number);						
			
			if (isLoaded) 
			{
				dispatchEvent(new Event(PlayerController.SCENE_LOADED));
				processList.processDoneByType(ASyncProcess.PROCESS_SCENE, true);
				updateSkinSettings();
				return;			
			}
			
			
			isLoaded = true;
			trace("PlayerController::vhss_sceneLoaded");
			//dispatchEvent(new VHSSEvent(VHSSEvent.SCENE_LOADED));
			hostMoveZoom = new MoveZoomUtil(hostMC);
			hostMoveZoom.boundBy(playerLoader, "intersects");
			//
			if (MovieClip(playerHolder.parent).playerMask != null)
			{
				var x:Number = MovieClip(playerHolder.parent).playerMask.width / 2;
				var y:Number = MovieClip(playerHolder.parent).playerMask.height / 2;
				x += 100;
				trace("PlayerController:setAnchor " + x + "," + y);
				
				hostMoveZoom.setAnchor(x, y, false);
				
			}
			else
			{
				hostMoveZoom.anchorTo(playerLoader);
			}			
			hostMoveZoom.setScaleLimits(0.3, 3);
			hostMoveZoom.enableDragging();
			if (SessionVars.editorMode != "CharacterEditor")
			{
				show = new ShowStruct();
				trace("getShowXML()="+player.getShowXML());
				show.parseXML(player.getShowXML());
				if (!show.scene.char.visible)
				{
					dispatchEvent(new Event(PlayerController.HOST_INVISIBLE));
				}
				curScene = show.scene;
			}
			if (curScene.model != null) modelCharIdArr[curScene.model.id] = curScene.model.charId;
			
			if (show.scene.model == null) dispatchEvent(new Event(Event.INIT));
			else 
			{
				//onSceneLoaded();
				//show.scene.model.getInfoXML(onSceneLoaded);
				/*
				if (SessionVars.editorMode != "CharacterEditor")
				{
				if (loadModelInfo && (scene.model.type.toLowerCase() != "3d" && scene.model.type.toLowerCase() != "host_3d"))
				{
				show.scene.model.getInfoXML(onSceneLoaded);
				}
				}
				*/
			}
			dispatchEvent(new Event(PlayerController.SCENE_LOADED));
			processList.processDoneByType(ASyncProcess.PROCESS_SCENE, true);
			
		}
		
		public function setHostToVisible(b:Boolean):void
		{
			player.getHostHolder().visible = b;
		}
		
		public function getShow():ShowStruct {
			return(show);
		}
		
		public function get scene():SceneStruct {
			if (show != null)
			{
				curScene = show.sceneArr[curSceneIndex - 1];
				return(curScene);
			}
			else
			{
				return null;
			}
			
		}
		/*public function loadScene(s:SceneStruct) {
		curScene = s;
		}*/
		
		/*private function get controller():IVhostConfigController {
		if (player == null) return(null);
		return(player.getConfigController() as IVhostConfigController);
		}*/
		public function get engineAPI():* {
			return(player.getActiveEngineAPI());
		}
		public function get controller():* {
			//trace("player = " + player);
			//trace("engineAPI = " + engineAPI);
			//trace("controller = " + engineAPI.getConfigController()+"   as interface - "+(engineAPI.getConfigController() as IVhostConfigController));
			//trace("SitepalV5::controller model type=" + scene.model.type);
			if (player == null) return(null);			
			try
			{
				return(engineAPI.getConfigController());
			}
			catch (e:Error)
			{
				return null;
			}
			/*
			else if (show.sceneArr[curSceneIndex].model.type.toLowerCase()!="3d" && show.sceneArr[curSceneIndex].model.type.toLowerCase()!="host_3d")
			{
			return(engineAPI.getConfigController());
			}
			else
			{
			return null;
			}
			*/
		}
		private function get hostMC():Sprite {
			return(player.getHostHolder());
		}
		public function get playerMC():Sprite {
			return(player as Sprite);
		}
		public function get zoomer():MoveZoomUtil {
			return(hostMoveZoom);
		}
		
		public function loadModel(model:SPHostStruct,forceReload:Boolean=false):void {
			if (modelCharIdArr[model.id] == undefined||forceReload) modelCharIdArr[model.id] = createNewCharId();
			doLoadModel(model, modelCharIdArr[model.id]);
		}
		
		private function createNewCharId():int {
			charIdCounter++;
			return(charIdCounter);
		}
		private function doLoadModel(model:SPHostStruct,charId:int):void {
			if (processList.isProcessingType(ASyncProcess.PROCESS_MODEL)||processList.isProcessingType(ASyncProcess.PROCESS_ACCESSORY)) return;
			if (controller != null)
			{
				controller.removeEventListener(EngineEvent.ACCESSORY_LOADED, onAccessoryLoaded);
			}
			if (model.engine == null) model.engine = defaultEngine;
			
			scene.model = model;
			//show.scene.model.getInfoXML(onSceneLoaded);
			processList.processStarted(model);
			if (model.engine == null) throw new Error("This model is missing an engine");
			//trace("SitepalV5::PlayerController::doLoadModel model id="+model.id+"  char id="+charId+" engine url="+model.engine.url+" model.type="+model.type);
			player.loadHost(model.cloneForPlayer(charId));
		}
		
		public function loadBG(bg:SPBackgroundStruct):void {
			trace("PlayerController::loadBG - " + bg);
			scene.bg = bg;
			if (bg!=null) processList.processStarted(bg);
			if (bg!=null && bg.transform != null)
			{
				//player.loadBackgroundWithTransform(bg, bg.transform);
				player.loadBackground(bg);
			}
			else
			{
				player.loadBackground(bg);
			}
		}
		
		public function loadAudio(audio:AudioData):void {
			
			if (audio != null)
			{
				var audioData:AudioStruct = new AudioStruct();
				audioData.url = audio.url;
				audioData.id = audio.id;
				audioData.type = audio.type;						
				player.setSceneAudio(audioData);
			}
			else
			{
				player.setSceneAudio(null);								
			}
			scene.audio = audio;			
		}
		
		public function loadAudios(audios:Array):void
		{
			scene.audioArr = audios;
		}
		
		public function loadSkin(skin:SPSkinStruct):void {
			loadingSkin = skin;
			manualLoadSkin = true;
			trace("isaac PlayerController::loadSkin -* " + (skin == null?"null":skin.name));
			if (skin != null) processList.processStarted(skin);			
			if (skin == null)
			{
				scene.skin = null;
			}
			player.loadSkin(skin);
		}
		public function updateSkinSettings():void {
			if (scene == null || scene.skin == null || scene.skinConfig == null) return;
			trace("isaac PlayerController::updateSkinSettings - " + scene.skinConfig.getXML().toXMLString());			
			if (show != null)
			{
				curScene = show.sceneArr[curSceneIndex - 1];				
			}
			//trace("updateSkinSettings:scene.title=" + scene.title+", scene.skinConfig.title="+scene.skinConfig.title);
			scene.title = scene.skinConfig.title!=""?scene.skinConfig.title:scene.title;
			var skinXML:XML = scene.skinConfig.getXML();
			//get rid of base url in the call
			var skinXMLStr:String = skinXML.toXMLString();
			if (SPAudioList.baseUrl != null)
			{
				var regex:RegExp = new RegExp(SPAudioList.baseUrl, "g");
				skinXMLStr = skinXMLStr.replace(regex, "");
			}
			var modSkinXML:XML = new XML(skinXMLStr);
			player.setSkinConfig(modSkinXML);
		}
		//----------------------------  COLOR FUNCTIONS -------------------------
		
		public function getSelectedAccessoryIdByType(typeId:int):int
		{
			var accData:AccessoryData = controller.getSelectedAccessory(typeId)
			return accData.id;
		}
		
		//color/sizing controller functions
		public function getColors():Array {
			if (controller == null) return([]);
			
			var colArr:Array = new Array();
			var colObj:Object=controller.getColorSections() as Object;
			for (var grp:String in colObj) {
				if (colObj[grp] == true) {
					colArr.push(new RangeData(grp,null,controller.getHexColor(grp)));
				}
			}
			
			return(colArr);
		}
		
		public function setColor(grpName:String,grpType:String, hexVal:uint):void {
			controller.setHexColor(grpName,hexVal);
			//dispatchEvent(new Event(COLOR_UPDATED));
		}
		
		public function getColor(grpName:String,grpType:String=null):uint {
			return(controller.getHexColor(grpName));
		}
		
		//----------------------------  SIZING FUNCTIONS -------------------------
		public function getRanges():Array {
			if (controller == null) return([]);
			var rangeArr:Array=new Array();
			var grpName:String;
			
			var ranges:Object;
			ranges=controller.getScaledSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"scale",ranges[grpName]));
			ranges=controller.getAlphaSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"alpha",ranges[grpName]));
			ranges=controller.getAgeSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"age",ranges[grpName]));
			
			return(rangeArr);
		}
		
		public function getScale(grpName:String,grpType:String=""):Number {
			return(controller.getScale(grpName));
			//return(0.5);
		}
		
		public function setScale(grpName:String, val:Number, grpType:String = ""):void {
			if (grpType=="scale") controller.setScale(grpName,val);
			else if (grpType=="alpha") controller.setAlpha(grpName,val);
			else if (grpType == "age") controller.setAge(val);
			//dispatchEvent(new Event(SIZING_UPDATED));
		}
		
		public function loadAccessory($acc:AccessoryData):void {
			//if (processList.isProcessingType(ASyncProcess.PROCESS_MODEL)||processList.isProcessingType(ASyncProcess.PROCESS_ACCESSORY)) return;
			if (processList.isProcessingType(ASyncProcess.PROCESS_MODEL)) return;
			if (processList.isProcessingType(ASyncProcess.PROCESS_ACCESSORY)) return;
			trace("PlayerController::loadAccessory : " + $acc);
			processList.processStarted($acc);
			controller.addEventListener(IOErrorEvent.IO_ERROR, onAccessoryLoadError);
			controller.setAccessory($acc);
			scene.model.removeInitialAccessory($acc.typeId);
			
		}
		
		private function onAccessoryLoaded(evt:EngineEvent):void {
			processList.processDoneByType(ASyncProcess.PROCESS_ACCESSORY, true);
			controller.removeEventListener(IOErrorEvent.IO_ERROR, onAccessoryLoadError);
			trace("PlayerController::onAccessoryLoaded");
		}
		
		private function onAccessoryLoadError(evt:IOErrorEvent):void
		{
			processList.processDoneByType(ASyncProcess.PROCESS_ACCESSORY, true);
			scene.model.undoRemoveInitialAccessory();
			controller.removeEventListener(IOErrorEvent.IO_ERROR, onAccessoryLoadError);
			dispatchEvent(evt);
		}
		
		//----------------------------  AUDIO  -------------------------
		
		public function playAudio(audio:AudioData):void {
			if (audio == null) return;
			trace("PlayerController::playAudio " + audio.url);
			stopAudio();
			processList.processStarted(audio);
			player.sayByUrl(audio.url);
		}
		public function stopAudio():void {
			trace("PlayerController::stopAudio");
			manualStopAudio = true;
			player.stopSpeech();
		}
		
		public function gotoScene(index:int):void
		{
			if (processList.isProcessingType(ASyncProcess.PROCESS_SCENE)) return;			
			compileScene();			
			curSceneIndex = index;
			processList.processStarted(scene);
			
			player.gotoScene(index);
		}
		
		private function playerClicked(evt:MouseEvent):void
		{
			trace("playerClicked " + evt.target.name);
			if (SessionVars.editorMode == "SceneEditor")
			{
				if (evt.target.name == "but_next")
				{
					if (curSceneIndex < show.sceneArr.length)
					{
						compileScene();			
						curSceneIndex++;
					}
				}
				else if (evt.target.name == "but_prev")
				{
					if (curSceneIndex > 1)
					{
						compileScene();
						curSceneIndex--;
					}
				}
			}
			if (evt.target.name == "but_play")
			{
				dispatchEvent(new Event(PlayerController.RESUME_CLICKED));
			}
			else if (evt.target.name == "but_pause")
			{
				dispatchEvent(new Event(PlayerController.FREEZE_CLICKED));
			}
		}
		
		//-------------------------------------  SAVING -----------------------------------
		
		public function freeze():void {
			engineAPI.freeze();
		}
		
		public function resume():void {
			engineAPI.resume();
		}
		
		public function compileScene():void {
			if (scene.model.type.toUpperCase() != "3D" && scene.model.type.toUpperCase()!="HOST_3D")
			{
				scene.char.url = "/" + engineAPI.getOHUrl();
			}
			if (zoomer != null)
			{
				scene.char.hostPos = zoomer.matrix;// hostMoveZoom.matrix;// hostMC.transform.matrix;
			}
			else
			{
				scene.char.hostPos = hostMC.transform.matrix;
			}
		}
		
		public function replay():void
		{
			player.replay(1);
		}
		
		//-------------------------------------  CALLBACKS -----------------------------------
		
		private function onSceneLoaded():void {
			trace("SitepalV5::onSceneLoaded");
			
			dispatchEvent(new Event(Event.INIT));
		}
		
		private function vhss_talkStarted(evt:Object):void {
			trace("PlayerController::vhss_talkStarted");
			if (!isLoaded) return;
			processList.processDoneByType(ASyncProcess.PROCESS_AUDIO,true);
			dispatchEvent(new VHSSEvent(VHSSEvent.TALK_STARTED));
		}
		
		private function vhss_talkEnded(evt:Object):void {
			trace("PlayerController::vhss_talkEnded");
			if (!isLoaded) return;
			dispatchEvent(new VHSSEvent(VHSSEvent.TALK_ENDED));
		}
		
		private function vhss_scenePlaybackComplete(evt:Object):void
		{
			if (!isLoaded) return;
			trace("PlayerController::vhss_scenePlaybackComplete");
			dispatchEvent(new VHSSEvent(VHSSEvent.SCENE_PLAYBACK_COMPLETE));
		}
		
		private function vhss_configDone(evt:Object):void {
			//			trace("PlayerController::vhss_configDone");
			//			if (scene!=null && (scene.model.type.toLowerCase() != "3d" && scene.model.type.toLowerCase() != "host_3d"))
			//			{
			//				if (zoomer != null)
			//				{
			//					zoomer.minScale = MoveZoomUtil.MIN_SCALE_2D;	
			//					if (zoomer.scale < MoveZoomUtil.MIN_SCALE_2D)
			//					{
			//						zoomer.scale = MoveZoomUtil.MIN_SCALE_2D;
			//					}
			//				}
			//			}
			//			else if (zoomer!=null)
			//			{
			//				
			//				if (zoomer.scale < MoveZoomUtil.MIN_SCALE_3D)
			//				{
			//					zoomer.scale = MoveZoomUtil.MIN_SCALE_3D;
			//				}								
			//				zoomer.minScale = MoveZoomUtil.MIN_SCALE_3D;				
			//			}
			//			if (!isLoaded && SessionVars.editorMode != "CharacterEditor") return;			
			//			if (scene!=null && loadModelInfo && (scene.model.type.toLowerCase() != "3d" && scene.model.type.toLowerCase() != "host_3d"))
			//			{
			//				if (zoomer != null)
			//				{
			//					zoomer.minScale = MoveZoomUtil.MIN_SCALE_2D;
			//				}
			//				show.scene.model.getInfoXML(onModelLoaded);
			//			}
			//			else
			//			{
			//				if (zoomer != null)
			//				{
			//					if (zoomer.scale < MoveZoomUtil.MIN_SCALE_3D)
			//					{
			//						zoomer.scaleTo(MoveZoomUtil.MIN_SCALE_3D, true);
			//					}								
			//					zoomer.minScale = MoveZoomUtil.MIN_SCALE_3D;
			//				}
			//				onModelLoaded();
			//			}
			//			
			//			
			//			if (controller!=null)
			//			{
			//				controller.addEventListener(EngineEvent.ACCESSORY_LOADED, onAccessoryLoaded);
			//			}
			//			
		}
		
		private function onModelLoaded():void {
			processList.processDone(scene.model, true);						
			dispatchEvent(new Event(HOST_LOADED));
			if (SessionVars.editorMode == "CharacterEditor")
			{
				//trace()
				onSceneLoaded();
			}
			
		}
		
		private function vhss_bgLoaded(evt:Event):void {
			trace("PlayerController::vhss_bgLoaded");
			if (!isLoaded) return;
			if (scene.bg!=null) processList.processDone(scene.bg,true);
		}
		
		private function vhss_skinLoaded(evt:Event):void {
			trace("PlayerController::vhss_skinLoaded");
			
			//if (SessionVars.editorMode == "SceneEditor")
			//{
			processList.processDoneByType(ASyncProcess.PROCESS_SKIN, true);
			//}
			if (manualLoadSkin)
			{
				
				//var title:String = scene.skin
				for (var i:int = 0; i < show.sceneArr.length; ++i)
				{
					var tmpScene:SceneStruct = show.sceneArr[i];
					tmpScene.skin = loadingSkin
					if (tmpScene != null)
					{
						if (tmpScene.skinConfig == null)
						{
							tmpScene.skinConfig = new SkinConfiguration(tmpScene.skin.type);							
						}
						tmpScene.skinConfig.setFromSkin(tmpScene.skin);
						tmpScene.skinConfig.title = tmpScene.title;
					}
				}				
				
				loadingSkin = null;
				//dispatchEvent(new Event(SKIN_TYPE_CHANGED));			
			}
			
			dispatchEvent(new Event(SKIN_LOADED));			
			if (!isLoaded) return;
			
			if (scene.skin!=null && manualLoadSkin) {
				processList.processDone(scene.skin, true);
				updateSkinSettings();				
			}
			manualLoadSkin = false;
		}
		
		private function vhss_modelLoadError(evt:VHSSEvent):void
		{
			processList.processDone(scene.model, true);	
			trace("vhss_modelLoadError");
			dispatchEvent(evt);
			dispatchEvent(new Event(PlayerController.LOAD_ERROR));
		}
		
		private function vhss_onDataError(evt:VHSSEvent):void
		{
			trace("vhss_onDataError");
			dispatchEvent(evt);
		}
		
		private function vhss_onAudioError(evt:VHSSEvent):void
		{
			processList.processDoneByType(ASyncProcess.PROCESS_AUDIO,true);
			trace("vhss_onAudioError");
			dispatchEvent(evt);
		}
		
		
		public function destroy():void {
			trace("PlayerController::destroy - ");
			player.removeEventListener(VHSSEvent.SCENE_LOADED, vhss_sceneLoaded);
			player.removeEventListener(VHSSEvent.TALK_STARTED, vhss_talkStarted);
			player.removeEventListener(VHSSEvent.TALK_ENDED, vhss_talkEnded);
			player.removeEventListener(VHSSEvent.CONFIG_DONE, vhss_configDone);;
			player.removeEventListener(VHSSEvent.BG_LOADED, vhss_bgLoaded);
			player.removeEventListener(VHSSEvent.SKIN_LOADED, vhss_skinLoaded);
			player.removeEventListener(VHSSEvent.MODEL_LOAD_ERROR, vhss_modelLoadError);
			player.removeEventListener(VHSSEvent.PLAYER_READY, vhss_ready);
			player.removeEventListener(VHSSEvent.SCENE_PLAYBACK_COMPLETE, vhss_scenePlaybackComplete);
			player.removeEventListener(VHSSEvent.PLAYER_DATA_ERROR, vhss_onDataError);
			player.removeEventListener(VHSSEvent.AUDIO_ERROR, vhss_onAudioError);
			try{ // isaac... this was to fix the intro model, if it has no accessories
				controller.removeEventListener(EngineEvent.ACCESSORY_LOADED, onAccessoryLoaded);
			}catch (err:Error){
				trace("PlayerController::destroy - err="+err);
			}
			playerLoader.unload();
		}
	}
	
}