package com.voki.processing {
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.assets.structures.HostStruct;
	import com.oddcast.assets.structures.SkinStruct;
	import com.oddcast.audio.AudioData;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.voki.data.SceneStruct;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ASyncProcess {
		public static const PROCESS_MODEL:String = "model";
		public static const PROCESS_BG:String = "bg";
		public static const PROCESS_AUDIO:String = "audio";
		public static const PROCESS_ACCESSORY:String = "accessory";
		public static const PROCESS_SKIN:String = "skin";
		public static const PROCESS_SCENE:String = "scene";
		
		public var success:Boolean;
		public var process:Object;
		public var processType:String;
		public var message:String;
		public var percentDone:Number; //number between 0 and 1
		
		public function ASyncProcess($process:Object, $processType:String = null, $message:String="") {
			process = $process;
			if ($processType == null) {
				if (process is String) processType = process as String;
				else if (process is HostStruct) processType = PROCESS_MODEL;
				else if (process is BackgroundStruct) processType = PROCESS_BG;
				else if (process is AudioData) processType = PROCESS_AUDIO;
				else if (process is SkinStruct) processType = PROCESS_SKIN;
				else if (process is AccessoryData) processType = PROCESS_ACCESSORY;
				else if (process is SceneStruct) processType = PROCESS_SCENE;
			}
			else processType = $processType;
			message = $message;
			success = false;
			percentDone = 0;
		}
	}
	
}