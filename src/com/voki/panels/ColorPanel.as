package com.voki.panels {
	import com.oddcast.event.ColorEvent;
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.ColorPicker;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.CustomCursor;
	import com.oddcast.vhost.ranges.RangeData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.SessionVars;
	import com.voki.player.PlayerController;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ColorPanel extends MovieClip implements IPanel {
		public var cp:ColorPicker;
		public var hexBox:MovieClip;
		public var groupSelector:Selector;
		public var swatchSelector:Selector;
		public var sliderSelector:Selector;
		public var undoBtn:BaseButton;
		public var resetBtn:BaseButton;
		
		public var player:PlayerController;
		private var undoColor:uint;
		//private var resetColors:Object;
		private var sliderNames:Object;
		private var isInited:Boolean = false;
		private const skinColorArr:Array = [0xFECAB2, 0xF9CFB7, 0xC5AD95, 0xFDDCD5, 0xDB9D76, 0xA66859, 0x836A56, 0xFCDABF, 0x774F35, 0x583B37, 0x524944, 0xCC9667, 0xF6D7C5, 0xF8EDEB, 0xEED1BF, 0xDCC29F, 0xE2A589, 0xF0BC97, 0xC3886A, 0xD3965F, 0x774E3A, 0xAD6243, 0x965B39, 0x7E2E0D]
		private var modelResetColorArr:Array;
		
		public function ColorPanel() {
			sliderNames=new Object();
			sliderNames["make-up"]="Eye shadow";
			sliderNames["blush"] = "Blush";
			
			modelResetColorArr = new Array();
			
			//hexBox.visible=SessionVars.adminMode;
			hexBox.visible = true;
			tf_hex.restrict="0-9 a-f A-F";
			tf_hex.addEventListener(Event.CHANGE, hexChanged);
			
			groupSelector.addEventListener(SelectorEvent.SELECTED, groupSelected);
			swatchSelector.addEventListener(SelectorEvent.SELECTED, swatchSelected);
			sliderSelector.addItemEventListener(ScrollEvent.SCROLL, sliderChanged);
			undoBtn.addEventListener(MouseEvent.CLICK, onUndo);
			resetBtn.addEventListener(MouseEvent.CLICK, onReset);
			cp.addEventListener(ColorEvent.SELECT, colorChanged);
			cp.addEventListener(ColorEvent.RELEASE, colorChanged);
			cp._mcSquare.addEventListener(MouseEvent.MOUSE_OVER, mouseOverPicker);
			cp._mcSquare.addEventListener(MouseEvent.MOUSE_OUT, mouseOutPicker);
		}
		
		private function get tf_hex():TextField {
			return(hexBox.tf_val as TextField);
		}
		
		public function openPanel() {
			trace("ColorPanel::openPanel "+player.scene.model.type);
			if (player.scene.model.type != "3D")
			{
				if (!isInited) init();
				populateSliders();
				populateGroups();			
			}
			else
			{
				SessionVars.selectPanelByName("expressions");
				SessionVars.disablePanelByName("color");
				SessionVars.disablePanelByName("attributes");
			}
		}
		public function closePanel() {
			
		}
		
		private function init() {
			populateSwatches();
			isInited = true;
		}

//----------------------------------------------------- POPULATE ----------------------------------------
		
		private function skinHex(n:int):uint {
			/*var perc=(n+5)/30;
			var r=Math.round(244-63*perc-85.5*perc*perc);
			var g=Math.round(199-108*perc-18*perc*perc);
			var b=Math.round(198-326.8*perc+197.7*perc*perc);
			c=(r<<16)+(g<<8)+b;*/
			return(skinColorArr[n]);
		}
		private function populateSwatches() {
			swatchSelector.clear();
			for (var i:int=0;i<24;i++) swatchSelector.add(i,"",skinHex(i),false);
			swatchSelector.update();
		}
		
		private function populateGroups() {
			var possibleGroups:Array = ["hair", "skin", "eyes", "make-up", "mouth"];
			
			var colorGroups:Array = player.getColors();
			if (modelResetColorArr[player.scene.model.id] == undefined) modelResetColorArr[player.scene.model.id] = colorGroups;
			var groupArr:Array = new Array();
			var indx:int;
			var colorGroup:RangeData;
			var i:int;
			var j:int;
			for (i = 0; i < possibleGroups.length; i++) {
				for (j = 0; j < colorGroups.length; j++) {
					colorGroup = colorGroups[j];
					if (colorGroup.name==possibleGroups[i]) groupArr.push(colorGroup)
				}
			}
			
			var curGroup:RangeData = getCurGroup();

			groupSelector.clear();
			var initGroupId:int = 0;
			
			for (i = 0; i < groupArr.length; i++) {
				colorGroup = groupArr[i];
				//resetColors[colorGroup.name]=player.getColor(groupArr[i])
				groupSelector.add(i,colorGroup.name,colorGroup);
				if (matchGroups(colorGroup,curGroup)) initGroupId=i;
			}

			groupSelector.selectById(initGroupId)
			chooseGroup();
		}
		private function matchGroups(r1:RangeData, r2:RangeData):Boolean {
			if (r1 == null || r2 == null) return(false);
			else
			{
				trace("r1.name="+r1.name+", r2.name="+r2.name+", r1.type="+r1.type+", r2.type="+r2.type);
				return(r1.name == r2.name && r1.type == r2.type);
			}
		}
		private function getSliderName(grpName:String):String {
			if (sliderNames[grpName]==undefined) return(grpName);
			else return(sliderNames[grpName]);
		}
		
		private function populateSliders() {
			var sliderName:String;
			sliderSelector.clear();
			var group:RangeData;
			var sizeGroups:Array = player.getRanges();
			for (var i = 0; i < sizeGroups.length; i++ ) {
				group = sizeGroups[i];
				if (group.type=="alpha") sliderSelector.add(i,getSliderName(group.name),group);
			}
		}
		
//----------------------------------------------------------------------------------------------------

		private function chooseColor(hex:uint, originator:Object = null) {
			//exclude sending the message to the originator
			var curGroup:RangeData = getCurGroup();
			trace("ColorPanel::chooseColor " + hex+" originator != player =>"+(originator != player)+", originator != cp =>"+(originator != cp+", originator != swatchSelector => "+(originator != swatchSelector)+", originator != hexBox => "+(originator != hexBox)));
			if (player != null && curGroup!=null)
			{
				var hexVal:uint = player.getColor(curGroup.name, curGroup.type);	
				if (hex != hexVal)
				{
					undoColor = hexVal;				
				}
			}			
			if (originator != player) {				
				player.setColor(curGroup.name,curGroup.type,hex)
			}
			if (originator != cp) {
				cp.selectColor(hex);
			}
			if (originator != swatchSelector) {
				var swatchMatch:Boolean = false;
				var swatchArr:Array = swatchSelector.getItemArray();
				var swatchItem:SelectorItem;
				for (var i:int = 0; i < swatchArr.length; i++) {
					swatchItem = swatchArr[i];
					if (swatchItem.data == hex) {
						swatchSelector.selectById(swatchItem.id);
						swatchMatch = true;
						break;
					}
				}
				if (!swatchMatch) swatchSelector.deselect();
			}
			if (originator != hexBox) {
				var hexStr:String=hex.toString(16);
				while (hexStr.length<6) hexStr="0"+hexStr;
				tf_hex.text=hexStr;
			}
		}
		
		private function chooseGroup() {
			
				var curGroup:RangeData = getCurGroup();
			if (player != null && curGroup!=null)
			{
				var hexVal:uint = player.getColor(curGroup.name,curGroup.type);
				chooseColor(hexVal, player);
				undoColor=hexVal;
				//trace("chooseGroup in SelectColor: "+grpName)
				swatchSelector.visible = (curGroup.name == "skin");
				sliderSelector.visible = (curGroup.name == "make-up");				
			}
		}
		
		private function getCurGroup():RangeData {
			if (!groupSelector.isSelected()) return(null);
			else return(groupSelector.getSelectedItem().data as RangeData);
		}
//----------------------------------------------------- CALLBACKS ----------------------------------------

		//undo,resetbutton callbacks
		
		private function onUndo(evt:MouseEvent) {
			chooseColor(undoColor)
		}
		
		private function onReset(evt:MouseEvent) {
			var group:RangeData;
			var resetArr:Array = modelResetColorArr[player.scene.model.id];
			for (var i:int = 0; i < resetArr.length; i++) {
				group = resetArr[i];
				//
					trace("onReset::player.setColor " + group.name + ", " + group.type + ", " + group.value);
					
					if (matchGroups(group, getCurGroup())) {
						player.setColor(group.name, group.type, group.value as uint);
						chooseColor(group.value as uint)
						undoColor = group.value as uint;
					}
					//break;
				//}
			}
		}
		
		//textfield onChanged
		private function hexChanged(evt:Event) {
			var hexValNum:Number=parseInt(tf_hex.text,16);
			if (!isNaN(hexValNum)) {
				chooseColor(hexValNum as uint, hexBox);
			}
		}
		
		//buttonselector callback
		private function groupSelected(evt:SelectorEvent) {
			chooseGroup();
		}
		
		private function swatchSelected(evt:SelectorEvent) {
			var hexVal:uint=evt.obj as uint;
			chooseColor(hexVal,swatchSelector);
		}
		
		//colorpicker callback
		public function colorChanged(evt:ColorEvent) {
			chooseColor(evt.color.hex, cp);
			if (sliderSelector.visible)
			{
				var count:int = 0;
				for (var i:String in sliderNames)
				{
					var percent:Number = sliderSelector.getItemByName(getSliderName(i)).data.value;					
					trace("chooseGroup::setScale " + i + "," + percent + ",alpha");
					player.setScale(i, percent, "alpha");
					count++;
				}
			}			
		}
		
		
		//colorpicker dragger callbacks
		public function mouseOverPicker(evt:MouseEvent) {
			CustomCursor.setCursorClass("sp_cursor_dropper");
		}
		public function mouseOutPicker(evt:MouseEvent) {
			CustomCursor.removeCursor();
		}
		
		
		//SliderGroup callback
		public function sliderChanged(evt:ScrollEvent) {
			var range:RangeData = evt.currentTarget.data as RangeData;
			trace("sliderChanged "+range.name+", "+evt.percent+", "+range.type);
			player.setScale(range.name,evt.percent,range.type);
		}
		
	}
	
}