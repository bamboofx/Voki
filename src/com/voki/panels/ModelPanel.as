﻿package com.voki.panels {
	import com.oddcast.event.ModelEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.ToolTipManager;
	import com.oddcast.utils.ToolTipManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.oddcast.event.AlertEvent;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SPCategory;
	import com.voki.data.SPHostStruct;
	import com.voki.data.SPModelList;
	import com.voki.player.PlayerController;
	import com.voki.processing.ASyncProcess;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ModelPanel extends MovieClip implements IPanel {
		public var catSelector:OComboBox;
		public var genderSelector:OComboBox;
		public var modelSelector:Selector;
		public var scrollbar:OScrollBar;
		public var cbOwn:OCheckBox;
		public var cbSpecialty:OCheckBox;
		public var loadingBar:MovieClip;
		public var ownedModelsText:MovieClip;
		public var specialtyModelsText:MovieClip;
		private var _mcBtnWhatThis:BaseButton;
		
		public var data:SPModelList;
		private var player:PlayerController;
		private var isInited:Boolean;
		private var isLoadingData:Boolean;
		
		private var lastModelId:int;
		private var _bSelectFirstModel;
		
		public function ModelPanel() {
			setIsLoadingData(false);
			isInited = false;
			//genderSelector.addListener(this);
			genderSelector.add(0, "All")
			genderSelector.add(3, "Animal")
			genderSelector.add(1,"Female")
			genderSelector.add(2,"Male")
			genderSelector.add(4,"Other")
			genderSelector.selectById(0);
			
			_mcBtnWhatThis = specialtyModelsText._mcBtnWhatThis;
			genderSelector.addEventListener(SelectorEvent.SELECTED, genderSelected);
			catSelector.addEventListener(SelectorEvent.SELECTED, catSelected);
			modelSelector.addEventListener(SelectorEvent.SELECTED, modelSelected);			
			cbOwn.addEventListener(MouseEvent.CLICK, ownedSelected);
			cbSpecialty.addEventListener(MouseEvent.CLICK, specialtySelected);
			_mcBtnWhatThis.addEventListener(MouseEvent.CLICK, whatSpecialtyClicked);
			modelSelector.addScrollBar(scrollbar);
		}
		
		public function openPanel() {
			trace("ModelPanel::openPanel");
			ToolTipManager.reset();
			if (!isInited) init();
			else 
			{
				modelSelector.selectById(selectedModelId);
				var itemsArr:Array = modelSelector.getItemArray();
				for (var i:int = 0; i < itemsArr.length; ++i)
				{
					ToolTipManager.add(itemsArr[i] as DisplayObject, SelectorItem(itemsArr[i]).text);
				}
			
			}
		}
		
		private function init() {			
			trace("ModelPanel::init - SessionVars.mode='" + SessionVars.mode + "' == SessionVars.DEMO_MODE='" + SessionVars.DEMO_MODE + "'");
			if (SessionVars.mode == SessionVars.DEMO_MODE)
			{
				cbOwn.visible = false;
				ownedModelsText.visible = false;
				cbSpecialty.visible = true;
				specialtyModelsText.visible = true;
				cbSpecialty.selected = false;
			}
			else
			{
				cbOwn.visible = true;
				ownedModelsText.visible = true;
				cbSpecialty.visible = false;
				specialtyModelsText.visible = false;
				cbOwn.selected = true;
			}
			setIsLoadingData(true);
			
			data.addEventListener(AlertEvent.ERROR, function(evt:AlertEvent):void
			{
				dispatchEvent(evt);;
			});
			data.getCategoryArr(gotCategories);
		}
		
		public function selectFirstModel():void
		{
			if (!isInited)
			{
				_bSelectFirstModel = true;
				init();
			}
			else
			{
				var si:SelectorItem = modelSelector.getItemArray()[0];
				modelSelector.selectById(si.id);
				var sEvt:SelectorEvent = new SelectorEvent(SelectorEvent.SELECTED, si.id, si.text, si.data);
				dispatchEvent(sEvt);				
			}
		}
		
		public function setPlayer($player:PlayerController) {
			player = $player;
		}
		
		public function returnToPreviousModel():void
		{			
			trace("ModelPanel::selectNextModel");
			modelSelector.selectById(lastModelId);			
			
		}
		
		private function gotCategories(catArr:Array) {
			trace("ModelPanel::gotCategories : " + catArr.length);
			catSelector.clear();
			var cat:SPCategory;
			for (var i:int = 0; i < catArr.length; i++) {
				cat = catArr[i];
				catSelector.add(cat.id, cat.name,cat);
			}
			isInited = true;
			if (catArr.length == 0) setIsLoadingData(false);
			else {
				catSelector.selectById(catArr[0].id);
				populateModels();
			}
		}
		
		private function populateModels() {
			if (!catSelector.isSelected()) return;
			setIsLoadingData(true);
			data.getModelsByCatId(gotModels, catSelector.getSelectedId(), genderSelector.getSelectedId());
		}
		
		private function gotModels(modelArr:Array) {
			setIsLoadingData(false);
			modelArr.sortOn("name", Array.CASEINSENSITIVE);
			ToolTipManager.reset();
			modelSelector.clear();
			var showOwned:Boolean = cbOwn.selected;
			var showSpecialty:Boolean = cbSpecialty.selected;
			var model:SPHostStruct;
			var firstIndex:int = -1;
			for (var i:int = 0; i < modelArr.length; i++) {
				model = modelArr[i];
				if (showOwned && !model.isOwned) continue;
				if (!showSpecialty && model.level > 3 && SessionVars.mode == SessionVars.DEMO_MODE) continue;
				if (model.is3d) continue; //don't show 3d models in this panel
				firstIndex = firstIndex < 0? i : firstIndex;
				ToolTipManager.add(modelSelector.add(model.modelId, model.name, model, false) as DisplayObject,model.name);
			}
			
			//if no model is selected, select first on list
			trace("ModelPanel::gotModels selectedModelId=" + selectedModelId);
			if (selectedModelId < 0 && modelArr.length > 0) { 
				dispatchEvent(new ModelEvent(ModelEvent.SELECT, modelArr[firstIndex]));
				//player.loadModel(modelArr[0]);
			}
			
			modelSelector.update();
			/*
			if (_bSelectFirstModel)
			{
				_bSelectFirstModel = false;
				var si:SelectorItem = modelSelector.getItemArray()[0];
				modelSelector.selectById(si.id);
				var sEvt:SelectorEvent = new SelectorEvent(SelectorEvent.SELECTED, si.id, si.text, si.data);
				dispatchEvent(sEvt);		
			}
			else
			{
			*/
				modelSelector.selectById(selectedModelId);
			
			dispatchEvent(new Event("modelDataReady"));
		}
		
		private function get selectedModelId():int {
			if (player == null) return(-1);
			else if (player.scene == null) return(-1);
			else if (player.scene.model == null) return(-1);
			else return(player.scene.model.modelId);
		}
		
		private function setIsLoadingData(b:Boolean) {
			isLoadingData = b;
			var isLoading:Boolean = isLoadingData;
			/*if (player != null) {
				if (player.processList.isProcessingType(ASyncProcess.PROCESS_MODEL)) isLoading = true;
				if (player.processList.isProcessingType(ASyncProcess.PROCESS_ACCESSORY)) isLoading = true;
			}*/
			
			loadingBar.visible = isLoading;
			modelSelector.visible = !isLoading;
			catSelector.disabled = isLoading;
			genderSelector.disabled = isLoading;
			cbOwn.disabled = isLoading;
		}
		
		//-------------------------------------------------------------
		
		private function catSelected(evt:SelectorEvent) {
			if (evt.id == SPModelList.PRIVATE_CATEGORY) {
				genderSelector.selectById(0);
				genderSelector.disabled = true;
			}
			else genderSelector.disabled = false;
			
			populateModels();
		}
		
		private function genderSelected(evt:SelectorEvent) {
			populateModels();
		}
		
		private function modelSelected(evt:SelectorEvent) {
			lastModelId = selectedModelId;
			dispatchEvent(new ModelEvent(ModelEvent.SELECT, evt.obj as SPHostStruct));
			//player.loadModel(evt.obj as SPHostStruct);
		}
		
		private function ownedSelected(evt:MouseEvent) {
			populateModels();
		}
		
		private function specialtySelected(evt:MouseEvent):void
		{
			populateModels();
		}
		
		private function whatSpecialtyClicked(evt:MouseEvent):void
		{
			//do nothing for now
			dispatchEvent(new AlertEvent("about", "sp218"));
		}
		
		//-------------------------------------------------------------
		public function closePanel() {
			trace("ModelPanel::closePanel");
		}
	}
}