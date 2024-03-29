﻿package com.voki.ui {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.SelectorItem;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.SkinPromoData;
	import com.voki.data.SPSkinStruct;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SkinPromoSelectorItem extends MovieClip implements SelectorItem {
		//private var id:Number;
		//private var skinType,_sPromoText:String;
		
		public var tf_title:TextField;
		public var tf_desc:TextField;
		public var selectBtn:SimpleButton;
		public var infoBtn:SimpleButton;
		public var thumb:MovieClip;
		public var medallion:MovieClip;
		
		private var promoData:SkinPromoData;
		private var _id:int;
		
		public function SkinPromoSelectorItem() {
			selectBtn.addEventListener(MouseEvent.CLICK, onSelect);
			infoBtn.addEventListener(MouseEvent.CLICK, onInfo);
		}
		
		public function select():void {}
		public function deselect():void {}		
		public function shown(b:Boolean):void {}
		public function get id():int {
			return(_id);
		}
		public function set id(in_id:int):void {
			_id = in_id;
		}
		public function get text():String {
			return(promoData.typeName);
		}
		public function set text(in_text:String):void { }
		
		public function get data():Object {
			return(promoData);
		}
		public function set data(in_data:Object):void {
			promoData = in_data as SkinPromoData;
			
			tf_title.text = promoData.title;
			tf_desc.text = promoData.description;
			if (promoData.typeName == SPSkinStruct.STANDARD_TYPE) {
				gotoAndStop(2);
				medallion.visible = false;
			}
			else {
				gotoAndStop(1);
				medallion.visible = true;
				medallion.gotoAndStop(promoData.level + 1);
			}
			thumb.gotoAndStop(promoData.typeName.toLowerCase());
		}
		
		private function onSelect(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent(SelectorEvent.SELECTED, id, text, data));
		}
		private function onInfo(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent("info", id, text, data));
		}
	}
	
}