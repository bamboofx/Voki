﻿package com.voki.data {
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.data.IThumbSelectorData;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPBackgroundStruct extends BackgroundStruct implements IThumbSelectorData {
		protected static var tempCounter:int=1;
		private var _tempId:int=0;

		private var _typeId:int;
		private var bgThumbUrl:String;
		public var isUploadPhoto:Boolean;
		public var level:int;
		public var transform:Object;
		
		public static const ALL_TYPES:String = "all";
		public static const IMAGE_TYPE:String = "photo";
		public static const VIDEO_TYPE:String = "video";
		public static const SLIDESHOW_TYPE:String = "slideshow";
		public static const ANIMATED_TYPE:String = "anim";
		
		public function SPBackgroundStruct($url:String,$id:int=0,$thumb:String=null,$name:String="",$catId:int=0, $transform:Object = null) {
			super($url,$id);
			_tempId=tempCounter;
			tempCounter++;
			
			thumbUrl=$thumb;
			name=$name;
			catId = $catId;
			transform = $transform;
			//typeId=in_typeId;
		}

		public function get thumbUrl():String {
			return(bgThumbUrl);
		}
		
		public function set thumbUrl(s:String):void {
			bgThumbUrl=s;
		}
		
		public function get hasId():Boolean {
			return(id>0);
		}
		
		public function get tempId():int {
			if (hasId) return(-1);
			else return(_tempId);
		}
		
		public function get typeId():int {
			return _typeId; 
		}
		
		public function set typeId(value:int):void {
			_typeId = value;
		}
		
	}
	
}