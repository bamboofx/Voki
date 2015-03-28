package com.voki.vhss.api
{
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	
	import com.voki.vhss.api.requests.APIAudioRequest;
	import com.voki.vhss.events.APIEvent;

	public class AudioRequestQueue extends RequestQueue
	{

		//private var _url_loader:URLLoader;
		private var _dom:String;
		private var _account:String;
		private var _cacher:CacheAudioQueue;
		private var _audio_by_name:AudioRequester;

		
		public function AudioRequestQueue()
		{
			_audio_by_name = new AudioRequester();
			_audio_by_name.addEventListener(APIEvent.SAY_AUDIO_URL, e_complete);
			
			_cacher = new CacheAudioQueue();
			_cacher.addEventListener(APIEvent.AUDIO_CACHED, e_audioCached);
		}
		
		override public function destroy():void
		{
			super.destroy();
			_cacher.removeEventListener(APIEvent.AUDIO_CACHED, e_audioCached);
			_cacher.destroy();
			_cacher = null;
			
		}
		
		
		override protected function loadQueuedItem():void
		{
			_audio_by_name.load(APIAudioRequest(_queue.shift()));
		}
		
		//Event Handlers
		private function e_complete($e:APIEvent):void
		{
			_is_busy = false;
			var t_req:APIAudioRequest = APIAudioRequest($e.data);
			if (t_req.url.indexOf("ERROR") == -1)
			{
				if (t_req.cache)
				{
					_cacher.load(t_req);
				}
				else
				{
					dispatchEvent(new APIEvent(APIEvent.SAY_AUDIO_URL, t_req));
				}
			}
			checkQueue();
		}
		
		private function e_audioCached($e:APIEvent):void
		{
			dispatchEvent(new APIEvent(APIEvent.AUDIO_CACHED, $e.data));
		}
		
		private function e_error($e:IOErrorEvent):void
		{
			_is_busy = false;
			//----trace("AudioURLRequest error: " + $e);
		}
		
		private function e_security($e:SecurityErrorEvent):void
		{
			_is_busy = false;
			//----trace("AudioURLRequest security: " + $e);
		}
		
	}
}