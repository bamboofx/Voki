package com.voki.panels {
	import com.adobe.utils.StringUtil;
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.MicRecorderEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.ToggleButton;
	import com.oddcast.utils.XMLLoader;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.system.SecurityPanel;
	import flash.text.TextField;
	import com.voki.data.SessionVars;
	import com.voki.data.SPAudioList;
	import com.voki.tracking.SPEventTracker;
	import com.voki.ui.AudioControls;
	import com.voki.ui.RecordingTimerBar;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class MicPanel extends MovieClip implements IPanel {
		public var nameBox:MovieClip;
		public var recTimer:RecordingTimerBar;
		public var tf_maxTime:TextField;
		public var recBtn:ToggleButton;
		public var saveBtn:BaseButton;
		public var audioControls:AudioControls;
		
		public var orcLoader:Loader;
		private var orc:*;
		private var isInited:Boolean;
		private var orcReady:Boolean = false;
		private var status:int;
		public var _arrExistingAudioNames:Array;
		
		public function MicPanel() {
			recBtn.getChildByName("recBtn").addEventListener(MouseEvent.CLICK, onRec);
			recBtn.getChildByName("stopRecBtn").addEventListener(MouseEvent.CLICK, onStopRec);
			saveBtn.addEventListener(MouseEvent.CLICK, onSave);
			audioControls.addEventListener("play", onPlay);
			audioControls.addEventListener("stop", onStop);
			recTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeup);
			//setMaxTime(60);
		}
		
		
		public function openPanel() {
			//if (!isInited) {
				setMaxTime(SessionVars.audioTimeLimit);
				tf_name.maxChars = 50;
				loadORC();
			//}
			setButtonState(AudioControls.NOAUDIO);
		}
		public function closePanel() {
			/*on unload:
			 * 
			*/
			if (orc != null)
			{
				orc.orc_disconnect();
				unloadORC();			
			}
			if (recTimer != null)
			{
				recTimer.stopTimer();
				recTimer.reset();
			}
			
			if (audioControls.state == AudioControls.PLAYING) onStop(null);
			else if (audioControls.state == AudioControls.RECORDING) onStopRec(null);
		}
		
		public function get tf_name():TextField {
			if (nameBox == null) return(null);
			return(nameBox.tf_name as TextField);
		}
		
		private function setMaxTime(n:Number) {
			tf_maxTime.text = Math.round(n).toString();
			recTimer.setTotalTime(n);
		}
		
		private function setButtonState(state:String) {
			saveBtn.disabled = (state != AudioControls.STOPPED)
			recBtn.disabled = (state == AudioControls.PLAYING || state == AudioControls.PROCESSING);
			recBtn.btn = (state == AudioControls.RECORDING)?"stopRecBtn":"recBtn";
			audioControls.state = state;
			if (!saveBtn.disabled)
			{
				SessionVars.audioDirty = true;
			}
		}
//------------------------------------------ ORC init ------------------------------------------
		
		private function loadORC() { //step 1
			var appParams="account="+SessionVars.acc+"|admin="+SessionVars.adminId+"|doorID="+SessionVars.doorId+"|PHPSESSID="+SessionVars.sessionId+"|type=audio|FORMAT=MP3";
			var orcUrl:String=SessionVars.localURL+"/ORC_v3.swf?app=SITEPAL&uid="+SessionVars.sessionId+"&app_params="+escape(appParams);
			//orcUrl = "http://fms.dev.oddcast.com/ORC_v3.swf?app=Workshop&uid=1196882167&pageDomain=host.staging.oddcast.com&app_params=doorId=199|FORMAT=MP3&js=0"
			
			orcLoader=new Loader();
			orcLoader.contentLoaderInfo.addEventListener(Event.INIT, orcLoadDone,false,0,true);
			orcLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, orcLoadError,false,0,true);
			var orcContext:LoaderContext=new LoaderContext(false, new ApplicationDomain(),SecurityDomain.currentDomain);
			try {
				orcLoader.load(new URLRequest(orcUrl),orcContext);
			}
			catch (e:Error) {
				orcLoadError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}
		
		private function unloadORC()
		{
			orcLoader.contentLoaderInfo.removeEventListener(Event.INIT, orcLoadDone);
			orcLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, orcLoadError);
			orcLoader.unload();
			orc = null;
		}

		private function orcLoadError(evt:ErrorEvent) {
			dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp431","Error Loading ORC",{details:evt.text}));
		}
		
		private function orcLoadDone(evt:Event) {
			trace("ORC load step 4");
			orc=orcLoader.content as Object;
			orcLoader.visible=false;
			var orcEvents:EventDispatcher=orcLoader.contentLoaderInfo.sharedEvents;
			orcEvents.addEventListener(MicRecorderEvent.ERROR,onError,false,0,true);
			orcEvents.addEventListener(MicRecorderEvent.READY_STATE,onReadyStateChanged,false,0,true);
			orcEvents.addEventListener(MicRecorderEvent.SAVE_DONE,onSaveDone,false,0,true);
			orcEvents.addEventListener(MicRecorderEvent.STREAM_STATUS, onStreamStatusChange, false, 0, true);
			isInited = true;
			setButtonState(AudioControls.NOAUDIO);
		}
				
