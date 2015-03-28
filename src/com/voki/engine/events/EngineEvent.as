
package com.voki.engine.events{
	import flash.events.Event;

	public class EngineEvent extends Event{
				
		public static const CONFIG_DONE:String = "configDone";
		public static const TALK_STARTED:String = "talkStarted";
		public static const TALK_ENDED:String = "talkEnded";
		public static const AUDIO_ENDED:String = "audioEnded";
		public static const WORD_ENDED:String = "wordEnded";
		public static const AUDIO_DOWNLOAD_START:String = "audioDownloadEnded";
		public static const SAY_SILENT_ENDED:String = "saySilentEnded";
		
		
		public var data:Object;
		
		public function EngineEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = false):void
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