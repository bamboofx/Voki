package com.voki.vhss.playback
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	public class GazeController
	{
		
		private var user_gaze_timer:Timer;
		private var host_holder:HostHolder
		private var follow_in_page:Boolean = false;
		private var mouse_mode:int;
		private var stage_ref:Stage;
		
		public function GazeController($hh:HostHolder)
		{
			host_holder = $hh;
			user_gaze_timer = new Timer(1, 1);
			user_gaze_timer.addEventListener(TimerEvent.TIMER_COMPLETE, e_userGazeDone);
		}
		
		public function setGazeUser($degrees:Number, $duration:Number, $radius:Number = 100):void
		{
			if (user_gaze_timer != null) user_gaze_timer.stop();
			user_gaze_timer.delay = $duration * 1000;
			user_gaze_timer.start();
			stopPageRequest();
			host_holder.setGaze($degrees, $duration, $radius);
		}
		
		public function setStageReference($s:Stage):void
		{
			stage_ref = $s;
		}
	
		public function setGazePage($degrees:Number, $duration:Number, $radius:Number = 100):void
		{
			if (follow_in_page) host_holder.setGaze($degrees, $duration, $radius);
		}
		
		public function followInPage($b:Boolean):void
		{
			follow_in_page = $b;
			if (stage_ref != null)
			{
				if (follow_in_page)
				{
					stage_ref.addEventListener(Event.MOUSE_LEAVE, e_mouseLeave);
					stage_ref.addEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
				}
				else
				{
					stage_ref.removeEventListener(Event.MOUSE_LEAVE, e_mouseLeave);
					stage_ref.removeEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
				}
			}
			(follow_in_page) ? startPageRequest() : stopPageRequest();
		}
		
		public function stopPageRequest():void
		{
			//----trace("VHSS V5 - GazeController --- stop page req");
			
			try
			{
				ExternalInterface.call("VHSS_Command", "vh_followOnPage",  0);
			}
			catch($e:Error)
			{
				//----trace("EXTERNAL INTERFACE ERROR -- "+$e.message);
			}
		}
		
		public function startPageRequest():void
		{
			//----trace("VHSS V5 - GazeController --- start page req");
			//if (follow_in_page)
			//{
			try
			{
				ExternalInterface.call("VHSS_Command", "vh_followOnPage", 4);
			}
			catch($e:Error)
			{
				//----trace("EXTERNAL INTERFACE ERROR -- "+$e.message);
			}
			//}
		}
		
		private function e_mouseLeave($e:Event):void
		{
			//----trace("VHSS MOUSE LEAVE --- DO MOUSE FOLLOW IN PAGE");
			startPageRequest();
			stage_ref.addEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
		}
		
		private function e_mouseOver($e:MouseEvent):void
		{
			//----trace("VHSS MOUSE OVER --- DO MOUSE OVER STOP FOLLOW IN PAGE");
			stopPageRequest();
			stage_ref.removeEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
		}
		
		private function e_userGazeDone($e:Event):void
		{
			//----trace("VHSS V5 - GazeController -- user gaze done - follow_in_page: "+follow_in_page);
			user_gaze_timer.stop();
			if (follow_in_page) startPageRequest();
		}
		
		public function destroy():void
		{
			if (user_gaze_timer != null)
			{
				user_gaze_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, e_userGazeDone);
				user_gaze_timer = null;
			}
			if (stage_ref != null)
			{
				stage_ref.removeEventListener(Event.MOUSE_LEAVE, e_mouseLeave);
				stage_ref.removeEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
				stage_ref = null;
			}
		}

	}
}