//------------------------------------------ ORC events ------------------------------------------

		public function onReadyStateChanged(evt:Event) { //step 4
			var ready:Boolean=(evt as Object).readyState;
			
			if (ready) {
				setButtonState(AudioControls.NOAUDIO);
				orcReady = true;
				orc.orc_setSilenceLevel(0);
			}
			else {
				setButtonState(AudioControls.PROCESSING);
			}
		}
		
		public function onError(evt:Event) {
			var msg:String=(evt as Object).message;
			dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp432","Mic Error",{details : msg})); //orc error
			//closeWin();
			setButtonState(AudioControls.NOAUDIO);
			recTimer.stopTimer();
		}
		
		public function onStreamStatusChange(evt:Event) {
			var oldStatus:int=(evt as Object).oldStatus;
			var newStatus:int=(evt as Object).newStatus;
			trace("ORC status changed --- old:"+oldStatus+"  new:"+newStatus);
			//0-none  1-recording  2-recorded  3-playback  4-paused
			status=newStatus;
			if (newStatus==1&&oldStatus!=1) {
				setButtonState(AudioControls.RECORDING);
				recTimer.startTimer();
			}
			else if (newStatus==2||newStatus==4) { //playback or recording finished
				if (oldStatus==1) recTimer.stopTimer(); //stop recording
				setButtonState(AudioControls.STOPPED);
			}
			else if (newStatus==3) setButtonState(AudioControls.PLAYING); //start playing
			else if (newStatus==5||newStatus==0) setButtonState(AudioControls.NOAUDIO);
		}

		public function onSaveDone(evt:Event) {
			
			var url:String = SessionVars.localBaseURL + "getUploaded.php?type=audio&rand=" + Math.round(Math.random() * 1000000);
			XMLLoader.loadXML(url,gotUploaded);
			/*
			var saveUrl:String=(evt as Object).message;
			saveUrl=StringUtil.trim(saveUrl);
			setButtonState(AudioControls.STOPPED);
			var audio:AudioData=new AudioData(saveUrl,-1,AudioData.MIC);
			closeWin();
			//dispatchEvent(new AudioEvent(AudioEvent.SELECT,audio));
			SPEventTracker.event("acmic");
			SPEventTracker.event("apmic");
			
			trace("ORC save done");
			*/
		}
		
		private function gotUploaded(_xml:XML) {
			trace("gotUploaded in AudioMic.as: "+_xml)
			/*<AUDIOS RES="OK" BASEURL="http://vhss-a.oddcast.com/ccs2/vhss/user/b6a/" PHPSESSID="a62f7e998ce10490878a55b2ba7b99f0">
	<AUDIO ID="4650020" URL="37533/audio/1182348202540_37533" TYPE="upload" NAME="micrtest1"/>
	</AUDIOS>*/
			if (_xml.@RES=="ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp433", "Failed to retrieve record by mic audio",{details:_xml.@MSG}));
				return;
			}
			
			var audioArr:Array = SPAudioList.parseAudioXML(_xml);
			if (audioArr==null||audioArr.length==0) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp433", "Failed to retrieve record by mic audio"));
				return;
			}
			//audio with highest id is the most recent
			audioArr.sortOn("id",Array.NUMERIC|Array.DESCENDING)
			var audio:AudioData = audioArr[0];
			audio.type = AudioData.MIC;
			//audio.name = encodeURI(audio.name);
			tf_name.text="";
			trace("ORC save done - "+audioArr[0].url+" in gotUploaded in AudioMic.as");
			
			recTimer.reset();
			setButtonState(AudioControls.NOAUDIO);
			SessionVars.audioDirty = false;
			dispatchEvent(new AudioEvent(AudioEvent.SELECT, audio));
		}

		
//------------------------------------------ ORC events ------------------------------------------

		//audio controls events
		private function onTimeup(evt:TimerEvent) {
			orc.orc_recordStop();
			setButtonState(AudioControls.PROCESSING);
		}
		private function onPlay(evt:Event) {
			setButtonState(AudioControls.PROCESSING);
			dispatchEvent(new AudioEvent(AudioEvent.STOP));
			orc.orc_play();
			SPEventTracker.event("apmic");			
		}
		private function onStop(evt:Event) {
			setButtonState(AudioControls.PROCESSING);
			orc.orc_stop();			
		}
		private function onRec(evt:MouseEvent) {
			var mic:Microphone = Microphone.getMicrophone();						
			if (mic.muted) 
			{
				recBtn.btn = "recBtn";
				Security.showSettings(SecurityPanel.PRIVACY);
			}
			else
			{
				setButtonState(AudioControls.PROCESSING);
				recTimer.reset();
				orc.orc_record();
			}
		}
		private function onStopRec(evt:MouseEvent) {
			setButtonState(AudioControls.PROCESSING);
			if (orc != null)
			{
				orc.orc_recordStop();			
			}
		}
		private function onSave(evt:MouseEvent) {
			if (tf_name.text=="") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp404", "Please title your audio"));
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
			
			
			orc.orc_save(escape(tf_name.text),3);
			setButtonState(AudioControls.PROCESSING)
			
		}
	}
	
}