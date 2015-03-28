package com.oddcast.oc3d.shared
{
	public class E
	{
		public static const ComponentFlag_X:uint = 0x1<<0;
		public static const ComponentFlag_Y:uint = 0x1<<1;
		public static const ComponentFlag_Z:uint = 0x1<<2;
		
		public static const PropertyType_Translate:uint = 1;
		public static const PropertyType_Rotate:uint = 2;
		public static const PropertyType_Scale:uint = 3;
		
		public static const TangentMode_Spline:uint = 1;
		public static const TangentMode_Step:uint = 2;
		public static const TangentMode_Linear:uint = 3;
		
		public static const DescriptorType_Identity:uint = 0;
		public static const DescriptorType_PositionOrientationScale:uint = 1;
		public static const DescriptorType_PositionScale:uint = 2;
		public static const DescriptorType_OrientationScale:uint = 3;
		public static const DescriptorType_PositionOrientation:uint = 4;
		public static const DescriptorType_Positon:uint = 5;
		public static const DescriptorType_Orientation:uint = 6;
		public static const DescriptorType_Scale:uint = 7;
	}
}