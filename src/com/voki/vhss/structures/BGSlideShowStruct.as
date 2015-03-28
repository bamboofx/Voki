package com.voki.vhss.structures
{
	import com.oddcast.animation.TransitionMaker;
	
	public class BGSlideShowStruct
	{
		
		public var id:String;
		public var seconds:Number;
		public var visible:Boolean;
		public var transition:TransitionMaker;
		
		public function BGSlideShowStruct($id:String, $sec:Number, $vis:Boolean)
		{
			id = $id;
			seconds = $sec;
			visible = $vis;
		}

	}
}