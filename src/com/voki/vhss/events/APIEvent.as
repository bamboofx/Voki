/**
* ...
* @author Default
* @version 0.1
*/

package com.voki.vhss.events{
	import flash.events.Event;

	public class APIEvent extends Event {

		public static const SAY_AUDIO_URL:String = "audio_url";
		public static const AUDIO_CACHED:String = "audio_cached";
		public static const AI_COMPLETE:String = "ai_complete";
		public static const BG_URL:String = "bg_url";
		public static const TTS_URL:String = "tts_url";
		
		public var data:Object;
	

		public function APIEvent($type:String, $data:Object = null,  $bubbles:Boolean = false, $cancelable:Boolean = false):void
		{
			super($type, $bubbles, $cancelable);
			data = $data;
		}
	
		public override function clone():Event
		{
			return new APIEvent(type, data, bubbles, cancelable);
		}
	
		public override function toString():String
		{
			return formatToString("APIEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}
	
}