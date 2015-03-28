package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.audio.TTSVoice;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.utils.XMLLoader;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class EditTTSPopup extends TTSPanel {
		public var closeBtn:SimpleButton;
		
		public function EditTTSPopup() {
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
			addEventListener(AudioEvent.SELECT, audioSaved);
			_bEditMode = true;
		}
		
		public function initWithAudio(audio:TTSAudioData, existingNames:Array) {
			emotionPanel.visible = false;
			audioToEdit = audio;
			origEditName = audio.name;
			_arrExistingAudioNames = existingNames;
			if (audio.voice != null && audio.text != null) setupAndOpenPanel();
			else {
				showLoadingBar(true);
				var rand:String=Math.floor(Math.random() * 1000000).toString();
				var url:String=SessionVars.localBaseURL+"getAudioInfo.php?audioId="+audio.id+"&accId="+SessionVars.acc+"&rand="+rand;
				XMLLoader.loadXML(url, gotTTSInfo)
			}
		}
	
		public function gotTTSInfo(_xml:XML) {
			trace("EditTTSPopup::gotTTSInfo - " + _xml.toXMLString());
			if (_xml.@RES!="OK") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp414","Error retreiving tts audio text"));
				showLoadingBar(false);
				return;
			}
			var audioXML:XML = _xml.AUDIO[0];
			audioToEdit.voice = new TTSVoice(parseInt(audioXML.@VOICE), parseInt(audioXML.@ENGINE), parseInt(audioXML.@LANG));
			try 
			{
				audioToEdit.text = unescape(decodeURI(audioXML.@TEXT.toString())).replace(/\+/g, " ");
			}
			catch (e:Error)
			{
				audioToEdit.text = unescape(audioXML.@TEXT.toString()).replace(/\+/g, " ");
			}
						
			audioToEdit.ttsMode = true;
			
			showLoadingBar(false);
			setupAndOpenPanel();
		}
		
		private function setupAndOpenPanel() {
			initEmotions();
			tf_name.text = audioToEdit.name;
			trace("EditTTSPopup::steupAndOpenPanel " + audioToEdit.text);
			ttsText = audioToEdit.text;
			
			
			voiceSelector.selectVoice(audioToEdit.voice);
			populateEmotionsList( audioToEdit.voice.name);
			noTextEntered = false;
			
			
			openPanel();
		}
		
		private function onClose(evt:MouseEvent) {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function audioSaved(evt:AudioEvent) {
			//close the window when audio is successfully edited
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
	
}