package com.oddcast.host.morph {
	import com.oddcast.host.morph.TargetList;
	import com.oddcast.app.FrameUpdate;
	
	public class FaceTarget {
		public function FaceTarget(s : String) : void {  {
			this.name = s;
		}}
		public var name : String;
		public function set2(frameUpdate : FrameUpdate,targetList : TargetList,receiveMorphWeighting : Array) : TargetList {
			return null;
		}
	}
}
