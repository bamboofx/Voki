package com.voki.vhss.playback
{
	import com.oddcast.utils.ErrorReportingURLLoader;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import com.voki.vhss.Constants;
	
	public class CachedSceneStatus extends EventDispatcher
	{
		private var ldr:ErrorReportingURLLoader;
		private var to_int:uint;
		public var doc:String;
		
		public function CachedSceneStatus($doc:String):void
		{
			try
			{
				doc = $doc;
				var t_id:String = doc.split("ss=")[1]
				t_id = t_id.split("/")[0];
				ldr = new ErrorReportingURLLoader();
				var t_params:URLVariables = new URLVariables();
				var t_req:URLRequest = new URLRequest();
				t_req.url = Constants.SCENE_STATUS_PHP;
				t_params.sc = t_id;
				t_params.t = "vhss";
				t_params.r = int(Math.random()*100000);
				t_req.data = t_params;
				t_req.method = URLRequestMethod.GET;
				ldr.addEventListener(Event.COMPLETE, e_requestComplete);
				ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_error);
			    ldr.addEventListener(IOErrorEvent.IO_ERROR, e_error);
				ldr.load(t_req);
				to_int = setTimeout(timeout, 5000);
			}
			catch ($e:Error)
			{
				e_error();
			}
			
		}
		
		public function destroy():void
		{
			try
			{
				removeListeners();
				ldr = null;
				clearTimeout(to_int);
			}
			catch ($e:Error)
			{
				trace("CachedSceneStatus -- Destory");
			}
		}
		
		private function e_requestComplete($e:Event):void
		{
			//trace("CACHED SCENE STATUS --  "+ErrorReportingURLLoader($e.target).data);
			clearTimeout(to_int);// confirm with SERgey what is returned here
			var t_resp:String = ErrorReportingURLLoader($e.target).data;
			t_resp = t_resp.split("=")[1];
			if (t_resp != null && t_resp.length > 1)
			{
				var t_protocol:String = doc.substring(0, doc.indexOf("://"));
				var t_dot_ar:Array;
				t_dot_ar = doc.split(".");
				t_dot_ar[0] = t_protocol+"://" + t_resp;
				doc = t_dot_ar.join(".");
				doc += "?r="+int(Math.random()*1000000);
			}
			dispatchEvent(new Event(Event.COMPLETE));
			removeListeners();
		}
		
		private function timeout():void
		{
			trace("CACHED SCENE STATUS -- timeout");
			e_error();
		}
		
		private function e_error($e:Event = null):void
		{
			trace("CACHED SCENE STATUS -- error");
			clearTimeout(to_int);
			dispatchEvent(new Event(Event.COMPLETE));
			removeListeners();
		}
		
		private function removeListeners():void
		{
			ldr.removeEventListener(Event.COMPLETE, e_requestComplete);
			ldr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, e_error);
            ldr.removeEventListener(IOErrorEvent.IO_ERROR, e_error);
		}
	}
}