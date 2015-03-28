package com.voki.ui {
	import com.oddcast.ui.ThumbSelectorItem;
	import flash.display.MovieClip;
	import com.voki.data.SPSkinStruct;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SkinSelectorItem extends ThumbSelectorItem {
		public var medallion:MovieClip;
		
		override public function set data(o:Object):void {
			super.data = o;
			var skin:SPSkinStruct = o as SPSkinStruct;
			if (skin == null) medallion.visible = false;
			else if (skin.level<=1) {
				medallion.visible = false;
			}
			else
			{
				medallion.gotoAndStop(skin.level + 1);
			}
		}
	}
	
}