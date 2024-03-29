﻿package com.voki.panels {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.ToolTipManager;
	import com.oddcast.utils.XMLLoader;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SPBackgroundList;
	import com.voki.data.SPBackgroundStruct;
	import com.voki.nav.PopupController;
	import com.voki.panels.IPanel;
	import com.voki.player.PlayerController;
	import com.voki.processing.ASyncProcess;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SavedBGPanel extends MovieClip implements IPanel {
		public var typeSelector:OComboBox;
		public var bgSelector:Selector
		public var scrollbar:OScrollBar;
		public var uploadBtn:BaseButton;
		public var loadingBar:MovieClip;
		
		private var player:PlayerController;
		private var data:SPBackgroundList;
		private var typeArr:Array;
		public var popups:PopupController;
		
		private static const NO_BG_ID:int = -1;
		private var isInited:Boolean = false;
		private var isLoadingData:Boolean = false;
		private var doUploadBgOnInit:Boolean = false;
		
		public function SavedBGPanel() {
			data = new SPBackgroundList();
			data.addEventListener(AlertEvent.ERROR, function(evt:AlertEvent):void
			{
				dispatchEvent(evt);;
			});
			setIsLoadingData(false);
			
			typeSelector.addEventListener(SelectorEvent.SELECTED, typeSelected);
			bgSelector.addEventListener(SelectorEvent.SELECTED, bgSelected);
			bgSelector.addItemEventListener("deleteBg", onBgDelete);
			uploadBtn.addEventListener(MouseEvent.CLICK, onUpload);
			
			bgSelector.addScrollBar(scrollbar);
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
			typeArr = [SPBackgroundStruct.ALL_TYPES, SPBackgroundStruct.IMAGE_TYPE, SPBackgroundStruct.VIDEO_TYPE];
			
			var typeName:String;
			for (var i:int = 0; i < typeArr.length; i++) {
				typeName = typeArr[i];
				typeSelector.add(i, SPBackgroundList.typeTitles[typeName]);
			}
			typeSelector.selectById(0);
			
			loadBgs();
		}
		
		public function setPlayer($player:PlayerController) {
			player = $player;
			player.processList.addEventListener(Event.CHANGE, onProcessingUpdate);
		}
		
		private function loadBgs() {
			if (!typeSelector.isSelected()) return;
			setIsLoadingData(true);
			
			var typeName:String = typeArr[typeSelector.getSelectedId()];
			data.getAccountBackgroundsByType(gotBgs, typeName);
		}
		
		private function gotBgs(bgArr:Array) {
			ToolTipManager.reset();
			bgSelector.clear();
			var bg:SPBackgroundStruct;

			//add "No background" button
			var noBGThumbUrl:String = SessionVars.adminURL + "img/en/none_thumb.jpg";
			bg = new SPBackgroundStruct(null, NO_BG_ID, noBGThumbUrl, "None");
			ToolTipManager.add(bgSelector.add(bg.id, bg.name, bg, false) as DisplayObject, bg.name);
			if (bgArr == null)
			{
				return;
			}			
			bgArr.sortOn("name", Array.CASEINSENSITIVE);
			for (var i:int = 0; i < bgArr.length; i++) {
				bg = bgArr[i];
				ToolTipManager.add(bgSelector.add(bg.id, bg.name, bg, false) as DisplayObject, bg.name);
				trace("SavedBGPanel::ad bg id=" + bg.id);
			}
			bgSelector.update();
			bgSelector.selectById(selectedBgId);
			trace("SavedBGPAnel::select by id : " + selectedBgId);
			setIsLoadingData(false);
			isInited = true;
			if (doUploadBgOnInit) {
				doUploadBgOnInit = false;
				uploadBg();
			}
			
			/*if (bgArr.length>=SessionVars.bgLimit) {
				broadcastMessage("closePopup","uploadImageWin")
				broadcastMessage("showAlert","maxBgsReached")
			}*/
		}
		
		private function get selectedBgId():int {
			if (player == null) return(NO_BG_ID);
			else if (player.scene == null) return(NO_BG_ID);
			else if (player.scene.bg == null) return(NO_BG_ID);
			else return(player.scene.bg.id);
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
		
		//callback from BGThumb inside thumbselector
		
		private function showLoadingBar(b:Boolean) {
			loadingBar.visible = b;
		}
		
		private var bgToDelete:SPBackgroundStruct;
		public function deleteBg(bg:SPBackgroundStruct) {
			bgToDelete = bg;
			showLoadingBar(true);
			var url:String = SessionVars.localBaseURL + "itemUsed.php?accId=" + SessionVars.acc + "&itemId=" + bgToDelete.id + "&itemType=bg";
			XMLLoader.loadXML(url, bgIsUsedResponse);
			
			//dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp304", "The asset {name} will be removed. This operation cannot be undone. Proceed?", { name:bg.name }, onConfirm));
		}
		
		private function bgIsUsedResponse(_xml:XML):void
		{
			showLoadingBar(false);
			if (_xml == null || _xml.@RES == "ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp401","Error deleting audio : {details}",{details: _xml==null?XMLLoader.lastError:_xml.@MSG}));
			}
			else 
			{
			//dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp214", "The asset {name} will be removed. This operation cannot be undone. Proceed?", { name:modelToDelete.name }, onConfirm));			
				if (_xml.@RES == "YES")
				{
					dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp407", "The asset {name} is in use by a scene. Are you sure you want to delete it?", {name:bgToDelete.name}, deleteConfirm));
				}
				else
				{
					dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp406", "The asset {name} will be removed. This operation cannot be undone. Proceed?", {name:bgToDelete.name}, deleteConfirm));
				}
			}
		}
		
		private function deleteConfirm(b:Boolean) {
			if (b) { //confirmed
				showLoadingBar(true);
				var rand:Number=Math.floor(Math.random()*1000000);
				var url:String = SessionVars.localBaseURL + "deleteItem.php?type=bg&id=" + bgToDelete.id+"&rnd="+rand;
				XMLLoader.loadXML(url, bgDeleted);				
			}
			else bgToDelete = null; //canceled
		}
						
		
		public function bgDeleted(_xml:XML) {
			showLoadingBar(false);
			if (_xml.firstChild.attributes.RES == "ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp302","Error deleting background : {details}", _xml.@MSG));
			}
			else {
				var id:int = parseInt(_xml.@ID);
				bgSelector.remove(id);
				data.removeAccountBackgroundWithId(id);
			}
			bgToDelete = null;
		}

