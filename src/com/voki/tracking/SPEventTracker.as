/**
* ...
* @author Sam
* @version 0.1
* 
* Contains a static instance of the EventTracker Object.
* 
* @see com.oddcast.reports.EventTracker
*/

package com.voki.tracking {
	import com.oddcast.reports.EventTracker;
	
	public class SPEventTracker {		
		private static var tracker:EventTracker;
		
		public static function init(in_req_url:String, in_init_obj:Object) {
			tracker=new EventTracker();
			tracker.init(in_req_url,in_init_obj);
		}
		
		public static function event(in_event:String, in_scene:String=null,count:uint=0) {
			if (tracker==null) return;
			tracker.event(in_event,in_scene,count);
		}
		
		public static function destroy() {
			if (tracker == null) return;
			trace("*** DESTROYING TRACKER ***");
			tracker.destroy();
			tracker=null;
		}
		
		public static function getTracker():EventTracker {
			return(tracker);
		}
	}
	
}