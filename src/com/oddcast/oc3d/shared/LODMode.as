package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	
	public class LODMode extends Enum
	{
		public function LODMode (id:uint){ super(id); }

		public static const Low:LODMode = new LODMode(1);
		public static const Mixed:LODMode = new LODMode(2);
		public static const Full:LODMode = new LODMode(3);
	}
}