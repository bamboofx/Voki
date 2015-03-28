package com.voki.vhss.api.requests
{
	public class APIAIRequest extends APITTSRequest
	{
		
		public var ai_text:String;
		public var ai_engine_id:String;
		public var bot:String;
		
		public function APIAIRequest($name:String, $voice:String, $lang:String, $engine:String, $bot:String = "0", $fx_type:String="", $fx_level:String="", $start:Number=0)
		{
			super("", $voice, $lang, $engine, $fx_type, $fx_level, $start);
			ai_text = $name;
			bot = $bot;
		}
		
	}
}