package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	public class MaterialLayerType extends Enum
	{
		public function MaterialLayerType (id:uint){ super(id); }

		public static const Image:MaterialLayerType = new MaterialLayerType(1);
		public static const Color:MaterialLayerType = new MaterialLayerType(2);
	}
}