package com.voki.vhss.api
{
	import flash.events.Event;
	
	import com.voki.vhss.api.requests.APIAudioRequest;
	import com.voki.vhss.events.APIEvent;
	
	public class CacheAudioQueue extends RequestQueue
	{
		private var _cacher:AudioLoader;
		
		
		public function CacheAudioQueue()
		{

		}
		
		override public function destroy():void
		{
			super.destroy();
			
		}
		
		override protected function loadQueuedItem():void
		{
			
			var t_req:APIAudioRequest = APIAudioRequest(_queue[0]);
			_cacher = new AudioLoader();
			_cacher.addEventListener(Event.COMPLETE, e_audioCached);
			//----trace("API -- CACHE AUDIO QUEUE "+t_req.url);
			_cacher.load(t_req.url);
		}
		
		private function e_audioCached($e:Event):void
		{
			//----trace("API -- CACHE AUDIO QUEUE -- LOADED");
			_is_busy = false;
			_cacher.removeEventListener(Event.COMPLETE, e_audioCached);
			_cacher.destroy();
			_cacher = null;
			dispatchEvent(new APIEvent(APIEvent.AUDIO_CACHED, _queue.shift()));
			checkQueue();
		}
	}
}