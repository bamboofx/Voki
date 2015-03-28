package com.voki.panels {
	import com.oddcast.data.ThumbSelectorData;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.event.SkinSelectEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.utils.ToolTipManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SPCategory;
	import com.voki.data.SPSkinList;
	import com.voki.data.SPSkinStruct;
	import com.voki.player.PlayerController;
	import com.voki.processing.ASyncProcess;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SkinPanel extends MovieClip implements IPanel {
		public var skinSelector:Selector;
		public var scrollbar:OScrollBar;
		public var topMenu:MovieClip;
		public var loadingBar:MovieClip;
		private var typeSelector:OComboBox;
		private var infoBtn:BaseButton;
		
		private var selectPopularSkin:Boolean = false;
		private var popularSkinTypeName:String;
		
		private var player:PlayerController;
		private var data:SPSkinList;
		private var typeArr:Array;
		private var isInited:Boolean = false;
		private var isLoadingData:Boolean = false;
		private static var NO_SKIN_ID:int = -1;
		
		public var _mcFirstSceneOnlyMsg:MovieClip;
		
		public function SkinPanel() {
			typeSelector = topMenu.getChildByName("typeSelector") as OComboBox;
			infoBtn = topMenu.getChildByName("infoBtn") as BaseButton;
			
			skinSelector.addScrollBar(scrollbar);
			skinSelector.addEventListener(SelectorEvent.SELECTED, skinSelected);
			typeSelector.addEventListener(SelectorEvent.SELECTED, typeSelected);
			if (SessionVars.editorMode == "SceneEditor")
			{
				infoBtn.visible = false;
			}
			else
			{
				infoBtn.addEventListener(MouseEvent.CLICK, onInfo);
			}
			
			data = new SPSkinList();
			
			setIsLoadingData(false);
			if (_mcFirstSceneOnlyMsg != null)
			{
				_mcFirstSceneOnlyMsg.visible = false;
			}
		}
		
		public function setPlayer($player:PlayerController) {
			player = $player;
			player.processList.addEventListener(Event.CHANGE, onProcessingUpdate);
		}
		
		public function selectPopularSkinType(typeName:String) {
			selectPopularSkin = true;
			popularSkinTypeName = typeName;
		}
		
		public function openPanel() {
			//only standard skins are available in partner unlogged-in mode
			ToolTipManager.reset();
			updateSelectionPerScene();
			if (SessionVars.mode == SessionVars.PARTNER_MODE && !SessionVars.loggedIn) topMenu.visible = false;
			init();
		}
		public function closePanel() {
			
		}
		
		public function updateSelectionPerScene():void
		{
			if (_mcFirstSceneOnlyMsg != null)
			{
				if (player.curSceneIndex == 1)
				{
					_mcFirstSceneOnlyMsg.visible = false;
					SessionVars.disablePanelByName("functions",false);
				}
				else
				{
					_mcFirstSceneOnlyMsg.visible = true;
					_mcFirstSceneOnlyMsg.buttonMode = true;
					_mcFirstSceneOnlyMsg.useHandCursor = false;
					
					SessionVars.disablePanelByName("functions", (player.scene.skin != null && player.scene.skin.type == SPSkinStruct.STANDARD_TYPE) || player.scene.skin==null);
					
				}
			}
		}
		
		public function setIsLoadingData(b:Boolean) {
			isLoadingData = b;
			updateLoadingBar();
		}
		private function updateLoadingBar() {
			var isLoading:Boolean = isLoadingData;
			if (player != null) {
				if (player.processList.isProcessingType(ASyncProcess.PROCESS_SKIN)) isLoading = true;
			}
			trace("SkinPanel::updateLoadingBar - loading:"+isLoading+" - data:"+isLoadingData+" - skin:"+(player==null?"null":player.processList.isProcessingType(ASyncProcess.PROCESS_SKIN)));
			
			loadingBar.visible = isLoading;
			skinSelector.visible = !isLoading;
			typeSelector.disabled = isLoading;
		}

//-------------------------------------------------  POPULATE  ---------------------------------------------------
		
		private function init() {
			setIsLoadingData(true);
			data.getTypeArr(populateTypes);
		}
		
		private function populateTypes($typeArr:Array) {
			trace("SkinPanel::populateTypes");
			
			typeArr = $typeArr;
			var typeName:String;
			
			typeSelector.clear();
			for (var i:int = 0; i < typeArr.length; i++) {
				
				typeName = SPSkinList.typeTitles[typeArr[i]];
				trace("SkinPanel::add type " + typeName);
				if (typeName!=null) typeSelector.add(i,typeName);
			}
			trace("SkinPanel::selectPopularSkin=" + selectPopularSkin + ", popularSkinTypeName=" + popularSkinTypeName + ", player.scene.skin=" + player.scene.skin);
			if (selectPopularSkin) typeSelector.selectById(typeArr.indexOf(popularSkinTypeName.toLowerCase()));
			else if (player.scene.skin == null) typeSelector.selectById(typeArr.indexOf(SPSkinStruct.STANDARD_TYPE));
			else 
			{
				trace("SkinPanel:: player.scene.skin.type="+player.scene.skin.type);
				typeSelector.selectById(typeArr.indexOf(player.scene.skin.type));
			}
			
			populateSkins();
		}
		
		private function populateSkins() {
			trace("SkinPanel::populateSkins typeSelector.isSelected()="+typeSelector.isSelected());
			setIsLoadingData(false);
			if (!typeSelector.isSelected()) return;
			
			setIsLoadingData(true);
			data.getSkinsByType(gotSkins, typeArr[typeSelector.getSelectedId()]);
		}
		
		private function gotSkins(skinArr:Array) {
			trace("SkinPanel::gotSkins");
			ToolTipManager.reset();
			skinSelector.clear();
			
			var noSkinUrl:String = SessionVars.adminURL + "img/en/none_thumb.jpg";
			skinSelector.add(NO_SKIN_ID, "No Skin", new ThumbSelectorData(noSkinUrl));
			
			var skin:SPSkinStruct;
			for (var i:int = 0; i < skinArr.length; i++) {
				skin = skinArr[i];
				
				ToolTipManager.add(skinSelector.add(skin.id, skin.name, skin, false) as DisplayObject,skin.name);
			}
			skinSelector.update();
			
			//add "no skin"
			
			
			setIsLoadingData(false);
			if (selectPopularSkin) {
				selectPopularSkin = false;
				loadSkin(skinArr[0]);
				skinSelector.selectById(SPSkinStruct(skinArr[0]).id);
			}
			else if (player.scene.skin == null) skinSelector.selectById(NO_SKIN_ID);
			else skinSelector.selectById(player.scene.skin.id);
		}
		private function loadSkin(skin:SPSkinStruct) {
			trace("SkinPanel::loadSkin");
				player.loadSkin(skin);
				dispatchEvent(new SkinSelectEvent(SkinSelectEvent.SELECT, skin));
		}
//-------------------------------------------------  EVENTS  ---------------------------------------------------
		private function onProcessingUpdate(evt:Event) {
			updateLoadingBar();
		}
		private function typeSelected(evt:SelectorEvent) {
			populateSkins();
		}
		private function skinSelected(evt:SelectorEvent) {
			loadSkin(evt.obj as SPSkinStruct);
		}
		private function onInfo(evt:MouseEvent) {
			dispatchEvent(new Event("openSkinPromoWin"));
		}
	}
	
}