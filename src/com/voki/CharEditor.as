package com.voki  {
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.ModelEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.event.SkinSelectEvent;
	import com.oddcast.event.VHSSEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.utils.CustomCursor;
	import com.oddcast.utils.XMLLoader;
	import com.voki.data.AlertLookup;
	import com.voki.data.SPAudioList;
	import com.voki.data.SPHostStruct;
	import com.voki.data.SPModelList;
	import com.voki.data.SPSkinStruct;
	import com.voki.data.SessionVars;
	import com.voki.data.ShowStruct;
	import com.voki.events.AssetIdEvent;
	import com.voki.nav.NavWindow;
	import com.voki.nav.NavigationBar;
	import com.voki.nav.NavigationController;
	import com.voki.nav.PopupController;
	import com.voki.panels.AISkinPanel;
	import com.voki.panels.AccessoryPanel;
	import com.voki.panels.BackgroundPanel;
	import com.voki.panels.BuyModelPopup;
	import com.voki.panels.ColorPanel;
	import com.voki.panels.FAQSkinPanel;
	import com.voki.panels.LeadSkinPanel;
	import com.voki.panels.MicPanel;
	import com.voki.panels.ModelPanel;
	import com.voki.panels.PhonePanel;
	import com.voki.panels.PhotoFacePanel;
	import com.voki.panels.SavedAudioPanel;
	import com.voki.panels.SavedBGPanel;
	import com.voki.panels.SavedCharPanel;
	import com.voki.panels.SizingPanel;
	import com.voki.panels.SkinPanel;
	import com.voki.panels.StandardSkinPanel;
	import com.voki.panels.TTSPanel;
	import com.voki.panels.UpgradePopup;
	import com.voki.panels.UploadAudioPanel;
	import com.voki.player.PlayerController;
	import com.voki.player.ThumbSaver;
	import com.voki.processing.ASyncProcess;
	import com.voki.processing.ASyncProcessEvent;
	import com.voki.tracking.SPEventTracker;
	
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class CharEditor extends MovieClip {
		private var show:ShowStruct;
		
		public var loadingBar:MovieClip;
		public var navBar:NavigationBar;
		public var navWin:NavWindow;
		public var navController:NavigationController;
		public var playerMC:MovieClip;
		public var playerController:PlayerController;
		public var popups:PopupController;
		
		private var charNameTF:TextField;
		private var thumbSaver:ThumbSaver;
		
		private var modelList:SPModelList;
		private var audioList:SPAudioList;
		private var alertLookup:AlertLookup;
		private var publishMode:String;
		private var publishEvent:SendEvent;
		private var savedSkin:SPSkinStruct;
		
		private var modelPanel:ModelPanel;
		private var photoFacePanel:PhotoFacePanel;
		private var bgPanel:BackgroundPanel;
		private var savedBgPanel:SavedBGPanel;
		private var savedCharPanel:SavedCharPanel;
		private var colorPanel:ColorPanel;
		private var sizingPanel:SizingPanel;
		private var accPanel:AccessoryPanel;
		//private var expressionsPanel:ExpressionsPanel;
		private var ttsPanel:TTSPanel;
		private var micPanel:MicPanel;
		private var uploadAudioPanel:UploadAudioPanel;
		private var phonePanel:PhonePanel;
		private var savedAudioPanel:SavedAudioPanel;
		private var skinPanel:SkinPanel;
		private var standardSkinPanel:StandardSkinPanel;
		private var leadSkinPanel:LeadSkinPanel;
		private var aiSkinPanel:AISkinPanel;
		private var faqSkinPanel:FAQSkinPanel;
		public var btnSitepal:BaseButton;
		
		public var upgradeTTSWin:UpgradePopup;
		public var upgradeSkinWin:UpgradePopup;
		public var upgradeModelWin:BuyModelPopup;
						
		public function CharEditor() {
			showLoadingMessage("Loading interface");			
			SessionVars.editorMode = "CharacterEditor";
			SessionVars.editorVer = "07.21.2010 10:46";
			initContextMenu();
		}
		
		private function initContextMenu():void {
			var myMenu:ContextMenu = new ContextMenu();
			myMenu.hideBuiltInItems();

			var menuItem1:ContextMenuItem = new ContextMenuItem("Powered by Oddcast");
			var menuItem2:ContextMenuItem = new ContextMenuItem("StudioEditor Ver "+SessionVars.editorVer);
			menuItem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openOddcastSite);
			myMenu.customItems.push(menuItem1);
			myMenu.customItems.push(menuItem2);
			contextMenu = myMenu; 			
		}
		
		public function swfLoaded():void {
			SessionVars.setLoaderInfo(loaderInfo);
			navBar.visible = false;
			navBar.step3Btn.visible = false;
			navBar.step4Btn.visible = false;
			navBar.step5Btn.visible = false;
			
			playerMC.visible = false;
			playerMC.playerHolder.mask = playerMC.playerMask;
			playerMC.playerMask.visible = false;
			playerController = new PlayerController(playerMC.playerHolder);
			playerController.addEventListener(PlayerController.HOST_LOADED, hostLoaded);
			playerController.processList.addEventListener(ASyncProcessEvent.STARTED,onProcessingStarted);
			playerController.processList.addEventListener(ASyncProcessEvent.DONE,onProcessingEnded);
			playerController.addEventListener(VHSSEvent.TALK_STARTED, onTalkStarted);
			playerController.addEventListener(VHSSEvent.TALK_ENDED, onTalkEnded);
					
			/*
			previewBtn = playerMC.bottomPanel.playBtn as StickyButton;
			previewBtn.addEventListener(SelectorEvent.SELECTED, onPreviewScene);
			previewBtn.addEventListener(SelectorEvent.DESELECTED, onStopScene);
			*/
			charNameTF = playerMC.tf_charName as TextField;
			
			popups = new PopupController(this);
			CustomCursor.setStage(stage);
			getSessionInfo();
			//getAccountInfo();
			XMLLoader.retries = 2;
		}
		
		private function showLoadingMessage(msg:String, percent:Number = Number.NaN):void {
			if (loadingBar.tf_loading != null) loadingBar.tf_loading.text = msg;
		}
		
		
		private function getSessionInfo():void {
			showLoadingMessage("Loading session info");
			var rand:String = Math.floor(Math.random() * 1000000).toString();
			var url:String = SessionVars.localBaseURL + "getSessionV5.php?dr=" + SessionVars.doorId;
			if (SessionVars.sessionId != null)
			{
				url += "&PHPSESSID=" + SessionVars.sessionId;
			}
			XMLLoader.loadVars(url, gotSessionInfo);
			//setInterval(this,"preventSessionExpiry",900000)
		}
		
		private function gotSessionInfo(urlVars:URLVariables):void {
			if (urlVars != null)
			{
				if (int(urlVars.showId) > 0 && SessionVars.sessionId==null)
				{
					SessionVars.showId = urlVars.showId;
				}
				SessionVars.sessionId = urlVars.PHPSESSID;
				SessionVars.acc = urlVars.accId;
				SessionVars.userId = int(urlVars.gUserId);
				SessionVars.userEmail = String(urlVars.email);
			}			
			getAccountInfo();
		}
		
		private function getAccountInfo():void {
			showLoadingMessage("Loading account info");
			var rand:String = Math.floor(Math.random() * 1000000).toString();
			XMLLoader.loadXML(SessionVars.baseURL + "getAccountInfoV5/acc="+ SessionVars.acc, gotAccountInfo);
			//setInterval(this,"preventSessionExpiry",900000)
		}
		
		private function gotAccountInfo(_xml:XML):void {
			if (_xml != null)
			{
				SessionVars.setFromXML(_xml);
			}			
			getAlertText();
		}
		
		private function getAlertText():void {
			showLoadingMessage("Loading alerts");
			//alertLoader = new AlertLoader(SessionVars.localBaseURL + "xml/alertsv4.xml");
			XMLLoader.loadXML(SessionVars.contentPath + "vhss_editors/xml/alertsv5.xml", gotAlertText);
		}
		
		private function gotAlertText(_xml:XML):void {
			if (_xml!=null) alertLookup = new AlertLookup(_xml);
			loadPlayer();
		}
		
		private function loadPlayer():void {
			showLoadingMessage("Loading scene");
			playerController.addEventListener(Event.INIT, playerLoaded);			
			var rand:Number = Math.floor(Math.random() * 100000);
			var url:String=SessionVars.acceleratedURL + "/php/playScene/acc=" + SessionVars.acc + "/ss=" + SessionVars.showId+"/editor=1/&rand="+rand
			playerController.init(url);
		}
		
		private function playerLoaded(evt:Event):void {
			playerController.removeEventListener(Event.INIT, playerLoaded);
			
			if (SessionVars.sessionId.length > 0) {
				var url:String = SessionVars.acceleratedURL + "/vhss_editors/getSession.php?PHPSESSID=" + SessionVars.sessionId;
				//XMLLoader.sendAndLoad(url, null, null, String);
			}		
			updateAccessoryPanelVisibility();
			modelList = new SPModelList();
			show = playerController.getShow();			
			charNameTF.text = SessionVars.charEdit_name;
			//trace("show.scene = " + show.scene);
			/*
			var moveZoomControls:MoveZoomControls = playerMC.bottomPanel.moveZoomPanel as MoveZoomControls;
			moveZoomControls.setTarget(playerController.zoomer);
			*/
			btnSitepal.addEventListener(MouseEvent.CLICK, openOddcastSite);		
			startAnimation();			
		}
				
		
		private function startAnimation():void {
			loadingBar.addEventListener("animationComplete", loadingAnimationComplete);
			loadingBar.gotoAndPlay(2);
		}
		
		private function loadingAnimationComplete(evt:Event):void {
			navBar.visible = true;
			navBar.initShareButtons();
			showScene();			
		}
		
		private function openOddcastSite(evt:*):void
		{									
			var req:URLRequest = new URLRequest(SessionVars.oddcast_url); 			
			if (!ExternalInterface.available) {
				trace("Terms Clicked: navigateToURL EI not available");
				navigateToURL(req, "sitepalWin");					
			} else {
				var strUserAgent:String = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
				if (strUserAgent.indexOf("firefox") != -1 || (strUserAgent.indexOf("msie") != -1 && uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7)) {
					trace("Terms Clicked: window.open");
					ExternalInterface.call("window.open", req.url, "sitepalWin");
				} else {
					trace("Terms Clicked: navigateToURL based on user agent");
					navigateToURL(req, "sitepalWin");
				}
			}							
			
		}
						
		private function showScene():void {
			playerMC.visible = true;
						
			
			navController = new NavigationController(navBar, navWin);
			navController.addEventListener("panelOpened", navPanelOpened);
			
			navBar.addEventListener(SelectorEvent.SELECTED, onNavBarWinSelected);			
			navBar.addEventListener("saveClick", onSaveClick);
			
			initPanels();
			
			upgradeModelWin.addEventListener(AssetIdEvent.MODEL_PURCHASED, modelPurchased);
			addEventListener(AlertEvent.ERROR, catchError);
			SessionVars.navController = navController;
			navController.selectPanel(modelPanel);
		}
		
		private function initPanels():void {	
			/*
			var ttsVoiceList:TTSVoiceList = new TTSVoiceList();
			ttsVoiceList.url = SessionVars.baseURL + "getTTSList/partnerId=" + SessionVars.partnerId;
			
			audioList.addEventListener("accountAudiosUpdated", privateAudioCountUpdated);
			
			popups.editTTSWin.voiceList = ttsVoiceList;
			popups.selectAudioWin.data = audioList;
			popups.selectAudioWin.addEventListener("createNewAudio", gotoCreateAudioPanel);
			popups.skinPromoWin.addEventListener("select", skinTypeSelected);
			*/
			popups.aboutWin.alertLookup = alertLookup;
			popups.alertWin.alertLookup = alertLookup;
			popups.confirmWin.alertLookup = alertLookup;
			popups.upgradeWin.alertLookup = alertLookup;
			
//			modelPanel = new sp_panel_model() as ModelPanel;
//			modelPanel.data = modelList;
//			modelPanel.setPlayer(playerController);
//			modelPanel.addEventListener(ModelEvent.SELECT, modelSelected);
//			modelPanel.addEventListener("modelDataReady", onModelsDataReady);
//			navController.addPanel(1, 1, "2D Illustrated", modelPanel);
//			
//			photoFacePanel = new sp_panel_photoFace() as PhotoFacePanel;			
//			photoFacePanel.setPlayer(playerController);
//			photoFacePanel.addEventListener(ModelEvent.SELECT, modelSelected);
//			photoFacePanel.addEventListener("hidePlayer", hidePlayer);
//			photoFacePanel.addEventListener("showPlayer", hidePlayer);
//			photoFacePanel.addEventListener(AlertEvent.ALERT, catchError);
//			navController.addPanel(1, 2, "3D PhotoFace", photoFacePanel);
//			
//			savedCharPanel = new sp_panel_savedChar() as SavedCharPanel;
//			savedCharPanel.setPlayer(playerController);
//			savedCharPanel.addEventListener(ModelEvent.SELECT, modelSelected);
//			navController.addPanel(1, 3, "Saved Models", savedCharPanel);
//			
//			accPanel = new sp_panel_acc() as AccessoryPanel;
//			accPanel.setPlayer(playerController);
//			navController.addPanel(2, 1, "Style", accPanel);
//
//			colorPanel = new sp_panel_color() as ColorPanel;
//			colorPanel.player = playerController;
//			navController.addPanel(2, 2, "Color", colorPanel);
//			
//			sizingPanel = new sp_panel_sizing() as SizingPanel;
//			sizingPanel.player = playerController;
//			navController.addPanel(2, 3, "Attributes", sizingPanel);
			
			/*
			expressionsPanel = new sp_panel_expressions() as ExpressionsPanel;
			expressionsPanel.player = playerController;
			navController.addPanel(2, 4, "Expressions", expressionsPanel);
			*/
			
			/*
			bgPanel = new sp_panel_bg();
			bgPanel.setPlayer(playerController);
			bgPanel.addEventListener("upload", onGotoBGUpload);
			navController.addPanel(3, 1, "Background Gallery", bgPanel);
			
			savedBgPanel = new sp_panel_savedBG();
			savedBgPanel.setPlayer(playerController);
			savedBgPanel.popups = popups;
			navController.addPanel(3, 2, "My Background", savedBgPanel);
			
			savedAudioPanel = new sp_panel_savedAudio();
			savedAudioPanel.data = audioList;
			savedAudioPanel.popupController = popups;
			savedAudioPanel.setPlayer(playerController);
			navController.addPanel(4, 1, "Saved", savedAudioPanel);
			
			ttsPanel = new sp_panel_tts();
			ttsPanel.voiceList = ttsVoiceList;
			ttsPanel.setPlayer(playerController);
			ttsPanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			ttsPanel.addEventListener(AudioEvent.STOP, onStopAudio);
			navController.addPanel(4, 2, "TTS", ttsPanel);
			
			micPanel = new sp_panel_mic();
			micPanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			micPanel.addEventListener(AudioEvent.STOP, onStopAudio);
			navController.addPanel(4, 3, "Mic", micPanel);
			
			uploadAudioPanel = new sp_panel_uploadAudio();
			uploadAudioPanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			uploadAudioPanel.addEventListener(AudioEvent.STOP, onStopAudio);
			navController.addPanel(4, 4, "Upload", uploadAudioPanel);
			
			phonePanel = new sp_panel_phone();
			phonePanel.addEventListener(AudioEvent.SELECT, onAudioSelected);
			phonePanel.addEventListener(AudioEvent.STOP, onStopAudio);
			navController.addPanel(4, 5, "Phone", phonePanel);
			
			var voiceTalentPanel:VoiceTalentPanel = new sp_panel_voiceTalent();
			navController.addPanel(4, 6, "Voice Talent", voiceTalentPanel);
			
			skinPanel = new sp_panel_skin();
			skinPanel.setPlayer(playerController);
			skinPanel.addEventListener(SkinSelectEvent.SELECT, skinSelected);
			skinPanel.addEventListener("openSkinPromoWin", openSkinPromoWin);
			navController.addPanel(5, 1, "Select Player", skinPanel);
			
			var skinSettingsPanel:SkinSettingsPanel = new sp_panel_skinSettings();
			skinSettingsPanel.player = playerController;
			skinSettingsPanel.addEventListener("update", updateSkinSettings);
			navController.addPanel(5, 2, "Display Settings", skinSettingsPanel);
			
			standardSkinPanel = new sp_panel_skinStandard();
			standardSkinPanel.addEventListener("select", skinTypeSelected);
			navController.addPanel(5, 3, "Functions (Standard)",standardSkinPanel);
						
			leadSkinPanel = new sp_panel_skinLead();
			leadSkinPanel.player = playerController;
			leadSkinPanel.popups = popups;
			leadSkinPanel.addEventListener("update", updateSkinSettings);
			
			aiSkinPanel = new sp_panel_skinAI();
			aiSkinPanel.player = playerController;
			aiSkinPanel.voiceList = ttsVoiceList;
			aiSkinPanel.addEventListener("update", updateSkinSettings);
			
			faqSkinPanel = new sp_panel_skinFaq();
			faqSkinPanel.player = playerController;
			faqSkinPanel.popups = popups;
			faqSkinPanel.addEventListener("update", updateSkinSettings);
			
			updateColorTabVisibility();
			updateSkinTabType(show.scene.skin);
			if (!SessionVars.loggedIn) {
				navController.setTabVisible(savedCharPanel, false);
				navController.setTabVisible(savedBgPanel, false);
			}
			*/
			navController.setTabVisible(savedCharPanel, false);
		}
		
		private function onModelsDataReady(evt:Event):void
		{
			photoFacePanel.setData(modelPanel.data);
		}
		
		private function catchError(evt:AlertEvent):void {
			if (evt.alertType == AlertEvent.CONFIRM) {
				popups.openPopup(popups.confirmWin);
				popups.confirmWin.alert(evt);
			}
			else if (evt.alertType == "about") {
				popups.openPopup(popups.aboutWin);
				popups.aboutWin.alert(evt);
			}
			else if (evt.alertType == "upgrade") {
				popups.openPopup(popups.upgradeWin);
				popups.upgradeWin.alert(evt);
			}
			else {
				popups.openPopup(popups.alertWin);
				popups.alertWin.alert(evt);
			}
		}

		private function hidePlayer(evt:Event):void
		{
			trace("SitepalV5::hidePlayer "+evt.type);
			playerMC.visible = evt.type == "hidePlayer"?false:true;
			navBar.disable(evt.type == "hidePlayer");
			navBar.visible = evt.type != "hidePlayer"
			if (upgradeModelWin != null)
			{
				
				if (show.scene.model != null && !show.scene.model.isOwned && !show.scene.model.is3d)
				{
					upgradeModelWin.visible = evt.type == "hidePlayer"?false:true;		
				}
			}						
		}
		
		private function onAudioSelected(evt:AudioEvent):void {
			playerController.loadAudio(evt.audio);
			if (evt.target == savedAudioPanel) {
				playerController.playAudio(evt.audio);
			}
			else {
				evt.audio.isPrivate = true;
				audioList.addAccountAudio(evt.audio);
				navController.selectPanel(savedAudioPanel);
				
				if (evt.audio.type == AudioData.TTS) SPEventTracker.event("astts")
				if (evt.audio.type == AudioData.MIC) SPEventTracker.event("asmic")
				if (evt.audio.type == AudioData.PHONE) SPEventTracker.event("asup")
				if (evt.audio.type == AudioData.UPLOADED) SPEventTracker.event("asph")
				else SPEventTracker.event("as")
				
				//if it's uploaded audio, preview it
				if (evt.target == uploadAudioPanel) playerController.playAudio(evt.audio);
			}
		}
		
		private function onStopAudio(evt:AudioEvent):void {
			playerController.stopAudio();
		}
		
		private function privateAudioCountUpdated(evt:Event):void {
			//do a check to make sure the number of private audios the user has doesn't exceed the max
			//if it does, disabled the "create audio" tabs and display an alert
			var maxExceeded:Boolean = (audioList.getAccountAudioArr().length >= SessionVars.audioLimit);
			navController.setTabDisabled(ttsPanel, maxExceeded);
			navController.setTabDisabled(micPanel, maxExceeded);
			navController.setTabDisabled(phonePanel, maxExceeded);
			navController.setTabDisabled(uploadAudioPanel, maxExceeded);
			if (maxExceeded) dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp403","You have reached the maximum number of audios for your account.  To create a new audio, you must first delete one of your existing audios."));
		}
		
		private function updateAccessoryPanelVisibility():void {
			//disable colour tab if there are no color sections for this model
			trace("playerController.scene.model.type = " + playerController.scene.model.type+" navController="+navController);
			if (navController == null) return;
			
			if (playerController.scene.model.type == "host_2d" || playerController.scene.model.type=="2D")
			{
				var numColors:uint = playerController.getColors().length;
				navController.setTabDisabled(colorPanel, (numColors == 0));
				navController.setTabDisabled(sizingPanel, false);
				navController.setTabDisabled(accPanel, false);
				//navController.setTabDisabled(expressionsPanel, true);
				/*
				if (navController.getActivePanel() == expressionsPanel)
				{
					navController.selectPanel(accPanel);
				}
				*/
				//navBar.step2Btn.disabled = false;
				//SessionVars.accPanelDisabled = false;
			}
			else
			{
				//SessionVars.accPanelDisabled = true;
				//navBar.step2Btn.disabled = true;
				
				navController.setTabDisabled(sizingPanel, true);
				navController.setTabDisabled(colorPanel, true);
				navController.setTabDisabled(accPanel, true);
				
				//navController.setTabDisabled(expressionsPanel, false);
				//trace("updateAccessoryPanelVisibility winId=" + navController.getActiveWinId());
				/*
				if (navController.getActiveWinId() == 2)//accessories
				{
					navController.selectPanel(expressionsPanel);
				}
				*/
			}
			
			
			
		}
		
		private function updateColorTabVisibility():void {
			//disable colour tab if there are no color sections for this model
			if (navController == null) return;
			var numColors:uint = playerController.getColors().length;
			navController.setTabDisabled(colorPanel, (numColors == 0));
		}
		
		private function updateSkinTabType(skin:SPSkinStruct):void {
			if (skin == null) {
				navController.setTabVisibleById(5, 2, false);
				navController.setTabVisibleById(5, 3, false);
			}
			else {
				navController.setTabVisibleById(5, 2, true);
				if (!SessionVars.loggedIn && SessionVars.mode == SessionVars.PARTNER_MODE) { 
					// only standard skins are available - you can't choose others
					navController.setTabVisibleById(5, 3, false);
				}
				else navController.setTabVisibleById(5, 3, true);
				
				trace("updateskinTabType : " + skin.type);
				if (skin.type == SPSkinStruct.LEAD_TYPE) {
					navController.addPanel(5, 3, "Functions (Lead)",leadSkinPanel);
				}
				else if (skin.type == SPSkinStruct.AI_TYPE) {
					navController.addPanel(5, 3, "Functions (AI)",aiSkinPanel);
				}
				else if (skin.type == SPSkinStruct.FAQ_TYPE) {
					navController.addPanel(5, 3, "Functions (FAQ)",faqSkinPanel);
				}
				else navController.addPanel(5, 3, "Functions (Standard)", standardSkinPanel);
			}
		}
		
		private function onGotoBGUpload(evt:Event):void {
			navController.selectPanel(savedBgPanel);
			savedBgPanel.uploadBg();
		}
		
		private function onNavBarWinSelected(evt:SelectorEvent):void {
			//if (navController.getActiveWinId() == 5
			if (navBar.selectedTab+1 == 5&&!SessionVars.noSkinPromo&&popups.skinPromoWin.firstOpen&&!show.isEdited) {
				popups.openPopup(popups.skinPromoWin);
				popups.skinPromoWin.init();
			}
			else popups.closePopup(popups.skinPromoWin);
		}
		
		private function navPanelOpened(evt:Event):void {
			updateAccessoryPanelVisibility();
			updateUpgradeAlerts();
		}
		
		private function updateUpgradeAlerts():void {
			if (navController.getActivePanel() == null||show==null||show.scene==null) {
				upgradeSkinWin.visible = false;
				upgradeTTSWin.visible = false;
				upgradeModelWin.closeWin();
				return;
			}
			if (navController.getActiveWinId() == 5 && SessionVars.loggedIn && show.scene.skin != null && !show.scene.skin.isOwned) {
				upgradeSkinWin.visible = true;
				if (show.scene.skin.type == SPSkinStruct.AI_TYPE) upgradeSkinWin.gotoAndStop(2);
				else upgradeSkinWin.gotoAndStop(1);
			}
			else upgradeSkinWin.visible = false;
			
			if (navController.getActivePanel() == ttsPanel && !SessionVars.ttsEnabled) upgradeTTSWin.visible = true;
			else upgradeTTSWin.visible = false;
			
			
			if (/*navController.getActivePanel() == modelPanel && */show.scene.model != null && !show.scene.model.isOwned && !show.scene.model.is3d) {
				upgradeModelWin.openWithModel(show.scene.model)
			}
			else upgradeModelWin.closeWin();
			
			/*
			if (navController.getActiveWinId() == 1 && show.scene.model != null && !show.scene.model.isOwned) {
				upgradeModelWin.openWithModel(show.scene.model)
			}
			else upgradeModelWin.closeWin();
			*/
		}
		
		
		private function modelPurchased(evt:AssetIdEvent):void {
			
		}
		
		private function skinSelected(evt:SkinSelectEvent):void {
			updateSkinTabType(evt.skin as SPSkinStruct);
			updateUpgradeAlerts();
		}
		private function skinTypeSelected(evt:TextEvent):void {
			trace("skinTypeSelected : " + evt.text);
			skinPanel.selectPopularSkinType(evt.text);
			if (navController.getActivePanel() == skinPanel) skinPanel.openPanel(); //re-initialize panel
			else navController.selectPanel(skinPanel);
		}
		private function openSkinPromoWin(evt:Event):void {
			popups.openPopup(popups.skinPromoWin);
			popups.skinPromoWin.init();
		}
		private function updateSkinSettings(evt:Event):void {
			playerController.updateSkinSettings();
		}
		private function gotoCreateAudioPanel(evt:Event):void {
			
		}
		private function onPreviewScene(evt:SelectorEvent):void {
			playerController.playAudio(show.scene.audio);
		}
		private function onStopScene(evt:SelectorEvent):void {
			playerController.stopAudio();
		}
		
		private function modelSelected(evt:ModelEvent):void {
			//modelBlocker._visible=true;
			
			//reload the model and reset the model accessories/colors if it is selected from the "scene characters" panel
			var forceReload:Boolean;
			if (evt.target == savedCharPanel) forceReload = true;
			else forceReload = false;
			
			var model:SPHostStruct = evt.model as SPHostStruct;
			//hostModule.loadOH(model.hostUrl+"&pd="+SessionVars.swfDomain,forceReload);
			trace("model is owned : " + model == null?null:model.isOwned);
			playerController.addEventListener(VHSSEvent.MODEL_LOAD_ERROR, onModelLoadError);
			playerController.loadModel(model,forceReload);
			
			updateUpgradeAlerts();
		}
	
		//player controller callbacks
		
		
		private function onModelLoadError(evt:VHSSEvent):void
		{
			trace("Sitepal::onModelLoadError");
			modelPanel.returnToPreviousModel();
			popups.closePopup(popups.modelBlocker);
			dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp213", "Character could not be loaded"));
			playerController.removeEventListener(VHSSEvent.MODEL_LOAD_ERROR, onModelLoadError);
		}
		
		private function hostLoaded(evt:Event):void {
			//if (firstTime) introStart();
			playerController.removeEventListener(VHSSEvent.MODEL_LOAD_ERROR, onModelLoadError);
			//modelBlocker._visible=false;
			//updateColorTabVisibility();
			navBar.selectedTab = 0;
			updateAccessoryPanelVisibility();
			//hostModule.getController().setInitialAccessories(OHUrlParser.getOHObject(hosturl));
		}
		
		private function onProcessingStarted(evt:ASyncProcessEvent):void {
			if (evt.process.processType==ASyncProcess.PROCESS_MODEL) {
				popups.openPopup(popups.modelBlocker);
			}
			else if (evt.process.processType==ASyncProcess.PROCESS_AUDIO) {
				popups.openPopup(popups.audioBlocker);
			}
		}
		
		private function onProcessingEnded(evt:ASyncProcessEvent):void {
			if (evt.process.processType==ASyncProcess.PROCESS_MODEL) {
				popups.closePopup(popups.modelBlocker);
			}
			else if (evt.process.processType==ASyncProcess.PROCESS_AUDIO) {
				popups.closePopup(popups.audioBlocker);
			}
		}
		
		private function onTalkStarted(evt:VHSSEvent):void {
			trace("talkStarted in main")
			//previewBtn.selected = true;
		}
		
		private function onTalkEnded(evt:VHSSEvent):void {
			trace("talkEnded in main")
			//previewBtn.selected = false;
		}
		
		/*
		public function ev_soundError() {
			audioBlocker._visible=false;
			showAlert("audioTimeout")
			panels.getCurrentPanel().talkEnded();
		}
		
		public function accessoryIncompatible(typeId:Number,state:Boolean,typeName:String) {
			panels.getCurrentPanel().accessoryIncompatible(typeId,state,typeName)
		}
		
		public function accessoryLoaded(typeId:Number,mcs:Array) {
			trace("accessory loaded")
			accBlocker._visible=false;
		}
		
		public function accessoryLoadError() {
			accBlocker._visible=false;
			showAlert("accessoryLoadError")
		}*/
	
		
		
		
		//save/cancel
		
		private function onSaveClick(evt:SendEvent):void {
			var btnName:String = evt.sendMode;
			
			if (btnName=="saveBtn") saveWithMode("save");
			else if (btnName=="publishBtn") {
				trace("publishing : Sesionvars.embedMode="+SessionVars.embedMode);
				if (SessionVars.embedMode) saveWithMode("embedcode");
				else saveWithMode("publish");
			}
			else if (btnName == "embedBtn") {
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp104", "<embed demo message goes here>"));
			}
			else if (btnName == "sendBtn") saveWithMode("email")
			else if (btnName == "cancelBtn") {
				publishMode="cancel";
				closeWin();
			}
		}
		
		private function saveWithMode($publishMode:String):void {
			trace("main::saveWithMode - " + $publishMode);
			publishMode = $publishMode;
			if (show.scene.model != null && !show.scene.model.isOwned && !show.scene.model.is3d) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp105","You must purchase this model before saving."));
				return;
			}
			saveRegistered();
		}
	
		private function onEmail(evt:SendEvent):void {
			publishEvent = evt;
			save();
		}
		
		private function onPublishScene(evt:SendEvent):void {
			evt.messageXML.@PARTNERID=SessionVars.partnerId;
			for (var paramName:String in loaderInfo.parameters) {
				if (paramName.indexOf("partner_")==0) evt.messageXML["@"+paramName.toUpperCase()]=loaderInfo.parameters[paramName];
			}
			evt.messageXML.@JUSTREGISTERED=SessionVars.justRegistered?"1":"0";
			publishEvent = evt;
			saveRegistered();
		}
		
		private function onEmbedClose(evt:Event):void {
			closeWin();
		}
		
		private function saveRegistered():void {
			save();	
		}
			
		public function registerDone(in_userId:String,in_acc:String,in_show:String=null):void {
			SessionVars.userId = parseInt(in_userId);
			SessionVars.acc = parseInt(in_acc);
			SessionVars.showId = in_show == null?0:parseInt(in_show);
			SessionVars.justRegistered = true;
			save();
		}
		
		private var saving_char_type_3d:Boolean;
		
		private function save():void {
			playerController.compileScene();						
			
			var postVars:URLVariables = new URLVariables();
			
			if ((SPHostStruct(playerController.scene.model).is3d || SPHostStruct(playerController.scene.model).type.toLowerCase() == "3d" || SPHostStruct(playerController.scene.model).type.toLowerCase() == "host_3d"))
			{
				saving_char_type_3d = true;
				
				postVars.charURL = SPHostStruct(playerController.scene.model).url;// origVars.oa1File
				postVars.thumbURL = SPHostStruct(playerController.scene.model).thumbUrl;// origVars.thumbUrl;				
				postVars.modelId = SPHostStruct(playerController.scene.model).id;
				postVars.charType = 1;
			}
			else
			{
				saving_char_type_3d = false;				
				postVars.charURL = playerController.scene.char.url;								
				postVars.modelId = playerController.scene.char.model.id;
				postVars.charType = 0;
			}
			
			postVars.charId = SessionVars.charEdit_charId;
			postVars.charName = charNameTF.text;
			postVars.showId = SessionVars.showId;
			postVars.accId = SessionVars.acc;
			
			
			
			
			/*
			var paramsXML:XML = <HOST />;
			paramsXML.@OHURL = playerController.scene.char.url;
			paramsXML.@CHARACTER = SessionVars.charEdit_charId.toString();
			paramsXML.@PUPPET = playerController.scene.char.model.id.toString();
			paramsXML.@NAME = charNameTF.text;
			paramsXML.@MODE = "update";
			paramsXML.@USERID = SessionVars.userId.toString();
			paramsXML.@ACCID = SessionVars.acc.toString();
			paramsXML.@SHOW = SessionVars.showId.toString();
			paramsXML.@REFSSID = SessionVars.sceneId.toString();
			paramsXML.@V = "5";
			*/
			
			popups.saveBlocker.tf_msg.text="Saving ......";
			popups.openPopup(popups.saveBlocker);
						
			XMLLoader.sendAndLoad(SessionVars.localBaseURL + "savecharacterV5.php?rnd=" + (Math.random() * 100000),charSavedToDB, postVars, URLVariables);
			//trace("sending XML : " + paramsXML.);
			//var url:String = SessionVars.localBaseURL + "savecharacterV5.php?rand="+Math.floor(Math.random()*1000000);
			//XMLLoader.sendXML(url,saveDone,paramsXML);
		}
		
		private function charSavedToDB(urlVars:URLVariables):void
		{
			
			if (int(urlVars.OK) == 1)
			{
				SPHostStruct(playerController.scene.model).isDirty = false;
				SPHostStruct(playerController.scene.model).charId = urlVars.charId;
				if (!saving_char_type_3d)
				{
					if (thumbSaver == null) thumbSaver = new ThumbSaver(100, 100, true);
					thumbSaver.addEventListener(Event.COMPLETE, onThumbmailComplete);
					thumbSaver.saveThumb(playerController.playerMC, playerMC.playerHolder);			
				}
				else
				{
					popups.closePopup(popups.saveBlocker);
					dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp101", "Save successful.", null, sendDoneOK));	
				}
				
			}
			else
			{		
				popups.closePopup(popups.saveBlocker);
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp109", "Error saving character : "+urlVars.ERROR,{details:urlVars.ERROR},sendDoneOK));
			}
		}
		
		
		private function onThumbmailComplete(evt:Event):void
		{
			popups.closePopup(popups.saveBlocker);
			dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp101", "Save successful.", null, sendDoneOK));	
		}
		
		public function saveDone(_xml:XML):void {
			trace("saveDone: " + _xml);	
			popups.closePopup(popups.saveBlocker);

			if (_xml == null || _xml.@RES.toString().toLowerCase() != "ok") {
				var reason:String = (_xml == null)?"Invalid xml":_xml.@MSG;
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp107", "Error saving scene : "+reason,{details:reason}));
				return;
			}			
			if (!saving_char_type_3d)
			{
				if (thumbSaver == null) thumbSaver = new ThumbSaver(100, 100, true);
				thumbSaver.saveThumb(playerController.playerMC, playerMC.playerHolder);			
			}
			dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp101", "Save successful.", null, sendDoneOK));			
		}
		
		private function sendDoneOK(b:Boolean):void {
			closeWin();
		}
	
		private function matchSkinDimensions(skin1:SPSkinStruct, skin2:SPSkinStruct):Boolean {
			//returns false if 2 skins have different dimensions
			//returns true if 2 skins have same dimensions, or skins are null
			
			if (skin1 == null || skin2 == null) return(true);
			if (skin1.width==0||skin1.height==0||skin2.width==0||skin2.height==0) return(true);
			
			//test if skin aspect ratios are within 1% of each other
			var aspect1:Number = Math.round(skin1.width * 100 / skin1.height);
			var aspect2:Number = Math.round(skin2.width * 100 / skin2.height);
			return(aspect1==aspect2)
		}
	
		public function closeWin():void { //close down sitepal window
			if (publishMode == null) publishMode = "cancel";
			trace("closeWin in main : publishMode=" + publishMode)
			
			//getURL("javascript: saveDone('"+publishMode+"',"+SessionVars.showId+");");
			ExternalInterface.call("saveDone", publishMode, SessionVars.showId);
			publishMode = null;
			publishEvent = null;
		}
	}
	
}