package com.voki.data {
	import com.oddcast.audio.AudioData;
	import flash.geom.Matrix;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SceneStruct {
		public var id:int;
		public var order:int;
		public var char:SPCharStruct;
		public var bg:SPBackgroundStruct;
		public var audioArr:Array;
		public var skin:SPSkinStruct;
		public var skinConfig:SkinConfiguration;
		public var title:String;
		
		public var audioIds:Array;
		public var expression:String;
		
		public function SceneStruct() {
			skinConfig = new SkinConfiguration();
		}
		
		public function get audio():AudioData {
			return(audioArr[0]);
		}
		
		public function set audio($audio:AudioData):void {
			if (audioArr == null) audioArr = new Array();
			audioArr[0] = $audio;
		}
		
		public function get model():SPHostStruct { 
			if (char == null) return(null);
			else return char.model;
		}
		
		public function set model(value:SPHostStruct):void {
			if (char == null) char = new SPCharStruct();
			char.model = value;
		}
	}
	
}