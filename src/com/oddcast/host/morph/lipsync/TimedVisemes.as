package com.oddcast.host.morph.lipsync {
	import com.oddcast.host.morph.TargetList;
	import com.oddcast.app.FrameUpdate;
	import com.oddcast.host.morph.sync.SyncDatum;
	import com.oddcast.host.morph.sync.TimedFaceBase;
	
	public class TimedVisemes extends TimedFaceBase {
		public function TimedVisemes(fSyncAheadOfSound : Number) : void {  {
			super();
			this.phonTargetList = null;
			this.syncAheadOfSound = fSyncAheadOfSound;
			this.bHasTranscript = false;
		}}
		public function addID3(id3Comment : String,power : * = null,maxEnergy : * = null,minEnergy : * = null) : void {
			if(minEnergy == null) minEnergy = 0.60;
			if(maxEnergy == null) maxEnergy = 2.00;
			if(power == null) power = 3.0;
			var chunks : Array = id3Comment.split(";" + String.fromCharCode(10));
			{
				var _g : int = 0;
				while(_g < chunks.length) {
					var ch : String = chunks[_g];
					++_g;
					var sub : Array = ch.split("\"");
					if(sub.length > 1) {
						if(sub[0].indexOf("timed_phonemes") != -1) {
							var all : String = sub[1];
							var lines : Array = all.split(String.fromCharCode(9));
							{
								var _g1 : int = 0;
								while(_g1 < lines.length) {
									var line : String = lines[_g1];
									++_g1;
									this.addToSyncData(line,minEnergy,maxEnergy,power);
								}
							}
						}
					}
				}
			}
		}
		public function addToSyncData(line : String,minEnergy : Number,maxEnergy : Number,power : Number) : void {
			var syncDatum : SyncDatum = new SyncDatum();
			if(syncDatum.extractFromCompressedString(line,minEnergy,maxEnergy,power) != SyncDatum.NO_EVENT) this.syncData[this.syncData.length] = syncDatum;
			this.bHasTranscript = this.bHasTranscript || syncDatum.isWord();
		}
		public override function play(startTime : Number) : void {
			super.play(startTime);
			this.keyFrame = 0;
		}
		public function adjustTime(time : Number,frameUpdate : FrameUpdate) : Number {
			var addTime : Number = this.syncAheadOfSound;
			if(frameUpdate != null) {
				addTime += frameUpdate.imageGenerationDelayMilliSecs;
				addTime += frameUpdate.imageDisplayedIntervalMilliSecs * 0.5;
			}
			time += addTime;
			return time;
		}
		public function findCurrentTarget(time : Number,frameUpdate : FrameUpdate) : TargetList {
			var targetList : TargetList = this.phonTargetList;
			var sync : SyncDatum = this.syncData[this.keyFrame];
			while(sync != null && (!sync.isPhoneme() || sync.peakTime < time)) {
				this.keyFrame++;
				if(this.keyFrame >= this.syncData.length) {
					this.keyFrame = this.syncData.length - 1;
					break;
				}
				sync = this.syncData[this.keyFrame];
				switch(sync.typeStr) {
				case SyncDatum.PHONE:{
					targetList = new TargetList(1.0,sync,targetList);
					if(frameUpdate != null) {
						if(sync.label == "x"["charCodeAt"](0)) frameUpdate.sinceTalkingMillis = time - sync.peakTime;
						else frameUpdate.sinceTalkingMillis = Math["NEGATIVE_INFINITY"];
					}
				}break;
				case SyncDatum.WORD:{
					this.wordDatum = sync;
				}break;
				case SyncDatum.SENTENCE:{
					this.sentenceDatum = sync;
				}break;
				}
			}
			if(targetList != null) {
				targetList.setSmoothingWeighting(time);
			}
			return this.phonTargetList = targetList;
		}
		public function getRecommendedMinimumVisemeDuration() : int {
			return (this.bHasTranscript?TRANSCRIPT_MINIMUM_VISEME_DURATION:MINIMUM_VISEME_DURATION);
		}
		protected var phonTargetList : TargetList;
		protected var sentenceDatum : SyncDatum;
		protected var wordDatum : SyncDatum;
		protected var firstPhonemeDatum : SyncDatum;
		protected var lastPhonemeDatum : SyncDatum;
		protected var keyFrame : int;
		protected var bHasTranscript : Boolean;
		static public var DEFAULT_SYNC_AHEAD_OF_SOUND : Number = 2 * 1000 / 24;
		static public var MIN_ENERGY_LEVEL : Number = 0.60;
		static public var MAX_ENERGY_LEVEL : Number = 2.00;
		static public var POWER_LEVEL : Number = 3.0;
		static protected var TRANSCRIPT_MINIMUM_VISEME_DURATION : int = 0;
		static protected var MINIMUM_VISEME_DURATION : int = 80;
	}
}
