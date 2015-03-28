package com.oddcast.host.morph.lipsync {
	import com.oddcast.host.morph.sync.SyncDatum;
	import com.oddcast.host.morph.TargetList;
	import com.oddcast.app.FrameUpdate;
	
	import com.oddcast.host.morph.lipsync.TimedVisemes;
	public class TimedInstantVisemes extends TimedVisemes {
		public function TimedInstantVisemes() : void {  {
			super(0.0);
		}}
		public override function findCurrentTarget(time : Number,frameUpdate : FrameUpdate) : TargetList {
			var targetList : TargetList = null;
			if(this.syncData.length >= 1) {
				var sync : SyncDatum = this.syncData[this.syncData.length - 1];
				targetList = new TargetList(1.0,sync,null);
				this.reset();
				this.syncData.push(sync);
			}
			return targetList;
		}
		public override function getRecommendedMinimumVisemeDuration() : int {
			return TIMED_MINIMUM_VISEME_DURATION;
		}
		static protected var TIMED_MINIMUM_VISEME_DURATION : int = 120;
	}
}
