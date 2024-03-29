﻿package com.voki.panels {
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.ui.Selector;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.DynamicClassGetter;
	import com.oddcast.vhost.ranges.RangeData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import com.voki.data.SessionVars;
	import com.voki.panels.IPanel;
	import com.voki.player.PlayerController;
	import com.oddcast.host.api.API_Constant;
	import com.oddcast.host.api.EditLabel;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.data.LibraryThumbSelectorData;
	import com.oddcast.ui.LibrarySelectorItem;
	import com.oddcast.ui.OScrollBar;
	
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ExpressionsPanel extends MovieClip implements IPanel {
		
		public var _mcExpressionSelector:Selector;		
		private var expressionsArr:Array;
		private var expressionsMap:Array;
		public var scrollbar:OScrollBar;
		
		public var player:PlayerController;
		private var _sSelectedExpression:String = "";
		public const EXPRESSION_AMP:Number = 1.0
		private var _bIsInited:Boolean;
		public var _mcNot3dMessage:MovieClip;
		
		public function ExpressionsPanel() {
			expressionsMap = new Array();
			//expressionsMap[expressionEngineName] = displayname
			expressionsMap["OpenSmile"] = {lib: "Smile", cap: "Happy"};
			expressionsMap["ClosedSmile"] = {lib: "ClosedSmile", cap: "Smile"};
			expressionsMap["Sad"] = {lib: "Sad", cap: "Sad"};
			expressionsMap["None"] = {lib: "None", cap: "None"};
			expressionsMap["Surprise"] = {lib: "Surprise", cap: "Surprise"};
			expressionsMap["Angry"] = { lib: "Angry", cap: "Angry" };
			
			expressionsMap["Disgust"] = { lib: "Disgust", cap: "Disgust" };
			//expressionsMap["RightWink"] = { lib: "RightBlink", cap: "Right Blink" };
			expressionsMap["Thinking"] = { lib: "Thinking", cap: "Thinking" };
			//expressionsMap["Blush"] = { lib: "Blush", cap: "Blush" };
			//expressionsMap["Blink"] = { lib: "Blink", cap: "Blink" };
			//expressionsMap["Scream"] = { lib: "Scream", cap: "Scream" };
			//expressionsMap["LeftWink"] = {lib: "LeftBlink", cap: "Left Blink"};
			
			
			
			
			/*
			 * AutophotoWin::initExpressions Fear
AutophotoWin::initExpressions Disgust
AutophotoWin::initExpressions OpenSmile
AutophotoWin::initExpressions Surprise
enableLibName=exp_surprise_enable, rolloverLibName=exp_surprise_rollover
obj.enabledlass=exp_surprise_enable
AutophotoWin::initExpressions RightWink
AutophotoWin::initExpressions Thinking
AutophotoWin::initExpressions Angry
AutophotoWin::initExpressions Blink
AutophotoWin::initExpressions Sad
enableLibName=exp_sad_enable, rolloverLibName=exp_sad_rollover
obj.enabledlass=exp_sad_enable
AutophotoWin::initExpressions Blush
AutophotoWin::initExpressions ClosedSmile
enableLibName=exp_smile_enable, rolloverLibName=exp_smile_rollover
obj.enabledlass=exp_smile_enable
AutophotoWin::initExpressions Scream
AutophotoWin::initExpressions LeftWink
*/
		}
		
		public function showModelTypeMessage(b:Boolean = true):void
		{
			if (_mcNot3dMessage != null)
			{
				_mcNot3dMessage.visible = b;
			}
		}
		
		public function openPanel() {
			
			if (player.scene.model.type.toLowerCase() != "3d" && player.scene.model.type.toLowerCase() != "host_3d")
			{
				showModelTypeMessage();
			}
			else
			{
				showModelTypeMessage(false);
				if (!_bIsInited)
					initExpressions();
			}			
		}
		
		private function initExpressions() {			
			if (_sSelectedExpression.length == 0 && player.scene.expression!=null)
			{
				_sSelectedExpression = player.scene.expression;
			}
			else if (SessionVars.editorMode == "SceneEditor")
			{
				_sSelectedExpression = "";
			}
			
			_mcExpressionSelector.addScrollBar(scrollbar,true);
			DynamicClassGetter.APP_DOMAIN = ApplicationDomain.currentDomain;
			var expressionsArr:Array = player.engineAPI.getEditorList(API_Constant.EXPRESSION);	
			
			//player.engineAPI.clearExpressionList();						
			_mcExpressionSelector.addEventListener(SelectorEvent.SELECTED, expressionChanged);	
			_mcExpressionSelector.addEventListener(SelectorEvent.DESELECTED, expressionDeselected);	
			var selectorThumb:LibraryThumbSelectorData = new LibraryThumbSelectorData("exp_big_none_enable", "exp_big_none_rollover", "exp_big_none_press", null, "None");
			_mcExpressionSelector.add(0, "None", selectorThumb);
			for (var i:int=0;i<expressionsArr.length;++i)
			{			
				trace("AutophotoWin::initExpressions "+expressionsArr[i]);
				if (expressionsMap[expressionsArr[i]] != null)
				{
					var expDisplayName:String = expressionsMap[expressionsArr[i]].cap;
					var expLibName:String = expressionsMap[expressionsArr[i]].lib;
					var enableLibName:String = "exp_big_" + expLibName.toLowerCase() + "_enable";
					var rolloverLibName:String = "exp_big_" + expLibName.toLowerCase() + "_rollover";
					var pressLibName:String = "exp_big_" + expLibName.toLowerCase() + "_press";
					trace("enableLibName=" + enableLibName + ", rolloverLibName=" + rolloverLibName);
					selectorThumb = new LibraryThumbSelectorData(enableLibName, rolloverLibName, pressLibName, null, expressionsArr[i]);
					_mcExpressionSelector.add(i + 1, expDisplayName, selectorThumb);
					if (expressionsArr[i] == _sSelectedExpression)
					{
						_mcExpressionSelector.selectById(i + 1);	
						_mcExpressionSelector.getItemById(i+1).select()
					}
				}				
			}	
			if (_mcExpressionSelector.getSelectedId() == -1)//nothing is selected
			{
				_mcExpressionSelector.selectById(0);
			}			
			_bIsInited = true;
		}						
		
		private function expressionDeselected(evt:SelectorEvent):void
		{
			player.engineAPI.clearExpressionList();	
		}
		
		private function expressionChanged(evt:SelectorEvent):void
		{
			player.engineAPI.clearExpressionList();			
			if (evt.id > 0)
			{
				player.engineAPI.setExpression(String(LibraryThumbSelectorData(evt.obj).obj), EXPRESSION_AMP, API_Constant.EXPRESSION_PERMENANT, API_Constant.EXPRESSION_PERMENANT);			
							
			}
			_sSelectedExpression = String(LibraryThumbSelectorData(evt.obj).obj);	
			dispatchEvent(new Event(Event.SELECT));
		}		
		
		public function closePanel() {
		}
		
		public function getExpression():String
		{
			return _sSelectedExpression;
		}
						
		public function setExpression(s:String, applyExp:Boolean = false):void
		{
			_sSelectedExpression;
			if (applyExp && (player.scene.model.type.toLowerCase()=="3d" || player.scene.model.type.toLowerCase()=="host_3d"))
			{
				player.engineAPI.clearExpressionList();						
				player.engineAPI.setExpression(s, EXPRESSION_AMP, API_Constant.EXPRESSION_PERMENANT, API_Constant.EXPRESSION_PERMENANT);													
				if (_mcExpressionSelector != null)
				{
					var item:SelectorItem = _mcExpressionSelector.getItemByName(s);
					if (item != null)
					{
						_mcExpressionSelector.selectById(item.id);
					}
				}
			}
		}
	}
	
}