package com.voki.player {
	import com.adobe.images.JPGEncoder;
	import com.dynamicflash.util.Base64;
	import com.oddcast.utils.XMLLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLVariables;
	import com.voki.data.SessionVars;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ThumbSaver extends EventDispatcher{
		public var w:Number;
		public var h:Number;
		private var _bCharEditorMode:Boolean;
		
		public function ThumbSaver($w:Number=100, $h:Number=100, charEditMode:Boolean = false) {
			w = $w;
			h = $h;
			_bCharEditorMode = charEditMode;
		}
		
		public function saveThumb(mc:Sprite,area:Sprite):Bitmap {
			trace("ThumbSaver::saveThumb");
			var thumbBitmap:BitmapData = new BitmapData(w,h,false,0xFF2200);
			var m:Matrix = new Matrix();
			//var bounds:Rectangle = area.getBounds(mc);
			//m.translate( -bounds.x, -bounds.y);
			//m.scale(w/bounds.width,h/bounds.height);
			m.scale(w/400,h/300);

			thumbBitmap.draw(mc,m)
			var bmp:Bitmap = new Bitmap(thumbBitmap);
			var encoder:JPGEncoder = new JPGEncoder(100);
			var urlvars:URLVariables = new URLVariables();
			urlvars.FileDataBase64 = Base64.encodeByteArray(encoder.encode(thumbBitmap));
			if (!_bCharEditorMode)
			{
				urlvars.type = "thumbs";
				urlvars.ss_id = SessionVars.showId;
			}
			else
			{
				urlvars.type = "char_thumb";
				urlvars.char_id = SessionVars.charEdit_charId;
				
			}
			var url:String = SessionVars.localBaseURL+"upload.php?rand="+Math.floor(Math.random()*1000000);
			XMLLoader.sendVars(url, thumbSaved, urlvars);
			return(bmp);
		}
		
		private function thumbSaved(_xml:XML) {
			trace("ThumbSaver::thumbSaved - " + _xml.toXMLString());
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
}