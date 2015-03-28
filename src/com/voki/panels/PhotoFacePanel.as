package com.voki.panels {
	import com.oddcast.assets.structures.HostStruct;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.ModelEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.MoveZoomUtil;
	import com.oddcast.utils.ToolTipManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;
	import com.voki.autophoto.AutoPhotoWin;
	import com.voki.data.SceneStruct;
	import com.voki.data.SPHostStruct;
	import com.voki.data.SPModelList;
	import com.voki.data.SPSavedCharList;
	import com.voki.panels.IPanel;
	import com.voki.player.PlayerController;
	import com.voki.processing.ASyncProcess;
	import com.oddcast.utils.XMLLoader;
	
	import com.oddcast.assets.structures.EngineStruct;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class PhotoFacePanel extends MovieClip implements IPanel {
		public var modelSelector:Selector;
		public var genderSelector:OComboBox;
		public var genderTitle:MovieClip;
		public var scrollbar:OScrollBar;
		public var cbOwn:OCheckBox;
		public var loadingBar:MovieClip;
		public var ownedModelsText:MovieClip;
		
		public var data:SPModelList;
		private var player:PlayerController;
		
		public var isInited:Boolean = false;
		private var isLoadingData:Boolean = false;
		
		public var _mcBtnCreate:BaseButton;
		private var _bHasModelLibrary:Boolean = true;
		private var _iAllCategory:int;
		private var _iLastModelId:int;
		private var _oLastSelectedEvent:Object;
		
		public var ap_win:AutoPhotoWin;
		
		public function PhotoFacePanel() {
			trace("SavedCharPanel::constructor");
			setIsLoadingData(false);
			
			
			
			
		}
		
		public function openPanel() {
			ToolTipManager.reset();
			trace("PhotoFacePanel::openPanel "+selectedModelId+" isInited="+isInited+", _bHasModelLibrary="+_bHasModelLibrary);
			if (!isInited)
			{
				init();
				isInited = true;
			}
			else if (_bHasModelLibrary) 
			{				
				modelSelector.selectById(selectedModelId);
				_iLastModelId = selectedModelId
				var itemsArr:Array = modelSelector.getItemArray();
				for (var i:int = 0; i < itemsArr.length; ++i)
				{
					ToolTipManager.add(itemsArr[i] as DisplayObject, SelectorItem(itemsArr[i]).text);
				}
			}
		}
		
		public function setData(modelList:SPModelList):void
		{
			data = modelList;
			_bHasModelLibrary = true;
			data.addEventListener(AlertEvent.ERROR, function(evt:AlertEvent):void
			{
				dispatchEvent(evt);;
			});
			trace("PhotoFacePanel:setData");
			data.getCategoryArr(gotCategories);						
		}
		
		private function gotCategories(catArr:Array) {
			trace("PhotoFacePanel:gotCategoris");
			_iAllCategory = catArr[0].id;			
			data.getModelsByCatId(populateModels, SPModelList.PRIVATE_CATEGORY);
		}
		
		public function setPlayer($player:PlayerController) {
			trace("PhotoFacePanel::setPlayer - "+$player);
			player = $player;
			player.processList.addEventListener(Event.CHANGE, onProcessingUpdate);
			player.addEventListener(PlayerController.LOAD_ERROR, onLoadingError);
		}
		
		public function openAutoPhotoWin(evt:MouseEvent):void
		{
			ap_win.init();
			trace("open AutophotoWin");
			ap_win.visible = true;
			dispatchEvent(new Event("hidePlayer"));
		}
		
		private function onAutophotoWinClosed(evt:Event = null):void
		{
			dispatchEvent(new Event("showPlayer"));
		}
		
		private function init() {					
			data.addEventListener(AlertEvent.ERROR, function(evt:AlertEvent):void
			{
				dispatchEvent(evt);;
			});
			
			data.getCategoryArr(gotCategories);	
			/*
			if (SessionVars.mode == SessionVars.DEMO_MODE)
			{
				cbOwn.visible = false;
				ownedModelsText.visible = false;
			}
			else
			{
				cbOwn.visible = true;
				ownedModelsText.visible = true;
			}
			*/
			if (_bHasModelLibrary)
			{
				/*
				data = new SPSavedCharList();
				setIsLoadingData(true);
				data.getModels(gotModels);
				*/
				gotoAndStop(2);
				modelSelector.visible = true;
				genderSelector.visible = true;
				genderTitle.visible = true;
				scrollbar.visible = true;								
			}
			else
			{
				_bHasModelLibrary = false;
				gotoAndStop(1);
				modelSelector.visible = false;
				genderSelector.visible = false;
				genderTitle.visible = false;
				scrollbar.visible = false;								
			}
			_mcBtnCreate.addEventListener(MouseEvent.CLICK, openAutoPhotoWin);
			modelSelector.addScrollBar(scrollbar, true);
			modelSelector.addEventListener(SelectorEvent.SELECTED, onModelSelected);
			modelSelector.addItemEventListener("deleteModel", onModelDelete);
			genderSelector.add(0,"All")
			genderSelector.add(1, "Female")	
			genderSelector.add(2,"Male")					
			genderSelector.selectById(0);
			genderSelector.addEventListener(SelectorEvent.SELECTED, genderSelected);
			cbOwn.addEventListener(MouseEvent.CLICK, ownedSelected);
			ap_win.visible = false;
			ap_win.addEventListener(AlertEvent.ALERT, function (evt:AlertEvent) { dispatchEvent(evt) } );
			ap_win.addEventListener(Event.CLOSE, onAutophotoWinClosed);
			ap_win.addEventListener("onAutophotoModelSaved", onAutophotoModelSaved);
			modelSelector.selectById(selectedModelId);
			dispatchEvent(new Event("photoFaceInit"));
			
		}	
				
		
		private function onModelDelete(evt:Event) {
			deleteModel(evt.target.data as SPHostStruct);
		}
		
		private function populateModels(modelArr:Array)
		{
			
			modelArr.sortOn("name", Array.CASEINSENSITIVE);
			ToolTipManager.reset();
			modelSelector.clear();			
			var model:SPHostStruct;
			for (var i:int = 0; i < modelArr.length; i++) {
				
				model = modelArr[i];				
				trace("PhotoFacePanel::populateModels " + model.name + ", genderId=" + model.modelGenderId + ", selectorGenderId=" + genderSelector.getSelectedId()+" model.is3d="+model.is3d);
				if (!model.is3d)
				{
					continue;
				}
				else if (genderSelector.getSelectedId() > 0 && model.modelGenderId != genderSelector.getSelectedId())
				{
					continue;
				}
				else
				{
					//model.isPrivate = true;
					if (!_bHasModelLibrary)
					{
						_bHasModelLibrary = true;										
						gotoAndStop(2);
						modelSelector.visible = true;
						scrollbar.visible = true;
						genderSelector.visible = true;
						genderTitle.visible = true;						
					}
				}
				ToolTipManager.add(modelSelector.add(model.modelId, model.name, model, false) as DisplayObject, model.name);
				
			}
			
			if (!cbOwn.selected)
			{
				data.getModelsByCatId(populateGalleryModels, _iAllCategory, genderSelector.getSelectedId());
				modelSelector.update();
				modelSelector.selectById(selectedModelId);
			}
			else
			{
				setIsLoadingData(false);
				modelSelector.update();
				modelSelector.selectById(selectedModelId);	
			}
			
		}
		
		private function populateGalleryModels(modelArr:Array):void
		{
			setIsLoadingData(false);
			modelArr.sortOn("name", Array.CASEINSENSITIVE);			
			var model:SPHostStruct;
			for (var i:int = 0; i < modelArr.length; i++) {
				model = modelArr[i];
				if (!model.is3d)
				{
					continue;
				}
				else
				{
					model.isPrivate = false;
					if (!_bHasModelLibrary)
					{
						_bHasModelLibrary = true;
						gotoAndStop(2);
						modelSelector.visible = true;
						genderSelector.visible = true;
						genderTitle.visible = true;
						scrollbar.visible = true;
						_bHasModelLibrary = true;
					}
				}
				ToolTipManager.add(modelSelector.add(model.modelId, model.name, model, false) as DisplayObject, model.name);
			}
						
			modelSelector.update();
			modelSelector.selectById(selectedModelId);			
		}
		
		private function addNewModel(model:SPHostStruct):void
		{
			if (!_bHasModelLibrary)
			{
				gotoAndStop(2);
				modelSelector.visible = true;
				scrollbar.visible = true;
				genderSelector.visible = true;
				genderTitle.visible = true;
				_bHasModelLibrary = true;				
				
			}
			data.addPrivateModel(model);
			ToolTipManager.add(modelSelector.add(model.modelId, model.name, model, false) as DisplayObject, model.name);
			modelSelector.update();
			modelSelector.selectById(model.modelId);
			_iLastModelId = model.modelId;
		}
		/*
		private function charSavedToDB(urlVars:URLVariables):void
		{
			showCharacterInPlayer();
		}
		*/
		
		private function showCharacterInPlayer(newCharId:int = 0):void
		{
			/*
			if (SessionVars.editorMode != "CharacterEditor")
			{
				var origVars:URLVariables = ap_win.getLastSavedData();
				var postVars:URLVariables = new URLVariables();
				postVars.charId = SessionVars.mode != SessionVars.DEMO_MODE ? player.scene.char.id : 0;
				postVars.charURL = origVars.oa1File
				postVars.thumbURL = origVars.thumbUrl;
				postVars.charName = origVars.modelName;
				postVars.modelId = ap_win.getLastSavedModelId();
				postVars.showId = SessionVars.showId;
				postVars.addId = SessionVars.acc;
				postVars.charType = 1;
				XMLLoader.sendAndLoad(SessionVars.localBaseURL + "savecharacterV5.php?rnd=" + (Math.random() * 100000),charSavedToDB, postVars, URLVariables);								
			}
			else
			{
				
			}						
			*/
			
			
			ap_win.visible = false;
			onAutophotoWinClosed();
			var newHost:SPHostStruct = new SPHostStruct(ap_win.getLastSavedOA1Url(), ap_win.getLastSavedModelId());
			newHost.charId = player.scene.char.id;
			newHost.charXml = ap_win.getAPModel().charXml;
			newHost.name = ap_win.getLastSavedData().modelName;
			newHost.thumbUrl = ap_win.getLastSavedData().thumbUrl;
			newHost.modelGenderId = ap_win.getLastSavedData().genderId;
			newHost.isPrivate = true;
			newHost.isDirty = true;
			
			/*
			if (newCharId > 0)
			{
				newHost.charId = newCharId;
			}
			else
			{
				newHost.charId = SessionVars.mode != SessionVars.DEMO_MODE ? player.scene.char.id : 0;
			}
			*/
			newHost.type = "host_3d"
			newHost.engine = new EngineStruct(SessionVars.apEngineUrl, SessionVars.apEngineId, SessionVars.apEngineType);
			newHost.isOwned = (SessionVars.photofaceSaveAllowed || SessionVars.mode == SessionVars.DEMO_MODE)? true: false;		
			newHost.is3d = true;
			addNewModel(newHost);
			dispatchEvent(new ModelEvent(ModelEvent.SELECT, newHost));
			trace("PhotoFacePanel::refresh and load oa1 in player");
		}
		
		private function onAutophotoModelSaved(evt:Event)
		{
			showCharacterInPlayer();
			
			
		}
		
		private function gotModels(modelArr:Array) {
			setIsLoadingData(false);
			ToolTipManager.reset();
			modelSelector.clear();
			var model:SPHostStruct;
			for (var i:int = 0; i < modelArr.length; i++) {
				model = modelArr[i];
				ToolTipManager.add(modelSelector.add(model.modelId, model.name, model, false) as DisplayObject, model.name);
			}
			modelSelector.selectById(selectedModelId);
			modelSelector.update();
			isInited = true;
		}
		
		private function setIsLoadingData(b:Boolean) {
			isLoadingData = b;
			modelSelector.visible = !isLoadingData;			
			genderSelector.visible = !isLoadingData;
			genderTitle.visible = !isLoadingData;						
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
			genderSelector.visible = !isLoadingData;
			genderTitle.visible = !isLoadingData;		
		}
		
		private function get selectedModelId():int {
			if (player == null) return(-1);
			else if (player.scene == null) return(-1);
			else if (player.scene.model == null) return(-1);
			else return(player.scene.model.modelId);
		}
		
		private function genderSelected(evt:SelectorEvent) {			
			data.getModelsByCatId(populateModels, SPModelList.PRIVATE_CATEGORY);
		}
		
		private function onModelSelected(evt:SelectorEvent) {			
			
			if ((player.scene.model.type.toLowerCase() != "3d" && player.scene.model.type.toLowerCase() != "host_3d") && player.zoomer!=null && player.zoomer.scale < MoveZoomUtil.MIN_SCALE_3D)
			{
				_oLastSelectedEvent = evt;
				dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "216", "The selected model cannot be displayed at this zoom level. Once loaded its zoom will be updated. Proceed?", null, selectConfirm));
			}
			else
			{
				_iLastModelId = SPHostStruct(evt.obj).id;
				dispatchEvent(new ModelEvent(ModelEvent.SELECT, evt.obj as SPHostStruct));
			}
			//player.loadModel(evt.obj as SPHostStruct);
		}
		
		private function selectConfirm(b:Boolean) {
			if (b) { //confirmed
					dispatchEvent(new ModelEvent(ModelEvent.SELECT, _oLastSelectedEvent.obj as SPHostStruct));			
			}
			else 
			{
				modelSelector.selectById(_iLastModelId);
			}
		}
		
		private function ownedSelected(evt:MouseEvent) {
			data.getModelsByCatId(populateModels, SPModelList.PRIVATE_CATEGORY);
		}
		
		private function onProcessingUpdate(evt:Event) {
			trace("SavedCharPanel::onProcessingUpdate");
			updateLoadingBar();
		}
		
		private function onLoadingError(evt:Event):void
		{			
			modelSelector.remove(_iLastModelId);
		}
		
		public function closePanel() {
			
		}
		
		//----------------------------------------------------------------------------------------------------
		
		//callback from BGThumb inside thumbselector
		private var modelToDelete:SPHostStruct;
		public function deleteModel(model:SPHostStruct) {
			modelToDelete = model;
			var rand:Number=Math.floor(Math.random()*1000000);
			var url:String=SessionVars.localBaseURL+"itemUsed.php?accId="+SessionVars.acc+"&itemId="+modelToDelete.id+"&itemType=mo&rnd="+rand;					
			
			XMLLoader.loadXML(url, modelUsed);
			setIsLoadingData(true);
			
			
		}
		
		private function modelUsed(_xml:XML)
		{
			setIsLoadingData(false);
			if (_xml==null || _xml.@RES == "ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp215","Error deleting model : {details}",{details: _xml==null?XMLLoader.lastError:_xml.@MSG}));
			}
			else 
			{
				if ( _xml.@RES == "NO")
				{
					dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp214", "The asset {name} will be removed. This operation cannot be undone. Proceed?", { name:modelToDelete.name }, onConfirm));
				}
				else if ( _xml.@RES == "YES")
				{
					dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp407", "The asset {name} is in use by a scene. Are you sure you want to delete it?", {name:modelToDelete.name}, onConfirm));					
				}
			}
		}
		
		public function onConfirm(ok:Boolean) {
			if (ok) {
				var rand:Number=Math.floor(Math.random()*1000000);
				var url:String=SessionVars.localBaseURL+"deleteItem.php?type=model&id="+modelToDelete.id+"&rnd="+rand;
				XMLLoader.loadXML(url, modelDeleted);
				setIsLoadingData(true);
			}
			else 
			{
				modelToDelete = null;
				setIsLoadingData(false);
			}
		}
		
		public function modelDeleted(_xml:XML) {
			if (_xml==null || _xml.@RES == "ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp215","Error deleting model : {details}", {details: _xml==null?XMLLoader.lastError:_xml.@MSG}));
			}
			else {
				var id:int = modelToDelete.id;// parseInt(_xml.@ID);				
				modelSelector.remove(id);
				data.removeAccountModelWithId(id);
				modelSelector.update();
				if (modelSelector.numItems == 0)
				{
					_bHasModelLibrary = false;
					gotoAndStop(1);
					modelSelector.visible = false;
					genderSelector.visible = false;
					genderTitle.visible = false;		
					scrollbar.visible = false;		
				}
			}
			setIsLoadingData(false);
			modelToDelete = null;
		}

//----------------------------------------------------------------------------------------------------
		
	}
	
}