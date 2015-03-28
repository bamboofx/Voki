package com.oddcast.oc3d.shared
{
	import flash.display.BlendMode;
	
	public class ThumbnailMode extends Enum
	{
		public function ThumbnailMode(id:uint){ super(id); }
		
		public static const SingleAccessory:ThumbnailMode = new ThumbnailMode(1);
		public static const EntireAccessoryTree:ThumbnailMode = new ThumbnailMode(2);
		public static const ImageOnly:ThumbnailMode = new ThumbnailMode(3);
	}
}