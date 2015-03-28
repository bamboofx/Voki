package com.voki.panels {
	import com.oddcast.audio.AudioPlayer;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OAccordion;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.ui.ToggleButton;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.LeadConfiguration;
	import com.voki.data.SkinConfiguration;
	import com.voki.nav.PopupController;
	import com.voki.panels.IPanel;
	import com.voki.player.PlayerController;
	import com.voki.ui.LeadStepButton;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class LeadSkinPanel extends MovieClip implements IPanel {
		public var step1:MovieClip;
		public var step2:MovieClip;
		public var step3:MovieClip;
		public var step4:MovieClip;
		public var stepSelector:OAccordion;
		
		private var tf_input1:TextField;
		private var tf_input2:TextField;
		private var tf_input3:TextField;
		private var tf_input4:TextField;
		private var tf_title:TextField;
		private var tf_email:TextField;
		private var tf_button:TextField;
		private var tf_progress:TextField;
		private var tf_success:TextField;
		private var tf_error:TextField;
		private var tf_successAudio:TextField;
		private var tf_errorAudio:TextField;
		private var successAudioBtn:BaseButton;
		private var errorAudioBtn:BaseButton;
		private var successPlayBtn:ToggleButton;
		private var errorPlayBtn:ToggleButton;
		private var cb_field2:OCheckBox;
		private var cb_field3:OCheckBox;
		
		public var player:PlayerController;
		public var popups:PopupController;
		private var audioPlayer:AudioPlayer;
		
		
		
		public function LeadSkinPanel() {
			trace("isaac LeadSkinPanel::");
			tf_email=step1.tf_email;
			
			tf_input1=step2.tf_input1;
			tf_input2=step2.tf_input2;
			tf_input3=step2.tf_input3;
			tf_input4=step2.tf_input4;
			tf_title=step2.tf_title;
			tf_button=step2.tf_button;
			tf_progress=step2.tf_progress;
			cb_field2=step2.cb_field2;
			cb_field3=step2.cb_field3;
			
			tf_success=step3.tf_success;
			tf_successAudio=step3.tf_successAudio;
			successAudioBtn=step3.successAudioBtn;
			successPlayBtn=step3.successPlayBtn;
			
			tf_error=step4.tf_error;
			tf_errorAudio=step4.tf_errorAudio;
			errorAudioBtn=step4.errorAudioBtn;
			errorPlayBtn=step4.errorPlayBtn;
			
			//set up accordion
			removeChild(step1);
			removeChild(step2);
			removeChild(step3);
			removeChild(step4);
			stepSelector.addTab(createBtn(1, "Recipient Settings"), step1);
			stepSelector.addTab(createBtn(2, "Field Customization"), step2);
			stepSelector.addTab(createBtn(3, "Success Message"), step3);
			stepSelector.addTab(createBtn(4, "Error Message"), step4);
			stepSelector.addEventListener(Event.RESIZE, tabOpened);
			
			//set up audio player
			audioPlayer = new AudioPlayer();
			audioPlayer.addEventListener(AudioPlayer.SOUND_STARTED, audioStarted);
			audioPlayer.addEventListener(Event.SOUND_COMPLETE, audioFinished);
			
			//set up textfields and add listeners
			var tfs:Array = [tf_email, tf_title, tf_input1, tf_input2, tf_input3, tf_input4, tf_button, tf_progress, tf_success, tf_error];
			var tf:TextField;
			for (var i:int = 0; i < tfs.length; i++) {
				tf = tfs[i];
				tf.tabIndex=100+i;
				tf.maxChars=80;
				tf.borderColor = 0x979797;
				//tf.addEventListener(FocusEvent.FOCUS_OUT, tfChanged);
				tf.addEventListener(Event.CHANGE, tfChanged);				
			}
			tf_email.restrict = "A-Z a-z 0-9 .@\\-_";
			
			successAudioBtn.addEventListener(MouseEvent.CLICK, selectSuccessAudio);
			errorAudioBtn.addEventListener(MouseEvent.CLICK, selectErrorAudio);
			
			cb_field2.addEventListener(MouseEvent.CLICK, onChecked);
			cb_field3.addEventListener(MouseEvent.CLICK, onChecked);
			successPlayBtn.getChildByName("playBtn").addEventListener(MouseEvent.CLICK, previewSuccessAudio);
			successPlayBtn.getChildByName("stopBtn").addEventListener(MouseEvent.CLICK, stopAudio);
			errorPlayBtn.getChildByName("playBtn").addEventListener(MouseEvent.CLICK, previewErrorAudio);
			errorPlayBtn.getChildByName("stopBtn").addEventListener(MouseEvent.CLICK, stopAudio);
		}
		
		private function tabOpened(evt:Event):void
		{
			trace("LeadSkinPanel::tabOpened");			
			audioPlayer.stop();
			audioFinished(null);
		}
		
		private function createBtn(stepNum:int, stepName:String):LeadStepButton {
			var btn:LeadStepButton = new sp_panel_skinLead_stepBtn();
			btn.text = stepName;
			btn.tf_stepNum.text = "Step " + stepNum.toString();
			return(btn);
		}
		
		public function openPanel() {
			if (config!=null) loadConfig();
		}
		public function closePanel() {
			audioPlayer.stop();
		}
		
		private function loadConfig() {
			var fields:Array=config.fields;
			cb_field2.selected = fields.length > 2;
			cb_field3.selected = fields.length > 3;
			tf_input1.text=fields[0];
			tf_input2.text = fields.length > 2?fields[1]:"";
			tf_input3.text = fields.length > 3?fields[2]:"";
			if (tf_input2.text.indexOf(LeadConfiguration.INVISIBLE_TOKEN) == 0)
			{
				tf_input2.text = tf_input2.text.substr(LeadConfiguration.INVISIBLE_TOKEN.length)
				cb_field2.selected = false;
			}
			if (tf_input3.text.indexOf(LeadConfiguration.INVISIBLE_TOKEN) == 0)
			{
				tf_input3.text = tf_input3.text.substr(LeadConfiguration.INVISIBLE_TOKEN.length)
				cb_field3.selected = false;
			}
			tf_input4.text=fields[fields.length-1];
			tf_title.text = config.title;
			tf_email.text = config.email;// config.email;
			tf_button.text = config.btnText;
			tf_progress.text = config.progressText;
			tf_error.text = config.errorText;
			tf_success.text = config.successText;
			if (config.successAudio==null) {
				tf_successAudio.text="None";
				successPlayBtn.visible=false;
			}
			else {
				tf_successAudio.text=config.successAudio.name
				successPlayBtn.visible=true;
			}
			if (config.errorAudio==null) {
				tf_errorAudio.text="None";
				errorPlayBtn.visible=false;
			}
			else {
				tf_errorAudio.text=config.errorAudio.name
				errorPlayBtn.visible=true;
			}
		}
		
		private function get config():LeadConfiguration {
			if (player == null) return(null);
			else if (player.scene == null) return(null);
			else if (player.scene.skin == null) return(null);
			else if (player.scene.skinConfig == null) return(null);
			else return(player.scene.skinConfig.lead);
		}
		
		private function saveConfig() {
			var fields:Array=new Array();
			fields.push(tf_input1.text);
			if (cb_field2.selected) fields.push(tf_input2.text) else fields.push(LeadConfiguration.INVISIBLE_TOKEN + tf_input2.text);
			if (cb_field3.selected) fields.push(tf_input3.text) else fields.push(LeadConfiguration.INVISIBLE_TOKEN + tf_input3.text);
			fields.push(tf_input4.text);
			config.fields=fields;
			config.title=tf_title.text;
			config.email=tf_email.text;
			config.btnText=tf_button.text;
			config.progressText=tf_progress.text;
			config.errorText=tf_error.text;
			config.successText=tf_success.text;
			//config.successAudio.name=tf_successAudio.text;
			//config.errorAudio.name=tf_errorAudio.text;
			player.updateSkinSettings();
		}

//----------------------------------------------  CALLBACKS  -------------------------------------------

		private function tfChanged(evt:Event) {
			trace("LeadSkinPanel::tfChanged ");
			saveConfig();
		}
		
		private function onChecked(evt:MouseEvent) {
			saveConfig();
		}
	
		private function selectSuccessAudio(evt:MouseEvent) {
			trace("LeadSkinPanel::selectSuccessAudio");
			popups.selectAudioWin.addEventListener(AudioEvent.SELECT, successAudioSelected);
			popups.openPopup(popups.selectAudioWin);
			popups.selectAudioWin.init(config.successAudio);
			//selectAudioWin.openWin(this,audioId,selectName);
			audioPlayer.stop();
		}
		private function selectErrorAudio(evt:MouseEvent) {
			trace("LeadSkinPanel::selectErrorAudio");
			popups.selectAudioWin.addEventListener(AudioEvent.SELECT,errorAudioSelected);
			popups.openPopup(popups.selectAudioWin);
			popups.selectAudioWin.init(config.errorAudio);
			//selectAudioWin.openWin(this,audioId,selectName);
			audioPlayer.stop();
		}
		
		private function successAudioSelected(evt:AudioEvent) {
			popups.selectAudioWin.removeEventListener(AudioEvent.SELECT, successAudioSelected);
			config.successAudio = evt.audio;
			successPlayBtn.visible=(evt.audio!=null); //hide button if "no audio" is selected
			tf_successAudio.text = (evt.audio == null)?"None":evt.audio.name;
			saveConfig();
			//skinModule.updateSkin();
		}
		private function errorAudioSelected(evt:AudioEvent) {
			popups.selectAudioWin.removeEventListener(AudioEvent.SELECT, errorAudioSelected);
			config.errorAudio = evt.audio;
			errorPlayBtn.visible=(evt.audio!=null); 
			tf_errorAudio.text = (evt.audio == null)?"None":evt.audio.name;
			saveConfig();
			//skinModule.updateSkin();
		}
		
		private function previewSuccessAudio(evt:MouseEvent) {
			
			audioPlayer.play(config.successAudio.url);
		}
		private function previewErrorAudio(evt:MouseEvent) {
			
			audioPlayer.play(config.errorAudio.url);
		}
		private function stopAudio(evt:MouseEvent) {
			audioPlayer.stop();
		}
		
		private function audioStarted(evt:Event) {
			trace("LeadSkinPanel::audioStarted");
			successPlayBtn.btn = "stopBtn";
			errorPlayBtn.btn = "stopBtn";
		}
		
		private function audioFinished(evt:Event) {
			trace("LeadSkinPanel::audioFinished");
			successPlayBtn.btn = "playBtn";
			errorPlayBtn.btn = "playBtn";
		}

		public function gotoAudioWin() {
		//	broadcastMessage("selectWin",4)
		}
	
	}
	
}