﻿package com.voki.panels {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.ToolTipManager;
	import com.oddcast.vhost.accessories.AccessoryData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.voki.data.SessionVars;
	import com.voki.data.SPAccessoryList;
	import com.voki.data.SPCategory;
	import com.voki.player.PlayerController;
	import com.voki.processing.ASyncProcess;
	import com.voki.ui.AccessoryTypeSelectorItem;
	import com.oddcast.event.AlertEvent;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AccessoryPanel extends MovieClip implements IPanel {
		
		public var typeSelector:Selector;
		public var catSelector:Selector;
		public var accSelector:Selector;
		public var scrollbar:OScrollBar;
		public var arrowLeft:BaseButton;
		public var arrowRight:BaseButton;
		public var loadingBar:MovieClip;
		
		private var player:PlayerController;
		private var accListArr:Array;
		
		private var isInited:Boolean = false;
		private var isLoadingData:Boolean = false;
		
		public var _mcNoAccessories:MovieClip;
		
		public function AccessoryPanel() {
			accListArr = new Array();
			
			typeSelector.addEventListener(SelectorEvent.SELECTED, typeSelected);
			catSelector.addEventListener(SelectorEvent.SELECTED, catSelected);
			accSelector.addEventListener(SelectorEvent.SELECTED, accSelected);
			
			catSelector.addScrollBtn(arrowLeft, -1);
			catSelector.addScrollBtn(arrowRight, 1);
			accSelector.addScrollBar(scrollbar,true);
			
			setIsLoadingData(false);
		}
		
		private function init() {
			typeSelector.add(3, "Hair", new acc_hair());
			typeSelector.add(4, "Glasses", new acc_glasses());
			typeSelector.add(6, "Costume", new acc_costume());
			typeSelector.add(8, "Necklace", new acc_necklace());
			typeSelector.add(9, "Hat", new acc_hat());
			typeSelector.add(10, "Facial Hair", new acc_fhair());
			typeSelector.add(12, "Mouth", new acc_mouth());	
			typeSelector.selectById(3);
			updateTypes();
			isInited = true;
		}
		
		public function openPanel() {
			if (_mcNoAccessories != null)
			{
				_mcNoAccessories.visible = false;
				if (player.scene.model.type != "host_2d" && player.scene.model.type != "2D")
				{
					_mcNoAccessories.visible = true;
					return;
				}
			}
			
			if (player.getShow().sceneArr[player.curSceneIndex-1].model == null) return;
			ToolTipManager.reset();
			if (!isInited) 
			{
				init();
			}
			else
			{
				if (accSelector != null)
				{
					var itemsArr:Array = accSelector.getItemArray();
					for (var i:int = 0; i < itemsArr.length; ++i)
					{
						ToolTipManager.add(itemsArr[i] as DisplayObject, SelectorItem(itemsArr[i]).text);
					}
				}
			}
			
			var modelId:int = player.getShow().sceneArr[player.curSceneIndex-1].model.id;
			trace("AccessoryPanel::openPanel - modelId=" + modelId);
			getCategories();
		}
		
		public function closePanel() {
			
		}
		
		public function setPlayer($player:PlayerController) {
			player = $player;
			player.processList.addEventListener(Event.CHANGE,onProcessingUpdate);
		}
		
		private function setIsLoadingData(b:Boolean) {
			isLoadingData = b;
			updateLoadingBar();
		}
		
		private function updateLoadingBar() {
			//show loading bar if 1 of the 3 is true :
			//1: XML is loading
			//2: model is loading
			//3: accessory is loading
			var isLoading:Boolean = isLoadingData;
			if (player != null) {
				if (player.processList.isProcessingType(ASyncProcess.PROCESS_MODEL)) isLoading = true;
				if (player.processList.isProcessingType(ASyncProcess.PROCESS_ACCESSORY)) isLoading = true;
			}
			
			loadingBar.visible = isLoading;
			catSelector.visible = !isLoading;
			accSelector.visible = !isLoading;
		}
		
//-------------------- LOADING -------------------------------

		private function getCategories() {
			setIsLoadingData(true);
			getCurAccList().getCategoryArr(gotCategories);			
		}
		
		private function gotCategories(catArr:Array) {
			var category:SPCategory;
			catSelector.clear();
			for (var i:int = 0; i < catArr.length; i++) {
				category = catArr[i];
				catSelector.add(category.id, category.name, null, false);
			}
			catSelector.update();
			if (catArr.length == 0) 
			{
				updateTypes();
				setIsLoadingData(false);
			}
			else {
				catSelector.selectById(catArr[0].id);
				getAccessories();
			}
		}
		
		private function getAccessories() {
			trace("AccessoryPanel::getAccessories catSelector.isSelected()="+catSelector.isSelected());
			if (!catSelector.isSelected()) return;
			setIsLoadingData(true);
			var catId:int = catSelector.getSelectedId();
			getCurAccList().getAccessoriesByCatId(gotAccessories,catId);
		}
		
		private function gotAccessories(accArr:Array) {
			ToolTipManager.reset();
			accSelector.clear();
			var acc:AccessoryData;
			//ignore duplicates
			var idArr:Array = new Array();
			for (var i:int = 0; i < accArr.length; i++) {
				acc = accArr[i];				
				if (idArr.indexOf(acc.id) == -1)
				{
					
					ToolTipManager.add(accSelector.add(acc.id, acc.name, acc, false) as DisplayObject, acc.name);
					idArr.push(acc.id);
				}
			}
			accSelector.update();
			accSelector.selectById(player.getSelectedAccessoryIdByType(typeSelector.getSelectedId()));
			updateTypes();
			setIsLoadingData(false);
		}
		
		private function updateTypes(incompat:int=0) {
			trace("AccessoryPanel::updateTypes");
			if (player.getShow().sceneArr[player.curSceneIndex - 1].model.type.toUpperCase() != "2D" && player.getShow().sceneArr[player.curSceneIndex - 1].model.type != "host_2d")
				return;
			var typeIdArr:Array = player.getShow().sceneArr[player.curSceneIndex-1].model.getAvailableTypeIds();
			var typeBtnArr:Array = typeSelector.getItemArray();
			var typeBtn:AccessoryTypeSelectorItem;
			var firstAvailableType:int = 999;
			var defaultDisabled:Boolean = false;
			for (var i:int = 0; i < typeBtnArr.length; i++) {
				typeBtn = typeBtnArr[i] as AccessoryTypeSelectorItem;
				typeBtn.disabled = (typeIdArr.indexOf(typeBtn.id) == -1) || incompat == typeBtn.id;
				if (player.controller != null)
				{
					var availAcc:Array = player.controller.getTypedAccessorySections();
					var typeFound:Boolean = false;
					for (var j:int = 0; j < availAcc.length; ++j )
					{
						if (typeBtn.id == availAcc[j].typeId)
						{
							typeFound = true;
						}
					}
					typeBtn.disabled = (!typeBtn.disabled && !typeFound)? true : typeBtn.disabled;
				}
				
				if (typeSelector.getSelectedId() == typeBtn.id && typeBtn.disabled)
				{			
					defaultDisabled = true;					
				}
				if (!typeBtn.disabled && typeBtn.id < firstAvailableType)
				{
					firstAvailableType = typeBtn.id;
				}									
			}			
			if (defaultDisabled)
			{
				//no accessory is available switch to next tab
				if (firstAvailableType == 999)
				{
					SessionVars.selectPanelByName("color");
					SessionVars.disablePanelByName("style");
				}
				else
				{
					trace("firstAvailableType=" + firstAvailableType);
					typeSelector.selectById(firstAvailableType);
					getCategories();
				}
			}
		}
		
		
		private function getCurAccList():SPAccessoryList {
			var modelId:int = player.getShow().sceneArr[player.curSceneIndex-1].model.id;
			var typeId:int = typeSelector.getSelectedId();
			if (accListArr[modelId] == null) accListArr[modelId] = new Array();
			var accList:SPAccessoryList = accListArr[modelId][typeId];
			if (accList == null) {
				var typeIsPrivate:Boolean = player.getShow().sceneArr[player.curSceneIndex-1].model.typeIsPrivate(typeId);
				accList = new SPAccessoryList(modelId, typeId, typeIsPrivate);
				accList.addEventListener(AlertEvent.ERROR, function(evt:AlertEvent):void
				{
					dispatchEvent(evt);;
				});
				accListArr[modelId][typeId] = accList;
			}
			return(accList);
		}
		
//-------------------- CALLBACKS -------------------------------
		
		private function typeSelected(evt:SelectorEvent) {
			getCategories();
		}
		
		private function catSelected(evt:SelectorEvent) {
			getAccessories();
		}
		
		private function accSelected(evt:SelectorEvent) {
			//fix incompatible hat/hair issue
			var acc:AccessoryData = AccessoryData(evt.obj);
			
			player.loadAccessory(acc);
			if (acc.incompatibleWith > 0)
			{
				updateTypes(acc.incompatibleWith);
			}
			else
			{
				updateTypes();
			}
		}

		private function onProcessingUpdate(evt:Event) {
			updateLoadingBar();
		}
	}
	
}