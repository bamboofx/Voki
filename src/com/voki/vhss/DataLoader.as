/**
* ...
* @author Default
* @version 0.1
*/

package com.voki.vhss{

	import com.oddcast.utils.ErrorReportingURLLoader;
	
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import com.voki.vhss.events.DataLoaderEvent;

	public class DataLoader extends EventDispatcher {
		
		private var load_type:String;
		
		public function load($req:URLRequest, in_type:String):void
		{
			load_type = in_type;
			var loader:ErrorReportingURLLoader = new ErrorReportingURLLoader();
			configureListeners(loader);
			try
			{
				//----trace("DATA LOADER ::: "+in_type+"   url: "+$req.url);
				loader.load($req);
			}
			catch (err:Error)
			{
				//----trace("DATA LOADER  ERROR ::: "+in_type+"   url: "+$req.url+" error: "+err);
			}
		}

        private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			dispatcher.addEventListener(Event.OPEN, openHandler, false, 0, true);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
        }

        private function completeHandler(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			//----trace("DATA LOADER  completeHandler: event type: "+event.type);// + loader.data);
			var t_ev:DataLoaderEvent;
			if (load_type == "xml")
			{
				t_ev = new DataLoaderEvent(DataLoaderEvent.ON_DATA_READY, {xml:new XML(loader.data)});
			}
			else
			{
				t_ev = new DataLoaderEvent(DataLoaderEvent.ON_DATA_READY, {data:loader.data});
			}
			dispatchEvent(t_ev);
        }

        private function openHandler(event:Event):void {
            //----trace("DATA LOADER  openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            //----trace("DATA LOADER  progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            //----trace("DATA LOADER  securityErrorHandler: " + event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            //----trace("DATA LOADER  httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            //----trace("DATA LOADER  ioErrorHandler: " + event);
        }
    }
	
}
	
	