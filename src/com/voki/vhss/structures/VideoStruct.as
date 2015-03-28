package com.voki.vhss.structures
{
	public class VideoStruct
	{
		public var url:String;
		public var id:int;
		public var name:String;
		public var desc:String;
		public var duration:Number;
		public var catName:String;
		
		public function VideoStruct($url:String, $id:int, $name:String, $desc:String, $duration:Number = 0, $catName:String="")
		{
			url = $url;
			id = $id;
			name = $name;
			desc=$desc;
			duration=$duration;
			catName = $catName;
		}
	}
}