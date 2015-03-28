package com.voki.vhss.api
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getDefinitionByName;
	
	import com.voki.vhss.Constants;
	import com.voki.vhss.api.requests.*;
	import com.voki.vhss.events.APIEvent;

	public class AIRequester extends Requester
	{
		

		private var _ai_request:APIAIRequest;
		private var _url_req:URLRequest;
		
		public function AIRequester()
		{
			
		}
		
		override public function load($req:APIRequest):void
		{	
			var t_ai_req:APIAIRequest = APIAIRequest($req);
			_ai_request = t_ai_req;
			_url_req = new URLRequest(Constants.VHSS_DOMAIN + Constants.AI_PHP);
			_url_req.data = new URLVariables("text="+escape(t_ai_req.ai_text)+"&botid="+t_ai_req.bot+"&acc="+t_ai_req.account_id+"&aiEngine="+t_ai_req.ai_engine_id);
			_url_req.method = URLRequestMethod.POST;
			super.load(t_ai_req);
		}
				
		override protected function getURLRequest():URLRequest
		{
			return _url_req;
		}
		
		//Event Handlers
		override protected function e_complete($e:Event):void
		{
			var t_ldr:URLLoader = URLLoader($e.target);
			//----trace("AI Request --- COMPLETE -- data "+t_ldr.data);
			var t_str:String = t_ldr.data as String;
			if (t_str.indexOf("response") == 0)
			{
				var t_ar:Array = t_str.split("&");
				var t_resp:AIResponse = new AIResponse();
				t_resp.ai_request = _ai_request;
				for (var i:uint = 0; i < t_ar.length; ++i)
				{
					if (String(t_ar[i]).indexOf("response") == 0)
					{
						t_resp.ai_request.name = String(t_ar[i]).substr(String(t_ar[i]).indexOf("=")+1);
					}
					else if (String(t_ar[i]).indexOf("location") == 0)
					{
						t_resp.url = String(t_ar[i]).substr(String(t_ar[i]).indexOf("=")+1);
					}
					else if (String(t_ar[i]).indexOf("aiDisplayTag") == 0)
					{
						t_resp.display_tag = String(t_ar[i]).substr(String(t_ar[i]).indexOf("=")+1);
					}
					else if (String(t_ar[i]).indexOf("display") == 0)
					{
						t_resp.display_text = String(t_ar[i]).substr(String(t_ar[i]).indexOf("=")+1);
					}
				}
				
				//var t_resp:String = t_str.substr(t_str.indexOf("=")+1);
				//.name = t_resp;
				dispatchEvent(new APIEvent(APIEvent.AI_COMPLETE, t_resp));
			}
			else if (t_str.toLowerCase().indexOf("err") == 0)
			{
				//----trace("AI REQUEST ERROR -- "+ t_str.substr(t_str.indexOf("=")+1));
			}
			else
			{
				//----trace("AI REQUEST - UNKNOWN RESPONSE "+t_str+"  type: "+t_ldr.dataFormat);
			}
		}
		
		
	}
}