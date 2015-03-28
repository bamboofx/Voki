package com.voki.vhss.playback
{
	import flash.utils.Timer;

	public class SessionPlaybackTimer extends Timer
	{
		public var audio_id:String;
		
		public function SessionPlaybackTimer(delay:Number, repeatCount:int=0)
		{
			super(delay, repeatCount);
		}
		
	}
}