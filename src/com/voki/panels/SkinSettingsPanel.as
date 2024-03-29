﻿package com.voki.panels {
	import com.oddcast.event.ColorEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.ColorPicker;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.ui.Selector;
	import com.oddcast.utils.CustomCursor;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.SkinConfiguration;
	import com.voki.player.PlayerController;
	import com.voki.ui.AlignmentSelector;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SkinSettingsPanel extends MovieClip implements IPanel {
		public var tf_title:TextField;
		public var alignSelector:AlignmentSelector;
		public var cb_title:OCheckBox;
		public var cb_mute:OCheckBox;
		public var cb_playpause:OCheckBox;
		public var cb_volume:OCheckBox;
		public var groupSelector:Selector;
		public var resetBtn:BaseButton;
		public var cp:ColorPicker;
		public var hexBox:MovieClip;
		public var cpBg:MovieClip;
		
		//added for studio
		public var cb_prev:OCheckBox;
		public var cb_next:OCheckBox;
		
		public var player:PlayerController;
		
		private static const colorNames:Array = ["Frame", "Buttons", "Font", "Extra"];
		
		public function SkinSettingsPanel() {
			groupSelector.addEventListener(SelectorEvent.SELECTED, groupSelected);
			cp.addEventListener(ColorEvent.RELEASE, colorSelected);
			cp._mcSquare.addEventListener(MouseEvent.MOUSE_OVER, mouseOverPicker);
			cp._mcSquare.addEventListener(MouseEvent.MOUSE_OUT, mouseOutPicker);
			tf_hex.addEventListener(FocusEvent.FOCUS_OUT, hexChanged);
			tf_hex.restrict = "A-F a-f 0-9 #"
			alignSelector.addEventListener(Event.SELECT, alignmentSelected);
			cb_title.addEventListener(MouseEvent.CLICK, onChecked);
			cb_mute.addEventListener(MouseEvent.CLICK, onChecked);
			cb_playpause.addEventListener(MouseEvent.CLICK, onChecked);
			cb_volume.addEventListener(MouseEvent.CLICK, onChecked);			
			resetBtn.addEventListener(MouseEvent.CLICK, onReset);
			tf_title.maxChars = 100;
			tf_title.addEventListener(FocusEvent.FOCUS_OUT, titleChanged);
			if (cb_prev!=null)
			{
				cb_prev.addEventListener(MouseEvent.CLICK, onChecked);
			}
			if (cb_next!=null)
			{
				cb_next.addEventListener(MouseEvent.CLICK, onChecked);
			}
		}
		
		private function get tf_hex():TextField {
			return(hexBox.getChildByName("tf_val") as TextField);
		}
		
		private function get config():SkinConfiguration {
			return(player.scene.skinConfig);
		}
		public function openPanel() {
			if (player.scene.skin == null || player.scene.skinConfig == null) throw new Error("Scene missing skin configuration");
			
			init();
		}
		public function closePanel() {
			
		}
		
		private function init() {
			groupSelector.clear();
			for (var i:int=0;i<config.colorArr.length;i++) {
				groupSelector.add(i,colorNames[i]);
			}
			if (groupSelector.numItems > 0)
			{
				cp.visible = true;
				hexBox.visible = true;
				cpBg.visible = true;
				resetBtn.visible = true;
			}
			else
			{
				cp.visible = false;
				hexBox.visible = false;
				cpBg.visible = false;
				resetBtn.visible = false;
			}
			
			cb_title.selected=config.showTitle;
			cb_volume.selected=config.showVolume;
			cb_playpause.selected=config.showPlay;
			cb_mute.selected = config.showMute;
			alignSelector.alignment = config.align;
			try
			{
				tf_title.text = unescape(decodeURI(config.title));
			}
			catch (e:Error)
			{
				tf_title.text = unescape(config.title);
			}
			
			if (cb_next != null)
			{
				cb_next.selected = config.showNext;
			}
			
			if (cb_prev != null)
			{
				cb_prev.selected = config.showPrev;
			}
			
			chooseGroup(0);
		}
		
		private function chooseGroup(groupId:int) {
			trace("SkinSettingsPanel::chooseGroup - "+groupId);
			groupSelector.selectById(groupId);
			setColor(config.colorArr[groupId]);
		}
		
		private function setColor(hex:uint) {
			trace("SkinSettingsPanel::setColor START - vals=" + player.scene.skin.selectedColorArr + "  defaults=" + player.scene.skin.defaultColorArr+"  config="+config.colorArr+"   ok="+(player.scene.skin.selectedColorArr==config.colorArr));
			cp.selectColor(hex);
			var hexStr:String = hex.toString(16);
			//while (hexStr.length < 6) hexStr = "0" + hexStr;
			tf_hex.text = hexStr;
			trace("SkinSettingsPanel::setColor - hex=" + hex.toString(16) + " - sel?=" + groupSelector.isSelected() + " id=" + groupSelector.getSelectedId());
			if (!groupSelector.isSelected()) return;
			config.colorArr[groupSelector.getSelectedId()]=hex;
			trace("SkinSettingsPanel::setColor END - vals=" + player.scene.skin.selectedColorArr + "  defaults=" + player.scene.skin.defaultColorArr+"  config="+config.colorArr+"   ok="+(player.scene.skin.selectedColorArr==config.colorArr));
		}
		
		private function update() {
			dispatchEvent(new Event("update"));
		}
//--------------------------------------------------  CALLBACKS  ---------------------------------------------------
		private function groupSelected(evt:SelectorEvent) {
			trace("SkinSettingsPanel::groupSelected - " + evt.id);
			setColor(config.colorArr[evt.id]);
			update();
		}
		private function colorSelected(evt:ColorEvent) {
			trace("SkinSettingsPanel::colorSelected - " + evt.color.hex.toString());
			setColor(evt.color.hex);
			update();
		}
		private function hexChanged(evt:Event) {
			trace("SkinSettingsPanel::hexChanged");
			setColor(parseInt(tf_hex.text, 16));
			update();
		}
		private function alignmentSelected(evt:Event) {
			config.align = alignSelector.alignment;
			update();
		}
		private function titleChanged(evt:FocusEvent) {
			config.title = tf_title.text;
			update();
		}
		private function onChecked(evt:MouseEvent) {
			config.showTitle=cb_title.selected
			config.showVolume=cb_volume.selected;
			config.showPlay=cb_playpause.selected;
			config.showMute = cb_mute.selected;
			if (cb_next != null)
			{
				config.showNext = cb_next.selected;				
			}
			if (cb_prev != null)
			{
				config.showPrev = cb_prev.selected;				
			}
			update();
		}
		private function onReset(evt:MouseEvent) {
			trace("SkinSettingsPanel::onReset - vals=" + player.scene.skin.selectedColorArr + "  defaults=" + player.scene.skin.defaultColorArr + "  config=" + config.colorArr + "   ok=" + (player.scene.skin.selectedColorArr == config.colorArr));
			for (var i:int = 0; i < player.scene.skin.defaultColorArr.length; i++) {
				player.scene.skin.selectedColorArr[i]=player.scene.skin.defaultColorArr[i];
				config.colorArr[i] = player.scene.skin.defaultColorArr[i];
				
			}
			update();
			init();
		}
		//colorpicker dragger callbacks
		private function mouseOverPicker(evt:MouseEvent) {
			trace("mouseOverPicker");
			CustomCursor.setCursorClass("sp_cursor_dropper");
		}
		private function mouseOutPicker(evt:MouseEvent) {
			CustomCursor.removeCursor();
		}

	}
	
}