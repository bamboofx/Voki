﻿package com.voki.ui {
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.audio.TTSLanguage;
	import com.oddcast.audio.TTSVoice;
	import com.oddcast.audio.TTSVoiceList;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OComboBox;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class TTSVoiceSelector extends MovieClip {
		public var languageSelector:OComboBox;
		public var voiceSelector:OComboBox;
		public var sampleBtn:BaseButton;
		
		private var voiceList:TTSVoiceList;
		private var defaultVoice:TTSVoice;
		
		public function TTSVoiceSelector() {
			languageSelector.addEventListener(SelectorEvent.SELECTED, languageSelected);
			voiceSelector.addEventListener(SelectorEvent.SELECTED, voiceSelected);
			sampleBtn.addEventListener(MouseEvent.CLICK, previewSample);
		}
		
		public function init($voiceList:TTSVoiceList) {
			voiceList = $voiceList;
			populateLanguages();
		}
		
		private function populateLanguages() {
			var langArr:Array = voiceList.getLanguages();
			languageSelector.clear();
			var lang:TTSLanguage;
			for (var i:int = 0; i < langArr.length; i++) {
				lang = langArr[i];
				languageSelector.add(lang.id, lang.name,null,false);
			}
			languageSelector.update();
			
			//automatically select first language on list			
			if (langArr.length == 0) return;
			languageSelector.selectById(langArr[0].id);
			populateVoices();
		}
		
		private function populateVoices() {
			voiceSelector.clear();
			if (!languageSelector.isSelected()) return;
			defaultVoice = null;
			var langId:int = languageSelector.getSelectedId();
			var voiceArr:Array = voiceList.getVoicesByLanguageId(langId);
			var voice:TTSVoice;
			for (var i:int = 0; i < voiceArr.length; i++) {
				voice = voiceArr[i];
				trace("TTSVoiceSelector::populateVoices " + ((1000 * voice.engineId) + voice.voiceId) + ", " + voice.name + ", " + voice.voiceId + ", " + voice.engineId);
				if (voice.engineId == SessionVars.defaultVoiceEngingId && voice.voiceId == SessionVars.defaultVoiceId)
				{
					defaultVoice = voice;
				}
				voiceSelector.add((1000*voice.engineId)+voice.voiceId, voice.name, voice, false);
			}
			voiceSelector.update();
			
			//automatically select first voice on list
			//if english is the language
			if (voiceArr.length == 0) return;
			if (defaultVoice != null)
			{
				voiceSelector.selectById((1000 * defaultVoice.engineId) + defaultVoice.voiceId);
			}
			else
			{
				voiceSelector.selectById((1000 * voiceArr[0].engineId) + voiceArr[0].voiceId);
			}
		}
		
		public function getCurrentVoice():TTSVoice {
			if (!voiceSelector.isSelected()) return(null);
			else return(voiceSelector.getSelectedItem().data as TTSVoice);
		}
		
		public function selectVoice(voice:TTSVoice) {
			if (voice == null) return;
			trace("TSVoiceSelector::selectVoice " + voice.name);
			languageSelector.selectById(voice.langId);
			populateVoices();
			trace("TTSVoiceSelector::selectById " + voice.voiceId + " (" + voice.name + ")");
			voiceSelector.selectById(voice.voiceId>1000?voice.voiceId:((1000*voice.engineId)+voice.voiceId));// > 1000?(voice.voiceId - (1000 * voice.engineId)):voice.voiceId);
		}
		
		public function getLangCharLimit():int
		{
			var langArr:Array = voiceList.getLanguages();
			var lang:TTSLanguage;
			for (var i:int = 0; i < langArr.length; i++) {
				lang = langArr[i];
				//languageSelector.add(lang.id, lang.name,null,false);				
				if (languageSelector.getSelectedId() == lang.id)
				{
					trace("TTSVoiceSelector::getLangCharLimit "+lang.charLimitPercent+" of "+SessionVars.ttsLimit);
					return int(lang.charLimitPercent * SessionVars.ttsLimit);
				}
			}
			return int(SessionVars.ttsLimit)
		}
//-------------------------------------------  CALLBACKS  -----------------------------------------------

		private function languageSelected(evt:SelectorEvent) {
			populateVoices();
			dispatchEvent(new Event(Event.SELECT));
		}
		
		private function voiceSelected(evt:SelectorEvent) {
			dispatchEvent(new Event(Event.SELECT));
		}
		
		private function previewSample(evt:MouseEvent) {
			if (!languageSelector.isSelected() || !voiceSelector.isSelected()) return;
			
			var text:String = voiceList.getLanguageById(languageSelector.getSelectedId()).sampleText;
			if (text == null || getCurrentVoice() == null) return;
			
			var audio:TTSAudioData = new TTSAudioData(text, getCurrentVoice());
			dispatchEvent(new AudioEvent(AudioEvent.PREVIEW, audio));
		}
	}
	
}