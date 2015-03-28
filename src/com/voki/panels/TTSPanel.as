package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.AudioPlayer;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.audio.TTSVoice;
	import com.oddcast.audio.TTSVoiceList;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.event.VHSSEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.Selector;
	import com.oddcast.utils.XMLLoader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import com.voki.data.SessionVars;
	import com.voki.tracking.SPEventTracker;
	import com.voki.ui.AudioControls;
	import com.voki.ui.TTSVoiceSelector;
	
	import com.voki.ui.VoiceEmotionItem;
	import com.voki.data.VoiceEmotionsList;
	import com.voki.player.PlayerController;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class TTSPanel extends MovieClip implements IPanel {
		public var nameBox:MovieClip;
		public var tf_name:TextField;
		public var tf_TTS:TextField;
		public var tf_charsLeft:TextField;
		public var audioControls:AudioControls;
		public var voiceSelector:TTSVoiceSelector;
		public var previewBtn:BaseButton;
		public var saveBtn:BaseButton;
		public var loadingBar:MovieClip;
		
		public var voiceList:TTSVoiceList;
		private var lastPreviewedAudio:TTSAudioData;
		private var audioPlayer:AudioPlayer;
		private var defaultText:String;
		protected var noTextEntered:Boolean = true;
		protected var audioToEdit:TTSAudioData;
		private var isInited:Boolean = false;
		
		public var emotionsSupported:VoiceEmotionsList;
		public var emotionsSelector:Selector;
		public var emotionPanel:MovieClip;
		public var emoBtn:BaseButton;
		public var chosenEmotions:Array;
		public var prevBtn:BaseButton;
		public var nextBtn:BaseButton;
		private var player:PlayerController;
		
		private var _lastTTSVoice:TTSVoice;
		protected var _bEditMode:Boolean;
		private var _bPanelIsOpen:Boolean;
		public var getExistingAudioNames:Function;
		public var _arrExistingAudioNames:Array;
		public var origEditName:String;
		
		public function TTSPanel() {
			tf_name = nameBox == null?null:nameBox.tf_name as TextField;
			_bEditMode = false;
			loadingBar.visible = false;
			/*
			audioPlayer = new AudioPlayer();
			audioPlayer.addEventListener(AudioPlayer.SOUND_STARTED, audioStarted);
			audioPlayer.addEventListener(Event.SOUND_COMPLETE, audioFinished);
			*/
			
			previewBtn.addEventListener(MouseEvent.CLICK, onPreview);
			saveBtn.addEventListener(MouseEvent.CLICK, onSave);
			audioControls.addEventListener("play", onPreview);
			audioControls.addEventListener("stop", onStop);
			voiceSelector.addEventListener(AudioEvent.PREVIEW, onPreviewSample);
			voiceSelector.addEventListener(Event.SELECT, onVoiceSelected);
			
			tf_TTS.maxChars = SessionVars.ttsLimit;
			defaultText = tf_TTS.text;
			tf_TTS.addEventListener(Event.CHANGE, textChanged);
			tf_TTS.addEventListener(FocusEvent.FOCUS_IN, textFocus);
			tf_TTS.addEventListener(FocusEvent.FOCUS_OUT, textUnfocus);
			
			//tf_TTS.restrict="^<>[]";
			updateCharsLeft();
			
			audioToEdit = null;
			
			
		}
		
		public function setPlayer($player:PlayerController) {
			player = $player;
			player.addEventListener(VHSSEvent.TALK_STARTED, audioStarted);
			player.addEventListener(VHSSEvent.TALK_ENDED, audioFinished);
		}
		
		public function openPanel() {
			_bPanelIsOpen = true;
			if (!isInited) 
			{				
				tf_name.maxChars = 50;
				initEmotions();
				init();
			}
			else
			{
				lastPreviewedAudio = null;
				updateCharsLimit();
				updateCharsLeft();
			}
			setState(AudioControls.STOPPED);
		}
		
		protected function initEmotions()
		{
			emotionsSelector = emotionPanel.emotionsSelector;
			emotionPanel.closeBtn.addEventListener(MouseEvent.CLICK, onOpenEmotionPanel);
			emoBtn.disabled = true;
			emoBtn.addEventListener(MouseEvent.CLICK, onOpenEmotionPanel);
			emotionsSelector.addEventListener( SelectorEvent.SELECTED, emotionSelected );
			
			emotionsSupported = new VoiceEmotionsList();
			chosenEmotions = new Array();
			prevBtn = emotionPanel.prevBtn;
			nextBtn = emotionPanel.nextBtn;
			emotionsSelector.addScrollBtn(prevBtn, -1);
			emotionsSelector.addScrollBtn(nextBtn, 1);
		}
		
		public function closePanel() {
			_bPanelIsOpen = false;
		}
		
		private function init() {
			trace("TTSPanel::init");
			if (voiceList == null) throw(new Error("TTSPanel::set voice list first before calling openPanel()"));
			if (voiceList.isInited) {
				voiceSelector.init(voiceList);
				updateCharsLimit();
				isInited = true;
			}
			else {
				showLoadingBar(true);
				voiceList.addEventListener(Event.COMPLETE, gotVoiceListData);
				var url:String = SessionVars.baseURL + "getTTSList/partnerId=" + SessionVars.partnerId;
				voiceList.init(url);
			}
		}
		
		private function gotVoiceListData(evt:Event) {
			trace("TTSPanel::gotVoiceListData");
			voiceList.removeEventListener(Event.COMPLETE, gotVoiceListData);
			voiceSelector.init(voiceList);
			if (_bEditMode)
			{
				voiceSelector.selectVoice(audioToEdit.voice);
			}
			_lastTTSVoice = voiceSelector.getCurrentVoice();
			emotionsSupported.getVoiceEmotionInfo( emotionsReceived );
			updateCharsLimit();
			updateCharsLeft();
			isInited = true;
			showLoadingBar(false);
		}
		
		public function emotionsReceived():void
		{						
			if (voiceSelector.getCurrentVoice() != null)
			{
				populateEmotionsList( voiceSelector.getCurrentVoice().name );
				if (_bEditMode)
				{
					var regex:RegExp = /\b(\_\w*)\b/g;
					var emotions:Array = String(audioToEdit.text).match(regex);
					for (var i in emotions)
					{
						//trace("EditTTSPopup::steupAndOpenPanel adding to chosen:" + String(emotions[i]).substr(1));
						addToList(String(emotions[i]).substr(1));
					}
				}
			}
		}
		
		/**
		 * Populates the emotions selector 
		 * @param	_name - Name of the current voice
		 */
		public function populateEmotionsList( _name:String ):void
		{
			var tempArray:Array = emotionsSupported.getEmotionsByVoiceName( removeParentheticalContent( _name ) );
			emotionsSelector.clear(); 
			trace("populateEmotionsList::hasEmotions()=" + hasEmotions());
			if ( tempArray == null || tempArray.length == 0 ) { 				
				if (hasEmotions())
				{
					var msg:String = "The chosen voice does not support emotions. The current emotions will be cleared if you proceed";
					dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp462", msg, null, clearConfirm));
				}				
				else
				{
					_lastTTSVoice = voiceSelector.getCurrentVoice();
				}
				
				emoBtn.disabled = true;
				emotionPanel.visible = false;
			}
			else {				
				emoBtn.disabled = false;
				for (var i:int = 0; i < tempArray.length; i++)
				{
					trace("TTSPanel::emotionsSelector.add " + i + "->" + tempArray[i]);
					emotionsSelector.add( i, (i+1)+"."+tempArray[i] );
				}
				_lastTTSVoice = voiceSelector.getCurrentVoice();
			}
		}
		
		private function clearConfirm(b:Boolean) {
			if (b) { //confirmed
				tf_TTS.text = clearEmotions( tf_TTS.text );
				_lastTTSVoice = voiceSelector.getCurrentVoice();
			}
			else 
			{
				trace("TTSPanel::lastVoice name = " + _lastTTSVoice.name);
				voiceSelector.selectVoice(_lastTTSVoice);
				populateEmotionsList(_lastTTSVoice.name);
				
			}
		}
		
		
		/**
		 * Handles selection event from emotionSelector
		 */
		public function emotionSelected( sEvt:SelectorEvent ):void{
			trace("TTSPanel::emotionSelected ---  " + sEvt.id + " / " + sEvt.text);
			addToList( emotionsSelector.getItemById( sEvt.id ).text.split(".")[1]);
			chooseEmotion( emotionsSelector.getItemById( sEvt.id ).text.split(".")[1]);
			emotionsSelector.deselect();
		}
		
		/**
		 * Adds the cosmetic string representing the emotion to the textfield
		 */
		public function chooseEmotion( _emotion:String ):void{
			if (noTextEntered)
			{
				tf_TTS.text = "";
				noTextEntered = false;
			}
			trace("caretIndex=" + tf_TTS.caretIndex);
			var cursorIndex:int = tf_TTS.caretIndex;
			var s1:String = tf_TTS.text.substring(0, cursorIndex);
			var s2:String = tf_TTS.text.substring(cursorIndex);
			tf_TTS.text = s1 + " \\_" + _emotion + (s2.charAt(0)==" "?"":" ") + s2;
			cursorIndex += (_emotion.length + 3);
			tf_TTS.setSelection(cursorIndex, cursorIndex);			
		}
		
		/**
		 * Removes the cosmetic represention of an emotion
		 */ 
		public function clearEmotions( _string:String ):String {
			var returnString:String = _string;
			
			for (var i:int = 0; i < chosenEmotions.length; i++) 
			{
				trace( "TEST :: clearEmotions " + chosenEmotions[i] );
				returnString = returnString.replace( (" \\_"+chosenEmotions[i]+"") , ("") );
				//returnString = returnString.replace( ("\_"+chosenEmotions[i]+"") , ("") );
			}
			
			return returnString;
		}
		
		/**
		 * Checks if there is an emotion in the text
		 */ 
		public function hasEmotions():Boolean {
			var testString:String = tf_TTS.text;
			
			for (var i:int = 0; i < chosenEmotions.length; i++) 
			{
				//if ( testString.indexOf( ("(\\_" + chosenEmotions[i] + ")") ) != -1 ) return true;
				if ( testString.indexOf( ("\_" + chosenEmotions[i] + "") ) != -1 ) return true;
			}
			
			return false;
		}
		
		public function addToList( _emotion:String ):void{
			trace( "TEST :: addToList :: "+ _emotion );
			if( chosenEmotions.indexOf( _emotion ) == -1 ) chosenEmotions.push( _emotion );
		}
		
		public function clearList():void{
			chosenEmotions = new Array();
		}
		
		/**
		 *  Removes parenthetical content from a string. Assumes there exist only one paren'and that it is located at the end of the string.
		 * @param	_string
		 * @return a clean string
		 */
		public function removeParentheticalContent( _string:String ):String{
			if( _string.indexOf( "(" )!= -1 )
			{
				var startIndex:uint = _string.indexOf( "(" );		
				_string = _string.substring( 0, startIndex );
				_string = _string.replace( " ", "" );
				return _string;
			} 
			else
			{
				return _string;
			}
		}
		
		protected function get ttsText():String {
			var isFocus:Boolean;
			if (stage == null) isFocus = false;
			else isFocus = (stage.focus == tf_TTS);
			if (noTextEntered&&!isFocus) return("");
			else return(tf_TTS.text);
		}
		
		protected function set ttsText(s:String) {
			if (s == null || s == "") {
				noTextEntered = true;
				if (stage.focus == tf_TTS) tf_TTS.text == "";
				else tf_TTS.text = defaultText;
			}
			else tf_TTS.text = s;
			updateCharsLeft();
			updateSaveBtn();
		}
		
		private function textIsBlank():Boolean {
			var str:String = ttsText;
			if (str==null||str.length==0) return(true);
			
			//faster implementation
			var blankTest:RegExp=/[^.,;:?!'() \t\n\r"\\\^\/]/;
			return(!blankTest.test(str));			
		}
		
		private function stopTTS() {
			player.stopAudio();
			//audioPlayer.stop();
			setState(AudioControls.STOPPED);
		}
			
		private function saveTTS() {
			if (!SessionVars.ttsEnabled) {
				if (SessionVars.loggedIn) dispatchEvent(new AlertEvent("upgrade", "sp411","Text-To-Speech functionality is not available for your account."));
				else dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp412","Text-To-Speech functionality is not available for your account."));
				return;
			}
			if (tf_name.text.length==0) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp404","Please title your audio"));
				return;
			}
			
			if (_arrExistingAudioNames != null)
			{
				if (_bEditMode)
				{
					if (_arrExistingAudioNames.indexOf(tf_name.text.toLowerCase()) >= 0 && origEditName.toLowerCase()!=tf_name.text.toLowerCase())
					{
						dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp465","An audio by the name {audioName} already exists. Please try a different name.",{audioName:tf_name.text}));
						return;
					}
				}
				else
				{
					if (_arrExistingAudioNames.indexOf(tf_name.text.toLowerCase()) >= 0)
					{
						dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp465","An audio by the name {audioName} already exists. Please try a different name.",{audioName:tf_name.text}));
						return;
					}
				}
			}
			stopTTS();
			setState(AudioControls.PROCESSING);

			//broadcastMessage("addAudioToScene",audio)
			var curVoice:TTSVoice=voiceSelector.getCurrentVoice();
			var audioUrl:String=lastPreviewedAudio.url;
			audioUrl=audioUrl.slice(0,audioUrl.indexOf("?"))
			trace("saveTTS in AudioTTS.as: "+audioUrl)
			
			var sendVars:URLVariables = new URLVariables();
			sendVars.type="audio";
			sendVars.name=encodeURI(tf_name.text);
			sendVars.ttsurl=audioUrl;
			sendVars.text = encodeURI(ttsText.replace(/\\/g, "\\\\"));
			sendVars.engineId=curVoice.engineId
			sendVars.langId = curVoice.langId;
			sendVars.voiceId=curVoice.voiceId
			if (audioToEdit != null) {
				sendVars.replaceId = audioToEdit.id;
				if (audioToEdit.fx != null) {
					sendVars.previewFX = "1";
					sendVars.fx = audioToEdit.fx.code;
				}
			}
			var url:String=SessionVars.localBaseURL+"upload.php";
			XMLLoader.sendVars(url, parseSaveResponse, sendVars);
		}

		private function parseSaveResponse(_xml:XML) {
			trace("parseSaveResponse in AudioTTS:"+_xml)
			setState(AudioControls.STOPPED);
			if (_xml.@RES!="OK") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp413","Error saving your audio"));
				return;
			}
			
			var audioId:int = parseInt(_xml.@ID);
			var audio:TTSAudioData;
			if (audioToEdit != null && audioToEdit.id == audioId) {
				audio = audioToEdit;
				audio.text = ttsText;
				audio.voice = voiceSelector.getCurrentVoice();
			}
			else audio = new TTSAudioData(ttsText, voiceSelector.getCurrentVoice(), audioId);
			audio.name = tf_name.text;
			
			//reset text field
			ttsText = "";
			tf_name.text = "";
			
			//lastPreviewedAudio = null;
			SessionVars.audioDirty = false;
			dispatchEvent(new AudioEvent(AudioEvent.SELECT, audio));
		}
		
		private function setState(state:String) {
			audioControls.state=state;
			previewBtn.disabled = (state != AudioControls.STOPPED);
			updateSaveBtn();
		}
		
		private function updateSaveBtn() {
			var audio:TTSAudioData;
			/*
			if (getCurrentAudio()!=null && _bPanelIsOpen)
			{
				if (getCurrentAudio().url != player.scene.audio.url && lastPreviewedAudio!=null)
				{
				trace("TTSPanelset audioDirty to true");
				SessionVars.audioDirty = true;
				}
			}
			*/
			if (textIsBlank() || voiceSelector.getCurrentVoice() == null) audio = null;
			else audio = getCurrentAudio();
			if (audioControls.state == AudioControls.STOPPED &&audio!=null && lastPreviewedAudio!=null&&lastPreviewedAudio.url == audio.url) saveBtn.disabled = false;
			else saveBtn.disabled = true;
			
			if (!saveBtn.disabled && _bPanelIsOpen)
			{
				SessionVars.audioDirty = true;
			}
			//trace("--updateSaveBtn - " + audioControls.state + "  --  " + (audio==null?"null":audio.url) + " -- " + (lastPreviewedAudio==null?"null":lastPreviewedAudio.url));
			
		}
		
		private function updateCharsLeft() {
			tf_charsLeft.text=(tf_TTS.maxChars-ttsText.length).toString()+" characters remaining"
		}
		
		protected function showLoadingBar(b:Boolean) {
			loadingBar.visible = b;
		}
