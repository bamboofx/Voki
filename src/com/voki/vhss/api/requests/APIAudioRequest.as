package com.voki.vhss.api.requests
{
	public class APIAudioRequest extends APIRequest
	{
		
		public var cache:Boolean = false;
		public var start_time:Number;
		public var url:String;
		
		public function APIAudioRequest($name:String, $start:Number = 0, $cache:Boolean = false)
		{
			start_time = $start;
			cache = $cache;
			super($name);
		}

	}
}