package com.oddcast.host.morph.mouth {
	import com.oddcast.host.morph.TargetList;
	import com.oddcast.app.FrameUpdate;
	
	import com.oddcast.host.morph.FaceTarget;
	public class Phoneme extends FaceTarget {
		public function Phoneme(s : String) : void {  {
			super(s);
			this.translate = new Array();
		}}
		protected var translate : Array;
		protected function getTranslateIndex(char : String) : int {
			return char["charCodeAt"](0);
		}
		protected function addToTranslateArray(char : String,zName : String,zWeight : Number) : void {
			var i : int = this.getTranslateIndex(char);
			var weighting : * = { name : zName, weight : zWeight}
			var weightings : Array = this.translate[i];
			if(weightings == null) this.translate[i] = weightings = new Array();
			weightings.push(weighting);
		}
		public function getWeightingsForPhonemeLabel(PhonemeLabel : int) : Array {
			return this.translate[PhonemeLabel];
		}
		public function load(name : String) : Phoneme {
			return null;
		}
		public override function set2(frameUpdate : FrameUpdate,targetList : TargetList,receiveTargetWeighting : Array) : TargetList {
			var target : TargetList = targetList;
			var prevTarget : TargetList = null;
			var weight : Number = 1.0;
			while(target != null) {
				if(prevTarget == null) weight *= target.smoothingWeight;
				var weightings : Array = this.getWeightingsForPhonemeLabel(target.sync.label);
				if(weightings != null) {
					var localweight : Number = weight * target.sync.energy;
					var adjustedMouthWeight : int = 1;
					{
						var _g : int = 0;
						while(_g < weightings.length) {
							var weighting : * = weightings[_g];
							++_g;
							var targetWeighting : * = { label : weighting.name, eyeWeight : 0.0, mouthWeight : adjustedMouthWeight * localweight * weighting.weight}
							receiveTargetWeighting.push(targetWeighting);
						}
					}
				}
				if(prevTarget == null) {
					weight = 1.0 - weight;
					prevTarget = target;
					target = target.child;
				}
				else {
					target.child = null;
					target = null;
				}
			}
			return targetList;
		}
		public function getPhonemeEntryAtIndex(i : int) : Array {
			if(i < 0 || i >= this.translate.length) return null;
			return this.translate[i];
		}
	}
}
