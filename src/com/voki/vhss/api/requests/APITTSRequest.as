package com.voki.vhss.api.requests
{
	public class APITTSRequest extends APIAudioRequest
	{
		
		public var voice:String;
		public var lang:String;
		public var engine:String;
		public var fx_type:String;
		public var fx_level:String;
		
		public function APITTSRequest($name:String, $voice:String, $lang:String, $engine:String, $fx_type:String="", $fx_level:String="", $start:Number=0)
		{
			super($name, $start, false);
			voice = $voice;
			lang = $lang;
			engine = $engine;
			fx_type = $fx_type;
			fx_level = $fx_level;
		}
		
	}
}