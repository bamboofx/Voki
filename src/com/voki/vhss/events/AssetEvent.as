/**
* ...
* @author David Segal
* @version 0.1
* @date 12.11.2007
* 
*/

package com.voki.vhss.events{
	import flash.events.Event;

	public class AssetEvent extends Event
	{
		public static const ASSET_LOADED:String = "asset_loaded";
		public static const ASSET_ERROR:String = "asset_error";
		public static const ASSET_INIT:String = "asset_init";
		public var data:Object;
		
		public function AssetEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false):void
		{
			super($type, $bubbles, $cancelable);
			data = $data;
		}
		
		public override function clone():Event
		{
			return new AssetEvent(type, data, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("AssetEvent", "data", "type", "bubbles", "cancelable");
		}
	}
	
}