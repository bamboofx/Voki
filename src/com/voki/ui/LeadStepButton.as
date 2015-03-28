package com.voki.ui {
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.ISelectable;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class LeadStepButton extends BaseButton implements ISelectable {
		public var tf_stepNum:TextField;
		public var arrow:MovieClip;
		
		public function LeadStepButton() {
			arrow.gotoAndStop(1);
		}
		
		public function set selected(b:Boolean) {
			arrow.gotoAndStop(b?2:1);
		}
		
		public function get selected():Boolean {
			return(arrow.currentFrame == 2);
		}
	}
	
}