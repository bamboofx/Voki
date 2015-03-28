package com.voki.vhss.api
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import com.voki.vhss.api.requests.APIRequest;

	public class Requester extends EventDispatcher
	{
		
		private var _url_loader:URLLoader;
		
		public function Requester()
		{
			
		}
		
		public function destroy():void
		{
			clearLoader();
		}
		
		private function clearLoader():void
		{
			if (_url_loader != null)
			{
				_url_loader.removeEventListener(Event.COMPLETE, e_complete);
				_url_loader.removeEventListener(IOErrorEvent.IO_ERROR, e_error);
				_url_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, e_security);
				_url_loader = null;
			}
		}
		
		public function load($req:APIRequest):void
		{
			clearLoader();
			_url_loader = new URLLoader();
			_url_loader.addEventListener(Event.COMPLETE, e_complete);
			_url_loader.addEventListener(IOErrorEvent.IO_ERROR, e_error);
			_url_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_security);
			var t_requester:URLRequest = getURLRequest();
			_url_loader.load(t_requester);
		}
		
		protected function getURLRequest():URLRequest
		{
			return new URLRequest();
		}
		
		//Event Handlers
		protected function e_complete($e:Event):void
		{
			
		}
		
		private function e_error($e:IOErrorEvent):void
		{
			//----trace("AI Request error: " + $e);
		}
		
		private function e_security($e:SecurityErrorEvent):void
		{
			//----trace("AI Request security: " + $e);
		}
		
	}
}