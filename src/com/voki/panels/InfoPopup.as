﻿package com.voki.panels {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.ui.OCheckBox;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.AlertLookup;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class InfoPopup extends MovieClip {
		public var tf_title:TextField; //only for "about" popup
		public var tf_alert:TextField;
		private var callback:Function = null;
		//private var msgLookup:TranslationLookup;
		public var okBtn:SimpleButton;
		public var cancelBtn:SimpleButton;
		public var cb_so:OCheckBox;
		public var tf_so:TextField;		
		
		public var alertLookup:AlertLookup;
		
		public function InfoPopup() {
			okBtn.addEventListener(MouseEvent.CLICK, onOK, false, 0, true);
			if (cancelBtn!=null) cancelBtn.addEventListener(MouseEvent.CLICK, onCancel, false, 0, true);
		}
		
		protected function onOK(evt:MouseEvent) {
			dispatchEvent(new Event(Event.CLOSE));
			if (callback != null) callback(cb_so.selected);
			callback = null;
		}
		
		protected function onCancel(evt:MouseEvent) {
			dispatchEvent(new Event(Event.CLOSE));
			if (callback != null) callback(false);
			callback = null;
		}
		
		/*public function setMessageTable(messageTable:TranslationLookup) {
			msgLookup = messageTable;
		}*/
		
		public function alert(evt:AlertEvent) {
			var alertText:String;
			if (alertLookup == null) alertText = evt.text;
			else {
				alertText = alertLookup.translate(evt.code, evt.text, evt.moreInfo);
				if (tf_title != null) tf_title.text = alertLookup.titleOf(evt.code);
			}
			
			tf_alert.text=alertText;
			//visible = true;
			if (evt.callback != null) callback = evt.callback;
			
			//report error
			//ErrorReporter.report(evt,alertText);
		}
		
	}
	
}