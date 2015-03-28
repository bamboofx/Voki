package com.voki.ui {
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.OComboBox;
	import com.oddcast.ui.SelectorItem;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.voki.data.FAQQuestion;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class FAQSelectorItem extends Sprite implements SelectorItem {
		public var deleteBtn:SimpleButton;
		public var selectAudioBtn:SimpleButton;
		public var tf_audioName:TextField;
		public var tf_question:TextField;
		public var orderSelector:OComboBox;
		
		private var order:int;
		private var question:String;
		private var audio:AudioData;
		
		public function FAQSelectorItem() {
			deleteBtn.addEventListener(MouseEvent.CLICK, onDelete);
			selectAudioBtn.addEventListener(MouseEvent.CLICK, onSelectAudio);
			tf_question.addEventListener(Event.CHANGE, onQuestionChanged);
			orderSelector.addEventListener(SelectorEvent.SELECTED, onOrderChanged);
		}
		
		public function select():void {}
		public function deselect():void {}
		public function shown(b:Boolean):void { }
		
		public function get id():int {
			return(order);
		}
		public function set id(in_id:int):void {
			order = in_id;
			orderSelector.selectById(id);
		}
		public function get text():String {
			return(question);
		}
		public function set text(in_text:String):void {
			question = in_text;
			tf_question.text = question;
		}
		public function get data():Object {
			return(audio);
		}
		public function set data(in_data:Object):void {
			audio = in_data as AudioData;
			if (audio == null) tf_audioName.text = "";
			else tf_audioName.text = audio.name;
		}
		
		public function setQuestionCount(total:uint) {
			orderSelector.clear();
			for (var i:int = 1; i <= total; i++) {
				orderSelector.add(i,i.toString(),null,false)
			}
			orderSelector.update();
			orderSelector.selectById(id);
		}
//------------------------------------------------  CALLBACKS  ----------------------------------------------------
		private function onDelete(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent("delete",id,text,data));
		}
		private function onSelectAudio(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent("selectAudio",id,text,data));
		}
		private function onQuestionChanged(evt:Event) {
			if (tf_question.text!=question) {
				question = tf_question.text;
				dispatchEvent(new Event("update"));
			}
		}
		private function onOrderChanged(evt:SelectorEvent) {
			if (evt.id != id) dispatchEvent(new SelectorEvent("swap", evt.id));
		}
	}
	
}