﻿package com.voki.panels {
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.OScrollBar;
	import com.oddcast.ui.Selector;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.FAQConfiguration;
	import com.voki.data.FAQQuestion;
	import com.voki.nav.PopupController;
	import com.voki.player.PlayerController;
	import com.voki.ui.FAQSelectorItem;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class FAQSkinPanel extends MovieClip implements IPanel {
		public var tf_title:TextField;
		public var addBtn:SimpleButton;
		public var questionSelector:Selector;
		public var scrollbar:OScrollBar;
		
		public var player:PlayerController;
		public var popups:PopupController;
		private var selectAudioQuestionId:int;
		
		public function FAQSkinPanel() {
			questionSelector.addScrollBar(scrollbar, false);
			questionSelector.addItemEventListener("delete", onDelete);
			questionSelector.addItemEventListener("update", questionUpdated);
			questionSelector.addItemEventListener("selectAudio", selectAudio);
			questionSelector.addItemEventListener("swap", swapOrder);
			
			addBtn.addEventListener(MouseEvent.CLICK, onAdd);
			
		}
		
		private function get config():FAQConfiguration {
			if (player == null) return(null);
			else if (player.scene == null) return(null);
			else if (player.scene.skin == null) return(null);
			else if (player.scene.skinConfig == null) return(null);
			else return(player.scene.skinConfig.faq);
		}
		
		public function openPanel() {
			if (player == null||popups==null) throw new Error("FAQSkinPanel : must set player and popups first");
			if (config != null) loadConfig();
		}
		public function closePanel() {
		}
		
		private function loadConfig() {
			questionSelector.clear();
			var question:FAQQuestion;
			for (var i:int = 0; i < config.questions.length; i++) {
				question = config.questions[i];
				//trace("FAQSkinPanel::loadConfig add question name="+question.question+" audioName="+question.audio.name);
				questionSelector.add(i + 1, question.question, question.audio);
				//questionSelector.getItemById(selectAudioQuestionId).data = evt.audio;
			}
			updateCount();
		}
		private function saveConfig() {
			var questionArr:Array = questionSelector.getItemArray();
			var item:FAQSelectorItem;
			config.questions = new Array();
			for (var i:int = 0; i < questionArr.length; i++) {
				item = questionArr[i] as FAQSelectorItem;
				config.questions.push(new FAQQuestion(item.text,item.data as AudioData));
			}
			dispatchEvent(new Event("update"));
		}
		
		private function updateCount() {
			var questionArr:Array = questionSelector.getItemArray();
			var item:FAQSelectorItem;
			var count:uint = questionSelector.numItems;
			for (var i:int = 0; i < questionArr.length; i++) {
				item = questionArr[i] as FAQSelectorItem;
				item.id = i + 1;
				item.setQuestionCount(count);
			}
			tf_title.text = "You have "+count.toString()+" FAQ question"+(count==1?"":"s");
		}
//--------------------------------------------------------------------------------------------------
		private function onAdd(evt:MouseEvent) {
			questionSelector.add(questionSelector.numItems + 1, "", new FAQQuestion());
			updateCount();
			saveConfig();
		}
		private function onDelete(evt:SelectorEvent) {
			questionSelector.remove(evt.id);
			updateCount();
			saveConfig();
		}
		private function questionUpdated(evt:Event) {
			saveConfig();
		}
		private function selectAudio(evt:SelectorEvent) {
			popups.selectAudioWin.addEventListener(AudioEvent.SELECT,audioSelected);
			popups.openPopup(popups.selectAudioWin);
			selectAudioQuestionId = evt.id;
			popups.selectAudioWin.init(evt.obj as AudioData);
		}
		private function audioSelected(evt:AudioEvent) {
			questionSelector.getItemById(selectAudioQuestionId).data = evt.audio;
			saveConfig();
		}
		private function swapOrder(evt:SelectorEvent) {
			var oldOrder:int = evt.target.id;
			var newOrder:uint = evt.id-1;
			questionSelector.setItemOrderById(oldOrder, newOrder);
			updateCount();
			saveConfig();
		}

	}
	
}