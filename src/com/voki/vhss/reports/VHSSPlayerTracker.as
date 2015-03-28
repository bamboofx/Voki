/**
* ...
* @author Dave Segal
* @date 07.08.08
* 
* description - static class that implements the standard Oddcast tracking class
* 
*/


package com.voki.vhss.reports{
	
	import com.oddcast.reports.MultiUrlEventTracker;
	
	import flash.display.LoaderInfo;
	
	
	public class VHSSPlayerTracker{
		
		private static var tracker:MultiUrlEventTracker;
		private static var parameters:Object;
		private static var request_url:String;
		private static var error:Error;
		
		/*
		public static function init($req_url:String, $init_obj:Object):void
		{
			tracker = new EventTracker();
			tracker.init($req_url, $init_obj);
		}
		*/
		
		public static function setInitObject($init_obj:Object):void
		{
			parameters = $init_obj;
		}
		
		public static function setRequestUrl($req_url:String):void
		{
			request_url = $req_url;
		}
		
		public static function initTracker($req_url:*, $init_obj:Object, $loader_info:LoaderInfo):void
		{
			tracker = new MultiUrlEventTracker();
			var track_url:String;
			if ($req_url is XMLList)
			{
				var url_ar:XMLList = $req_url as XMLList;
				track_url = url_ar[0].toString();
				for (var i:int = 1; i < url_ar.length(); ++i)
				{
					tracker.addReportingUrl(url_ar[i].toString());
				}
			}
			else if ($req_url is String)
			{
				track_url = $req_url as String;
			}
			if (track_url) tracker.init(track_url, $init_obj, $loader_info);
		}
		
		public static function setEventTracker($et:MultiUrlEventTracker):void
		{
			tracker = $et;
		}
		
		public static function event($event:String, $scene:String=null, $count:Number = 0, $value:String=null):void
		{
			if (tracker != null)
			{
				tracker.event($event, $scene, $count, $value);
			}
		}
		
		public static function destroy():void
		{
			tracker.destroy();
			tracker = null;
		}
		//public static function getTracker():EventTracker
		//{
		//	if (tracker == null)
		//	{
		//		tracker = new EventTracker();
		//	}
		//	return tracker;
			
			/*if (tracker != null)
			{
				return tracker;
			}
			else if (request_url != null && parameters != null)
			{
				tracker = new EventTracker(request_url, parameters);
				return tracker;
			}
			else
			{
				return new Error("VHSS PLAYER ERROR - EVENT TRACKER PARAMETERS NOT SET");
			}
			*/
		//}
		
	}
	
}