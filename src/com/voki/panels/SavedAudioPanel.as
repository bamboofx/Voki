﻿package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.AudioEffectList;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.MultiSelector;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.ToolTipManager;
	import com.oddcast.utils.XMLLoader;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SPAudioList;
	import com.voki.data.SPCategory;
	import com.voki.nav.PopupController;
	import com.voki.player.PlayerController;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SavedAudioPanel extends MovieClip implements IPanel {
		public var audioSelector:MultiSelector;
		public var scrollbar:OScrollBar;
		public var cb_multiple:OCheckBox;
		public var whatsThisBtn:SimpleButton;
		public var catSelector:OComboBox;
		public var loadingBar:MovieClip;
		public var effectsWin:AudioEffectsPopup;
		
		public var data:SPAudioList;
		public var popupController:PopupController;
		private var player:PlayerController;
		private var isInited:Boolean = false;
		private static const NO_AUDIO_ID:int = -1;
		private var audioToDelete:AudioData;
		public var _arrExistingAudioNames:Array;
		private var iLastCategory:int;
		
		public function SavedAudioPanel() {
			whatsThisBtn.addEventListener(MouseEvent.CLICK, whatsThis);
			catSelector.addEventListener(SelectorEvent.SELECTED, catSelected);
			cb_multiple.addEventListener(SelectorEvent.SELECTED, toggleMultiple);
			cb_multiple.addEventListener(SelectorEvent.DESELECTED, toggleMultiple);
			
			audioSelector.setNoneId(NO_AUDIO_ID);
			audioSelector.addEventListener(SelectorEvent.SELECTED, audioSelected);
			audioSelector.addEventListener(SelectorEvent.DESELECTED, audioDeselected);
			audioSelector.addItemEventListener("editAudio", onEditAudio);
			audioSelector.addItemEventListener("deleteAudio", onDeleteAudio);
			audioSelector.addItemEventListener("editEffects", editAudioFX);
			audioSelector.addScrollBar(scrollbar);
			
			effectsWin.addEventListener(AudioEvent.SELECT, audioEffectsEdited);
			
			//default no multiple audio
			cb_multiple.selected = false;
			audioSelector.allowMultiple = false;
		}
		
		public function openPanel() {
			ToolTipManager.reset();
			if (isInited) getAudios();
			else init();
		}
		public function closePanel() {
			effectsWin.closeWin();
			player.stopAudio();
		}
		
		public function setPlayer($player:PlayerController) {
			player = $player;
		}
		
		private function showLoadingBar(b:Boolean) {
			loadingBar.visible = b;
		}
		
		public function showInfoMessage():void
		{
			var o:Object = new Object();
			//check if set to permenantly not show
			trace('String(SessionVars.getSOVar("multipleAudiosMsg"))='+String(SessionVars.getSOVar("multipleAudiosMsg")));
			if (String(SessionVars.getSOVar("multipleAudiosMsg")) != "1")
			{
				//check if shown in this session
				var sessData:Object = SessionVars.getSOVar("sessionData");
				if (sessData != null)
				{
					trace("sessData.sessionId=" + sessData.sessionId + ", SessionVars.sessionId=" + SessionVars.sessionId + ", String(sessData.multipleAudioMsg)=" + String(sessData.multipleAudioMsg));
					if (sessData.sessionId != SessionVars.sessionId || (sessData.sessionId == SessionVars.sessionId && String(sessData.multipleAudioMsg) != "1"))
					{
						
						o.sessionId = SessionVars.sessionId;
						o.multipleAudioMsg = "1";
						SessionVars.setSOVar("sessionData", o);
						dispatchEvent(new AlertEvent("info", "sp464", "", null, onInfoOK));
					}
				}
				else
				{		
					trace("sessData == null");
					o.sessionId = SessionVars.sessionId;
					o.multipleAudioMsg = "1";
					SessionVars.setSOVar("sessionData", o);
					dispatchEvent(new AlertEvent("info", "sp464", "", null, onInfoOK));
				}
			}
		}
		
		private function onInfoOK(b:Boolean)
		{
			if (b)
			{
				SessionVars.setSOVar("multipleAudiosMsg", "1");
			}
		}
		
//-------------------------------------------------------------------------------------
		
		private function init() {
			data.addEventListener(AlertEvent.ERROR, function(evt:AlertEvent):void
			{
				dispatchEvent(evt);;
			});
			showLoadingBar(true);
			effectsWin.fxList = new AudioEffectList(SessionVars.localBaseURL + "getFXList.php");			
			data.getCategoryArr(populateCategories);
		}
		
		private function populateCategories(catArr:Array) {
			catSelector.clear();
			var curCatExists:Boolean = false;
			var catId:int = 0;
			var category:SPCategory;
			for (var i = 0; i < catArr.length; i++) {
				category = catArr[i];
				catSelector.add(category.id,category.name,null,false);
				if (catId==category.id) curCatExists=true;
			}
			catSelector.update();
			if (!curCatExists) catId = SPAudioList.PRIVATE_CATEGORY;// catArr[0].id;
			if (player.scene.audioArr.length >0)//if there's one audio
			{
				var audioData:AudioData = player.scene.audioArr[0];
				if (audioData.catId > 0)
				{
					catSelector.selectById(audioData.catId);
				}
				else
				{
					catSelector.selectById(catId);
				}
			}
			else
			{
				catSelector.selectById(catId);
			}
			iLastCategory = catSelector.getSelectedId();
			isInited = true;
			getAudios();
		}
		
		public function getAudios() {
			if (!catSelector.isSelected()) {
				showLoadingBar(false);
				return;
			}
			showLoadingBar(true);
			var selectedCatId:int = catSelector.getSelectedId();
			data.getAudiosByCatId(populateAudios,selectedCatId, player.scene.audio);
		}
		
		public function resetMultiple(audio:AudioData):void
		{
			cb_multiple.selected = false; 
			player.scene.audioArr = new Array();
			player.scene.audioArr.push(audio);
		}
		
		private function populateAudios(audioArr:Array) {
			audioArr.sortOn("name", Array.CASEINSENSITIVE);
			//if (catId==PRIVATE_CAT) broadcastMessage("setAudioCount",privateAudioArr.length)
			ToolTipManager.reset();
			audioSelector.clear();			
			ToolTipManager.add(audioSelector.add(NO_AUDIO_ID, "No Audio", null, false) as DisplayObject, "No Audio");
			var audio:AudioData;
			var i:int;
			for (i = 0; i < audioArr.length; i++) {
				audio = audioArr[i];
				ToolTipManager.add(audioSelector.add(audio.id, audio.name, audio, false) as DisplayObject, audio.name);
				
			}
			audioSelector.update();
			
			if (player.scene.audioArr.length > 1)
			{
				cb_multiple.selected = true;
				audioSelector.allowMultiple = true;
			}
			for (i = 0; i < player.scene.audioArr.length; i++) {
				if (player.scene.audioArr[i] != undefined)
				{
					audioSelector.selectById(player.scene.audioArr[i].id);					
				}
			}
			
			if (catSelector.getSelectedId() == SPAudioList.PRIVATE_CATEGORY)
			{
				_arrExistingAudioNames = new Array();
				for (i = 0; i < audioArr.length; i++) 
				{
					audio = audioArr[i];
					_arrExistingAudioNames.push(audio.name.toLowerCase());					
				}
				dispatchEvent(new Event(Event.INIT));
			}
			
			showLoadingBar(false);
		}
		
//---------------------------------- edit functions ---------------------------------------------------
		public function deleteAudio(audio:AudioData) {
			audioToDelete = audio;
			//check if audio is assigned to another scene
			
			showLoadingBar(true);
			var url:String = SessionVars.localBaseURL + "itemUsed.php?accId=" + SessionVars.acc + "&itemId=" + audioToDelete.id + "&itemType=au";
			XMLLoader.loadXML(url, audioIsUsedResponse);																		
		}
		
		private function audioIsUsedResponse(_xml:XML):void
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
					dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp407", "The asset {name} is in use by a scene. Are you sure you want to delete it?", {name:audioToDelete.name}, deleteConfirm));
				}
				else
				{
					dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp406", "The asset {name} will be removed. This operation cannot be undone. Proceed?", {name:audioToDelete.name}, deleteConfirm));
				}
			}
		}
		
		private function deleteConfirm(b:Boolean) {
			if (b) { //confirmed
				showLoadingBar(true);
				var url:String = SessionVars.localBaseURL + "deleteItem.php?type=audio&id=" + audioToDelete.id;
				XMLLoader.loadXML(url, audioDeleted);				
			}
			else audioToDelete = null; //canceled
		}
		

		//<DELETEITEM RES="OK" ID="audioId" />
		//<DELETEITEM RES="ERROR" MSG="error text message" />
		public function audioDeleted(_xml:XML) {
			trace("gotDeleteResponse:"+_xml)
			showLoadingBar(false);
			var res:String=_xml.@RES.toUpperCase();
			if (res == "OK") {		
				var audio:AudioData;
				if (cb_multiple.selected && audioSelector.getSelectedIdArr().indexOf(audioToDelete.id) >= 0)
				{
					var ids:Array = audioSelector.getSelectedIdArr();
					if (ids.length > 1)
					{
						var audios:Array = new Array();
						var rnd:int = int(Math.random() * ids.length);
						audio = AudioData(audioSelector.getItemById(ids[rnd]).data);
						for (var i:int = 0; i < ids.length;++i)
						{
							audios.push(AudioData(audioSelector.getItemById(ids[i]).data));
						}
						player.loadAudios(audios);
					}
					else
					{
						player.loadAudios(null);
						player.loadAudio(audio);
					}
				}
				else if (audioToDelete.id == audioSelector.getSelectedId())
				{
					player.loadAudio(null);
				}
				audioSelector.remove(audioToDelete.id);
				data.removeAccountAudioWithId(audioToDelete.id);								
			}
			else if (res=="ERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp401","Error deleting audio : {details}",{details:_xml.@MSG}));
			}
			
			var delInd:int = _arrExistingAudioNames.indexOf(audioToDelete.name.toLowerCase())
			if (delInd >= 0)
			{
				_arrExistingAudioNames.splice(delInd, 1);
				dispatchEvent(new Event(Event.INIT));
			}			
			audioToDelete = null;
		}
		
		//rename....
	
		public function editAudio(audio:AudioData) {
			player.stopAudio();
			if (audio is TTSAudioData) {
				popupController.openPopup(popupController.editTTSWin);
				popupController.editTTSWin.addEventListener(AudioEvent.SELECT, audioEdited);
				popupController.editTTSWin.initWithAudio(audio as TTSAudioData, _arrExistingAudioNames);
				trace("editAudio::setPlayer");
				popupController.editTTSWin.setPlayer(player);
			}
			else {
				popupController.openPopup(popupController.renameWin);
				popupController.renameWin.addEventListener(AudioEvent.SELECT, renameAudio);
				popupController.renameWin.initWithAudio(audio, _arrExistingAudioNames);
			}
		}

		private function audioEdited(evt:AudioEvent) {			
			var item:SelectorItem = audioSelector.getItemById(evt.audio.id);
			if (item == null) return;
			
			var delInd:int = _arrExistingAudioNames.indexOf(item.text.toLowerCase())
			if (delInd >= 0)
			{
				_arrExistingAudioNames.splice(delInd, 1);
				
			}			
			_arrExistingAudioNames.push(evt.audio.name.toLowerCase());
			item.text = evt.audio.name;
			item.data = evt.audio;
			dispatchEvent(new Event(Event.INIT));
		}
		
		private function renameAudio(evt:AudioEvent) {
			var audioId:Number = evt.audio.id;
			var newName:String = popupController.renameWin.newName;
			var url:String=SessionVars.localBaseURL+"updateItemName.php?mode=audio&acc="+SessionVars.acc+"&id="+evt.audio.id+"&name="+escape(newName);
			XMLLoader.loadXML(url,gotRenameResponse,evt.audio)
			showLoadingBar(true);
		}

		//<UPDATEITEM RES="ok" ID="itemID" NEWNAME="new name"/>
		//<UPDATEITEM RES="ERROR" /> in case of error	
		public function gotRenameResponse(_xml:XML,audio:AudioData) {
			trace("gotRenameResponse:"+_xml.toXMLString())
			showLoadingBar(false);
			var res:String = _xml.@RES.toString().toUpperCase();
			if (res == "OK") {
				
				var delInd:int = _arrExistingAudioNames.indexOf(audioSelector.getItemById(audio.id).text.toLowerCase())
				if (delInd >= 0)
				{
					_arrExistingAudioNames.splice(delInd, 1);
					
				}			

				audio.name = unescape(_xml.@NEWNAME.toString());
				_arrExistingAudioNames.push(audio.name.toLowerCase());
				audioSelector.getItemById(audio.id).text = audio.name;
				dispatchEvent(new Event(Event.INIT));
			}
			else {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,"sp402","Error renaming audio : {details}",{details:_xml.@MSG}));
			}
		}

		private function audioEffectsEdited(evt:AudioEvent) {
			audioSelector.getItemById(evt.audio.id).data = evt.audio;
		}
