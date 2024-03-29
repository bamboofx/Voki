﻿package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.FileUploadEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.utils.FileUploader;
	import com.oddcast.utils.XMLLoader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.SessionVars;
	import com.voki.data.SPAudioList;
	import com.voki.tracking.SPEventTracker;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class UploadAudioPanel extends MovieClip implements IPanel {
		public var nameBox:MovieClip;
		public var tf_filename:TextField;
		public var browseBtn:BaseButton;		
		public var uploadBtn:BaseButton;
		public var cb_normalization:OCheckBox;
		public var whatsThisBtn:SimpleButton;
		public var _arrExistingAudioNames:Array;
		
		private var uploader:FileUploader;
		public var loadingBar:MovieClip;
		
		public function UploadAudioPanel() {
			uploader = new FileUploader();
			uploader.addAudioFileType();
			uploader.addEventListener(FileUploadEvent.ON_SELECT, fileSelected);
			uploader.addEventListener(FileUploadEvent.ON_ERROR, onUploadError);
			uploader.addEventListener(FileUploadEvent.ON_DONE, onFinishUpload);
			loadingBar.visible = false;
			browseBtn.addEventListener(MouseEvent.CLICK, onBrowse);
			uploadBtn.addEventListener(MouseEvent.CLICK, onUpload);
			whatsThisBtn.addEventListener(MouseEvent.CLICK, whatsThis);
		}
		
		public function get tf_name():TextField {
			return(nameBox.tf_name as TextField);
		}
		public function openPanel() {
			uploadBtn.disabled = true;
			browseBtn.disabled = false;
		}
		
		public function closePanel() {
			
		}

//---------------------------------------------  UPLOADING  --------------------------------------------
		private function uploadAudio() {
			var normalization:uint=cb_normalization.selected?3:0;
			var url:String=SessionVars.localBaseURL+"upload.php?type=audio&name="+escape(tf_name.text)+"&PHPSESSID="+SessionVars.sessionId+"&normalization="+normalization;
			trace("upload in Uploadaudio url="+url)
			uploader.setUploadUrl(url,false);
			uploader.upload();
			loadingBar.visible = true;
			SPEventTracker.event("acup")
			browseBtn.disabled = true;
			uploadBtn.disabled = true;
		}
		
		private function getUploadedAudio() {
			var url:String=SessionVars.localBaseURL+"getUploaded.php?type=audio&rnd="+Math.floor(Math.random() * 100000);
			XMLLoader.loadXML(url,gotUploaded);
		}

		public function gotUploaded(_xml:XML) {
			trace("gotUploaded in Uploadaudio: " + _xml)
			loadingBar.visible = false;
			if (_xml.@RES=="ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp420","There was an error trying to upload your file. Please check your file & try again or use another file : {details}",{details:_xml.@MSG}))
				browseBtn.disabled = false;
				return;
			}
			
			var audioArr:Array = SPAudioList.parseAudioXML(_xml);
			if (audioArr == null || audioArr.length == 0) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp420","There was an error trying to upload your file. Please check your file & try again or use another file"))
				browseBtn.disabled = false;
				return;
			}
			
			//audio with highest id is the most recent
			audioArr.sortOn("id", Array.NUMERIC | Array.DESCENDING)
			var audio:AudioData = audioArr[0];
			audio.type = AudioData.UPLOADED;
			//audio.name = encodeURI(audio.name);
			
			browseBtn.disabled = false;
			dispatchEvent(new AudioEvent(AudioEvent.SELECT, audio));
		}
//---------------------------------------------  BUTTON CALLBACKS  --------------------------------------------
		public function whatsThis(evt:Event = null) {
			dispatchEvent(new AlertEvent("about","sp461"));
		}
		
		private function onBrowse(evt:MouseEvent) {
			uploader.browse();
		}

		private function onUpload(evt:MouseEvent) {
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
			
			uploadAudio();
		}

//---------------------------------------------  FILE UPLOAD CALLBACKS  --------------------------------------------

		private function fileSelected(evt:FileUploadEvent) {
			var filename:String = uploader.getFile().name;
			tf_filename.text = filename;
			if (tf_name.text.length==0) {
				tf_name.text=filename.slice(0,filename.lastIndexOf("."));
			}
			uploadBtn.disabled=false;
		}
		
		private function onUploadError(evt:FileUploadEvent) {
			//listener.showAlert("bgUploadError", err)
			loadingBar.visible = false;
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp421", "There was an error trying to upload your file. Please check your file & try again or use another file : {details}",{details:evt.data.msg}));
			browseBtn.disabled = false;
		}
		
		/*public function onStartUpload() {
			trace("start upload")
		}
		public function onUploadProgress(percent:Number) {
			trace("uploading: "+percent+"%")
		}*/
		private function onFinishUpload(evt:FileUploadEvent) {
			trace("upload finished")
			tf_name.text = "";
			tf_filename.text="";
			getUploadedAudio();
		}
		
		
	}
	
}