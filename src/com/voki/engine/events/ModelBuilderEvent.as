
package com.voki.engine.events{
	import flash.events.Event;

	public class ModelBuilderEvent extends Event{
				
		public static const MODEL_READY:String = "modelReady";
		public static const MODEL_ERROR:String = "modelError";
		public var data:Object;
		
		public function ModelBuilderEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = false):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new ModelBuilderEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("DataLoaderEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}