package com.oddcast.host.morph {
	import com.oddcast.host.morph.sync.SyncDatum;
	
	public class TargetList {
		public function TargetList(smoothingWeight : Number,sync : SyncDatum,child : TargetList) : void {  {
			this.smoothingWeight = smoothingWeight;
			this.child = child;
			this.sync = sync;
		}}
		public var smoothingWeight : Number;
		public var child : TargetList;
		public var sync : SyncDatum;
		public function promoteGrandChildToChild() : TargetList {
			this.child = this.child.child;
			return this;
		}
		public function setSmoothingWeighting(time : Number) : Number {
			var prevTime : Number = (this.child != null?this.child.sync.peakTime:this.sync.startTime);
			var interval : Number = (this.sync.peakTime - prevTime);
			var weightNext : Number = (interval > 0?(time - prevTime) / interval:0);
			this.smoothingWeight = this.clampAndSmooth(weightNext);
			if(this.child != null) {
				this.child.smoothingWeight = this.clampAndSmooth(1 - weightNext);
				this.child.child = null;
			}
			return this.smoothingWeight;
		}
		public function isEmpty(minimumWeight : Number) : Boolean {
			return (this.smoothingWeight < minimumWeight);
		}
		public function cullEmpty(minimumWeight : Number) : TargetList {
			while(this.child != null) {
				if(this.child.isEmpty(minimumWeight)) this.promoteGrandChildToChild();
				else break;
			}
			if(this.child != null) this.child.cullEmpty(minimumWeight);
			return (this.isEmpty(minimumWeight)?this.child:this);
		}
		protected function clampAndSmooth(weightNext : Number) : Number {
			if(weightNext > 1) weightNext = 1;
			if(weightNext < 0) weightNext = 0;
			var w2 : Number = weightNext * weightNext;
			weightNext = 3 * w2 - 2 * w2 * weightNext;
			return weightNext;
		}
	}
}
