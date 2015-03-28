package com.oddcast.host.morph.lipsync {
	import com.oddcast.host.morph.TargetList;
	import com.oddcast.host.morph.lipsync.TimedInstantVisemes;
	import com.oddcast.host.morph.lipsync.TimedVisemes;
	import com.oddcast.host.morph.mouth.PhonemeOddcast17;
	public class StubForVectorHosts {
		static public function main() : void {
			var phoneme2oddcast17 : PhonemeOddcast17 = new PhonemeOddcast17("Oddcast17");
			phoneme2oddcast17.load("auto");
			var timedVisemes : TimedVisemes = new TimedVisemes(TimedVisemes.DEFAULT_SYNC_AHEAD_OF_SOUND);
			timedVisemes.addID3("junk");
			var timedInstantVisemes : TimedInstantVisemes = new TimedInstantVisemes();
			timedVisemes.play(0.0);
			var targetList : TargetList = timedVisemes.findCurrentTarget(0.0,null);
			var mouthFrame : int = phoneme2oddcast17.getMouthFrame(null,targetList,100);
		}
	}
}
