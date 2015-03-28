package com.voki.panels {
	import com.oddcast.ui.OCheckBox;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class EmbedPopup extends MovieClip {
		public var tf_embed:TextField;
		public var cb_mailingList:OCheckBox
		public var closeBtn:SimpleButton;
		
		public function EmbedPopup() {
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
		}
		
		public function init(embedCode:String="") {
			tf_embed.text = embedCode;
			stage.focus = tf_embed;
			tf_embed.setSelection(0, tf_embed.text.length);
			//System.setClipboard(tf_embed.text);
		}
		
		private function onClose(evt:MouseEvent) {
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
	
}