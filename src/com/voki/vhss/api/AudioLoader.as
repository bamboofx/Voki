package com.voki.vhss.api
{

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;

	public class AudioLoader extends EventDispatcher
	{
		private var _sound:Sound;
		private var _queue:Array;
		
		
		public function AudioLoader()
		{
			_sound = new Sound();
			_sound.addEventListener(Event.COMPLETE, e_loadComplete);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, e_IOError);
		}
		
		public function destroy():void
		{
			_sound.removeEventListener(Event.COMPLETE, e_loadComplete);
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, e_IOError);
			_sound = null;
		}
		
		public function load($url:String):void
		{
			try{
				_sound.load(new URLRequest($url));
			}
			catch ($e:Error)
			{
				//----trace("MP3Cacher :: ERROR "+$e.message);
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			}
		}
		
		private function e_loadComplete($ev:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function e_IOError($ev:IOErrorEvent):void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			//----trace("MP3Cacher :: IO ERROR "+$ev.toString());
		}
		
	}
}