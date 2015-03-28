package com.voki.data {
	import com.oddcast.audio.TTSVoice;
	/**
	* ...
	* @author Sam Myer
	*/
	public class AIConfiguration {
		public var btnText:String;
		public var showResponse:Boolean;
		public var voice:TTSVoice;
		
		public function AIConfiguration(_xml:XML=null) {
			btnText="Say It!";
			showResponse=true;
			//voice = null;
			voice = new TTSVoice(3, 3, 1);
			if (_xml != null)
			{
				trace("AIConfiguration " + _xml.toXMLString());
			}
			if (_xml != null) parseAIVars(_xml);
		}
			
		/* <AI ENGINE="1" LANG="1" VOICE="5" BOT="0" RESPONSE="1"><BUTTON>Ask it!</BUTTON></AI>	*/	
		private function parseAIVars(_xml:XML):void {
			trace("AIConfiguration::parseAIVars "+_xml.toXMLString());
			showResponse=(_xml.@RESPONSE=="1")
			btnText= unescape(decodeURI(_xml.BUTTON.toString()));
			var voiceId:int;
			voiceId = parseInt(_xml.@VOICE.toString());			
			if (voiceId > 0) {
				var engineId:int = parseInt(_xml.@ENGINE.toString());
				var langId:int = parseInt(_xml.@LANG.toString());
				trace("AIConfiguration::parseAIVars "+voiceId+", "+engineId+", "+langId);
				voice=new TTSVoice(voiceId,engineId,langId);
			}
			else voice=null;
		}
		
		public function getXML():XML {
			var node:XML = new XML("<AI />");
			if (voice!=null) {
				node.@ENGINE = voice.engineId.toString();
				node.@LANG=voice.langId.toString();
				node.@VOICE = voice.voiceId.toString();
			}
			node.@BOT="0";
			node.@RESPONSE = showResponse?"1":"0";
			node.BUTTON = encodeURI(btnText);
			return(node);
		}
	}
	
}