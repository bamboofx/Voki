package com.voki.panels {
	import com.oddcast.event.ModelEvent;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.ToolTipManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.voki.data.SceneStruct;
	import com.voki.data.SPHostStruct;
	import com.voki.data.SPSavedCharList;
	import com.voki.panels.IPanel;
	import com.voki.player.PlayerController;
	import com.voki.processing.ASyncProcess;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SavedCharPanel extends MovieClip implements IPanel {
		public var modelSelector:Selector;
		public var scrollbar:OScrollBar;
		public var loadingBar:MovieClip;
		
		public var data:SPSavedCharList;
		private var player:PlayerController;
		
		private var isInited:Boolean = false;
		private var isLoadingData:Boolean = false;
		
		public function SavedCharPanel() {
			trace("SavedCharPanel::constructor");
			setIsLoadingData(false);
			modelSelector.addScrollBar(scrollbar, true);
			modelSelector.addEventListener(SelectorEvent.SELECTED, onModelSelected);
		}
		
		public function openPanel() {
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
		
		public function setPlayer($player:PlayerController) {
			trace("SavedCharPanel::setPlayer - "+$player);
			player = $player;
			player.processList.addEventListener(Event.CHANGE, onProcessingUpdate);
		}
		
		private function init() {
			data = new SPSavedCharList();
			data.addEventListener(AlertEvent.ERROR, function(evt:AlertEvent):void
			{
				dispatchEvent(evt);;
			});
			setIsLoadingData(true);
			data.getModels(gotModels);
		}
		
		private function gotModels(modelArr:Array) {
			setIsLoadingData(false);
			ToolTipManager.reset();
			modelSelector.clear();
			var model:SPHostStruct;
			var selectedIndex:int;
			for (var i:int = 0; i < modelArr.length; i++) {
				model = modelArr[i];
				if (model.id == selectedModelId)
				{
					selectedIndex = i;
				}
				ToolTipManager.add(modelSelector.add(i, model.name, model, false) as DisplayObject, model.name);
			}
			modelSelector.selectById(selectedIndex);
			modelSelector.update();
			isInited = true;
		}
		
		private function setIsLoadingData(b:Boolean) {
			isLoadingData = b;
			updateLoadingBar();
		}
		
		private function updateLoadingBar() {
			trace("SavedCharPanel::updateLoadingBar");
			var isLoading:Boolean = isLoadingData;
			if (player != null) {
				if (player.processList.isProcessingType(ASyncProcess.PROCESS_MODEL)) isLoading = true;
				if (player.processList.isProcessingType(ASyncProcess.PROCESS_ACCESSORY)) isLoading = true;
			}

			loadingBar.visible = isLoading;
			modelSelector.visible = !isLoading;
		}
		
		private function get selectedModelId():int {
			if (player == null) return(-1);
			else if (player.scene == null) return(-1);
			else if (player.scene.model == null) return(-1);
			else return(player.scene.model.modelId);
		}
		
		private function onModelSelected(evt:SelectorEvent) {
			dispatchEvent(new ModelEvent(ModelEvent.SELECT, evt.obj as SPHostStruct));
			//player.loadModel(evt.obj as SPHostStruct);
		}
		
		private function onProcessingUpdate(evt:Event) {
			trace("SavedCharPanel::onProcessingUpdate");
			updateLoadingBar();
		}
		
		public function closePanel() {
			
		}
	}
	
}