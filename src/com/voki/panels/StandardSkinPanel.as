package com.voki.panels {
	import com.oddcast.ui.BaseButton;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import com.voki.data.SPSkinStruct;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class StandardSkinPanel extends MovieClip implements IPanel {
		public var faqBtn:BaseButton;
		public var leadBtn:BaseButton;
		public var aiBtn:BaseButton;
		
		public function StandardSkinPanel() {
			faqBtn.addEventListener(MouseEvent.CLICK, typeSelected);
			leadBtn.addEventListener(MouseEvent.CLICK, typeSelected);
			aiBtn.addEventListener(MouseEvent.CLICK, typeSelected);
		}
		public function openPanel() {}
		public function closePanel() { }
		
		private function typeSelected(evt:MouseEvent) {
			var selectedTypeName:String;
			if (evt.target == faqBtn) selectedTypeName = SPSkinStruct.FAQ_TYPE;
			else if (evt.target == leadBtn) selectedTypeName = SPSkinStruct.LEAD_TYPE;
			else if (evt.target == aiBtn) selectedTypeName = SPSkinStruct.AI_TYPE;
			
			dispatchEvent(new TextEvent("select",false,false,selectedTypeName));
		}
	}
	
}