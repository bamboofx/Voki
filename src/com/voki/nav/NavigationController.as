﻿package com.voki.nav {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SelectorEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import com.voki.data.SessionVars;
	import com.voki.panels.IPanel;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class NavigationController extends EventDispatcher {
		private var navBar:NavigationBar;
		private var navWin:NavWindow;
		
		private var selectedWinId:int = -1;
		private var selectedTabIds:Array;
		private var navPanels:Array;
		
		private var confirmWinId:int;
		private var confirmTabId:int;
		
		public function NavigationController($navBar:NavigationBar,$navWin:NavWindow):void {
			navBar = $navBar;
			navWin = $navWin;
			
			navWin.addEventListener("animationComplete",navWinAnimationDone);
			navBar.addEventListener(SelectorEvent.SELECTED, navBarSelected);
			navWin.addEventListener(SelectorEvent.SELECTED, navWinTabSelected);
			
			navPanels = new Array();
			selectedTabIds = new Array();
		}
		
		public function setSelectedPanel(winId:int, tabId:int):void
		{
			selectedTabIds[winId] = tabId;
		}
		
		public function addPanel(winId1:int, tabId1:int, tabName:String, mc:Sprite):void {
			//convert 1-based index to 0-based
			var winId:int = winId1 - 1;
			var tabId:int = tabId1 - 1;
			if (navPanels[winId] == undefined) navPanels[winId] = new Array();
			if (selectedTabIds[winId] == undefined) selectedTabIds[winId] = -1;
			
			var panel:NavPanelStruct = navPanels[winId][tabId];
			if (panel == null) {
				panel = new NavPanelStruct(winId, tabId, tabName, mc);
				navPanels[winId][tabId]= panel;
			}
			else {
				panel.tabName = tabName;
				panel.mc = mc;
				if (selectedWinId == winId) navWin.getTabById(tabId).text = tabName;
			}
		}
		
		private function getPanelByInstance(panel:IPanel):NavPanelStruct {
			var i:int;
			var j:int;
			var navPanel:NavPanelStruct;
			for (i = 0; i < navPanels.length; i++) {
				if (navPanels[i] != null)
				{
					for (j = 0; j < navPanels[i].length; j++) {
						navPanel = navPanels[i][j];
						if (navPanel.mc == panel) return(navPanel);
					}
				}
			}
			return(null);
		}
		
		private function getPanel(winId:int, tabId:int):NavPanelStruct {
			if (navPanels == null) return(null);
			if (navPanels[winId] == undefined || navPanels[winId] == null) return(null);
			if (navPanels[winId][tabId] == undefined) return(null);
			return(navPanels[winId][tabId]);
		}
		
		private function getPanelArr(winId:int):Array {
			if (navPanels == null) return(null);
			return(navPanels[winId]);
		}
		
		private function getCurrentPanel():NavPanelStruct {
			//trace("get panel : " + [selectedWinId, selectedTabId] + " -- " + (getPanel(selectedWinId, selectedTabId) != null));
			return(getPanel(selectedWinId, selectedTabId));
		}
		
		private function navBarSelected(evt:SelectorEvent):void {			
			var winId:int = navBar.selectedTab;
			if (winId == selectedWinId) return;
			
			if (selectedTabIds[winId] == -1) selectPanelById(winId, 0);
			else selectPanelById(winId, selectedTabIds[winId]);
		}
		
		private function navWinTabSelected(evt:SelectorEvent):void {			
			selectPanelById(selectedWinId, navWin.selectedTab);
			dispatchEvent(new Event("winTabSelectedManually"));
		}
		
		private function doSelectPanelById(winId:int, tabId:int):void
		{
			if (winId == selectedWinId) {
				if (tabId == selectedTabId) return;
				//selectedTabIds[selectedWinId] = tabId;
				loadPanel(winId, tabId);
				navWin.selectedTab = tabId;
				initPanel();
			}
			else {
				//selectedWinId = winId;
				//selectedTabIds[selectedWinId] = tabId;
				loadPanel(winId, tabId);
				var tabNameArr:Array = new Array();
				var panel:NavPanelStruct;
				var i:int;
				trace("winId=" + winId + ", tabId=" + tabId);
				for (i = 0; i < getPanelArr(winId).length; i++ ) {
					if (getPanelArr(winId)[i] != null)
					{
						panel = getPanelArr(winId)[i];
						tabNameArr.push(panel.tabName);
					}
				}
				navWin.openWithTabs(tabNameArr);
				navWin.selectedTab = tabId;
				var tabBtn:NavButton;
				for (i = 0; i < getPanelArr(winId).length; i++ ) {
					panel = getPanelArr(winId)[i];
					tabBtn = navWin.getTabById(i);
					tabBtn.visible = panel.visible;
					tabBtn.disabled = !panel.enabled;
				}
			}
		}
		
		public function selectPanelById(winId:int, tabId:int):void
		{			
			trace("SessionVars.audioDirty=" + SessionVars.audioDirty);
			if (SessionVars.audioDirty)
			{
				confirmWinId = winId;
				confirmTabId = tabId;
				dispatchEvent(new AlertEvent(AlertEvent.CONFIRM, "sp463", "You have not saved the following audio. Click CANCEL to return and save this audio. Click OK to discard this audio.", null, onConfirm));
			}
			else
			{
				doSelectPanelById(winId, tabId)
			}						
		}
		
		public function onConfirm(ok:Boolean):void {
			if (ok) {
				SessionVars.audioDirty = false;
				doSelectPanelById(confirmWinId, confirmTabId)
			}			
			else
			{
				navWin.selectedTab = selectedTabId;
				navBar.selectedTab = selectedWinId;
			}
		}
		
		private function navWinAnimationDone(evt:Event):void {
			initPanel();
		}
		
		private function loadPanel(winId:int, tabId:int):void {
			var panelStruct:NavPanelStruct = getCurrentPanel();
			var panel:IPanel = panelStruct==null?null:(panelStruct.mc as IPanel);
			if (panel != null) panel.closePanel();
			navWin.removeContents();
			
			selectedWinId = winId;
			selectedTabIds[selectedWinId] = tabId;
			
			panelStruct = getCurrentPanel();
			var panelMC:Sprite = panelStruct==null?null:panelStruct.mc;
			if (panelMC != null) navWin.setContents(panelMC);
		}
		
		private function initPanel():void {
			var panelStruct:NavPanelStruct = getCurrentPanel();
			var panel:IPanel = panelStruct==null?null:(panelStruct.mc as IPanel);
			if (panel == null) return;
			dispatchEvent(new Event("panelOpened"));
			panel.openPanel();
		}
		
		private function get selectedTabId():int {
			return(selectedTabIds[selectedWinId]);
		}
		
		public function setTabDisabledById(winId1:int, tabId1:int, disabled:Boolean):void {
			//convert 1-based index to 0-based
			var winId:int = winId1 - 1;
			var tabId:int = tabId1 - 1;
			
			getPanel(winId, tabId).enabled=!disabled;
			if (winId == selectedWinId) navWin.getTabById(tabId).disabled = disabled;
		}
		public function setTabVisibleById(winId1:int, tabId1:int, vis:Boolean):void {
			//convert 1-based index to 0-based
			var winId:int = winId1 - 1;
			var tabId:int = tabId1 - 1;
			
			getPanel(winId, tabId).visible = vis;
			if (winId == selectedWinId) navWin.getTabById(tabId).visible = vis;
		}
		public function setTabDisabled(panel:IPanel,disabled:Boolean):void {
			var navPanel:NavPanelStruct = getPanelByInstance(panel);
			navPanel.enabled=!disabled;
			if (navPanel.winId == selectedWinId) navWin.getTabById(navPanel.tabId).disabled = disabled;
		}
		public function setTabVisible(panel:IPanel, vis:Boolean):void {
			var navPanel:NavPanelStruct = getPanelByInstance(panel);
			navPanel.visible = vis;
			if (navPanel.winId == selectedWinId) navWin.getTabById(navPanel.tabId).visible = vis;
		}
		public function selectPanel(panel:IPanel):void {
			var navPanel:NavPanelStruct = getPanelByInstance(panel);
			selectPanelById(navPanel.winId, navPanel.tabId);
		}
		public function getActiveWinId():int { //1-based index
			return(selectedWinId + 1);
		}
		public function getActivePanel():IPanel {
			var activePanel:NavPanelStruct = getCurrentPanel();
			if (activePanel != null)
			{
				return(activePanel.mc as IPanel);
			}
			else
			{
				return null;
			}
		}
	}
	
}