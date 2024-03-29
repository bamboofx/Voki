﻿package com.voki.panels {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import com.voki.data.SessionVars;
	/**
	* ...
	* @author Sam Myer
	*/
	public class VoiceTalentPanel extends MovieClip implements IPanel {
		public var voiceBtn:SimpleButton;
		
		public function VoiceTalentPanel() {
			voiceBtn.addEventListener(MouseEvent.CLICK, openPopup);
		}
		public function openPanel() {
			if (SessionVars.mode==SessionVars.DEMO_MODE) voiceBtn.visible=false; //hide button in demo mode
		}
		public function closePanel() {
			
		}
		private function openPopup(evt:MouseEvent) {
			//var url:String = "https://www.oddcast.com/store/voiceTalents.php?departmentSku=RECORDINGSERVICES_EN";
			var url:String = "https://www.sitepal.com/store/voiceTalents.php?departmentSku=RECORDINGSERVICES_EN";
			navigateToURL(new URLRequest(url), "_blank");
			
		}
	}
	
}