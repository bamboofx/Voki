package com.voki.ui {
	import com.oddcast.ui.ThumbSelectorItem;
	import flash.display.Sprite;
	import com.voki.data.SPHostStruct;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ModelThumb extends ThumbSelectorItem {
		public var dollarSign:Sprite;
		
		override public function set data(o:Object):void {
			super.data = o;
			var model:SPHostStruct = o as SPHostStruct;
			dollarSign.visible = !model.isOwned;
		}
		
	}
	
}