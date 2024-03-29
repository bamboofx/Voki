﻿package com.voki.panels {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.ToolTipManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SPBackgroundList;
	import com.voki.data.SPBackgroundStruct;
	import com.voki.data.SPCategory;
	import com.voki.player.PlayerController;
	import com.voki.processing.ASyncProcess;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class BackgroundPanel extends MovieClip implements IPanel {
		public var catSelector:OComboBox;
		public var bgSelector:Selector;
		public var scrollbar:OScrollBar;
		public var uploadBtn:BaseButton;
		public var loadingBar:MovieClip;
		
		private var player:PlayerController;
		private var data:SPBackgroundList;
		
		private static const NO_BG_ID:int = -1;
		private var isInited:Boolean = false;
		private var isLoadingData:Boolean = false;
		
		public function BackgroundPanel() {
			data = new SPBackgroundList();
			
			catSelector.addEventListener(SelectorEvent.SELECTED, catSelected);
			bgSelector.addEventListener(SelectorEvent.SELECTED, bgSelected);
			uploadBtn.addEventListener(MouseEvent.CLICK, onUpload);
			
			bgSelector.addScrollBar(scrollbar);
			setIsLoadingData(false);
		}
		
		public function openPanel() {
			ToolTipManager.reset();
			if (!isInited) init();
			else 
			{
				bgSelector.selectById(selectedBgId);
				var itemsArr:Array = bgSelector.getItemArray();
				for (var i:int = 0; i < itemsArr.length; ++i)
				{
					ToolTipManager.add(itemsArr[i] as DisplayObject, SelectorItem(itemsArr[i]).text);
				}
			}
		}
		
		private function init() {
			isInited = true;
			getCategories();
		}
		
		public function setPlayer($player:PlayerController) {
			player = $player;
			player.processList.addEventListener(Event.CHANGE, onProcessingUpdate);
		}
		
		private function getCategories() {
			setIsLoadingData(true);
			data.getCategoryArr(gotCategories);
		}
		
		private function gotCategories(catArr:Array) {
			catSelector.clear();
			var cat:SPCategory;
			for (var i:int = 0; i < catArr.length; i++) {
				cat = catArr[i];
				catSelector.add(cat.id, cat.name);
			}

			if (catArr.length == 0) setIsLoadingData(false);
			else {
				if (selectedBgCatId > 0)
				{
					catSelector.selectById(selectedBgCatId);
				}
				else
				{
					catSelector.selectById(catArr[0].id);
				}
				loadBgs();
			}
		}
		
		private function loadBgs() {
			if (!catSelector.isSelected()) return;
			setIsLoadingData(true);
			
			var catId:int = catSelector.getSelectedId();
			data.getBgsByCatId(gotBgs,catId);
		}
		
		private function gotBgs(bgArr:Array) {
			ToolTipManager.reset();
			bgSelector.clear();
			var bg:SPBackgroundStruct;

			//add "No background" button
			var noBGThumbUrl:String = SessionVars.adminURL + "img/en/none_thumb.jpg";
			bg = new SPBackgroundStruct(null, NO_BG_ID, noBGThumbUrl, "None");
			ToolTipManager.add(bgSelector.add(bg.id,bg.name,bg,false) as DisplayObject, bg.name);
			
			bgArr.sortOn("name", Array.CASEINSENSITIVE);
			for (var i:int = 0; i < bgArr.length; i++) {
				bg = bgArr[i];
				ToolTipManager.add(bgSelector.add(bg.id, bg.name, bg, false) as DisplayObject, bg.name);
			}
			bgSelector.update();
			bgSelector.selectById(selectedBgId);
			setIsLoadingData(false);
		}
		
		private function get selectedBgId():int {
			var id:int;
			if (player == null) id=NO_BG_ID
			else if (player.scene == null) id=NO_BG_ID
			else if (player.scene.bg == null) id=NO_BG_ID
			else id = player.scene.bg.id;
			trace("BackgroundPanel::selectedBgId = " + id);
			return(id);
		}
		
		private function get selectedBgCatId():int {
			var id:int;
			if (player == null) id=0
			else if (player.scene == null) id = 0;
			else if (player.scene.bg == null) id=0
			else id = SPBackgroundStruct(player.scene.bg).catId;
			trace("BackgroundPanel::selectedBgId = " + id);
			return(id);
		}
		
		public function closePanel() {
			
		}
		
		private function setIsLoadingData(b:Boolean) {
			isLoadingData = b;
			updateLoadingBar();
		}
		
		private function updateLoadingBar() {
			var isLoading:Boolean = isLoadingData;
			if (player != null&&player.processList.isProcessingType(ASyncProcess.PROCESS_BG)) isLoading = true;
			
			loadingBar.visible = isLoading;
			bgSelector.visible = !isLoading;
		}
		
//----------------------------------------------------------------------------------------------------

		private function catSelected(evt:SelectorEvent) {
			loadBgs();
		}
		
		private function bgSelected(evt:SelectorEvent) {
			//trace("BackgroundPanel::bgSelected - "+evt.id);
			if (evt.id == NO_BG_ID) player.loadBG(null);
			else player.loadBG(evt.obj as SPBackgroundStruct);
		}
		
		private function onUpload(evt:MouseEvent) {
			dispatchEvent(new Event("upload"));
		}
		
		private function onProcessingUpdate(evt:Event) {
			updateLoadingBar();
		}
	}
	
}