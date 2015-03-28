package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.AudioEffect;
	import com.oddcast.audio.AudioEffectList;
	import com.oddcast.audio.AudioEffectType;
	import com.oddcast.audio.AudioPlayer;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.Slider;
	import com.oddcast.utils.XMLLoader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.SessionVars;
	import com.voki.ui.AudioControls;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AudioEffectsPopup extends MovieClip {
		public var audioControls:AudioControls;
		public var fxSelector:Selector;
		public var scrollbar:OScrollBar;
		public var acceptBtn:BaseButton;
		public var cancelBtn:BaseButton;
		public var levelSlider:Slider;
		public var tf_audioName:TextField;
		
		private var NOFX_ID:int = -1;
		private var audio:AudioData;
		public var fxList:AudioEffectList;
		private var isInited:Boolean = false;
		private var curLevelStep:int;
		private var hasPreview:Boolean;
		private var previewFullUrl:String;
		private var previewRelUrl:String;
		private var audioPlayer:AudioPlayer;
		
		public function AudioEffectsPopup() {
			visible = false;
			fxSelector.addEventListener(SelectorEvent.SELECTED, fxSelected);
			fxSelector.addScrollBar(scrollbar, true);
			levelSlider.addEventListener(ScrollEvent.RELEASE, levelSelected);
			audioControls.addEventListener("play", onPlay);
			audioControls.addEventListener("stop", onStop);
			acceptBtn.addEventListener(MouseEvent.CLICK, onAccept);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);
			audioPlayer = new AudioPlayer();
			audioPlayer.addEventListener(AudioPlayer.SOUND_STARTED, audioStarted);
			audioPlayer.addEventListener(Event.SOUND_COMPLETE, audioFinished);
		}

		public function closeWin() {
			audioPlayer.stop();
			visible = false;
		}
//------------------------------------------------ INIT ------------------------------------------------

		public function openWithAudio($audio:AudioData) {
			trace("AudioEffectsPopup::openWithAudio");
			visible = true;
			
			audio = $audio;
			tf_audioName.text = audio.name;
			
			previewRelUrl=previewFullUrl="";
			hasPreview=false;
			
			cancelBtn.disabled = false;
			acceptBtn.disabled = true;
				
			if (isInited) {
				audioControls.state = AudioControls.STOPPED;
				selectEffect(audio.fx);
			}
			else {
				audioControls.state = AudioControls.PROCESSING;
				fxList.init(populateFX);
			}
		}
		
		private function populateFX() {
			trace("AudioEffectsPopup::populateFX");
			var fxTypeArr:Array = fxList.getEffectTypes();
			var fxType:AudioEffectType;
			fxSelector.add(NOFX_ID, "None");
			for (var i:int = 0; i < fxTypeArr.length; i++) {
				fxType = fxTypeArr[i];
				fxSelector.add(i, fxType.typeName,fxType.typeId);
			}
			selectEffect(audio.fx);
			acceptBtn.disabled = true;
			audioControls.state = AudioControls.STOPPED;
			isInited = true;
		}
		
		private function selectEffect(effect:AudioEffect) {
			//trace("AudioEffectsPopup::selectEffect - "+effect.type+" - "+fxList.getEffectTypeIds().indexOf(effect.type));
			//trace("AudioEffectsPopup::selectEffect cont. - "+fxList.getEffectTypeIds());
			if (effect == null) {
				fxSelector.selectById(NOFX_ID);
				levelSlider.visible = false;
			}
			else {
				fxSelector.selectById(fxList.getEffectTypeIds().indexOf(effect.type));
				var levels:Array = fxList.getEffectsByType(getSelectedType());
				var levelNo:int;
				for (var i:int = 0; i < levels.length; i++) {
					if ((levels[i] as AudioEffect).level == effect.level) levelNo = i;
				}
				populateLevels();
				if (levels.length > 1) levelSlider.step = levelNo;
			}
		}
		
		private function populateLevels() {
			trace("AudioEffectsPopup::populateLevels");
			var numLevels:uint;
			if (fxSelector.getSelectedId() == NOFX_ID) numLevels = 0;
			else numLevels = fxList.getEffectsByType(getSelectedType()).length;
			
			if (numLevels>1) {
				levelSlider.visible = true;
				levelSlider.totalSteps = numLevels;
				levelSlider.percent = 0.5; //select somewhere in the middle
				curLevelStep=levelSlider.step;
			}
			else {
				levelSlider.visible = false;
				curLevelStep = 0;
			}
		}
		
		private function getSelectedType():String {
			if (!fxSelector.isSelected() || fxSelector.getSelectedId() == NOFX_ID) return(null);
			else return(fxSelector.getSelectedItem().data as String);
		}
		
		private function getSelectedEffect():AudioEffect {
			var effectArr:Array = fxList.getEffectsByType(getSelectedType());
			if (effectArr.length == 0) return(null);
			else if (effectArr.length == 1 ) return(effectArr[0]);
			else return(effectArr[levelSlider.step]);
		}
		
		private function showLoadingBar(b:Boolean) {
			//if (b) loadingBar.gotoAndPlay(2);
			//else loadingBar.gotoAndStop(1);
		}

