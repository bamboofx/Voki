﻿package com.voki.panels {
	import com.oddcast.audio.AudioPlayer;
	import com.oddcast.audio.TTSVoice;
	import com.oddcast.audio.TTSVoiceList;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.ui.OCheckBox;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.AIConfiguration;
	import com.voki.player.PlayerController;
	import com.voki.ui.TTSVoiceSelector;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AISkinPanel extends MovieClip implements IPanel {
		public var tf_aiButton:TextField;
		public var cb_response:OCheckBox;
		public var voiceSelector:TTSVoiceSelector;
		
		public var player:PlayerController;
		public var voiceList:TTSVoiceList;
		private var audioPlayer:AudioPlayer;
		private var isInited:Boolean = false;
		
		public function AISkinPanel() {
			audioPlayer = new AudioPlayer();
			
			tf_aiButton.addEventListener(Event.CHANGE, textChanged);
			cb_response.addEventListener(MouseEvent.CLICK, onShowReponse);
			voiceSelector.addEventListener(Event.SELECT, voiceSelected);
			voiceSelector.addEventListener(AudioEvent.PREVIEW, previewVoice);
		}
		
		private function get config():AIConfiguration {
			if (player == null) return(null);
			else if (player.scene == null) return(null);
			else if (player.scene.skin == null) return(null);
			else if (player.scene.skinConfig == null) return(null);
			else return(player.scene.skinConfig.ai);
		}
		
		public function openPanel() {
			if (voiceList == null || player == null) throw new Error("AISkinPanel : must set voiceList and player first");
			
			if (!voiceList.isInited) {
				voiceList.addEventListener(Event.COMPLETE, gotVoices);
				voiceList.init();
			}
			else init();
		}
		
		private function gotVoices(evt:Event) {
			voiceList.removeEventListener(Event.COMPLETE, gotVoices);
			init();
		}
		
		private function init() {
			if (!isInited) {
				voiceSelector.init(voiceList);
				isInited = true;
			}
			if (config != null) loadConfig();
		}
		
		public function closePanel() {
			audioPlayer.stop();
		}
		
		private function loadConfig() {
			cb_response.selected = config.showResponse;
			tf_aiButton.text = config.btnText;
			if (config.voice == null) config.voice = voiceSelector.getCurrentVoice();
			else 
			{
				
				var adjustedVoice:TTSVoice = new TTSVoice(config.voice.voiceId + (1000 * config.voice.engineId), config.voice.engineId, config.voice.langId);
				trace("AISkinPanel::voiceSelector.selectVoice " + adjustedVoice.voiceId + "," + adjustedVoice.langId);
				voiceSelector.selectVoice(adjustedVoice);
			}
		}
		private function saveConfig() {
			config.showResponse = cb_response.selected;
			config.btnText = tf_aiButton.text;
			config.voice = voiceSelector.getCurrentVoice();
			dispatchEvent(new Event("update"));
		}
		
//--------------------------------------------------------------------------------------		

		private function onShowReponse(evt:MouseEvent) {
			saveConfig();
		}
		private function textChanged(evt:Event) {
			if (tf_aiButton.text != config.btnText) saveConfig();
		}
		private function voiceSelected(evt:Event) {
			saveConfig();
		}
		private function previewVoice(evt:AudioEvent) {
			audioPlayer.play(evt.audio.url);
		}
	}
	
}