//----------------------------------callbacks---------------------------------------------------
		private function toggleMultiple(evt:SelectorEvent) {
			audioSelector.allowMultiple = cb_multiple.selected;
			if (!cb_multiple.selected)
			{
				player.scene.audioArr = new Array();
				if (audioSelector.getSelectedItem() != null)
				{
					player.scene.audioArr.push(audioSelector.getSelectedItem().data);
				}
			}
		}
		private function catSelected(evt:SelectorEvent) {
			
			if (cb_multiple.selected)
			{
				dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp467", "Multiple audios can be selected only from the same category. Your selections will be lost when changing categories. Are you sure you want to change catgoery?", null, catSelectConfirm));								
			}
			else
			{
				iLastCategory = catSelector.getSelectedId();
				getAudios();
			}
			
		}
		
		private function catSelectConfirm(b:Boolean)
		{
			if (b)
			{
				cb_multiple.selected = false;
				audioSelector.allowMultiple = cb_multiple.selected;
				player.scene.audioArr = new Array();
				player.loadAudios(null);
				player.loadAudio(null);
				iLastCategory = catSelector.getSelectedId();
				getAudios();
			}
			else
			{
				catSelector.selectById(iLastCategory);
			}
		}
						
		private function audioSelected(evt:SelectorEvent) {
			//trace("SavedAudioPanel::audioSelected - catSelector.getSelectedId()=" + catSelector.getSelectedId() + ",  SPAudioList.PRIVATE_CATEGORY=" + SPAudioList.PRIVATE_CATEGORY);
			var audio:AudioData;
			/*
			if (catSelector.getSelectedId() != SPAudioList.PRIVATE_CATEGORY)
			{
				cb_multiple.selected = false;
				audioSelector.allowMultiple = cb_multiple.selected;
				player.scene.audioArr = new Array();
				if (audioSelector.getSelectedItem() != null)
				{
					player.scene.audioArr.push(audioSelector.getSelectedItem().data);
				}
			}
			*/
			if (cb_multiple.selected)
			{
				var ids:Array = audioSelector.getSelectedIdArr();
				if (ids.length > 1)
				{
					var audios:Array = new Array();
					var selItem:SelectorItem
					var rnd:int = int(Math.random() * ids.length);
					selItem = audioSelector.getItemById(ids[rnd]);
					if (selItem != null)
					{
						audio = AudioData(selItem.data);
					}
					else
					{
						audio = null;
					}
					for (var i:int = 0; i < ids.length;++i)
					{
						selItem = audioSelector.getItemById(ids[i]);
						if (selItem != null)
						{
							audios.push(AudioData(selItem.data));
						}
					}
					if (audios.length > 0)
					{
						player.loadAudios(audios);
					}
				}
				else
				{
					player.loadAudios(null);
					player.loadAudio(audio);
				}
			}
			else
			{
				audio = evt.obj as AudioData;			
				player.loadAudio(audio);
			}
			if (audio != null)
			{
				player.playAudio(audio);
			}
		}
		private function audioDeselected(evt:SelectorEvent) {
			var audio:AudioData;
			if (cb_multiple.selected)
			{
				var ids:Array = audioSelector.getSelectedIdArr();
				if (ids.length > 1)
				{
					var audios:Array = new Array();
					var rnd:int = int(Math.random() * ids.length);
					audio = AudioData(audioSelector.getItemById(ids[rnd]).data);
					for (var i:int = 0; i < ids.length;++i)
					{
						audios.push(AudioData(audioSelector.getItemById(ids[i]).data));
					}
					player.loadAudios(audios);
				}
				else
				{
					player.loadAudios(null);
					player.loadAudio(audio);
				}
			}
			else
			{
				//attempt to not allow deselection
				
				audio = evt.obj as AudioData;			
				audioSelector.selectById(audio.id);
				//player.loadAudio(null);
			}
		}
		private function onEditAudio(evt:SelectorEvent) {
			editAudio(evt.obj as AudioData);
		}
		private function onDeleteAudio(evt:SelectorEvent) {
			deleteAudio(evt.obj as AudioData);
		}
		private function editAudioFX(evt:SelectorEvent) {
			player.stopAudio();
			effectsWin.openWithAudio(evt.obj as AudioData);
		}
		private function whatsThis(evt:MouseEvent) {
			dispatchEvent(new AlertEvent("about", "sp460"));
		}
		
	}
	
}