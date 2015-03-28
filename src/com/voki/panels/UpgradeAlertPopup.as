package com.voki.panels {
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class UpgradeAlertPopup extends AlertPopup {
		public var upgradeBtn:SimpleButton;
		
		public function UpgradeAlertPopup() {
			upgradeBtn.addEventListener(MouseEvent.CLICK, onUpgrade);
		}
		
		private function onUpgrade(evt:MouseEvent) {
			ExternalInterface.call("upgradeAccount", SessionVars.acc);
			onOK(evt);
		}
		
	}
	
}