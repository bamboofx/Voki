﻿package com.voki.panels {
	import com.oddcast.ui.StickyButton;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import com.voki.data.SessionVars;
	import com.voki.player.PlayerController;
	import com.oddcast.player.PlayerInitFlags;
	import com.oddcast.event.VHSSEvent;
	/**
	* ...
	* @author Sam Myer
	*/
	public class IntroScreen extends MovieClip {
		public var welcomeHolder:MovieClip;
		public var playerHolder:MovieClip;
		public var playBtn:StickyButton;
		public var blocker:MovieClip;
		public var _mcCover:MovieClip;
		
		private var welcomeLoader:Loader;
		private var player:PlayerController;
		
		public function IntroScreen() {
		}
		
		public function init() {
			blocker.visible = true;
			
			player = new PlayerController(playerHolder);
			welcomeLoader = new Loader();
			welcomeHolder.addChild(welcomeLoader);
			var demoMode:String = (SessionVars.mode == SessionVars.DEMO_MODE)?"1":"0";
			//http://content.dev.oddcast.com/vhss_dev/admin/sitepal_v5.swf?PHPSESSID=524a50ff735e120c9e94b3bfd8999ccc&acc=7035&gShow=43776&gUserId=501&lc_name=sitepal_lc&gLoggedIn=1&gAlert=0&gAS=vhss-d.dev.oddcast.com&gDS=vhost.dev.oddcast.com&gEmail=am9uQG9kZGNhc3QuY29t
			var welcomeUrl:String=SessionVars.contentPath+"vhss_editors/sitepal_intro/sitepalv5_intro.swf?demoMode="+demoMode;
			welcomeLoader.contentLoaderInfo.addEventListener(Event.INIT, onWelcomeLoaded);
			welcomeLoader.load(new URLRequest(welcomeUrl));
		}
		
		public function stopAudio():void
		{
			if (player != null)
			{
				player.stopAudio();
			}
		}
		
		private function onWelcomeLoaded(evt:Event) {
			welcomeLoader.contentLoaderInfo.removeEventListener(Event.INIT, onWelcomeLoaded);
			welcomeLoader.content.addEventListener("introClose", onClose);
			var showUrl:String = SessionVars.introURL;// "http://vhss-d.dev.oddcast.com/php/playScene/acc=7035/ss=43776/editor=1/";
			//showUrl = "http://vhss-d.oddcast.com/php/playScene/acc=237929/ss=1750000";
			_mcCover.addEventListener(MouseEvent.CLICK, coverClicked);
			player.addEventListener(Event.INIT, onPlayerLoaded);			
			player.addEventListener(VHSSEvent.TALK_ENDED, onPlayerTalkEnded);			
			player.loadModelInfo = false;
			player.init(showUrl);
			blocker.visible = false;
		}
		
		private function coverClicked(evt:MouseEvent):void
		{
			//onClose(null);
		}
		
		private function onPlayerLoaded(evt:Event) {
			trace("SitepalV5::IntroScreen::onPlayerLoaded");
			player.removeEventListener(Event.INIT, onPlayerLoaded);	
			player.setPlayerInitFlags(PlayerInitFlags.SUPPRESS_PLAY_ON_CLICK);			
			dispatchEvent(new Event("introReady"));
			playBtn.select();
			playBtn.addEventListener(MouseEvent.CLICK, onPlayBtnClicked);
			player.replay();
			
		}
				
		public function destroy():void
		{
			onClose(null, true);
		}
		
		private function onPlayBtnClicked(evt:MouseEvent):void
		{
			if (!playBtn.selected)
			{
				player.stopAudio();
			}
			else
			{
				player.replay();
			}
		}
		
		private function onPlayerTalkEnded(evt:VHSSEvent):void
		{
			playBtn.deselect();
		}
		
		private function onClose(evt:Event, noDispatch:Boolean = false) {
			if ((welcomeLoader.content as Object).dontShow != null) {
				SessionVars.noIntro = (welcomeLoader.content as Object).dontShow();
			}
			playBtn.removeEventListener(MouseEvent.CLICK, onPlayBtnClicked);
			welcomeLoader.content.removeEventListener("introClose", onClose);
			welcomeLoader.unload();
			
			
				player.stopAudio();
				player.destroy();
			if (!noDispatch)
			{
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
	}
	
}