//----------------------------------------------------------------------------------------------------
		
		//button callback
		public function uploadBg() {
			if (!isInited) doUploadBgOnInit = true;
			else if (data.getLoadedAccountBackgroundArr().length >= SessionVars.bgLimit) {
				dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp303", "You have reached the maximum number of backgrounds for your account."));
			}
			else {
				popups.openPopup(popups.uploadBGWin);
				popups.uploadBGWin.openWindow();
				popups.uploadBGWin.setData(data);
				popups.uploadBGWin.addEventListener("bgSelected", gotUploadedBG);
				//broadcastMessage("openPopup","uploadImageWin",this)
			}
		}
		
		//upload bg popup callback
		public function gotUploadedBG(evt:Event) {
			var bg:SPBackgroundStruct = popups.uploadBGWin.uploadedBG;
			
			data.addAccountBackground(bg);
			var typeName:String = typeArr[typeSelector.getSelectedId()];
			if (typeName==SPBackgroundStruct.ALL_TYPES||typeName==bg.type) {
				
				ToolTipManager.add(bgSelector.add(bg.id,bg.name,bg) as DisplayObject, bg.name);
				bgSelector.selectById(bg.id);
			}
			player.loadBG(bg);
		}
		
//----------------------------------------------------------------------------------------------------

		private function typeSelected(evt:SelectorEvent) {
			loadBgs();
		}
		
		private function bgSelected(evt:SelectorEvent) {
			if (evt.id == NO_BG_ID) player.loadBG(null);
			else player.loadBG(evt.obj as SPBackgroundStruct);
		}
		
		private function onBgDelete(evt:Event) {
			deleteBg(evt.target.data as SPBackgroundStruct);
		}
		
		private function onUpload(evt:MouseEvent) {
			uploadBg();
		}
		
		private function onProcessingUpdate(evt:Event) {
			updateLoadingBar();
		}
	}
	
}