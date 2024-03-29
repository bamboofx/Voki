﻿package com.voki.ui {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AlignmentSelector extends MovieClip {
		public var btn1:SimpleButton;
		public var btn2:SimpleButton;
		public var btn3:SimpleButton;
		private var selectedId:int;
		private const alignNames:Array = ["left", "center", "right"];
		
		public function AlignmentSelector() {
			btn1.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			btn2.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			btn3.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			
			alignment = alignNames[0];
		}
		
		public function set alignment(s:String) {
			var id:int = alignNames.indexOf(s);
			if (id == -1) return;
			selectedId = id;
			gotoAndStop(id + 1);
		}
		
		public function get alignment():String {
			return(alignNames[selectedId]);
		}
		
		private function onClick(evt:MouseEvent) {
			var oldId:int = selectedId;
			if (evt.target == btn1) selectedId = 0;
			if (evt.target == btn2) selectedId = 1;
			if (evt.target == btn3) selectedId = 2;
			if (selectedId!=oldId) {
				gotoAndStop(selectedId + 1);
				dispatchEvent(new Event(Event.SELECT));
			}
		}
	}
	
}