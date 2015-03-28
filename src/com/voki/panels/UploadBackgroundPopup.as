package com.voki.panels {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.FileUploadEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.utils.FileUploader;
	import com.oddcast.utils.XMLLoader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.FileFilter;
	import flash.text.TextField;
	import flash.utils.Timer;
	import com.voki.data.SessionVars;
	import com.voki.data.SPBackgroundList;
	import com.voki.data.SPBackgroundStruct;
	import com.voki.tracking.SPEventTracker;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class UploadBackgroundPopup extends MovieClip {
		public var browseBtn:BaseButton;
		public var uploadBtn:BaseButton;
		public var cancelBtn:BaseButton;
		public var tf_name:TextField;
		public var tf_filename:TextField;
		public var cb_resize:OCheckBox;
		public var resizeUI:MovieClip;
		public var loadingBar:MovieClip;
		
		private var uploader:FileUploader
		private var sessionId:String;
		private var listener:Object;
		//private var checkUploadTimer:Timer;
		private var _uploadedBG:SPBackgroundStruct;
		private var _data:SPBackgroundList;

		public function UploadBackgroundPopup() {
			browseBtn.addEventListener(MouseEvent.CLICK, browse);
			uploadBtn.addEventListener(MouseEvent.CLICK, upload);
			cancelBtn.addEventListener(MouseEvent.CLICK, closeWindow);
			
			uploader = new FileUploader();
			var fileTypeArr:Array = new Array();
			fileTypeArr.push(new FileFilter("Images (*.jpg *.jpeg)", "*.jpg;*.jpeg"));
			fileTypeArr.push(new FileFilter("Video (*.avi, *.wmv, *.mpg, *.mov)", "*.avi;*.wmv;*.mpg;*.mov"));
			fileTypeArr.push(new FileFilter("All supported types", "*.jpg;*.jpeg;*.avi;*.wmv;*.mpg"));
			uploader.fileTypeArr = fileTypeArr;
			uploader.setSizeLimit(8*1024);
			
			uploader.addEventListener(FileUploadEvent.ON_SELECT, fileSelected);
			uploader.addEventListener(FileUploadEvent.ON_ERROR, onUploadError);
			uploader.addEventListener(FileUploadEvent.ON_DONE, onFinishUpload);
			
			cb_resize = resizeUI.cb_resize;
			cb_resize.selected = true;
		}
		
		public function setData(data:SPBackgroundList):void
		{
			_data = data;
		}
		
		public function openWindow() {
			tf_name.text = "";
			tf_filename.text="";
			uploadBtn.disabled = true;
			cancelBtn.disabled=false;
			browseBtn.disabled = false;
			showLoadingBar(false);
			//this._visible=true;
		}
		
		public function closeWindow(evt:MouseEvent = null) {
			dispatchEvent(new Event(Event.CLOSE));
		}

		//button callbacks

		private function browse(evt:MouseEvent) {
			uploader.browse();
		}

		private function upload(evt:MouseEvent) {
			if (tf_name.text == "") return;
			
			if (_data.nameExists(tf_name.text.toLowerCase()))
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp305", "A background by the name {bgName} already exists. Please try a different name.",{bgName:tf_name.text}));
				showLoadingBar(false);
				return;
			}			
			
			var resizeNum:String=cb_resize.selected?"1":"0";
			var url:String=SessionVars.localBaseURL+"upload.php?type=bg&name="+escape(tf_name.text)+"&PHPSESSID="+SessionVars.sessionId+"&rz="+resizeNum;
			trace("upload bg - upload url=" + url)
			uploader.setUploadUrl(url);
			uploader.upload();
			showLoadingBar(true);
		}

		//fileuploader callbacks
		//public function fileSelected(filename:String) {
		private function fileSelected(evt:FileUploadEvent) {
			var filename:String = uploader.getFile().name;
			tf_filename.text = filename;
			if (tf_name.text=="") {
				tf_name.text=filename.slice(0,filename.lastIndexOf("."));
			}
			var extension:String = filename.slice(filename.lastIndexOf(".") + 1).toLowerCase();
			if (extension=="jpg"||extension=="jpeg") {
				resizeUI.visible = true;
			}
			else {
				resizeUI.visible = false;
				cb_resize.selected = false;
			}
			uploadBtn.disabled=false;
		}
		
		private function onUploadError(evt:FileUploadEvent) {
			//listener.showAlert("bgUploadError", err)
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp300", "Error uploading background : {details}",{details:evt.data.msg}));
			showLoadingBar(false);
		}
		
		/*public function onUploadProgress(percent:Number) {
			trace("uploading: "+percent+"%")
		}*/
		
		private function onFinishUpload(evt:FileUploadEvent) {
			
			
			trace("UploadBackground::onFinishUpload")
			SPEventTracker.event("edbgu");
			getUploadedBG();
/*
			//getUploadedBG();
			if (checkUploadTimer == null) checkUploadTimer = new Timer(2000);
			checkUploadTimer.addEventListener(TimerEvent.TIMER, checkBGUploaded);
			checkUploadTimer.reset();
			checkBGUploaded();
			*/
		}
		/*
		private function checkBGUploaded(evt:TimerEvent = null) {
			checkUploadTimer.stop();
			var rand:int = Math.floor(Math.random() * 100000);
			var url:String = SessionVars.localBaseURL + "uploadedStatus.php?type=bg&rand=" + rand
			XMLLoader.loadXML(url,gotBGStatus);
		}
		
		private function gotBGStatus(_xml:XML) {
			trace("UploadBackground::gotBGStatus - " + _xml);
			var res:String = _xml.@RES;
			if (res == "OK") getUploadedBG();
			else {
				//_global["setTimeout"](this, "checkBGUploaded", 2000);
				checkUploadTimer.start();
			}
		}
		*/
		
		private function getUploadedBG() {
			//checkUploadTimer.removeEventListener(TimerEvent.TIMER, checkBGUploaded);
			var rand:Number = Math.floor(Math.random() * 100000)
			var url:String = SessionVars.localBaseURL + "getUploaded.php?type=bg&as=3&rand=" + rand;
			XMLLoader.loadXML(url, gotUploadedBG);
		}
		
		private function gotUploadedBG(_xml:XML) {
			trace("UploadBackground::gotUploadedBG - "+_xml);
			//listener.gotUploadedBG(_xml);
			
			if (_xml.@RES=="ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp301", "There was an error trying to upload your file. Please check your file & try again or use another file : {details}", { details:_xml.@MSG } ));
				showLoadingBar(false);
				return;
			}
			var bgs:Array=SPBackgroundList.parseBgXML(_xml,SPBackgroundList.PRIVATE_CATEGORY);
			if (bgs.length==0) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp301", "There was an error trying to upload your file. Please check your file & try again or use another file"));
				showLoadingBar(false);
				return;
			}			
			
			bgs.sortOn("id", Array.NUMERIC | Array.DESCENDING);
			_uploadedBG=bgs[0];
			dispatchEvent(new Event("bgSelected"));
			
			showLoadingBar(false);
			closeWindow();
		}
		
		public function get uploadedBG():SPBackgroundStruct {
			return(_uploadedBG);
		}
		
		private function showLoadingBar(b:Boolean) {
			//uploadBtn.disabled(b);
			//cancelBtn.disabled(b);
			//browseBtn.disabled(b);
			loadingBar.visible = b;
		}
	}
	
}