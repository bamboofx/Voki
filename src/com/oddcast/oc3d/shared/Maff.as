package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.data.*;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class Maff
	{
		public static const RAD360:Number = Math.PI*2;
		public static const RAD270:Number = Math.PI*3*0.5;
		public static const RAD180:Number = Math.PI;
		public static const RAD90:Number = Math.PI*.5;
		public static const RAD45:Number = Math.PI*.25;
		
		public static const HALF_PI:Number = Math.PI*0.5;
		public static const QUATER_PI:Number = Math.PI*0.25;
		public static const INVERSE_HALF_PI:Number = 1/HALF_PI;
		public static const INVERSE_PI:Number = 1/Math.PI;
		public static const TWO_PI:Number = Math.PI*2;
		public static const DEG_TO_RAD:Number = Math.PI/180.0;
		public static const RAD_TO_DEG:Number = 180.0/Math.PI;
		public static const EPSILON:Number = 0.001;
		public static const SQRT_TWO:Number = Math.sqrt(2);
		public static const HALF_SQRT_TWO:Number = Math.sqrt(2)/2;
		public static const QUATER_SQRT_TWO:Number = Math.sqrt(2)/4;
		public static const INVERSE_SQRT_TWO:Number = 1/SQRT_TWO;
		public static const SIN45:Number = Math.sin(RAD45);
		
		public static const ONE_THIRD:Number = 1 / 3;
		
		public static function clamp(value:Number, minimum:Number, maximum:Number):Number
		{
			var result:Number = value > minimum ? value : minimum; 
			return result < maximum ? result : maximum; 
		}
		public static function clampInt(value:int, minimum:int, maximum:int):int { var result:int = value < minimum ? value : minimum; return result < maximum ? result : maximum; }
		public static function clampUInt(value:uint, minimum:uint, maximum:uint):int { var result:uint = value < minimum ? value : minimum; return result < maximum ? result : maximum; }
		public static function maxInt(value1:int, value2:int):int { return value1 > value2 ? value1 : value2; }
		public static function minInt(value1:int, value2:int):int { return value1 < value2 ? value1 : value2; }
		public static function max(v1:*, v2:*):* { return v1 > v2 ? v1 : v2; }
		public static function min(v1:*, v2:*):* { return v1 > v2 ? v2 : v1; }
		
		// ancillary Vector3D methods
		public static const Vector3D_UNIT:Vector3D	= new Vector3D( 1, 1, 1);
		public static const Vector3D_ZERO:Vector3D	= new Vector3D( 0, 0, 0);
		public static const Vector3D_FRONT:Vector3D	= new Vector3D( 0, 0, 1);
		public static const Vector3D_BACK:Vector3D	= new Vector3D( 0, 0,-1);
		public static const Vector3D_LEFT:Vector3D	= new Vector3D(-1, 0, 0);
		public static const Vector3D_RIGHT:Vector3D	= new Vector3D( 1, 0, 0);
		public static const Vector3D_UP:Vector3D	= new Vector3D( 0, 1, 0);
		public static const Vector3D_DOWN:Vector3D	= new Vector3D( 0,-1, 0);
		public static function Vector3D_assign(vec:Vector3D, x:Number, y:Number, z:Number):void { vec.x = x; vec.y = y; vec.z = z; }
		public static function Vector3D_assignVec(vec:Vector3D, src:Vector3D):void { vec.x = src.x; vec.y = src.y; vec.z = src.z; }
		public static function Vector3D_multiplyCopy(vec:Vector3D, scaler:Number):Vector3D { return new Vector3D(vec.x*scaler, vec.y*scaler, vec.z*scaler); }
		public static function Vector3D_clone(vec:Vector3D):Vector3D { return new Vector3D(vec.x, vec.y, vec.z, vec.w); }
	}
}