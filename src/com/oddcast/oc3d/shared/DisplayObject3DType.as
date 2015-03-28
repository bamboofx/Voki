package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.shared.Enum;
	
	public class DisplayObject3DType extends Enum
	{
		public function DisplayObject3DType(id:uint){ super(id); }
		
		public static const Default:DisplayObject3DType = new DisplayObject3DType(0);
		public static const Joint:DisplayObject3DType = new DisplayObject3DType(1);
		public static const Shape:DisplayObject3DType = new DisplayObject3DType(2);
		
		public static function  fromId(id:uint):DisplayObject3DType
		{
			if (Default.id == id)
				return Default;
			else if (Joint.id == id)
				return Joint;
			else if (Shape.id == id)
				return Shape;
			else
				throw new Error("unknown DisplayObject3DType");
		}
	}
}