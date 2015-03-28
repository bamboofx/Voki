package com.voki.data
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import com.oddcast.workshop.ServerInfo;
	import com.voki.ui.VoiceEmotionItem;
	
	
	public class VoiceEmotionsList
	{
		private var emotion_loader:URLLoader;
		private var emotion_request:URLRequest;
		private var emotion_url:String;
		public  var callBack:Function;
		
		private var emotions_list:Array;
		
		public function VoiceEmotionsList() { emotions_list = new Array(); }
		
		/**
		 * Method for getting voice/emotions compatability xml
		 */
		public function getVoiceEmotionInfo( _callBack:Function = null ):void
		{
			callBack = _callBack;			
			emotion_url = SessionVars.baseURL + "getEmotions/partnerId=" + SessionVars.partnerId;//ServerInfo.contentURL + "/host/tts_widget/xml/ssml.xml";
			//emotion_url = "http://content.dev.oddcast.com/host/tts_widget/xml/ssml.xml";
			
			emotion_request = new URLRequest( emotion_url );
			emotion_request.method = URLRequestMethod.GET;
			
			emotion_loader = new URLLoader();
			emotion_loader.addEventListener( Event.COMPLETE, xmlReceived, false, 0 , true );
			emotion_loader.load(emotion_request);
		}
		
		/**
		 * Called when loading is complete
		 * @param	event
		 */
		private function xmlReceived(event:Event):void {
			emotion_loader.removeEventListener( Event.COMPLETE, xmlReceived );
           
			var emotion_xml:XML = XML( event.target.data );
			emotionsXMLParser( emotion_xml );
        }
		
		/**
		 * Parse voice/emotions compatability XML
		 */
		private function emotionsXMLParser( _XML:XML ):void
		{
			var temp_voiceName:String;
			var temp_emotionsArray:Array;
			
			for ( var pname:String in _XML.voice)
			{
				temp_voiceName = _XML.voice.@id[pname];
				temp_emotionsArray = getCompatibleEmotions( _XML, temp_voiceName );
				emotions_list.push(  new VoiceEmotionItem( temp_voiceName, temp_emotionsArray )  );
			}
			if ( callBack != null ) callBack();
		}
		
		/**
		 * Returns the emotions available for a voice. Called by emotions parser.
		 */
		private function getCompatibleEmotions( _XML:XML, _name:String ):Array
		{
			var tempArray:Array = new Array();
			var tempNode:XMLList = _XML.voice.( @id == _name ).children();
			var item:XML;
			for each ( item in tempNode ) 
			{
				tempArray.push( item.toString() );
			}
			
			return tempArray;
		}
		
		/*
		 * Returns the emotions for a queried voice as an array
		 */ 
		public function getEmotionsByVoiceName( _name:String ):Array
		{
			_name = _name.split(" ")[0];
			for (var i:int = 0; i < emotions_list.length; i++) 
			{
				if ( (emotions_list[i] as VoiceEmotionItem).VOICE_NAME.toLowerCase() == _name.toLowerCase() ) {
					return (emotions_list[i] as VoiceEmotionItem).EMOTIONS_ARRAY;
				}
			}
			
			return null;
		}
		
		
		
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
		
        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }
		
	}
	
}