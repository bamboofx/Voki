package com.voki.ui {
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.SelectorItem;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AudioSelectorItem extends Sprite implements SelectorItem {
		public var selectBtn:MovieClip;
		public var effectsBtn:BaseButton;
		public var editBtn:BaseButton;
		public var deleteBtn:BaseButton;
		public var tf_name:TextField;
		
		private var _id:int;
		private var isSelected:Boolean = false;
		private var audio:AudioData;
		
		public function AudioSelectorItem() {
			selectBtn.buttonMode = true;
			tf_name.mouseEnabled = false;
			
			selectBtn.addEventListener(MouseEvent.CLICK, onSelect, false, 0, true);
			effectsBtn.addEventListener(MouseEvent.CLICK, onEffects, false, 0, true);
			editBtn.addEventListener(MouseEvent.CLICK, onEdit, false, 0, true);
			deleteBtn.addEventListener(MouseEvent.CLICK, onDelete, false, 0, true);
			
			selectBtn.gotoAndStop(1);
		}
					
		public function select():void {
			setSelected(true);
		}
		
		public function deselect():void {
			setSelected(false);
		}
		
		public function shown(b:Boolean):void { }
		
		public function get id():int {
			return(_id);
		}
		public function set id(in_id:int):void {
			_id = in_id;
		}
		public function get text():String {
			return(tf_name.text);
		}
		public function set text(in_text:String):void {
			tf_name.text = in_text;
		}
		public function get data():Object {
			return(audio);
		}
		
		private function get fxIcon():MovieClip {
			return(effectsBtn.getChildByName("fxIcon") as MovieClip);
		}
		public function set data(in_data:Object):void {
			audio = in_data as AudioData;
			if (audio == null || !audio.isPrivate) {
				//public audios cannot be edited, only private account audios can
				//also, don't show the editing buttons if this is the "No Audio" button
				effectsBtn.visible=false;				
				deleteBtn.visible=false;
				editBtn.visible=false;
			}
			else {
				fxIcon.gotoAndStop(audio.hasFX()?2:1);
				if (!SessionVars.loggedIn) {
					//you can't delete audios in demo mode
					deleteBtn.visible = false;
				}
			}
			/*
			if (isSelected)
			{
				deleteBtn.visible = false;
			}
			*/
		}
		
		private function setSelected(b:Boolean) {
			isSelected = b;
			/*
			if (isSelected)
			{
				deleteBtn.visible = false;
			}
			
			else 
			*/
			if (audio!=null)
			{
				if (audio.isPrivate && SessionVars.loggedIn)
				{
					deleteBtn.visible = true;
				}
			}
			selectBtn.gotoAndStop(b?2:1);
		}
//---------------------------------------  CALLBACKS  ------------------------------------------------

		private function onSelect(evt:MouseEvent) {			
			setSelected(!isSelected);
			dispatchEvent(new SelectorEvent(isSelected?SelectorEvent.SELECTED:SelectorEvent.DESELECTED, id, text, data));
		}
		private function onEffects(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent("editEffects", id, text, data));
		}
		private function onDelete(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent("deleteAudio", id, text, data));
		}
		private function onEdit(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent("editAudio", id, text, data));
		}
	}
	
}