package com.voki.ui {
	import com.oddcast.ui.ButtonSelectorItem;
	import com.oddcast.utils.ToolTipManager;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AccessoryTypeSelectorItem extends ButtonSelectorItem {
		public var icon:MovieClip;
		
		public function AccessoryTypeSelectorItem() {
			addEventListener(Event.REMOVED, onRemoved);
		}
		
		override public function set data(o:Object):void {
			icon.addChild(o as Sprite);
		}
		
		override public function set text(value:String):void {
			super.text = value;
			ToolTipManager.add(this, value);
		}
		
		private function onRemoved(evt:Event) {
			ToolTipManager.remove(this);
		}
	}
	
}