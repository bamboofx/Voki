﻿package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.AudioEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.oddcast.event.AlertEvent;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class RenamePopup extends MovieClip {
		public var closeBtn:SimpleButton;
		public var okBtn:SimpleButton
		public var tf:TextField;
		private var audio:AudioData;
		private var _arrExistingAudioNames:Array;
		
		public function RenamePopup() {
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
			okBtn.addEventListener(MouseEvent.CLICK, onOK);
			tf.maxChars = 50;
		}
		
		public function initWithAudio($audio:AudioData, existingNames:Array) {
			audio = $audio;
			tf.text = audio.name;
			_arrExistingAudioNames = existingNames;
		}
		
		private function onOK(evt:MouseEvent) {	
			if (_arrExistingAudioNames != null)
			{
				if (_arrExistingAudioNames.indexOf(tf.text.toLowerCase()) >= 0)
				{
					dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp465","An audio by the name {audioName} already exists. Please try a different name.",{audioName:tf.text}));
					return;
				}
			}
			dispatchEvent(new Event(Event.CLOSE));
			if (newName!=audio.name) dispatchEvent(new AudioEvent(AudioEvent.SELECT, audio));
		}
		
		private function onClose(evt:MouseEvent) {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		public function get newName():String {
			return(tf.text);
		}
	}
	
}