package com.oddcast.oc3d.shared
{
	public class BinType extends Enum
	{
		public function BinType(id:uint){ super(id); }
		
		public static const Accessory:BinType = new BinType(0);
		public static const Animation:BinType = new BinType(1);
		public static const Material:BinType = new BinType(2);
		
		public static function idToEnum(id:uint):BinType
		{
			if (id == 0)
				return Accessory;
			else if (id == 1)
				return Animation;
			else if (id == 2)
				return Material
			else
				throw new Error("unknown bin type");
		}
		
		public static function forEachEnum(fn:Function):void
		{
			fn(Accessory);
			fn(Animation);
			fn(Material);
		}
		
		public function toString():String
		{
			if (id == 0)
				return "Accessory";
			else if (id == 1)
				return "Animation";
			else if (id == 2)
				return "Material";
			else
				throw new Error("unknown bin type");
		}
	}
}