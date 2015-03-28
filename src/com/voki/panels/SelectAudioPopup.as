package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.AudioPlayer;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.utils.ToolTipManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SPAudioList;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SelectAudioPopup extends MovieClip {
		public var audioSelector:Selector;
		public var scrollbar:OScrollBar;
		public var newAudioBtn:BaseButton;
		public var closeBtn:SimpleButton;
		public var loadingBar:MovieClip;
		public var _mcCreateNewAudioInstructions:MovieClip;
		
		public var data:SPAudioList;
		private var audioPlayer:AudioPlayer;
		private var initAudioId:int;
		
		public function SelectAudioPopup() {
			audioPlayer = new AudioPlayer();
			audioPlayer.addEventListener(Event.SOUND_COMPLETE, audioComplete);
			
			audioSelector.addScrollBar(scrollbar, true);
			audioSelector.addItemEventListener(AudioEvent.PREVIEW, playAudio);
			audioSelector.addItemEventListener(AudioEvent.STOP, stopAudio);
			audioSelector.addItemEventListener(AudioEvent.SELECT, selectAudio);
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
			if (SessionVars.editorMode == "SceneEditor")
			{
				newAudioBtn.visible = false;	
				_mcCreateNewAudioInstructions.visible = false;
			}
			else
			{
				newAudioBtn.addEventListener(MouseEvent.CLICK, createNewAudio);
			}
			
		}
		
		public function init(audio:AudioData = null) {
			ToolTipManager.reset();
			if (audio == null) initAudioId = -1;
			else initAudioId = audio.id;
			
			showLoadingBar(true);
			data.getAllAudios(populateAudios);
		}
		
		private function populateAudios(audioArr:Array) {
			showLoadingBar(false);
			audioSelector.clear();
			var audio:AudioData;
			ToolTipManager.add(audioSelector.add( -1, "No Audio", null, false) as DisplayObject, "No Audio");
			for (var i:int = 0; i < audioArr.length; i++) {
				audio = audioArr[i];
				ToolTipManager.add(audioSelector.add(audio.id, audio.name, audio, false) as DisplayObject, audio.name);
			}
			audioSelector.update();
			audioSelector.selectById(initAudioId);
		}
		
		private function showLoadingBar(b:Boolean) {
			loadingBar.visible = b;
		}
//---------------------------------------------------  CALLBCAKS  ------------------------------------------------------

		private function playAudio(evt:AudioEvent) {
			audioPlayer.play(evt.audio.url);
		}
		private function stopAudio(evt:AudioEvent) {
			audioPlayer.stop();
		}
		private function selectAudio(evt:AudioEvent) {
			audioPlayer.stop();
			dispatchEvent(new Event(Event.CLOSE));
			dispatchEvent(evt);
		}
		private function createNewAudio(evt:MouseEvent) {
			dispatchEvent(new Event(Event.CLOSE));
			dispatchEvent(new Event("createNewAudio"));
		}
		private function onClose(evt:MouseEvent) {
			audioPlayer.stop();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function audioComplete(evt:Event) {
			audioSelector.deselect();
		}
	}
	
}