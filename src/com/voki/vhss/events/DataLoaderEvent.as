/**
* ...
* @author Dave Segal
* @version 0.1
* @date 11.19.2007
* 
*/

package com.voki.vhss.events{
	import flash.events.Event;

	public class DataLoaderEvent extends Event{
		
		public static const DEFAULT_NAME:String = "com.voki.vhss.events.DataLoaderEvent";
		public static const ON_DATA_READY:String = "dataReady";
		public var data:Object;
		
		public function DataLoaderEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = false):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new DataLoaderEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("DataLoaderEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}