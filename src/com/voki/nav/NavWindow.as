package com.voki.nav {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.ItemGroup;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class NavWindow extends MovieClip {
		public var win:MovieClip;
		
		public var tabHolder:Sprite;
		public var contents:Sprite;
		
		private var tabButtonClassName:String="sp_nav_win_tabBtn";
		private var tabGroup:ItemGroup;
		
		public function NavWindow():void {
			stop();
			tabGroup = new ItemGroup();
			tabGroup.addEventListener(SelectorEvent.SELECTED, tabSelected);
			tabHolder = win.tabHolder;
		}
		
		public function openWithTabs(tabNames:Array, tabWidth:Number = 0):void {
			clearTabs();
			if (tabNames.length == 0) return;
			if (tabWidth == 0) tabWidth = (win.bg.width-3) / tabNames.length;
			var classDefinition:Class = getDefinitionByName(tabButtonClassName) as Class;
			var tabBtn:NavButton;
			for (var i:int = 0; i < tabNames.length; i++) {
				//tabBtn = new classDefinition() as ButtonSelectorItem;
				tabBtn = new classDefinition() as NavButton;
				tabBtn.dynamicWidth = tabWidth+2;
				tabBtn.x = tabWidth * i
				tabHolder.addChild(tabBtn);
				tabGroup.registerItem(tabBtn, i, tabNames[i]);
			}
			gotoAndPlay(2);
		}
		
		public function clearTabs():void {
			var tabArr:Array = tabGroup.getItemArray();
			for (var i:int = 0; i < tabArr.length; i++) tabHolder.removeChild(tabArr[i]);
			tabGroup.clear();
		}
		
		private function tabSelected(evt:SelectorEvent):void {
			dispatchEvent(evt);
		}
		
		public function get selectedTab():int {
			if (!tabGroup.isSelected()) return( -1);
			return(tabGroup.getSelectedId());
		}
		public function set selectedTab(tabId:int):void {
			if (tabId == selectedTab) return;
			tabGroup.selectById(tabId);
		}
		public function getTabById(tabId:int):NavButton {
			return(tabGroup.getItemById(tabId) as NavButton);
		}
		public function setContents(panel:Sprite):void {
			removeContents();
			contents = panel;
			win.addChild(contents);
		}
		public function removeContents():void {
			if (contents == null) return;
			win.removeChild(contents);
			contents = null;
		}
	}
	
}