package com.voki.ui {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.ui.ThumbSelectorItem;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SPHostStruct;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ModelThumbSelectorItem extends MovieClip implements SelectorItem {
		public var deleteBtn:BaseButton;		
		public var dollarSign:MovieClip;
		public var thumb:ThumbSelectorItem;
		private var isSelected:Boolean = false;		
		
		public function ModelThumbSelectorItem() {
			if (deleteBtn != null) deleteBtn.addEventListener(MouseEvent.CLICK, onDelete);
			thumb.addEventListener(SelectorEvent.SELECTED, onSelect);
		}
		
		private function onDelete(evt:MouseEvent) {
			dispatchEvent(new Event("deleteModel"));
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
			var model:SPHostStruct = o as SPHostStruct;			
			if (deleteBtn != null) deleteBtn.visible = (model.isPrivate == true && !isSelected && SessionVars.mode != SessionVars.DEMO_MODE);
			if (dollarSign != null) dollarSign.visible = !model.isOwned;
		}
		
		private function setSelected(b:Boolean) {
			isSelected = b;		
			/*
			if (isSelected)
			{
				deleteBtn.visible = false;
			}
			else */if (SPHostStruct(thumb.data).isPrivate && SessionVars.loggedIn && SessionVars.mode != SessionVars.DEMO_MODE)
			{
				deleteBtn.visible = true;
			}
		}
	}
	
}