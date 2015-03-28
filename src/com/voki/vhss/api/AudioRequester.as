package com.voki.vhss.api
{
	import flash.events.Event;
	import flash.net.*;
	
	import com.voki.vhss.Constants;
	import com.voki.vhss.api.requests.*;
	import com.voki.vhss.events.APIEvent;

	public class AudioRequester extends Requester
	{
		
		private var _url_req:URLRequest;
		private var _audio_req:APIAudioRequest;
		
		public function AudioRequester()
		{
			
		}
		
		override public function load($req:APIRequest):void
		{
			_audio_req = APIAudioRequest($req);
			_url_req = new URLRequest(Constants.VHSS_DOMAIN + Constants.SAY_BY_NAME_PHP);
			_url_req.data = new URLVariables("audioname="+escape($req.name)+"&acc="+$req.account_id+"&r="+uint(Math.random()*100000));
			_url_req.method = URLRequestMethod.GET;
			super.load($req);
		}
		
		
		override protected function getURLRequest():URLRequest
		{
			return _url_req;
		}
		
		
		//Event Handlers
		override protected function e_complete($e:Event):void
		{
			var t_ldr:URLLoader = URLLoader($e.target);
			//var t_str:String = t_ldr.data as String;
			var t_ar1:Array = String(t_ldr.data).split("&");
			var t_url:String;
			for (var i:int = 0; i < t_ar1.length; ++i)
			{
				if (t_ar1[i].indexOf("location") == 0)
				{
					t_url = t_ar1[i].split("=")[1];
				}
			}
			if (t_url == null) // URL Error
			{
				//----trace("AudioURLRequester -- error -- NO URL for " + _audio_req.name);
			}
			else
			{
				//----trace("AudioURLRequest url : "+t_url);
				_audio_req.url = t_url;
				
				dispatchEvent(new APIEvent(APIEvent.SAY_AUDIO_URL, _audio_req));
			}
			
			/*
			//----trace("Audio Request --- COMPLETE -- data "+t_ldr.data);
			
			
			//----trace("AudioURLRequest complete data:: " + _url_loader.data);
			
			var t_req:APIAudioRequest = _queue.shift();
			var t_url:String;
			for (var i:int = 0; i < t_ar1.length; ++i)
			{
				if (t_ar1[i].indexOf("location") == 0)
				{
					t_url = t_ar1[i].split("=")[1];
				}
			}
			if (t_url == null) // URL Error
			{
				//----trace("AudioURLRequester -- error -- NO URL for " + t_req.name);
			}
			else
			{
				//----trace("AudioURLRequest url : "+t_url);
				t_req.url = t_url;
				if (t_req.cache) // 
				{
					_cacher.load(t_req);
				}
				else
				{
					dispatchEvent(new APIEvent(APIEvent.SAY_AUDIO_URL, t_req));
				}
			}
			checkQueue();
			
			*/
			
			
		}
		
	}
}