﻿/**
* @author Sam Myer
*/
package com.voki.processing {
	import flash.events.Event;
	
	public class ASyncProcessEvent extends Event {
		public static const STARTED:String = "loadStarted";
		public static const PROGRESS:String = "loadProgress";
		public static const DONE:String = "loadDone";
		
		private var _process:ASyncProcess;
		
		public function ASyncProcessEvent($type:String, $process:ASyncProcess) {
			super($type);
			_process = $process;
		}
		
		public function get process():ASyncProcess {
			return(_process);
		}
		
		public override function clone():Event {
			return(new ASyncProcessEvent(type, process));
		}
	}
	
}