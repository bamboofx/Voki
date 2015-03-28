package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.shared.Enum;
	
	public class AnimationChannelType extends Enum
	{
		public function AnimationChannelType(id:uint) { super(id); }

		public static const Transform:AnimationChannelType = new AnimationChannelType(0);
		public static const Morph:AnimationChannelType = new AnimationChannelType(1);
		public static const Property:AnimationChannelType = new AnimationChannelType(2);
		public static const Trigger:AnimationChannelType = new AnimationChannelType(3);
		public static const Channel:AnimationChannelType = new AnimationChannelType(4);
		public static const OptimizedTransform:AnimationChannelType = new AnimationChannelType(5);
	}
}