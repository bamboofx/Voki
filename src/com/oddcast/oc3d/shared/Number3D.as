package com.oddcast.oc3d.shared
{
	import flash.geom.Vector3D;

	/*
	public class Number3D
	{
		public function get __debug__():String{ return toString(); }

		public static const UNIT:Number3D = new Number3D(1, 1, 1);
		public static const ZERO:Number3D = new Number3D(0, 0, 0);
		
		public static const FRONT	:Number3D = new Number3D( 0,  0,  1);
		public static const BACK	:Number3D = new Number3D( 0,  0, -1);
		public static const LEFT	:Number3D = new Number3D(-1,  0,  0);
		public static const RIGHT	:Number3D = new Number3D( 1,  0,  0);
		public static const UP		:Number3D = new Number3D( 0,  1,  0);
		public static const DOWN	:Number3D = new Number3D( 0, -1,  0);
		
		public var x: Number;
		public var y: Number;
		public var z: Number;
		
		public function Number3D( x: Number=0, y: Number=0, z: Number=0 )
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public function assign(x:Number, y:Number, z:Number):void
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		public function assignVec(other:Number3D):void
		{
			x = other.x;
			y = other.y;
			z = other.z;
		}
	
		public function clone():Number3D
		{
			return new Number3D(x, y, z);
		}
		
		public function length():Number
		{
			return Math.sqrt(x*x + y*y + z*z);
		}
		public function squaredLength():Number
		{
			return x*x + y*y + z*z;
		}
	
		public function add(d:Number):void
		{
			x += d;
			y += d;
			z += d;
		}
		public function sub(d:Number):void
		{
			x -= d;
			y -= d;
			z -= d;
		}
		public function mul(s:Number):void
		{
			x *= s;
			y *= s;
			z *= s;
		}
		public function div(d:Number):void
		{
			var invD:Number = 1/d;
			x *= invD;
			y *= invD;
			z *= invD;
		}
		
		public function addVec(v:Number3D):void
		{
			x += v.x;
			y += v.y;
			z += v.z;
		}
		
		public function subVec(v:Number3D):void
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;
		}
		public function mulVec(v:Number3D):void
		{
			x *= v.x;
			y *= v.y;
			z *= v.z;
		}
		
		public function divVec(v:Number3D):void
		{
			x /= v.x;
			y /= v.y;
			z /= v.z;
		}		
		
		public function mulMat(m:Matrix3D):void
		{
			Matrix3D.mulMatVec(m, this);
		}
		
		public static function mulVecCopy(v:Number3D, s:Number):Number3D
		{
			return new Number3D(v.x*s, v.y*s, v.z*s);
		}
		public static function divVecCopy(v:Number3D, d:Number):Number3D
		{
			var invD:Number = 1 / d;
			return new Number3D(v.x*invD, v.y*invD, v.z*invD);
		}
		
		public static function addVecVecCopy(a:Number3D, b:Number3D):Number3D
		{
			return new Number3D(a.x+b.x, a.y+b.y, a.z+b.z);
		}
		public static function subVecVecCopy(a:Number3D, b:Number3D):Number3D
		{
			return new Number3D(a.x-b.x, a.y-b.y, a.z-b.z);
		}

		public static function dot( v:Number3D, w:Number3D ):Number
		{
			return v.x*w.x + v.y*w.y + w.z*v.z;
		}
	
		public function cross(v:Number3D, w:Number3D):void
		{
			x = w.y*v.z - w.z*v.y;
			y = w.z*v.x - w.x*v.z;
			z = w.x*v.y - w.y*v.x;
		}
		public static function crossCopy(v:Number3D, w:Number3D):Number3D
		{
			return new Number3D(w.y*v.z - w.z*v.y, w.z*v.x - w.x*v.z, w.x*v.y - w.y*v.x);
		}
	
		public function normalize():void
		{
			var len:Number = length();
			
			if (len == 0)
				throw new Error("divide by zero");
	
			var invLen:Number = 1 / len;
			x *= invLen;
			y *= invLen;
			z *= invLen;
		}
		
		public function toString():String
		{
			return '{x:' + x + ', y:' + y + ', z:' + z + '}';
		}
	}
	*/
	public class Number3D extends Vector3D
	{
		public function get __debug__():String{ return toString(); }

		public static const UNIT:Number3D = new Number3D(1, 1, 1);
		public static const ZERO:Number3D = new Number3D(0, 0, 0);
		
		public static const FRONT	:Number3D = new Number3D( 0,  0,  1);
		public static const BACK	:Number3D = new Number3D( 0,  0, -1);
		public static const LEFT	:Number3D = new Number3D(-1,  0,  0);
		public static const RIGHT	:Number3D = new Number3D( 1,  0,  0);
		public static const UP		:Number3D = new Number3D( 0,  1,  0);
		public static const DOWN	:Number3D = new Number3D( 0, -1,  0);

		public function Number3D(x:Number=0, y:Number=0, z:Number=0, w:Number=1)
		{
			super(x, y, z, w);
		}
		
		public function assign(x:Number, y:Number, z:Number):void
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		public function assignVec(other:Number3D):void
		{
			this.x = other.x;
			this.y = other.y;
			this.z = other.z;
		}
	
		public function _tmp_clone():Number3D
		{
			return new Number3D(x, y, z);
		}

		public function squaredLength():Number
		{
			return lengthSquared;
		}
	
		public function _tmp_add(d:Number):void
		{
			x += d;
			y += d;
			z += d;
		}
		public function sub(d:Number):void
		{
			x -= d;
			y -= d;
			z -= d;
		}
		public function mul(s:Number):void
		{
			x *= s;
			y *= s;
			z *= s;
		}
		public function fullMul(s:Number):void
		{
			x *= s;
			y *= s;
			z *= s;
			w *= s;
		}
		public function div(d:Number):void
		{
			var invD:Number = 1/d;
			x *= invD;
			y *= invD;
			z *= invD;
		}
		public function fullDiv(d:Number):void
		{
			var invD:Number = 1/d;
			x *= invD;
			y *= invD;
			z *= invD;
			w *= invD;
		}
		
		public function addVec(v:Number3D):void
		{
			x += v.x;
			y += v.y;
			z += v.z;
		}
		
		public function subVec(v:Number3D):void
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;
		}
		public function mulVec(v:Number3D):void
		{
			x *= v.x;
			y *= v.y;
			z *= v.z;
		}
		
		public function divVec(v:Number3D):void
		{
			x /= v.x;
			y /= v.y;
			z /= v.z;
		}		
		
		/*public function mulMat(m:Matrix3D):void
		{
			Matrix3D.mulMatVec(m, this);
		}*/
		
		public static function mulVecCopy(v:Number3D, s:Number):Number3D
		{
			return new Number3D(v.x*s, v.y*s, v.z*s);
		}
		public static function divVecCopy(v:Number3D, d:Number):Number3D
		{
			var invD:Number = 1 / d;
			return new Number3D(v.x*invD, v.y*invD, v.z*invD);
		}
		
		public static function addVecVecCopy(a:Number3D, b:Number3D):Number3D
		{
			return new Number3D(a.x+b.x, a.y+b.y, a.z+b.z);
		}
		public static function subVecVecCopy(a:Number3D, b:Number3D):Number3D
		{
			return new Number3D(a.x-b.x, a.y-b.y, a.z-b.z);
		}

		public static function dot( v:Number3D, w:Number3D ):Number
		{
			return v.x*w.x + v.y*w.y + w.z*v.z;
		}
	
		public function cross(v:Number3D, w:Number3D):void
		{
			var tmp:Vector3D = w.crossProduct(v);
			x = tmp.x;
			y = tmp.y;
			z = tmp.z;
		}
		public static function crossCopy(v:Number3D, w:Number3D):Number3D
		{
			var data:Vector3D = w.crossProduct(v);
			return new Number3D(data.x, data.y, data.z);
		}
		
		public override function toString():String
		{
			return '{x:' + x + ', y:' + y + ', z:' + z + ', w:' + w + '}';
		}
	}
}