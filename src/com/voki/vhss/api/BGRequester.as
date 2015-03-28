package com.voki.vhss.api
{
	import com.oddcast.assets.structures.BackgroundStruct;
	
	import flash.events.Event;
	import flash.net.*;
	
	import com.voki.vhss.Constants;
	import com.voki.vhss.api.requests.*;
	import com.voki.vhss.events.APIEvent;

	public class BGRequester extends Requester
	{
		
		private var _url_req:URLRequest;
		
		public function BGRequester()
		{
			
		}
		
		override public function load($req:APIRequest):void
		{
			_url_req = new URLRequest(Constants.VHSS_DOMAIN + Constants.BG_PHP);
			_url_req.data = new URLVariables("bgname="+escape($req.name)+"&acc="+$req.account_id);
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
			//----trace("BG Request --- COMPLETE -- data "+t_ldr.data);
			var t_str:String = t_ldr.data as String;
			if (t_str.indexOf("location") == 0)
			{
				var t_ar:Array = t_str.split("&");
				var t_url:String;
				var t_type:String = "bg";
				for (var i:uint = 0; i < t_ar.length; ++i)
				{
					if (String(t_ar[i]).indexOf("location") == 0) t_url = String(t_ar[i]).substr(String(t_ar[i]).indexOf("=")+1);
					if (String(t_ar[i]).indexOf("type") == 0) t_type = String(t_ar[i]).substr(String(t_ar[i]).indexOf("=")+1);
				}
				if (t_url != "ERROR")
				{
					dispatchEvent(new APIEvent(APIEvent.BG_URL, new BackgroundStruct(t_url, 0, t_type)));
				}
				else
				{
					//----trace("BG REQUEST ERROR -- "); 
				}
			}
			else
			{
				//----trace("BG REQUEST - UNKNOWN RESPONSE "+t_str+"  type: "+t_ldr.dataFormat);
			}
		}
		
	}
}