package com.voki.vhss.api
{
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	
	import com.voki.vhss.api.requests.APIRequest;
	
	public class RequestQueue extends EventDispatcher
	{
		protected var _queue:Array; 
		protected var _is_busy:Boolean;
		
		public function RequestQueue()
		{
			_queue = new Array();
		}
		
		public function destroy():void
		{
			_queue = null;
		}
		
		public function load($req:APIRequest):void
		{
			_queue.push($req);
			checkQueue();
		}
		
		protected function checkQueue():void
		{
			if (!_is_busy && _queue.length > 0)
			{
				_is_busy = true;
				loadQueuedItem();
			}
		}
		
		protected function loadQueuedItem():void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "You must override this function in your sub-class"));
		}
		

		

	}
}