//-------------------------------------------  CALLBACKS  -----------------------------------------------
		
		private function textChanged(evt:Event) {
			updateSaveBtn();
			updateCharsLeft();
		}
		
		private function textFocus(evt:FocusEvent) {
			if (noTextEntered) tf_TTS.text = "";
		}
		
		private function textUnfocus(evt:FocusEvent) {
			if (tf_TTS.text.length == 0) {
				tf_TTS.text = defaultText;
				noTextEntered = true;
			}
			else noTextEntered = false;
		}

		private function onVoiceSelected(evt:Event) {
			updateCharsLimit();
			updateSaveBtn();			
			populateEmotionsList( voiceSelector.getCurrentVoice().name );
			
		}
		
		public function updateCharsLimit()
		{
			tf_TTS.maxChars = voiceSelector.getLangCharLimit();
			updateCharsLeft();			
		}

		private function onPreviewSample(evt:AudioEvent) {
			if (evt.audio == null) return;
			if (audioControls.state != AudioControls.STOPPED) return;
			setState(AudioControls.PROCESSING);
			dispatchEvent(new AudioEvent(AudioEvent.STOP));
			player.playAudio(new AudioData(evt.audio.url));
			//audioPlayer.play(evt.audio.url);
		}

		private function getCurrentAudio():TTSAudioData {
			if (textIsBlank() || voiceSelector.getCurrentVoice() == null) return(null);
			var audio:TTSAudioData = new TTSAudioData(ttsText, voiceSelector.getCurrentVoice());
			if (audioToEdit!=null&&audioToEdit.hasFX()) {
				audio.fx = audioToEdit.fx;
				trace("in playTTS audio.setFX")
			}
			return(audio);
		}
		
		private function onPreview(evt:Event) {
			if (textIsBlank()) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp415", "Please enter some text."));
				return;
			}
			var audio:TTSAudioData = getCurrentAudio();
			if (audio == null) return;
			if (lastPreviewedAudio!=null&&audio.url != lastPreviewedAudio.url) SPEventTracker.event("actts");
			lastPreviewedAudio=audio;
			setState(AudioControls.PROCESSING);
			SPEventTracker.event("aptts");
			dispatchEvent(new AudioEvent(AudioEvent.STOP));
			player.playAudio(new AudioData(audio.url));
			//audioPlayer.play(audio.url);
		}
		
		private function onOpenEmotionPanel(evt:MouseEvent) {
						
			emotionPanel.visible = !emotionPanel.visible;
		}
		
		private function onStop(evt:Event) {
			stopTTS();
		}
		
		private function onSave(evt:MouseEvent) {
			saveTTS();
		}
		
		private function audioStarted(evt:Event) {
			setState(AudioControls.PLAYING);
		}
		
		private function audioFinished(evt:Event) {
			setState(AudioControls.STOPPED);
		}
	}
	
}