//------------------------------------------------ PROCESS ------------------------------------------------
		private function processEffect(accept:Boolean) {
			var effect:AudioEffect = getSelectedEffect();
			var effectCode:String = effect == null?"":effect.code;
			
			var url=SessionVars.adminURL+"saveFXAudio.php?curFX="+effectCode+"&audioId="+audio.id+"&acc_id="+SessionVars.acc+"&buttonPressed="+(accept?2:1)+"&rnd="+Math.random()*100000;
			if (accept) url+="&previewSWF="+previewRelUrl;
			audioControls.state=AudioControls.PROCESSING;
			acceptBtn.disabled=true;
			cancelBtn.disabled = true;
			showLoadingBar(true);
			XMLLoader.loadXML(url,processEffectComplete,accept)
		}

		public function processEffectComplete(_xml:XML, accept:Boolean) {
			trace("AudioEffectsPopup:processEffectComplete  ("+accept+") : "+_xml.toXMLString())
			showLoadingBar(false);
			
			if (_xml.hasOwnProperty("ERROR")||_xml.toXMLString().length==0) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp405", "Error generating effect",{details:_xml.@MSG}));
				return;
			}
			
			hasPreview=true;
			audioControls.state=AudioControls.STOPPED;
			acceptBtn.disabled = false;
			cancelBtn.disabled = false;
			
			if (accept) {
				audio.url = previewFullUrl;
				audio.fx = getSelectedEffect();
				dispatchEvent(new AudioEvent(AudioEvent.SELECT, audio));
				closeWin();
			}
			else {
				previewRelUrl=_xml.@NAME;
				previewFullUrl=_xml.@FULLNAME;
				previewCurrentAudio();
			}
		}
		private function previewCurrentAudio() {
			//trace("AudioEffectsPopup::previewCurrentAudio url=" + previewFullUrl);
			if (!hasPreview) return;
			audioPlayer.play(previewFullUrl);
		}
//------------------------------------------------ CALLBACKS ------------------------------------------------
		private function fxSelected(evt:SelectorEvent) {
			if (!isInited) return;
			
			hasPreview=false;
			acceptBtn.disabled=true;

			populateLevels();
		}
		private function levelSelected(evt:ScrollEvent) {
			if (!isInited) return;
			
			if (evt.step!=curLevelStep) {
				curLevelStep = evt.step;
				hasPreview=false;
				acceptBtn.disabled = true;
			}
		}
		
		private function onAccept(evt:MouseEvent) {
			processEffect(true);
		}
		private function onCancel(evt:MouseEvent) {
			closeWin();
		}
		private function onPlay(evt:Event) {
			if (hasPreview) previewCurrentAudio(); //preview is already generated
			else processEffect(false); //generate preview
		}
		private function onStop(evt:Event) {
			audioControls.state = AudioControls.STOPPED;
			audioPlayer.stop();
		}
		
		private function audioStarted(evt:Event) {
			audioControls.state = AudioControls.PLAYING;
		}
		private function audioFinished(evt:Event) {
			audioControls.state = AudioControls.STOPPED;
		}
	}
}