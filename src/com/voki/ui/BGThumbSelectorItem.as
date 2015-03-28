package com.voki.ui {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.ui.ThumbSelectorItem;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SPBackgroundStruct;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class BGThumbSelectorItem extends MovieClip implements SelectorItem {
		public var deleteBtn:BaseButton;
		public var bgType:MovieClip;
		public var thumb:ThumbSelectorItem;
		private var isSelected:Boolean = false;	
		
		public function BGThumbSelectorItem() {
			if (deleteBtn != null) deleteBtn.addEventListener(MouseEvent.CLICK, onDelete);
			thumb.addEventListener(SelectorEvent.SELECTED, onSelect);
		}
		
		private function onDelete(evt:MouseEvent) {
			dispatchEvent(new Event("deleteBg"));
		}
		
		private function onSelect(evt:SelectorEvent) {
			dispatchEvent(evt);
		}
		
		public function get id():int {
			return(thumb.id);
		}
		
		public function set id(in_id:int):void{
			thumb.id = in_id;
		}
		
		public function get text():String{
			return(thumb.text);
		}
		
		public function set text(in_text:String):void{
			thumb.text = in_text;
		}
		
		public function get data():Object{
			return(thumb.data);
		}
		
		public function select():void{
			thumb.select();
			setSelected(true);
		}
		
		public function deselect():void{
			thumb.deselect();
			setSelected(false);
		}
		
		public function shown(b:Boolean):void{
			thumb.shown(b);
		}
		
		public function set data(o:Object):void {
			thumb.data = o;
			var bg:SPBackgroundStruct = o as SPBackgroundStruct;
			if (bgType != null) {
				bgType.visible = (bg.url != null);
				if (bg.type==SPBackgroundStruct.VIDEO_TYPE) bgType.gotoAndStop("video");
				else bgType.gotoAndStop("image");
			}
			if (deleteBtn != null) deleteBtn.visible = (bg.url!=null && !isSelected && SessionVars.mode != SessionVars.DEMO_MODE);
		}
		
		private function setSelected(b:Boolean) {
			isSelected = b;			
			if (deleteBtn != null) 
			{
				/*
				if (isSelected)
				{
					deleteBtn.visible = false;
				}
				*/
				if (SPBackgroundStruct(thumb.data).url != null && SessionVars.mode != SessionVars.DEMO_MODE)
				{
					deleteBtn.visible = true;
				}
			}
		}
	}	
}