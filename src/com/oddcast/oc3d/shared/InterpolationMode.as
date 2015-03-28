package com.oddcast.oc3d.shared
{
	public class InterpolationMode extends Enum
	{
		public function InterpolationMode(id:uint) { super(id); }
		
		public static const Bezier:InterpolationMode = new InterpolationMode(1);
		public static const Linear:InterpolationMode = new InterpolationMode(2);
		public static const Step:InterpolationMode = new InterpolationMode(3);
		
		public static function stringToEnum(str:String):InterpolationMode
		{
			if (str == "BEZIER")
				return Bezier;
			else if (str == "LINEAR")
				return Linear;
			else if (str == "STEP")
				return Step;
			else
				throw new Error("unknown interpolation mode \"" + str + "\"");
		}
	}
}