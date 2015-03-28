package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.AudioPlayer;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.PhoneRecorderEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.utils.XMLLoader;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import com.voki.data.SessionVars;
	import com.voki.tracking.SPEventTracker;
	import com.voki.ui.AudioControls;
	import com.voki.ui.RecordingTimerCountdown;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class PhonePanel extends MovieClip implements IPanel {
		public var nameBox:MovieClip;
		public var statusIcon:MovieClip;
		public var tf_accountId:TextField;
		public var tf_pin:TextField;
		public var tf_status:TextField;
		//public var tf_name:TextField;
		public var tf_tel_us:TextField;
		public var tf_tel_inter:TextField;
		public var saveBtn:BaseButton;
		public var instructBtn:SimpleButton;
		public var processing:MovieClip;
		public var audioControls:AudioControls;
		public var recTimer:RecordingTimerCountdown;
		public var _arrExistingAudioNames:Array;
		
		private var phoneAudio:AudioData;
		private var isInited:Boolean = false;
		public var otcLoader:Loader;
		private var otc:*;
		private var processingStatus:Boolean = false;
		private var audioPlayer:AudioPlayer;
		
		public function PhonePanel() {
			tf_tel_us.text="";
			tf_tel_inter.text = "";
			audioPlayer = new AudioPlayer();
			saveBtn.addEventListener(MouseEvent.CLICK, onSave);
			audioControls.addEventListener("play", onPlay);
			audioControls.addEventListener("stop", onStop);
			audioPlayer.addEventListener(AudioPlayer.SOUND_STARTED, audioStarted);
			audioPlayer.addEventListener(Event.SOUND_COMPLETE, audioFinished);
			instructBtn.addEventListener(MouseEvent.CLICK, showInstructions);
		}
		
		public function get tf_name():TextField {
			if (nameBox == null) return(null);
			return(nameBox.tf_name as TextField);
		}
		
		public function openPanel() {
			if (SessionVars.mode == SessionVars.DEMO_MODE)
			{
				instructBtn.visible = false;
			}
			phoneAudio = null;
			setButtonState(AudioControls.PROCESSING);
			statusIcon.gotoAndStop("disconnected")
			//processingStatus = false;
			tf_accountId.text=SessionVars.acc.toString();
			tf_pin.text=SessionVars.accountPin.toString();
			tf_status.text="Loading ..."
			recTimer.reset();
			
			if (isInited) otc.otc_restart();
			else {
				recTimer.setTotalTime(SessionVars.audioTimeLimit);
				tf_name.maxChars = 50;
				initOTC();
			}
		}
		public function closePanel() {
			stopAudio();
			if (otc!=null) otc.otc_stop();
		}
		
		private function setButtonState(state:String) {
			audioControls.state = state;
			saveBtn.disabled = (state != AudioControls.STOPPED);			
		}
//-------------------------------------------------------  INIT OTC ----------------------------------------------------
		private function initOTC() {
			trace("otc init");
			
			var extParam:String=SessionVars.acc.toString()+SessionVars.accountPin.toString();
			var otcUrl:String = SessionVars.otcURL + "?acc=" + SessionVars.doorId + "&app=" + SessionVars.otcAppName + "&extparam=" + extParam;
			//otcUrl = otcUrl.split("OTC.swf").join("OTCv3.swf"); //temporary
			
			otcLoader=new Loader();
			otcLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, otcLoadDone);
			otcLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, otcLoadError);
			otcLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, otcLoadError);
			try {
				otcLoader.load(new URLRequest(otcUrl));
			}
			catch (e:Error) {
				otcLoadError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}

		private function otcLoadError(evt:ErrorEvent) {
			dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp442","Error Loading OTC",{details:evt.text}));
		}
		
		private function otcLoadDone(evt:Event) {
			trace("ORC load step 4");
			isInited = true;
			otc=otcLoader.content as Object;
			otcLoader.visible=false
			addChild(otcLoader);
			
			var otcEvents:EventDispatcher = otcLoader.contentLoaderInfo.sharedEvents;
			otcEvents.addEventListener(PhoneRecorderEvent.LOADED,otc_onLoaded);
			otcEvents.addEventListener(PhoneRecorderEvent.PROCESSING,otc_onAudioProcessing);
			otcEvents.addEventListener(PhoneRecorderEvent.SAVEDONE,otc_onAudioReady);
			otcEvents.addEventListener(PhoneRecorderEvent.RECORDED,otc_onAudioRecorded);
			otcEvents.addEventListener(PhoneRecorderEvent.RECORDING,otc_onAudioStartRecord);
			otcEvents.addEventListener(PhoneRecorderEvent.CONNECTED,otc_onPhoneConnect);
			otcEvents.addEventListener(PhoneRecorderEvent.DISCONNECTED,otc_onPhoneDisconnect);
			otcEvents.addEventListener(PhoneRecorderEvent.IDLE,otc_onIdle);
			otcEvents.addEventListener(ErrorEvent.ERROR, otc_onError);
		}
