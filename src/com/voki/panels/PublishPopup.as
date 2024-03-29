﻿package com.voki.panels {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.ColorEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.ColorPicker;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.ui.OComboBox;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.SceneStruct;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class PublishPopup extends MovieClip {
		public var tf_width:TextField;
		public var tf_height:TextField;
		public var tf_hex:TextField;
		public var cb_secure:OCheckBox;
		public var cp:ColorPicker;
		public var embedSelector:OComboBox;
		public var publishBtn:SimpleButton;
		public var cancelBtn:SimpleButton;
		public var resetBtn:BaseButton;
		public var transparentBtn:BaseButton;
		public var closeBtn:SimpleButton;
		public var transparentSwatch:MovieClip
		
		private var curEmbed:String;
		private var skinW:Number;
		private var skinH:Number;	
		
		public function PublishPopup() {
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
			publishBtn.addEventListener(MouseEvent.CLICK, onPublish);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);
			resetBtn.addEventListener(MouseEvent.CLICK, onReset);
			transparentBtn.addEventListener(MouseEvent.CLICK, onSelectTransparent);
			
			embedSelector.tabIndex=1;
			tf_width.tabIndex=2;
			tf_height.tabIndex=3;
			cb_secure.tabIndex = 4;
			
			embedSelector.add(1,"Standard Web Page","FULL")
			embedSelector.add(2,"Web Page (No Javascript)","HTML")
			embedSelector.selectById(1);
			
			curEmbed = "FULL";
			
			embedSelector.addEventListener(SelectorEvent.SELECTED, onEmbedModeSelected);
			cp.addEventListener(ColorEvent.SELECT, onColorChanged);
			cp.selectColor(0);
			
			tf_hex.text="000000";
			tf_hex.restrict="A-F 0-9"
			tf_width.restrict="0-9"
			tf_height.restrict = "0-9"
			tf_width.addEventListener(Event.CHANGE, onWidthChanged);
			tf_height.addEventListener(Event.CHANGE, onHeightChanged);
			tf_hex.addEventListener(Event.CHANGE, onHexChanged);
			
			transparentSwatch.buttonMode = true;
			transparentSwatch.mouseChildren = false;
			transparentSwatch.useHandCursor=false;
		}
		
		public function init(scene:SceneStruct) {
			if (scene.skin==null||scene.skin.width<=0||scene.skin.height<=0) {
				skinW=400;
				skinH=300;
			}
			else {
				skinW=scene.skin.width;
				skinH=scene.skin.height;
			}
			tf_width.text=skinW.toString();
			tf_height.text=skinH.toString();
			transparentSwatch.visible=false;
			cb_secure.selected = false;
		}

		private function closeWin() {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		
		private function showHex(hex:uint):String {
			var hexStr:String=hex.toString(16).toUpperCase();
			while (hexStr.length<6) hexStr="0"+hexStr;
			tf_hex.text=hexStr;
			return(hexStr);
		}
		
		//button callback
		
		private function onPublish(evt:MouseEvent) {
			if (tf_width.text.length == 0 || tf_width.text == "0" || tf_height.text.length == 0 || tf_height.text == "0") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp109", "Invalid scene dimensions"));
				return;
			}
			
			var publishXML:XML =<PARTNER />;
			publishXML.@PUBLISHTO=curEmbed;
			publishXML.@SCENEW=tf_width.text;
			publishXML.@SCENEH=tf_height.text;
			publishXML.@BGCOLOR=tf_hex.text;
			publishXML.@TRANSPARENT=transparentSwatch.visible?"1":"0";
			publishXML.@SECURE=cb_secure.selected?"Y":"N";
			closeWin();
			
			dispatchEvent(new SendEvent(SendEvent.SEND, "publish", publishXML));
		}
		
		private function onClose(evt:MouseEvent) {
			closeWin();
		}
		
		private function onCancel(evt:MouseEvent) {
			closeWin();
		}
		
		private function onReset(evt:MouseEvent) {
			tf_width.text=skinW.toString();
			tf_height.text=skinH.toString();
		}
		
		private function onSelectTransparent(evt:MouseEvent) {
			transparentSwatch.visible=!transparentSwatch.visible;			
		}

		//colorpicker callback
		public function onColorChanged(evt:ColorEvent) {
			showHex(evt.color.hex);
			
			transparentSwatch.visible=false;
		}
		
			
		//textfield callback
		
		public function onWidthChanged(evt:Event) {
			var w:Number=parseInt(tf_width.text);
			if (isNaN(w)) w=0;
			var h:Number=Math.round(w/skinW*skinH)
			tf_height.text=h.toString();
		}
		
		public function onHeightChanged(evt:Event) {
			var h:Number=parseInt(tf_height.text);
			if (isNaN(h)) h=0;
			var w:Number=Math.round(h/skinH*skinW)
			tf_width.text=w.toString();		
		}
		
		public function onHexChanged(evt:Event) {
			var hex:uint=parseInt(tf_hex.text,16);
			cp.selectColor(hex);
		}
		
		//combox callback
		
		public function onEmbedModeSelected(evt:SelectorEvent) {
			curEmbed = evt.obj as String;
		}
	}
	
}