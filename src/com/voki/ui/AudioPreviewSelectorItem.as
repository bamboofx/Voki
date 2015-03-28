package com.voki.ui {
	import com.oddcast.audio.AudioData;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.ui.StickyButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AudioPreviewSelectorItem extends Sprite implements SelectorItem {
		public var selectBtn:BaseButton;
		public var playBtn:StickyButton;
		public var tf_name:TextField;
		private var _id:int;
		private var audio:AudioData;
		
		public function AudioPreviewSelectorItem() {
			selectBtn.addEventListener(MouseEvent.CLICK, selectAudio);
			playBtn.addEventListener(SelectorEvent.SELECTED, playAudio);
			playBtn.addEventListener(SelectorEvent.DESELECTED, stopAudio);
		}
		
		/* INTERFACE com.oddcast.ui.SelectorItem */
		
		public function get id():int{
			return(_id);
		}
		
		public function set id(in_id:int):void{
			_id = in_id;
		}
		
		public function get text():String{
			return(tf_name.text);
		}
		
		public function set text(in_text:String):void{
			tf_name.text = in_text;
		}
		
		public function get data():Object{
			return(audio);
		}
		
		public function set data(in_data:Object):void{
			audio = in_data as AudioData;
			playBtn.visible = (audio!=null);
		}
		
		public function select():void{}
		
		public function deselect():void {
			playBtn.deselect();
		}
		
		public function shown(b:Boolean):void { }
		
		// callbacks
		
		private function playAudio(evt:SelectorEvent) {
			dispatchEvent(new SelectorEvent(SelectorEvent.SELECTED, id, text, data));
			dispatchEvent(new AudioEvent(AudioEvent.PREVIEW, audio));
		}
		
		private function stopAudio(evt:SelectorEvent) {
			dispatchEvent(new AudioEvent(AudioEvent.STOP));
		}
		
		private function selectAudio(evt:MouseEvent) {
			dispatchEvent(new SelectorEvent(SelectorEvent.SELECTED, id, text, data));
			dispatchEvent(new AudioEvent(AudioEvent.SELECT, audio));
		}
	}
	
}