//------------------------------------------------  AUDIO FNS ----------------------------------------------------
		private function stopAudio() {
			audioPlayer.stop();
			setButtonState(AudioControls.STOPPED);
		}
		
		private function saveAudio() {
			if (tf_name.text.length==0) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp404","Please title your audio"));
				return;
			}
			
			if (_arrExistingAudioNames != null)
			{
				if (_arrExistingAudioNames.indexOf(tf_name.text.toLowerCase()) >= 0)
				{
					dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp465","An audio by the name {audioName} already exists. Please try a different name.",{audioName:tf_name.text}));
					return;
				}
			}
			
			phoneAudio.name = tf_name.text;
			stopAudio();
			setButtonState(AudioControls.PROCESSING)
			var url:String=SessionVars.localBaseURL+"upload.php?&type=audio&name="+encodeURI(tf_name.text)+"&url="+escape(phoneAudio.url)+"&duration=10"+SessionVars.sessionId;
			XMLLoader.loadXML(url, parseSaveResponse);
		}
		
		public function parseSaveResponse(_xml:XML) {
			trace("AudioPhone::parseSaveResponse : " + _xml);
			if (_xml.@RES!="OK") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp441","Error saving your audio"));
				setButtonState(AudioControls.STOPPED)
				return;
			}
			phoneAudio.id = parseInt(_xml.@ID);
			tf_name.text="";
			setButtonState(AudioControls.NOAUDIO);
			SessionVars.audioDirty = false;
			dispatchEvent(new AudioEvent(AudioEvent.SELECT, phoneAudio));
		}

//---------------------------------------------  OTC CALLBACKS  -------------------------------------------------

		//STEP_1:
		public function otc_onLoaded(evt:Event){
			trace("PhonePanel::otc_onLoaded");
			SessionVars.audioDirty = false;
			var passcode:String=(evt as Object).passCode;
			var phoneNum:String = unescape((evt as Object).phoneNum);
			var telArr:Array=phoneNum.split(":");
			tf_tel_us.text=telArr[0];
			tf_tel_inter.text = telArr[1];
			
			tf_status.text = "Ready";
			statusIcon.gotoAndStop("disconnected");
			setButtonState(AudioControls.RECORDING);
		}
		
		//STEP_2:
		private function otc_onPhoneConnect(evt:Event) {
			trace("PhonePanel::otc_onPhoneConnect");
			SPEventTracker.event("edivr")
			tf_status.text="Connected";
			statusIcon.gotoAndStop("connected")
		}
		
		//STEP_3:
		private function otc_onAudioStartRecord(evt:Event){
			trace("PhonePanel::otc_onAudioStartRecord");
			recTimer.startTimer();
			
			tf_status.text="Recording";
			statusIcon.gotoAndStop("recording")
		}
		
		//STEP_4:
		private function otc_onAudioRecorded(evt:Event){
			trace("PhonePanel::otc_onAudioRecorded");
			tf_status.text="Recording Done";
			recTimer.stopTimer();
			statusIcon.gotoAndStop("recordingDone")
			SessionVars.audioDirty = true;
		}
		
		//STEP_5:
		private function otc_onAudioProcessing(evt:Event){
			trace("PhonePanel::otc_onAudioProcessing");
			tf_status.text="Processing ...";
			statusIcon.gotoAndStop("processing")
			processingStatus=true;
		}
		
		//STEP_6:
		private function otc_onAudioReady(evt:Event){
			var phoneAudioUrl:String = unescape((evt as Object).url);
			//phoneAudioUrl=unescape(in_url.slice(0,-4));

			trace("PhonePanel::otc_onAudioReady : "+phoneAudioUrl);
			
			SPEventTracker.event("acph")
			phoneAudio=new AudioData(phoneAudioUrl,-1,AudioData.PHONE);
			//broadcastMessage("previewAudio",phoneAudio); //you gotta do this to clear the audio

			setButtonState(AudioControls.STOPPED);
			tf_status.text = "Audio Ready";
			statusIcon.gotoAndStop("ready")
			processingStatus=false;
			//otc.otc_restart();
		}
		//STEP_7:
		private function otc_onPhoneDisconnect(evt:Event) {
			trace("PhonePanel::otc_onPhoneDisconnect");

			if (processingStatus==false&&phoneAudio==null) {
				tf_status.text="Not Saved";
				statusIcon.gotoAndStop("disconnected")
				setButtonState(AudioControls.NOAUDIO)
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp443", "Your phone connection has been reset", null, onIdleOK));
				//otc.otc_restart();
			}
			recTimer.stopTimer();
			//recTimer.hideTimer();
		}
		
		//TIMEOUT:
		private function otc_onIdle(evt:Event) {
			trace("PhonePanel::otc_onIdle");
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp443", "Your phone connection has been reset", null, onIdleOK));
			tf_status.text="Ready"
			statusIcon.gotoAndStop("disconnected")
			setButtonState(AudioControls.RECORDING)
			SessionVars.audioDirty = false;
		}
		
		private function onIdleOK(b:Boolean = false) {
			otc.otc_restart();		
		}
		
		//ON ERROR
		private function otc_onError(evt:ErrorEvent) {
			trace("PhonePanel::otc_onError");
			tf_status.text="Error";
			statusIcon.gotoAndStop("disconnected")
			setButtonState(AudioControls.NOAUDIO)
			dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp442","Phone error : "+evt.text,{details:evt.text}));
		}
//--------------------------------------------------  BUTTON CALLBACKS  ----------------------------------------------

		//button callback
		private function onPlay(evt:Event) {
			setButtonState(AudioControls.PROCESSING);
			dispatchEvent(new AudioEvent(AudioEvent.STOP));
			audioPlayer.play(phoneAudio.url);
			SPEventTracker.event("apph");
		}
		
		private function onStop(evt:Event) {
			stopAudio();
		}
		
		private function onSave(evt:MouseEvent) {
			saveAudio();			
		}
		
		private function showInstructions(evt:MouseEvent) {
			trace("javascript:printInstructions(0,0)")
			//getURL("javascript:printInstructions(0,0)")
			ExternalInterface.call("printInstructions", 0, 0)
		}
		
		private function audioStarted(evt:Event) {
			setButtonState(AudioControls.PLAYING);
		}
		
		private function audioFinished(evt:Event) {
			setButtonState(AudioControls.STOPPED);
		}
		
		/*other
		public function isUnsaved():Boolean {
			return(!saveBtn.isDisabled())
		}*/
	}
	
}