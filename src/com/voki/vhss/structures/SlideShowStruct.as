/**
* ...
* @author Dave Segal
* @version 0.1
* @date 11.26.2007
* 
*/

package com.voki.vhss.structures{

	public class SlideShowStruct {
		
		//public static var ai_engine:String;
		
		public var show_xml:XML;
		public var door_id:String;
		public var account_id:String;
		public var edition_id:String;
		public var show_id:String;
		public var ai_engine_id:String;
		public var track_url:XMLList;
		public var oh_dom:String;
		public var name:String;
		public var content_dom:String;
		public var tts_dom:String;
		public var watermark_url:String; 
		public var loader_url:String;
		public var loaderIsCustom:Boolean = false;
		public var id:String;
		public var scenes:Array;
		public var bg_color:String;
		public var volume:int = -1;
		
		public function SlideShowStruct()
		{
			//trace("SlideShowStruct constructor");
			scenes = new Array();
		}
	}
}