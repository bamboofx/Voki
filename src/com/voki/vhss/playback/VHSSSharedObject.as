package com.voki.vhss.playback
{
	import com.oddcast.utils.OddcastSharedObject;
	
	import flash.events.TimerEvent;
	
	public class VHSSSharedObject
	{
		
		private var account_id:String;
		private var show_id:String;
		private var embed_id:String;
		//private var so:SharedObject;
		private var so:OddcastSharedObject;
		private var so_data:Object;
		private var session_timer:SessionPlaybackTimer;
		//private var audio_id:String;
		
		private const thirty_days:Number = 2592000000;	// 30 days in milliseconds
		private const one_day:Number = 86400000; 		// 1 day in milliseconds
		private const session_time:Number = 420000; 	// 7 minutes in milliseconds
		
		
		public function VHSSSharedObject($account_id:String, $show_id:String, $embed_id:String)
		{
			//trace("-------------TESTINGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG");
			account_id = $account_id;
			show_id = $show_id;
			embed_id = $embed_id;
			try
			{
				//so = SharedObject.getLocal("oddcast_so", "/");
				var t_date:Date = new Date();
				t_date.setMonth(t_date.getMonth()+1);
				so = new OddcastSharedObject("vhss_player", t_date);
			}
			catch ($e:Error)
			{
				trace("VHSSSharedObj - ERROR "+$e.message);
			}
			if (so != null)
			{
				so_data = so.getDataObject();
				initSharedObject();
			}
		}
		
		public function destroy():void
		{
			so = null;
			so_data = null;
			if (session_timer)
			{
				session_timer.stop();
				session_timer.removeEventListener(TimerEvent.TIMER, e_resetDate);
				session_timer = null
			}
			
		}
		
		public function isPlayable($audio_id:String, $play_limit:Number, $play_interval:Number):Boolean
		{
			if (so == null)
			{
				return true;
			}
			else
			{
				//var t_o:Object = so_data[account_id][show_id][embed_id];
				if (so_data[account_id][show_id][embed_id][$audio_id] == null) so_data[account_id][show_id][embed_id][$audio_id] = new Object();
				//var t_o:Object = so_data[account_id][show_id][embed_id][$audio_id];
				var t_then:Date = (so_data[account_id][show_id][embed_id][$audio_id].date == null) ? new Date(-1) : so_data[account_id][show_id][embed_id][$audio_id].date as Date;
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
					if (session_timer != null && so != null)
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
					if (so_data[account_id][show_id][embed_id][$audio_id] != null) delete so_data[account_id][show_id][embed_id][$audio_id];
					if (so != null) so.write(so_data);//flush();
					return true;
				}
				else if (so_data[account_id][show_id][embed_id][$audio_id] == null || (t_then.getTime() + t_n) < t_now.getTime()) // this is the first time the audio player or the interval time has elapsed
				{
					//----trace("VHSSSHAREDOBJECT   --- pass 3");
					so_data[account_id][show_id][embed_id][$audio_id] = new Object();
					so_data[account_id][show_id][embed_id][$audio_id].date = new Date();
					so_data[account_id][show_id][embed_id][$audio_id].plays = 1;
					if (so != null) so.write(so_data);//flush();
					return true;
				}
				else if ((t_then.getTime() + t_n) > t_now.getTime() && so_data[account_id][show_id][embed_id][$audio_id].plays < $play_limit) // inside the playback interval and the playback limit has not been reached
				{
					//----trace("VHSSSHAREDOBJECT   --- pass 4");
					++so_data[account_id][show_id][embed_id][$audio_id].plays;
					if (so != null) so.write(so_data);//flush();
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
			//if (so.size > 10000) so.clear();
			if (so_data[account_id] == null) so_data[account_id] = new Object();
			if (so_data[account_id][show_id] == null) so_data[account_id][show_id] = new Object();
			if (so_data[account_id][show_id][embed_id] == null) so_data[account_id][show_id][embed_id] = new Object();
			so.write(so_data);
		}
		
		private function cleanUp():void
		{
			var t_d:Date = new Date();
			var t_o:Object = so_data[account_id][show_id][embed_id];
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
			if (so != null)
			{
				so_data[account_id][show_id][embed_id][session_timer.audio_id].date = new Date();
				so.write(so_data);//.flush();
			}
		}

	}
}