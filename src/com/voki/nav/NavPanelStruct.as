﻿package com.voki.nav {
	import flash.display.Sprite;
	import com.voki.panels.IPanel;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class NavPanelStruct {
		public var winId:int;
		public var tabId:int;
		public var tabName:String;
		public var mc:Sprite;
		public var enabled:Boolean;
		public var visible:Boolean;
		
		public function NavPanelStruct($winId:int,$tabId:int,$tabName:String,$mc:Sprite) {
			winId = $winId;
			tabId = $tabId;
			tabName = $tabName;
			mc = $mc;
			enabled = true;
			visible = true;
		}
	}
	
}