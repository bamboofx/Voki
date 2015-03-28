package com.oddcast.host.morph.sync {
	
	public class TimedFaceBase {
		public function TimedFaceBase() : void {  {
			this.reset();
		}}
		public var syncData : Array;
		public var syncAheadOfSound : Number;
		public function reset() : void {
			this.syncData = new Array();
		}
		public function play(startTime : Number) : void {
			null;
		}
	}
}
