﻿package com.voki.data {
	import com.oddcast.assets.structures.SkinStruct;
	import com.oddcast.data.IThumbSelectorData;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPSkinStruct extends SkinStruct implements IThumbSelectorData {
		public var selectedColorArr:Array;
		private var _defaultColorArr:Array;
		public var width:Number;
		public var height:Number;
		public var level:int;
		public var _thumbUrl:String;
		
		public static const STANDARD_TYPE:String = "standard";
		public static const FAQ_TYPE:String = "faq";
		public static const AI_TYPE:String = "ai";
		public static const LEAD_TYPE:String = "lead";				
		
		public function SPSkinStruct($url:String, $id:int, $thumbUrl:String = null, $name:String = "", $catId:int = 0, $level:int = 0,$typeName:String="none",$width:Number=0,$height:Number=0) {
			super($url, $id,$typeName);
			width = $width;
			height = $height;
			level = $level;
			name = $name;
			catId = $catId;
			_thumbUrl = $thumbUrl;
		}
		
		public function get thumbUrl():String {
			return(_thumbUrl);
		}
		
		public function set thumbUrl(s:String):void {
			_thumbUrl=s;
		}
		
		public function get isOwned():Boolean {
			return(level <= SessionVars.level)
		}
		
		public function get defaultColorArr():Array { return _defaultColorArr; }
		
		public function set defaultColorArr(colorArr:Array):void {
			//Notes:
			//1. the default array is cloned, because we don't want the defaults to be changed when selectedColorArr
			//is changed... we want these 2 arrays to have different pointer values.
			//2. selectedColorArr should be the same pointer as the colorArr variable from the skin configuration
			//3. initialize the selected colors to the default colors if they are not already set
			
			_defaultColorArr = cloneArr(colorArr);
			if (selectedColorArr == null) selectedColorArr = colorArr;
		}
		
		private function cloneArr(a:Array):Array {
			var a2:Array = new Array();
			for (var i:int = 0; i < a.length; i++) {
				a2[i]=a[i];
			}
			return(a2);
		}
	}
	
}