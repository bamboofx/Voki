/**
* ...
* @author Default
* @version 0.1
*/

package com.voki.ui {
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.ui.Slider;
	import com.oddcast.vhost.ranges.RangeData;
	import flash.display.MovieClip;
	import flash.text.TextField;

	public class SliderSelectorItem extends Slider implements SelectorItem {
		
		public var tf_name:TextField;
		private var range:RangeData;
		
		private var _id:int;
		
		public function SliderSelectorItem() {
		}
		
		public function select():void {}
		public function deselect():void {}
		public function shown(b:Boolean):void {}
		
		public function get id():int {
			return _id;
		}
		public function set id(in_id:int):void {
			_id=in_id;
		}
		public function get text():String {
			return tf_name.text;
		}
		public function set text(in_text:String):void {
			if (in_text == null) tf_name.text = "";
			else tf_name.text=in_text;
		}
		public function get data():Object {
			if (range == null) return(percent);
			else {
				range.value = percent;
				return(range);
			}
		}
		
		public function set data(in_data:Object):void {
			if (in_data == null) return;
			if (in_data is RangeData) {
				range = in_data as RangeData;
				percent = range.value;
			}
			else if (typeof in_data == "number") {
				range = null;
				percent=(in_data as Number);
			}
		}
	}
	
}