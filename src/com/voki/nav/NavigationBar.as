package com.voki.nav {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.ui.ButtonSelectorItem;
	import com.oddcast.ui.ItemGroup;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class NavigationBar extends MovieClip {
		public var step1Btn:ButtonSelectorItem;
		public var step2Btn:ButtonSelectorItem;
		public var step3Btn:ButtonSelectorItem;
		public var step4Btn:ButtonSelectorItem;
		public var step5Btn:ButtonSelectorItem;
		
		public var step6Default:MovieClip;
		public var step6Demo:MovieClip;
		public var step6Partner:MovieClip;
		
		public var _mcBlocker:MovieClip;
		public var step6MC:MovieClip;
		
		private var stepBtnGroup:ItemGroup;
		
		public function NavigationBar():void {
			stepBtnGroup = new ItemGroup();
			if (step1Btn!=null)
				stepBtnGroup.registerItem(step1Btn, 0);
			if (step2Btn!=null)
				stepBtnGroup.registerItem(step2Btn, 1);
			if (step3Btn!=null)
				stepBtnGroup.registerItem(step3Btn, 2);
			if (step4Btn!=null)
				stepBtnGroup.registerItem(step4Btn, 3);
			if (step5Btn!=null)
				stepBtnGroup.registerItem(step5Btn, 4);
			
			stepBtnGroup.addEventListener(SelectorEvent.SELECTED, stepSelected);
			//showShareButtons();
			step6Default.addEventListener(MouseEvent.CLICK, saveClick);
			step6Demo.cancelBtn.visible = false;
			step6Demo.addEventListener(MouseEvent.CLICK, saveClick);
			step6Partner.addEventListener(MouseEvent.CLICK, saveClick);
			_mcBlocker.visible = false;
		}
		
		public function hideSaveButtons(b:Boolean):void
		{
			step6MC.visible = !b;			
		}
		
		public function disable(b:Boolean):void
		{			
			trace("NavigationBar::disable " + b);
			_mcBlocker.visible = b;
		}
		
		public function initShareButtons():void {
			showShareButtons(SessionVars.mode);
			if (SessionVars.mode==SessionVars.PARTNER_MODE&&!SessionVars.loggedIn&&SessionVars.embedMode) {
				step6Partner.publishBtn.disabled=true;
			}
		}
		
		private function showShareButtons(mode:String):void {
			step6Default.visible = (mode == SessionVars.NORMAL_MODE || SessionVars.editorMode=="CharacterEditor");
			step6Demo.visible = (mode == SessionVars.DEMO_MODE && SessionVars.editorMode!="CharacterEditor");
			step6Partner.visible = (mode == SessionVars.PARTNER_MODE);
			
			step6MC = (mode == SessionVars.NORMAL_MODE || SessionVars.editorMode == "CharacterEditor")?step6Default:step6MC;
			step6MC = (mode == SessionVars.DEMO_MODE && SessionVars.editorMode!="CharacterEditor")?step6Demo:step6MC;
			step6MC = (mode == SessionVars.PARTNER_MODE)?step6Partner:step6MC;
		}
		
		private function stepSelected(evt:SelectorEvent):void {
			dispatchEvent(evt);			
		}
		
		public function get selectedTab():int {
			if (!stepBtnGroup.isSelected()) return(0);
			else return(stepBtnGroup.getSelectedId());
		}
		
		public function set selectedTab(id:int):void {
			stepBtnGroup.selectById(id);
		}
		
		private function saveClick(evt:MouseEvent):void {
			dispatchEvent(new SendEvent("saveClick", evt.target.name));
		}
	}
	
}