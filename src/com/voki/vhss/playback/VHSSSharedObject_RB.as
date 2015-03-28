package vhss.playback
{
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	
	public class VHSSSharedObject
	{
		
		private var account_id:String;
		private var show_id:String;
		private var embed_id:String;
		private var so:SharedObject;
		private var session_timer:SessionPlaybackTimer;
		//private var audio_id:String;
		
		private const thirty_days:Number = 2592000000;	// 30 days in milliseconds
		private const one_day:Number = 86400000; 		// 1 day in milliseconds
		private const session_time:Number = 420000; 	// 7 minutes in milliseconds
		
		
		public function VHSSSharedObject($account_id:String, $show_id:String, $embed_id:String)
		{
			account_id = $account_id;
			show_id = $show_id;
			embed_id = $embed_id;
			try{
				so = SharedObject.getLocal("oddcast_so", "/");
				initSharedObject();
			}
			catch ($e:Error)
			{
				//----trace("VHSSSharedObj - ERROR "+$e.message);
			}
		}
		
		public function destroy():void
		{
			session_timer.stop();
			session_timer.removeEventListener(TimerEvent.TIMER, e_resetDate);
			session_timer = null
		}
		
		public function isPlayable($audio_id:String, $play_limit:Number, $play_interval:Number):Boolean
		{
			if (so == null)
			{
				return true;
			}
			else
			{
				var t_o:Object = so.data[account_id][show_id][embed_id];
				if (t_o[$audio_id] == null) t_o[$audio_id] = new Object();
				var t_then:Date = (t_o[$audio_id].date == null) ? new Date(-1) : t_o[$audio_id].date as Date;
				var t_now:Date = new Date();
				var t_isSessionInterval:Boolean = ($play_interval == 0 && $play_limit > 0)
				var t_n:Number;
				if (t_isSessionInterval)
				{
					// do something here
					if (session_timer == null)
					{
						session_timer = new SessionPlaybackTimer(10000);
						session_timer.audio_id = $audio_id;
						session_timer.addEventListener(TimerEvent.TIMER, e_resetDate);
						session_timer.start();
					}
					t_n = session_time;
				}
				else
				{
					if (session_timer != null)
					{
						session_timer.stop();
						session_timer.removeEventListener(TimerEvent.TIMER, e_resetDate);
						session_timer = null;
					}
					t_n = one_day * $play_interval;
				}
				if ($play_limit == 0) // unlimited playback. playLimit = -1
				{
					//----trace("VHSSSHAREDOBJECT   --- pass 1");
					return false;
				}
				else if (!($play_limit >= 0))
				{
					//----trace("VHSSSHAREDOBJECT   --- pass 2");
					if (t_o[$audio_id] != null) delete t_o[$audio_id];
					so.flush();
					return true;
				}
				else if (t_o[$audio_id] == null || (t_then.getTime() + t_n) < t_now.getTime()) // this is the first time the audio player or the interval time has elapsed
				{
					//----trace("VHSSSHAREDOBJECT   --- pass 3");
					t_o[$audio_id] = new Object();
					t_o[$audio_id].date = new Date();
					t_o[$audio_id].plays = 1;
					so.flush();
					return true;
				}
				else if ((t_then.getTime() + t_n) > t_now.getTime() && t_o[$audio_id].plays < $play_limit) // inside the playback interval and the playback limit has not been reached
				{
					//----trace("VHSSSHAREDOBJECT   --- pass 4");
					++t_o[$audio_id].plays;
					so.flush();
					return true;
				}
				else
				{
					//----trace("VHSSSHAREDOBJECT   --- pass 5 - false ");
					return false;
				}
			}
		}
		
		private function initSharedObject():void
		{
			try
			{
				cleanUp();
			}
			catch($e:Error)
			{
				//----trace("VHSSSharedObject --- clean up error");
			}
			if (so.size > 10000) so.clear();
			if (so.data[account_id] == null) so.data[account_id] = new Object();
			if (so.data[account_id][show_id] == null) so.data[account_id][show_id] = new Object();
			if (so.data[account_id][show_id][embed_id] == null) so.data[account_id][show_id][embed_id] = new Object();
		}
		
		private function cleanUp():void
		{
			var t_d:Date = new Date();
			var t_o:Object = so.data[account_id][show_id][embed_id];
			for (var i:String in t_o)
			{
				if (t_o[i].date != null && t_o[i].date.getTime() <  (t_d.getTime() - thirty_days))
				{
					delete t_o[i];
				}
			}
		}
		
		// Timer Event
		private function e_resetDate($ev:TimerEvent):void
		{
			so.data[account_id][show_id][embed_id][session_timer.audio_id].date = new Date();
			so.flush();
		}

	}
}