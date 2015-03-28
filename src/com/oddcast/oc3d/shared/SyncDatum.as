package com.oddcast.oc3d.shared
{
	public class SyncDatum {
		public function SyncDatum() : void {  {
			this.nEnergy = 0.0;
		}}
		public var label : int;
		public var startTime : Number;
		public var endTime : Number;
		public var peakTime : Number;
		public var energy : Number;
		public var eventString : String;
		public var typeStr : String;
		public var nEnergy : Number;
		public function extractFromCompressedString(input : String,minEnergy : Number,maxEnergy : Number,power : Number) : String {
			var seg : Array = input.split(",");
			this.typeStr = seg[0];
			if(this.typeStr == PHONE || this.typeStr == SENTENCE || this.typeStr == GROUP) {
				this.label = seg[4]["charCodeAt"](0);
			}
			this.eventString = seg[4];
			this.startTime = parseFloat(seg[1]);
			this.endTime = parseFloat(seg[2]);
			this.energy = parseFloat(seg[3]) * 0.01;
			this.energy = minEnergy + (Math.pow(this.energy,power) * (maxEnergy - minEnergy));
			this.calcValues();
			return this.typeStr;
		}
		public function setTimedMood(name : String,amount : Number,startTime : Number,endTime : Number) : SyncDatum {
			this.startTime = startTime;
			this.endTime = endTime;
			this.energy = amount;
			this.eventString = name;
			this.typeStr = MOOD;
			this.calcValues();
			return this;
		}
		public function isMood() : Boolean {
			return this.typeStr == MOOD;
		}
		public function isPhoneme() : Boolean {
			return this.typeStr == PHONE;
		}
		public function isWord() : Boolean {
			return this.typeStr == WORD;
		}
		public function normalizeEnergy(min : Number,max : Number) : void {
			this.nEnergy = (this.energy - min) / (max - min);
		}
		public function calcValues() : void {
			var startWeight : Number = 1.0;
			if(this.typeStr == PHONE) {
				var vowel : Number = 0.35;
				var sharpConsonant : Number = 0.65;
				switch(this.label) {
				case "c"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "a"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "^"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "C"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "W"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "I"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "E"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "U"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "O"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "A"["charCodeAt"](0):{
					startWeight = vowel;
				}break;
				case "b"["charCodeAt"](0):{
					startWeight = 0.5;
				}break;
				case "D"["charCodeAt"](0):{
					startWeight = sharpConsonant;
				}break;
				case "F"["charCodeAt"](0):{
					startWeight = sharpConsonant;
				}break;
				default:{
					startWeight = 0.5;
				}break;
				}
			}
			if(this.typeStr == MOOD) startWeight = 0.5;
			this.peakTime = this.startTime * startWeight + this.endTime * (1 - startWeight);
		}
		static public var NO_EVENT : String = "";
		static public var PHONE : String = "P";
		static public var WORD : String = "W";
		static public var SENTENCE : String = "S";
		static public var GROUP : String = "G";
		static public var USERTYPE1 : String = "1";
		static public var USERTYPE2 : String = "2";
		static public var USERTYPE3 : String = "3";
		static public var NONTEXTGROUP : String = "N";
		static public var MOOD : String = "M";
	}
}