package com.voki.engine
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	public class MouseController
	{
		import flash.utils.Timer;		
		import flash.events.TimerEvent;
		
		private var _timerRecenter:Timer;	
		private var _timerMouseFollowDelay:Timer;	
		private var _engine:EngineV5;
		private var _mouseStage:InteractiveObject;
		private var _count:int = 0;
		
		private var _is_following_mouse:Boolean = false;
		
		
		function MouseController(engineRef:EngineV5)
		{
			_engine = engineRef;			
			_timerRecenter = new Timer(EngineV5Constants.MOUSE_IDLE_RECENTER_TIME);
			_timerRecenter.addEventListener(TimerEvent.TIMER, doRecenter);
		}
		
		public function setMouseStage(st:InteractiveObject):void
		{
			//trace("MouseController::setMouseStage " + st);
			if (_mouseStage && st)
			{
				_mouseStage.removeEventListener(MouseEvent.MOUSE_MOVE,doMouseFollow);
			}
			if (st)
			{
				try
				{
					_mouseStage = st;
					_mouseStage.addEventListener(MouseEvent.MOUSE_MOVE,doMouseFollow);
				}
				catch (error:*)
				{
					
				}
			}
		}
		
		private function doRecenter(evt:TimerEvent):void
		{	
			//trace("----------  DO RECENTER -------------");		
			if (!_engine.isGazing())
			{
				_is_following_mouse = false;
				_engine.recenter();
			}
		}
		
		public function stopMouseFollow():void
		{
			//_timerMouseFollow.stop();	
			_is_following_mouse = false;	
			if (_mouseStage!=null)
			{
				//trace("MouseController::startMouseFollow removeEventListener(MouseEvent.MOUSE_MOVE,doMouseFollow)");	
				_mouseStage.removeEventListener(MouseEvent.MOUSE_MOVE,doMouseFollow);
			}
		}
		
		public function startMouseFollow():void
		{
			//trace("MouseController::startMouseFollow _engine.getModel() is MovieClip=?"+(_engine.getModel() is MovieClip));
			//_timerMouseFollow.delay = Math.round(1000/_engine.getFPS());
			//_timerMouseFollow.start();	
			
			try
			{
				if (_mouseStage!=null)
				{
					//if (!_engine.getModel().hasEventListener(MouseEvent.MOUSE_MOVE))
					//{
					//trace("MouseController::startMouseFollow addEventListener(MouseEvent.MOUSE_MOVE,doMouseFollow)");
					_mouseStage.addEventListener(MouseEvent.MOUSE_MOVE,doMouseFollow);
					//}
				}
			}
			catch (error:Error)
			{
				
			}
			
		}
		
		private function doMouseFollow(evt:MouseEvent):void
		{			
			//trace("MouseController::doMouseFollow isFollowing: "+_is_following_mouse+" isFC:: "+_engine.isFollowingCursor()+" "+_timerMouseFollowDelay+" "+(++_count));
			if (_engine.isFollowingCursor())
			{
				if (!_is_following_mouse)
				{
					_is_following_mouse = true;
					if (_timerMouseFollowDelay == null)
					{
						_timerMouseFollowDelay = new Timer(EngineV5Constants.MOUSE_FOLLOW_DELAY,1);
						//trace("MOUSE CONTROLLER - START MOUSE FOLLOW DELAY - AddListener");
						_timerMouseFollowDelay.addEventListener(TimerEvent.TIMER,doDelayedMouseFollow);
						_timerMouseFollowDelay.start();	
					}
					else
					{
						_timerMouseFollowDelay.reset();
						//trace("TMFD _____ start");
						_timerMouseFollowDelay.start();
					}
				}
				else
				{
					_engine.setMouseFollow(true);
				}
				_timerRecenter.reset();
				_timerRecenter.repeatCount = 1;
				_timerRecenter.start();
			}		
		}				
		
		private function doDelayedMouseFollow(evt:TimerEvent):void
		{
			///trace("ENGINE DO DELAYED MOUSE FOLLLOW !!!!!!!!!!  "+_timerRecenter);
			if (_timerRecenter)
			{
				_timerRecenter.reset();
				_timerRecenter.repeatCount = 1;
				_timerRecenter.start();
			}
			_engine.setMouseFollow(true);//followCursor(true);
		}
		
		public function destroy():void
		{
			trace("MOUSE CONTROLLER - destroy - ");
			if (_timerMouseFollowDelay != null)
			{
				//trace("MOUSE CONTROLLER - destroy - _timerMouseFollowDelay");
				_timerMouseFollowDelay.stop();
				_timerMouseFollowDelay.removeEventListener(TimerEvent.TIMER,doDelayedMouseFollow);
				_timerMouseFollowDelay = null;
			}
			if (_mouseStage!=null)
			{
				_mouseStage.removeEventListener(MouseEvent.MOUSE_MOVE,doMouseFollow);
				_mouseStage = null;
			}
			if (_timerRecenter != null)
			{
				_timerRecenter.stop();
				_timerRecenter.removeEventListener(TimerEvent.TIMER,doRecenter);
				_timerRecenter = null;
			}
			if (_engine != null)
			{
				_engine = null;
			}
		}
	}
}