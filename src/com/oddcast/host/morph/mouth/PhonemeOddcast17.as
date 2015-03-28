package com.oddcast.host.morph.mouth {
	import com.oddcast.host.morph.TargetList;
	import com.oddcast.app.FrameUpdate;
	
	import com.oddcast.host.morph.mouth.Phoneme;
	public class PhonemeOddcast17 extends Phoneme {
		public function PhonemeOddcast17(s : String) : void {  {
			super(s);
			this.currFrame = 0;
			this.currFrameStartTime = 0;
		}}
		public override function load(name : String) : Phoneme {
			this.addToTranslateArray("x",BASE,1.0);
			this.addToTranslateArray("X",BASE,1.0);
			this.addToTranslateArray("U",WET,0.6);
			this.addToTranslateArray("w",WET,1.0);
			this.addToTranslateArray("C",WET,0.5);
			this.addToTranslateArray("o",WET,0.65);
			this.addToTranslateArray("F",FAVE,0.5);
			this.addToTranslateArray("v",FAVE,0.75);
			this.addToTranslateArray("b",BUMP,0.75);
			this.addToTranslateArray("m",BUMP,0.45);
			this.addToTranslateArray("p",BUMP,0.45);
			this.addToTranslateArray("c",OX,0.75);
			this.addToTranslateArray("i",IF,0.8);
			this.addToTranslateArray("a",IF,1.0);
			this.addToTranslateArray("I",IF,0.8);
			this.addToTranslateArray("A",IF,1.0);
			this.addToTranslateArray("^",IF,0.6);
			this.addToTranslateArray("H",IF,0.75);
			this.addToTranslateArray("!",IF,1.0);
			this.addToTranslateArray("d",TOLD,0.6);
			this.addToTranslateArray("t",TOLD,0.6);
			this.addToTranslateArray("l",TOLD,0.7);
			this.addToTranslateArray("n",NEW,0.7);
			this.addToTranslateArray("N",NEW,0.5);
			this.addToTranslateArray("u",OAT,0.7);
			this.addToTranslateArray("W",OAT,0.55);
			this.addToTranslateArray("O",OAT,0.6);
			this.addToTranslateArray("s",SIZE,0.6);
			this.addToTranslateArray("J",CHURCH,0.8);
			this.addToTranslateArray("S",CHURCH,1.0);
			this.addToTranslateArray("Z",CHURCH,0.7);
			this.addToTranslateArray("j",CHURCH,0.7);
			this.addToTranslateArray("y",CHURCH,0.7);
			this.addToTranslateArray("y",EAT,0.4);
			this.addToTranslateArray("z",CHURCH,0.75);
			this.addToTranslateArray("R",ROAR,1.0);
			this.addToTranslateArray("r",ROAR,0.7);
			this.addToTranslateArray("T",THOUGH,1.0);
			this.addToTranslateArray("D",THOUGH,1.0);
			this.addToTranslateArray("E",EAT,0.75);
			this.addToTranslateArray("k",CAGE,0.85);
			this.addToTranslateArray("G",CAGE,0.85);
			this.addToTranslateArray("e",EARTH,0.75);
			return this;
		}
		public function getMouthFrame(frameUpdate : FrameUpdate,targetList : TargetList,minimumDuration : * = null) : int {
			if(minimumDuration == null) minimumDuration = MINIMUM_VISEME_DURATION;
			var receiveTargetWeighting : Array = new Array();
			this.set2(null,targetList,receiveTargetWeighting);
			var maxWeight : Number = 0.0;
			var maxTarget : * = null;
			{
				var _g : int = 0;
				while(_g < receiveTargetWeighting.length) {
					var t : * = receiveTargetWeighting[_g];
					++_g;
					if(t.mouthWeight > maxWeight) {
						maxWeight = t.mouthWeight;
						maxTarget = t;
					}
				}
			}
			var frame : int = this.getFrameFromTargetWeighting(maxTarget);
			if(frame != this.currFrame) {
				var time : Number = 0.0;
				if(targetList != null) time = targetList.sync.endTime;
				var duration : Number = time - this.currFrameStartTime;
				if(frame == 0 || duration >= minimumDuration || duration <= 0.0) {
					this.currFrameStartTime = time;
					this.currFrame = frame;
				}
			}
			return this.currFrame;
		}
		protected function getFrameFromTargetWeighting(targetWeighting : *) : int {
			return parseInt((targetWeighting != null?targetWeighting.label:BASE));
		}
		protected var currFrame : int;
		protected var currFrameStartTime : Number;
		static protected var MINIMUM_VISEME_DURATION : Number = 80.0;
		static protected var BASE : String = "0";
		static protected var WET : String = "1";
		static protected var FAVE : String = "2";
		static protected var BUMP : String = "3";
		static protected var OX : String = "4";
		static protected var IF : String = "5";
		static protected var TOLD : String = "6";
		static protected var NEW : String = "7";
		static protected var OAT : String = "8";
		static protected var SIZE : String = "9";
		static protected var CHURCH : String = "10";
		static protected var ROAR : String = "11";
		static protected var THOUGH : String = "12";
		static protected var EAT : String = "13";
		static protected var CAGE : String = "14";
		static protected var EARTH : String = "15";
	}
}
