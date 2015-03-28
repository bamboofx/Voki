///*
package com.oddcast.oc3d.shared
{
	import flash.geom.*;

	public class Matrix3D
	{
		public static const e11:Number = 0;
		public static const e21:Number = 1;
		public static const e31:Number = 2;
		public static const e41:Number = 3;
		public static const e12:Number = 4;
		public static const e22:Number = 5;
		public static const e32:Number = 6;
		public static const e42:Number = 7;
		public static const e13:Number = 8;
		public static const e23:Number = 9;
		public static const e33:Number = 10;
		public static const e43:Number = 11;
		public static const e14:Number = 12;
		public static const e24:Number = 13;
		public static const e34:Number = 14;
		public static const e44:Number = 15;
		
		public var n11:Number;
		public var n12:Number;
		public var n13:Number;
		public var n14:Number; // tx
		public var n21:Number;
		public var n22:Number;
		public var n23:Number;
		public var n24:Number; // ty
		public var n31:Number;
		public var n32:Number;
		public var n33:Number;
		public var n34:Number; // tz
		public var isIdentity:Boolean;
		
		public var n41:Number; // just for projection
		public var n42:Number;
		public var n43:Number;
		public var n44:Number;

		public function Matrix3D(
			_11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
			_21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
			_31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
			_41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false)
		{
			this.n11 = _11, this.n12 = _12, this.n13 = _13, this.n14 = _14,
			this.n21 = _21, this.n22 = _22, this.n23 = _23, this.n24 = _24,
			this.n31 = _31, this.n32 = _32, this.n33 = _33, this.n34 = _34;
			this.n41 = _41, this.n42 = _42, this.n43 = _43, this.n44 = _44;
			this.isIdentity = isIdentity;
		}
		
		public function identity():void
		{
			this.n11 = 1; this.n12 = 0; this.n13 = 0; this.n14 = 0;
			this.n21 = 0; this.n22 = 1; this.n23 = 0; this.n24 = 0;
			this.n31 = 0; this.n32 = 0; this.n33 = 1; this.n34 = 0;
			this.isIdentity = true; 
		}
		public function get debug():String
		{
			return "{pos:" + debug__Position.toString() + ", ori:" + debug__Orientation.toString() + ", scl:" + debug__Scale.toString() + "}";
		}
		public function get debug__Position():Number3D
		{
			return new Number3D(n14, n24, n34);
		}
		public function get debug__Orientation():Number3D
		{
			var sx:Number = new Number3D(n11, n21, n31).length;
			var sy:Number = new Number3D(n12, n22, n32).length;
			var sz:Number = new Number3D(n13, n23, n33).length;

			var iX:Number = 1/sx;
			var iY:Number = 1/sy;
			var iZ:Number = 1/sz;
			
			return new Number3D(
				-Math.atan2(n32*iY, n33*iZ) * Maff.RAD_TO_DEG,
				-Math.asin(n31*iX) * Maff.RAD_TO_DEG,
				-Math.atan2(n21*iX, n11*iX) * Maff.RAD_TO_DEG);
		}
		public function get debug__Scale():Number3D
		{
			return new Number3D(
				new Number3D(n11, n21, n31).length,
				new Number3D(n12, n22, n32).length, 
				new Number3D(n13, n23, n33).length);
		}
		
		public function clone():Matrix3D
		{
			return new Matrix3D(
				n11, n12, n13, n14,
				n21, n22, n23, n24,
				n31, n32, n33, n34,
				n41, n42, n43, n44, isIdentity);
		}
		
		public static function createFromArray(array:Array):Matrix3D
		{
			var a:Array = [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1];
			for (var i:int=0; i<Math.min(array.length,a.length); ++i)
				a[i] = array[i];
				
			return new Matrix3D(
				a[ 0], a[ 1], a[ 2], a[ 3],
				a[ 4], a[ 5], a[ 6], a[ 7],
				a[ 8], a[ 9], a[10], a[11],
				a[12], a[13], a[14], a[15]);
		}
		
		public function translateBy(x:Number, y:Number, z:Number):void
		{
			n14 += x;
			n24 += y;
			n34 += z;
			isIdentity = false;
		}
		
		public function translateTo(x:Number, y:Number, z:Number):void
		{
			n14 = x;
			n24 = y;
			n34 = z;
			isIdentity = false;
		}
		
		public function transformInRadians(position:Number3D, orientation:Number3D, scale:Number3D):void
		{
			// translate
			n14 = position.x;
			n24 = position.y;
			n34 = position.z;
			
			// rotate
	        var cx:Number = Math.cos(orientation.x);
	        var sx:Number = Math.sin(orientation.x);
	        var cy:Number = Math.cos(orientation.y);
	        var sy:Number = Math.sin(orientation.y);
	        var cz:Number = Math.cos(orientation.z);
	        var sz:Number = Math.sin(orientation.z);

			n11 = cy*cz;	
			n12 = cx*sz-sx*sy*cz;	
			n13 = cx*sy*cz+sx*sz;	
			n21 = -cy*sz;
			n22 = sx*sy*sz+cx*cz;	
			n23 = sx*cz-cx*sy*sz;	
			n31 = -sy;
			n32 = -sx*cy;				
			n33 = cx*cy;
					
			// scale	
			if (scale.x != 1)
			{ 
				n11 *= scale.x;	
				n21 *= scale.x;
				n31 *= scale.x;
			}
			if (scale.y != 1)
			{
				n12 *= scale.y;	
				n22 *= scale.y;	
				n32 *= scale.y;				
			}
			if (scale.z != 1)
			{
				n13 *= scale.z;	
				n23 *= scale.z;	
				n33 *= scale.z;
			}
			isIdentity = false;
		}
		
		public static function createTranslate(x:Number, y:Number, z:Number):Matrix3D
		{
			return new Matrix3D(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, z, 0, 0, 0, 1);
		}

		public static function createScale(xScale:Number, yScale:Number, zScale:Number):Matrix3D
		{
			return new Matrix3D(xScale, 0, 0, 0, 0, yScale, 0, 0, 0, 0, zScale, 0, 0, 0, 0, 1);
		}

		public static function createRotateAngleAxis(x:Number, y:Number, z:Number, degrees:Number):Matrix3D
		{
			return createRotateAngleAxisWithRadians(x, y, z, Maff.DEG_TO_RAD * degrees);
		}
		public static function createRotateAngleAxisWithRadians(x:Number, y:Number, z:Number, radians:Number):Matrix3D
		{
			var c:Number = Math.cos(radians);
			var s:Number = Math.sin(radians);
			var scos:Number	= 1-c;

			var sxy:Number = x*y*scos;
			var syz:Number = y*z*scos;
			var sxz:Number = x*z*scos;
			var sz:Number = s*z;
			var sy:Number = s*y;
			var sx:Number = s*x;

			return new Matrix3D(
				c+x*x*scos,	-sz+sxy,	sy+sxz,		0,
				sz+sxy, 	c+y*y*scos,	-sx+syz, 	0,	
				-sy+sxz,	sx+syz,		c+z*z*scos,	0,
				0, 			0, 			0, 			1);
		}
		public static function createRotateVecWithRadians(radians:Number3D):Matrix3D
		{
			return createRotateWithRadians(radians.x, radians.y, radians.z);
		}
		public static function createRotateWithRadians(radiansX:Number, radiansY:Number, radiansZ:Number):Matrix3D
		{
			var pitch:Number = radiansX;
			var yaw:Number = radiansY;
			var roll:Number = radiansZ;
			
	        var cx:Number = Math.cos(pitch);
	        var sx:Number = Math.sin(pitch);
	        var cy:Number = Math.cos(yaw);
	        var sy:Number = Math.sin(yaw);
	        var cz:Number = Math.cos(roll);
	        var sz:Number = Math.sin(roll);
	
			//rx->ry->rz
			return new Matrix3D(
				cy*cz,	cx*sz-sx*sy*cz,	cx*sy*cz+sx*sz,	0,
				-cy*sz,	sx*sy*sz+cx*cz,	sx*cz-cx*sy*sz,	0,
				-sy,	-sx*cy,			cx*cy,			0,
				0,			0,			0,				1);
		}

		public static function createRotateVec(degrees:Number3D):Matrix3D
		{
			return createRotate(degrees.x, degrees.y, degrees.z);
		}
		public static function createRotate(degreesX:Number, degreesY:Number, degreesZ:Number):Matrix3D
		{
			var pitch:Number = degreesX * Maff.DEG_TO_RAD;
			var yaw:Number = degreesY * Maff.DEG_TO_RAD;
			var roll:Number = degreesZ * Maff.DEG_TO_RAD;
			
	        var cx:Number = Math.cos(pitch);
	        var sx:Number = Math.sin(pitch);
	        var cy:Number = Math.cos(yaw);
	        var sy:Number = Math.sin(yaw);
	        var cz:Number = Math.cos(roll);
	        var sz:Number = Math.sin(roll);
	
			//rx->ry->rz
			return new Matrix3D(
				cy*cz,	cx*sz-sx*sy*cz,	cx*sy*cz+sx*sz,	0,
				-cy*sz,	sx*sy*sz+cx*cz,	sx*cz-cx*sy*sz,	0,
				-sy,	-sx*cy,			cx*cy,			0,
				0,			0,			0,				1);
		}
		
		public static function decomposeTransform(transform:Matrix3D, position:Number3D, orientation:Number3D, scale:Number3D):void
		{
			decomposeElementsToRadians(
				transform.n11, transform.n12, transform.n13, transform.n14,
				transform.n21, transform.n22, transform.n23, transform.n24,
				transform.n31, transform.n32, transform.n33, transform.n34, 
				position, orientation, scale);
			
			if (orientation != null)
			{
				orientation.x *= Maff.RAD_TO_DEG;
				orientation.y *= Maff.RAD_TO_DEG;
				orientation.z *= Maff.RAD_TO_DEG;
			}
		}
		public static function decomposeTransformToRadians(transform:Matrix3D, position:Number3D, orientationRadians:Number3D, scale:Number3D):void
		{
			if (transform.isIdentity)
			{
				position.assign(0, 0, 0);
				orientationRadians.assign(0, 0, 0);
				scale.assign(1, 1, 1);
			}
			else
			{
				decomposeElementsToRadians(
					transform.n11, transform.n12, transform.n13, transform.n14,
					transform.n21, transform.n22, transform.n23, transform.n24,
					transform.n31, transform.n32, transform.n33, transform.n34,
					position, orientationRadians, scale);
			}
		}
		public static function decomposeElements(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			position:Number3D, orientation:Number3D, scale:Number3D):void
		{
			decomposeElementsToRadians(
				n11, n12, n13, n14,
				n21, n22, n23, n24,
				n31, n32, n33, n34,
				position, orientation, scale);
				
			orientation.x *= Maff.RAD_TO_DEG;
			orientation.y *= Maff.RAD_TO_DEG;
			orientation.z *= Maff.RAD_TO_DEG;
		}
		
		private static var tmpData_:Vector.<Number> = new Vector.<Number>(16, true);
		private static var tmpMat_:flash.geom.Matrix3D = new flash.geom.Matrix3D(tmpData_); 
		public static function decomposeElementsToRadians(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			position:Number3D, orientationRadians:Number3D, scale:Number3D):void
		{
			//tmpData_[e11] = n11; tmpData_[e21] = n21; tmpData_[e31] = n31; tmpData_[e41] = 0; 
			//tmpData_[e12] = n12; tmpData_[e22] = n22; tmpData_[e32] = n32; tmpData_[e42] = 0;
			//tmpData_[e13] = n13; tmpData_[e23] = n23; tmpData_[e33] = n33; tmpData_[e43] = 0;
			//tmpData_[e14] = n14; tmpData_[e24] = n24; tmpData_[e34] = n34; tmpData_[e44] = 1;
			//tmpMat_.rawData = tmpData_; 
			//var decomp:Vector.<Vector3D> = tmpMat_.decompose();
			//if (position != null)
			//	position.impl_ = decomp[0];
			//if (orientationRadians != null)
			//	orientationRadians.impl_ = decomp[1];
			//if (scale != null)
			//	scale.impl_ = decomp[2];
			
			///*
			var sx:Number = new Number3D(n11, n21, n31).length;
			var sy:Number = new Number3D(n12, n22, n32).length;
			var sz:Number = new Number3D(n13, n23, n33).length;

			if (scale != null)
			{
	    		var det:Number = (n11 * n22 - n21 * n12) * n33 - (n11 * n32 - n31 * n12) * n23 + (n21 * n32 - n31 * n22) * n13;
				scale.x = det < 0 ? -sx : sx;
				scale.y = sy;
				scale.z = sz;
			}
			
			if (orientationRadians != null)
			{
				var iX:Number = 1 / sx;
				var iY:Number = 1 / sy;
				
				n31 *= iX;
				if (n31 > 0.998)
				{
					n12 *= iY;
					n22 *= iY;
					
					orientationRadians.x = 0;
					orientationRadians.y = -Maff.HALF_PI;
					orientationRadians.z = Math.atan2(n12, n22);
				}
				else if (n31 < -0.998)
				{
					n12 *= iY;
					n22 *= iY;
					
					orientationRadians.x = 0;
					orientationRadians.y = Maff.HALF_PI;
					orientationRadians.z = Math.atan2(n12, n22);
				}
				else
				{
					var iZ:Number = 1 / sz;
					
					n11 *= iX;
					n21 *= iX;
					n32 *= iY;
					n33 *= iZ;
					
					orientationRadians.x = Math.atan2(-n32, n33);
					orientationRadians.y = Math.asin(-n31);
					orientationRadians.z = Math.atan2(-n21, n11); 			
				}
			}
			
			if (position != null)
			{
				position.x = n14;
				position.y = n24;
				position.z = n34;
			}
		}
	
		public function transpose():void
		{
			if (!isIdentity)
			{
				var tmp:Number;
				tmp = n21; n21 = n12; n12 = tmp;
				tmp = n31; n31 = n13; n13 = tmp;
				tmp = n32; n32 = n23; n23 = tmp;
				//tmp = n41; n41 = n14; n14 = tmp;
				//tmp = n42; n42 = n24; n24 = tmp;
				//tmp = n43; n43 = n34; n34 = tmp;
			}
		}
		
		private var rawDataTmp:Vector.<Number> = new Vector.<Number>(16, true);
		public function rawData():Vector.<Number>
		{
			rawDataTmp[e11] = n11;
			rawDataTmp[e21] = n21;
			rawDataTmp[e31] = n31;
			rawDataTmp[e41] = 0;
			rawDataTmp[e12] = n12;
			rawDataTmp[e22] = n22;
			rawDataTmp[e32] = n32;
			rawDataTmp[e42] = 0;
			rawDataTmp[e13] = n13;
			rawDataTmp[e23] = n23;
			rawDataTmp[e33] = n33;
			rawDataTmp[e43] = 0;
			rawDataTmp[e14] = n14;
			rawDataTmp[e24] = n24;
			rawDataTmp[e34] = n34;
			rawDataTmp[e44] = 1;
			return rawDataTmp;
		}
	
		public static const STATIC_IDENTITY:Matrix3D = new Matrix3D(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, true);
	
		public static function get IDENTITY():Matrix3D
		{
			return new Matrix3D(
				1, 0, 0, 0, 
				0, 1, 0, 0, 
				0, 0, 1, 0, 
				0, 0, 0, 1, true);
		}
		
		public function append(m:Matrix3D):void
		{
			if (m.isIdentity)
				return;
			else if (this.isIdentity)
				assign(m);
			else
			{
				var a:Matrix3D = this;
				var m11:Number = a.n11 * m.n11 + a.n12 * m.n21 + a.n13 * m.n31 + a.n14 * m.n41;
				var m12:Number = a.n11 * m.n12 + a.n12 * m.n22 + a.n13 * m.n32 + a.n14 * m.n42;
				var m13:Number = a.n11 * m.n13 + a.n12 * m.n23 + a.n13 * m.n33 + a.n14 * m.n43;
				var m14:Number = a.n11 * m.n14 + a.n12 * m.n24 + a.n13 * m.n34 + a.n14 * m.n44;
				var m21:Number = a.n21 * m.n11 + a.n22 * m.n21 + a.n23 * m.n31 + a.n24 * m.n41;
				var m22:Number = a.n21 * m.n12 + a.n22 * m.n22 + a.n23 * m.n32 + a.n24 * m.n42;
				var m23:Number = a.n21 * m.n13 + a.n22 * m.n23 + a.n23 * m.n33 + a.n24 * m.n43;
				var m24:Number = a.n21 * m.n14 + a.n22 * m.n24 + a.n23 * m.n34 + a.n24 * m.n44;
				var m31:Number = a.n31 * m.n11 + a.n32 * m.n21 + a.n33 * m.n31 + a.n34 * m.n41;
				var m32:Number = a.n31 * m.n12 + a.n32 * m.n22 + a.n33 * m.n32 + a.n34 * m.n42;
				var m33:Number = a.n31 * m.n13 + a.n32 * m.n23 + a.n33 * m.n33 + a.n34 * m.n43;
				var m34:Number = a.n31 * m.n14 + a.n32 * m.n24 + a.n33 * m.n34 + a.n34 * m.n44;
				var m41:Number = a.n41 * m.n11 + a.n42 * m.n21 + a.n43 * m.n31 + a.n44 * m.n41;
				var m42:Number = a.n41 * m.n12 + a.n42 * m.n22 + a.n43 * m.n32 + a.n44 * m.n42;
				var m43:Number = a.n41 * m.n13 + a.n42 * m.n23 + a.n43 * m.n33 + a.n44 * m.n43;
				var m44:Number = a.n41 * m.n14 + a.n42 * m.n24 + a.n43 * m.n34 + a.n44 * m.n44;
				
				n11 = m11; n12 = m12; n13 = m13; n14 = m14;
				n21 = m21; n22 = m22; n23 = m23; n24 = m24;
				n31 = m31; n32 = m32; n33 = m33; n34 = m34;
				n41 = m41; n42 = m42; n43 = m43; n44 = m44;
				
				isIdentity = false;
			}
		}

		public function prepend(a:Matrix3D):void
		{
			if (a.isIdentity)
				return;
			else if (this.isIdentity)
				assign(a);
			else
			{
				var m:Matrix3D = this;
				var m11:Number = a.n11 * m.n11 + a.n12 * m.n21 + a.n13 * m.n31 + a.n14 * m.n41;
				var m12:Number = a.n11 * m.n12 + a.n12 * m.n22 + a.n13 * m.n32 + a.n14 * m.n42;
				var m13:Number = a.n11 * m.n13 + a.n12 * m.n23 + a.n13 * m.n33 + a.n14 * m.n43;
				var m14:Number = a.n11 * m.n14 + a.n12 * m.n24 + a.n13 * m.n34 + a.n14 * m.n44;
				var m21:Number = a.n21 * m.n11 + a.n22 * m.n21 + a.n23 * m.n31 + a.n24 * m.n41;
				var m22:Number = a.n21 * m.n12 + a.n22 * m.n22 + a.n23 * m.n32 + a.n24 * m.n42;
				var m23:Number = a.n21 * m.n13 + a.n22 * m.n23 + a.n23 * m.n33 + a.n24 * m.n43;
				var m24:Number = a.n21 * m.n14 + a.n22 * m.n24 + a.n23 * m.n34 + a.n24 * m.n44;
				var m31:Number = a.n31 * m.n11 + a.n32 * m.n21 + a.n33 * m.n31 + a.n34 * m.n41;
				var m32:Number = a.n31 * m.n12 + a.n32 * m.n22 + a.n33 * m.n32 + a.n34 * m.n42;
				var m33:Number = a.n31 * m.n13 + a.n32 * m.n23 + a.n33 * m.n33 + a.n34 * m.n43;
				var m34:Number = a.n31 * m.n14 + a.n32 * m.n24 + a.n33 * m.n34 + a.n34 * m.n44;
				var m41:Number = a.n41 * m.n11 + a.n42 * m.n21 + a.n43 * m.n31 + a.n44 * m.n41;
				var m42:Number = a.n41 * m.n12 + a.n42 * m.n22 + a.n43 * m.n32 + a.n44 * m.n42;
				var m43:Number = a.n41 * m.n13 + a.n42 * m.n23 + a.n43 * m.n33 + a.n44 * m.n43;
				var m44:Number = a.n41 * m.n14 + a.n42 * m.n24 + a.n43 * m.n34 + a.n44 * m.n44;
				
				n11 = m11; n12 = m12; n13 = m13; n14 = m14;
				n21 = m21; n22 = m22; n23 = m23; n24 = m24;
				n31 = m31; n32 = m32; n33 = m33; n34 = m34;
				n41 = m41; n42 = m42; n43 = m43; n44 = m44;
				
				isIdentity = false;
			}
		}

		public function mulMat(b:Matrix3D):void
		{
			if (b.isIdentity)
				return;
			else if (this.isIdentity)
				assign(b);
			else
			{
				var a11:Number = this.n11; var b11:Number = b.n11;
				var a21:Number = this.n21; var b21:Number = b.n21;
				var a31:Number = this.n31; var b31:Number = b.n31;
				
				var a12:Number = this.n12; var b12:Number = b.n12;
				var a22:Number = this.n22; var b22:Number = b.n22;
				var a32:Number = this.n32; var b32:Number = b.n32;
				
				var a13:Number = this.n13; var b13:Number = b.n13;
				var a23:Number = this.n23; var b23:Number = b.n23;
				var a33:Number = this.n33; var b33:Number = b.n33;
				
				var a14:Number = this.n14; var b14:Number = b.n14;
				var a24:Number = this.n24; var b24:Number = b.n24;
				var a34:Number = this.n34; var b34:Number = b.n34;
		
				this.n11 = a11 * b11 + a12 * b21 + a13 * b31;
				this.n12 = a11 * b12 + a12 * b22 + a13 * b32;
				this.n13 = a11 * b13 + a12 * b23 + a13 * b33;
				this.n14 = a11 * b14 + a12 * b24 + a13 * b34 + a14;
		
				this.n21 = a21 * b11 + a22 * b21 + a23 * b31;
				this.n22 = a21 * b12 + a22 * b22 + a23 * b32;
				this.n23 = a21 * b13 + a22 * b23 + a23 * b33;
				this.n24 = a21 * b14 + a22 * b24 + a23 * b34 + a24;
		
				this.n31 = a31 * b11 + a32 * b21 + a33 * b31;
				this.n32 = a31 * b12 + a32 * b22 + a33 * b32;
				this.n33 = a31 * b13 + a32 * b23 + a33 * b33;
				this.n34 = a31 * b14 + a32 * b24 + a33 * b34 + a34;
				this.isIdentity = false;
			}
		}
		
		public function fullInverse():Matrix3D
		{
			if (isIdentity)
				return clone();
			else
			{
				var det:Number = n14 * n23 * n32 * n41 - n13 * n24 * n32 * n41 - n14 * n22 * n33 * n41 + n12 * n24 * n33 * n41 +
					n13 * n22 * n34 * n41 - n12 * n23 * n34 * n41 - n14 * n23 * n31 * n42 + n13 * n24 * n31 * n42 +
					n14 * n21 * n33 * n42 - n11 * n24 * n33 * n42 - n13 * n21 * n34 * n42 + n11 * n23 * n34 * n42 +
					n14 * n22 * n31 * n43 - n12 * n24 * n31 * n43 - n14 * n21 * n32 * n43 + n11 * n24 * n32 * n43 +
					n12 * n21 * n34 * n43 - n11 * n22 * n34 * n43 - n13 * n22 * n31 * n44 + n12 * n23 * n31 * n44 +
					n13 * n21 * n32 * n44 - n11 * n23 * n32 * n44 - n12 * n21 * n33 * n44 + n11 * n22 * n33 * n44;
				var invDet:Number = det == 1 ? 1 : 1 / det;
				
				return new Matrix3D(
					(n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44) * invDet,
					(n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44) * invDet,
					(n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44) * invDet,
					(n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34) * invDet,
					(n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * invDet,
					(n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * invDet,
					(n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * invDet,
					(n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * invDet,
					(n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * invDet,
					(n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * invDet,
					(n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * invDet,
					(n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * invDet,
					(n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * invDet,
					(n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * invDet,
					(n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * invDet,
					(n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * invDet);
			}
		}
		public function inverse():Matrix3D
		{
			if (isIdentity)
				return clone();
			else
			{
		    	var det:Number = 
		    		(this.n11 * this.n22 - this.n21 * this.n12) * this.n33 - 
		    		(this.n11 * this.n32 - this.n31 * this.n12) * this.n23 +
					(this.n21 * this.n32 - this.n31 * this.n22) * this.n13;
				var invDet:Number = det == 1 ? 1 : 1 / det;
				
				var m11:Number = n11; var m21:Number = n21; var m31:Number = n31;
				var m12:Number = n12; var m22:Number = n22; var m32:Number = n32;
				var m13:Number = n13; var m23:Number = n23; var m33:Number = n33;
				var m14:Number = n14; var m24:Number = n24; var m34:Number = n34;
		
				return new Matrix3D(
					 invDet * ( m22 * m33 - m32 * m23 ),
					-invDet * ( m12 * m33 - m32 * m13 ),
					 invDet * ( m12 * m23 - m22 * m13 ),
					-invDet * ( m12 * (m23*m34 - m33*m24) - m22 * (m13*m34 - m33*m14) + m32 * (m13*m24 - m23*m14) ),
		
					-invDet * ( m21 * m33 - m31 * m23 ),
					 invDet * ( m11 * m33 - m31 * m13 ),
					-invDet* ( m11 * m23 - m21 * m13 ),
					 invDet * ( m11 * (m23*m34 - m33*m24) - m21 * (m13*m34 - m33*m14) + m31 * (m13*m24 - m23*m14) ),
		
					 invDet * ( m21 * m32 - m31 * m22 ),
					-invDet* ( m11 * m32 - m31 * m12 ),
					 invDet * ( m11 * m22 - m21 * m12 ),
					-invDet* ( m11 * (m22*m34 - m32*m24) - m21 * (m12*m34 - m32*m14) + m31 * (m12*m24 - m22*m14) ),
					0, 0, 0, 1);
			}
		}

		public function assignElements(
			_11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
			_21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
			_31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
			_41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false):void
		{
			this.n11 = _11, this.n12 = _12, this.n13 = _13, this.n14 = _14,
			this.n21 = _21, this.n22 = _22, this.n23 = _23, this.n24 = _24,
			this.n31 = _31, this.n32 = _32, this.n33 = _33, this.n34 = _34;
			this.n41 = _41, this.n42 = _42, this.n43 = _43, this.n44 = _44;
			this.isIdentity = isIdentity;
		}

		public function assign(m:Matrix3D):void
		{
			if (m.isIdentity && isIdentity)
				return;
				
			this.n11 = m.n11; this.n12 = m.n12; this.n13 = m.n13; this.n14 = m.n14;
			this.n21 = m.n21; this.n22 = m.n22; this.n23 = m.n23; this.n24 = m.n24;
			this.n31 = m.n31; this.n32 = m.n32; this.n33 = m.n33; this.n34 = m.n34;
			this.n41 = m.n41, this.n42 = m.n42, this.n43 = m.n43, this.n44 = m.n44;
			this.isIdentity = m.isIdentity;
		}

		public static function clone( m:Matrix3D ):Matrix3D
		{
			return new Matrix3D
			(
				m.n11, m.n12, m.n13, m.n13,
				m.n21, m.n22, m.n23, m.n24,
				m.n31, m.n32, m.n33, m.n34,
				0, 0, 0, 1, m.isIdentity
			);
		}
		
		public function mulMatMat(a:Matrix3D, b:Matrix3D):void
		{
			if (a.isIdentity && b.isIdentity)
			{
				assign(STATIC_IDENTITY);
				isIdentity = true;
			}
			else if (a.isIdentity)
			{
				assign(b);
				isIdentity = false;
			}
			else if (b.isIdentity)
			{
				assign(a);
				isIdentity = false;
			}
			else
			{
				n11 = a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31,
				n12 = a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32,
				n13 = a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33,
				n14 = a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14,
				n21 = a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31,
				n22 = a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32,
				n23 = a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33,
				n24 = a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24,
				n31 = a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31,
				n32 = a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32,
				n33 = a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33,
				n34 = a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34;
				isIdentity = false;

			}
		}
		public static function mulMatVec(m:Matrix3D, v:Number3D):void
		{
			if (!m.isIdentity)
			{
				var x:Number = v.x;
				var y:Number = v.y;
				var z:Number = v.z;
				
				v.x = x * m.n11 + y * m.n12 + z * m.n13 + m.n14;
				v.y = x * m.n21 + y * m.n22 + z * m.n23 + m.n24;
				v.z = x * m.n31 + y * m.n32 + z * m.n33 + m.n34;
			}
		}
		public static function fullMulMatVec(m:Matrix3D, v:Number3D):void
		{
			if (!m.isIdentity)
			{
				var x:Number = v.x;
				var y:Number = v.y;
				var z:Number = v.z;
				var w:Number = v.w;
				
				v.x = x * m.n11 + y * m.n12 + z * m.n13 + w * m.n14;
				v.y = x * m.n21 + y * m.n22 + z * m.n23 + w * m.n24;
				v.z = x * m.n31 + y * m.n32 + z * m.n33 + w * m.n34;
				v.w = x * m.n41 + y * m.n42 + z * m.n43 + w * m.n44;
			}
		}
		public static function mulMatVecWithWDivide(m:Matrix3D, v:Number3D):void
		{
			if (!m.isIdentity)
			{
				var x:Number = v.x;
				var y:Number = v.y;
				var z:Number = v.z;
				
				var invW:Number = 1.0 / (v.x*m.n41 + v.y*m.n42 + v.z*m.n43 + m.n44);
				v.x = (x * m.n11 + y * m.n12 + z * m.n13 + m.n14) * invW;
				v.y = (x * m.n21 + y * m.n22 + z * m.n23 + m.n24) * invW;
				v.z = (x * m.n31 + y * m.n32 + z * m.n33 + m.n34) * invW;
			}
		}
		public static function fullMulMatVecWithWDivide(m:Matrix3D, v:Number3D):void
		{
			if (!m.isIdentity)
			{
				var x:Number = v.x;
				var y:Number = v.y;
				var z:Number = v.z;
				var w:Number = v.w;
				
				var invW:Number = 1.0 / (x * m.n41 + y * m.n42 + z * m .n43 + w * m.n44);
				v.x = (x * m.n11 + y * m.n12 + z * m.n13 + w * m.n14) * invW;
				v.y = (x * m.n21 + y * m.n22 + z * m.n23 + w * m.n24) * invW;
				v.z = (x * m.n31 + y * m.n32 + z * m.n33 + w * m.n34) * invW;
			}
		}
		public static function mulMatVecCopy(m:Matrix3D, v:Number3D):Number3D
		{
			if (m.isIdentity)
				return new Number3D(v.x, v.y, v.z);
			else
			{
				return new Number3D(
					v.x * m.n11 + v.y * m.n12 + v.z * m.n13 + m.n14,
					v.x * m.n21 + v.y * m.n22 + v.z * m.n23 + m.n24,
					v.x * m.n31 + v.y * m.n32 + v.z * m.n33 + m.n34);
			}
		}
		public static function mulMatVecCopyWithWDivide(m:Matrix3D, v:Number3D):Number3D
		{
			var invW:Number = 1.0 / (v.x*m.n41 + v.y*m.n42 + v.z*m.n43 + m.n44);
			return new Number3D(
				(v.x*m.n11 + v.y*m.n12 + v.z*m.n13 + m.n14)*invW,
				(v.x*m.n21 + v.y*m.n22 + v.z*m.n23 + m.n24)*invW,
				(v.x*m.n31 + v.y*m.n32 + v.z*m.n33 + m.n34)*invW);
		}
		public function mulMatMatFull(a:Matrix3D, b:Matrix3D):void
		{
			n11 = a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31 + a.n14 * b.n41;
			n12 = a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32 + a.n14 * b.n42;
			n13 = a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33 + a.n14 * b.n43;
			n14 = a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14 * b.n44;
			n21 = a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31 + a.n24 * b.n41;
			n22 = a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32 + a.n24 * b.n42;
			n23 = a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33 + a.n24 * b.n43;
			n24 = a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24 * b.n44;
			n31 = a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31 + a.n34 * b.n41;
			n32 = a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32 + a.n34 * b.n42;
			n33 = a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33 + a.n34 * b.n43;
			n34 = a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34 * b.n44;
			n41 = a.n41 * b.n11 + a.n42 * b.n21 + a.n43 * b.n31 + a.n44 * b.n41;
			n42 = a.n41 * b.n12 + a.n42 * b.n22 + a.n43 * b.n32 + a.n44 * b.n42;
			n43 = a.n41 * b.n13 + a.n42 * b.n23 + a.n43 * b.n33 + a.n44 * b.n43;
			n44 = a.n41 * b.n14 + a.n42 * b.n24 + a.n43 * b.n34 + a.n44 * b.n44;
		}
		public static function mulMatMatCopy(a:Matrix3D, b:Matrix3D):Matrix3D
		{
			if (a.isIdentity && b.isIdentity)
				return IDENTITY;
			else if (a.isIdentity)
				return b.clone();
			else if (b.isIdentity)
				return a.clone();
			else
			{
				return new Matrix3D(
					a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31,
					a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32,
					a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33,
					a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14,
					a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31,
					a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32,
					a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33,
					a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24,
					a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31,
					a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32,
					a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33,
					a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34,
					0, 0, 0, 1);
			}
		}
		
		public function toString():String
		{
			//var rd:Function = function(n:Number):Number{ return int(n*1000)*.001; }
			var rd:Function = function(n:Number):Number{ return n; };
			return '{{' + rd(n11) + ' ' + rd(n12) + ' ' + rd(n13) + ' ' + rd(n14) + '}{' + rd(n21) + ' ' + rd(n22) + ' ' + rd(n23) + ' ' + rd(n24) + '}{' + rd(n31) + ' ' + rd(n32) + ' ' + rd(n33) + ' ' + rd(n34) + '}}';
		}

		private var arrayBuffer_:Array;
		public function toArray():Array
		{
			if (arrayBuffer_ == null)
				arrayBuffer_ = [n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, 0, 0, 0, 1];
			else
			{
				arrayBuffer_[0] = n11; 
				arrayBuffer_[1] = n12; 
				arrayBuffer_[2] = n13;
				arrayBuffer_[3] = n14;
				arrayBuffer_[4] = n21; 
				arrayBuffer_[5] = n22; 
				arrayBuffer_[6] = n23; 
				arrayBuffer_[7] = n24,
				arrayBuffer_[8] = n31; 
				arrayBuffer_[9] = n32; 
				arrayBuffer_[10] = n33; 
				arrayBuffer_[11] = n34;
			}
			
			return arrayBuffer_;
		}
		
		public static function interpolate(target:Matrix3D, src:Matrix3D, des:Matrix3D, percent:Number):Matrix3D
		{
			target.assignElements(
					src.n11 + percent * (des.n11 - src.n11),
					src.n12 + percent * (des.n12 - src.n12),
					src.n13 + percent * (des.n13 - src.n13),
					src.n14 + percent * (des.n14 - src.n14),
					src.n21 + percent * (des.n21 - src.n21),
					src.n22 + percent * (des.n22 - src.n22),
					src.n23 + percent * (des.n23 - src.n23),
					src.n24 + percent * (des.n24 - src.n24),
					src.n31 + percent * (des.n31 - src.n31),
					src.n32 + percent * (des.n32 - src.n32),
					src.n33 + percent * (des.n33 - src.n33),
					src.n34 + percent * (des.n34 - src.n34),
					0, 0, 0, 1);
			return target;
		}
	}
}
//*/
/*
package com.oddcast.oc3d.shared
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	

	public class Matrix3D
	{
		public var impl_:flash.geom.Matrix3D;
		
		public static const e11:Number = 0;
		public static const e21:Number = 1;
		public static const e31:Number = 2;
		public static const e41:Number = 3;
		public static const e12:Number = 4;
		public static const e22:Number = 5;
		public static const e32:Number = 6;
		public static const e42:Number = 7;
		public static const e13:Number = 8;
		public static const e23:Number = 9;
		public static const e33:Number = 10;
		public static const e43:Number = 11;
		public static const e14:Number = 12;
		public static const e24:Number = 13;
		public static const e34:Number = 14;
		public static const e44:Number = 15;
		
		public var isIdentity:Boolean;

		public function Matrix3D(
			_11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
			_21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
			_31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
			_41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false)
		{
			var data:Vector.<Number> = new Vector.<Number>();
			data[e11] = _11;
			data[e21] = _21;
			data[e31] = _31;
			data[e41] = _41;
			data[e12] = _12;
			data[e22] = _22;
			data[e32] = _32;
			data[e42] = _42;
			data[e13] = _13;
			data[e23] = _23;
			data[e33] = _33;
			data[e43] = _43;
			data[e14] = _14;
			data[e24] = _24;
			data[e34] = _34;
			data[e44] = _44;
			
			impl_ = new flash.geom.Matrix3D(data);
			
			this.isIdentity = isIdentity;
		}
		
		public function get debug():String
		{
			return "{pos:" + debug__Position.toString() + ", ori:" + debug__Orientation.toString() + ", scl:" + debug__Scale.toString() + "}";
		}
		public function get debug__Position():Number3D
		{
			var pos:Number3D;
			decomposeTransformToRadians(this, pos, null, null);
			return pos;
		}
		public function get debug__Orientation():Number3D
		{
			var ori:Number3D;
			decomposeTransform(this, null, ori, null);
			return ori;
		}
		public function get debug__Scale():Number3D
		{
			var scl:Number3D;
			decomposeTransformToRadians(this, null, null, scl);
			return scl;
		}
		
		public function clone():Matrix3D
		{
			var data:Vector.<Number> = impl_.rawData;
			return new Matrix3D(
				data[e11], data[e12], data[e13], data[e14],
				data[e21], data[e22], data[e23], data[e24],
				data[e31], data[e32], data[e33], data[e34],
				data[e41], data[e42], data[e43], data[e44], isIdentity);
		}
		
		public static function createFromArray(array:Array):Matrix3D
		{
			var a:Array = [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1];
			for (var i:int=0; i<Math.min(array.length,a.length); ++i)
				a[i] = array[i];
				
			return new Matrix3D(
				a[ 0], a[ 1], a[ 2], a[ 3],
				a[ 4], a[ 5], a[ 6], a[ 7],
				a[ 8], a[ 9], a[10], a[11],
				a[12], a[13], a[14], a[15]);
		}
		
		public function identity():void
		{
			impl_.identity();
			isIdentity = true;
		}
		
		public function translateBy(x:Number, y:Number, z:Number):void
		{
			var pos:Vector3D = impl_.position;
			pos.x += x;
			pos.y += y;
			pos.z += z;
			impl_.position = pos; 
			isIdentity = false;
		}
		
		public function translateTo(x:Number, y:Number, z:Number):void
		{
			var pos:Vector3D = new Vector3D(x, y, z);
			impl_.position = pos;
			isIdentity = false;
		}
		
		public function transformInRadians(position:Number3D, orientationInRadians:Number3D, scale:Number3D):void
		{
			impl_.identity();
			impl_.prependTranslation(position.x, position.y, position.z);
			impl_.prependRotation(-orientationInRadians.z*Maff.RAD_TO_DEG, new Vector3D(0,0,1));
			impl_.prependRotation( orientationInRadians.y*Maff.RAD_TO_DEG, new Vector3D(0,1,0));
			impl_.prependRotation(-orientationInRadians.x*Maff.RAD_TO_DEG, new Vector3D(1,0,0));
			impl_.prependScale(scale.x, scale.y, scale.z);
			isIdentity = false;
		}

		public static function createTranslate(x:Number, y:Number, z:Number):Matrix3D
		{
			var result:Matrix3D = new Matrix3D();
			result.impl_.identity();
			result.impl_.prependTranslation(x, y, z);
			return result;
		}

		public static function createScale(xScale:Number, yScale:Number, zScale:Number):Matrix3D
		{
			var result:Matrix3D = new Matrix3D();
			result.impl_.identity();
			result.impl_.prependScale(xScale, yScale, zScale);
			return result;
		}

		public static function createRotateAngleAxis(x:Number, y:Number, z:Number, degrees:Number):Matrix3D
		{
			return createRotateAngleAxisWithRadians(x, y, z, Maff.DEG_TO_RAD * degrees);
		}
		public static function createRotateAngleAxisWithRadians(x:Number, y:Number, z:Number, radians:Number):Matrix3D
		{
			var result:Matrix3D = new Matrix3D();
			result.impl_.identity();
			result.impl_.prependRotation(radians*Maff.RAD_TO_DEG, new Vector3D(x, y, z));
			return result;
		}
		public static function createRotateVecWithRadians(radians:Number3D):Matrix3D
		{
			return createRotateWithRadians(radians.x, radians.y, radians.z);
		}
		public static function createRotateWithRadians(radiansX:Number, radiansY:Number, radiansZ:Number):Matrix3D
		{
			var result:Matrix3D = new Matrix3D();
			result.impl_.identity();
			result.impl_.prependRotation(-radiansZ*Maff.RAD_TO_DEG, new Vector3D(0, 0, 1));
			result.impl_.prependRotation( radiansY*Maff.RAD_TO_DEG, new Vector3D(0, 1, 0));
			result.impl_.prependRotation(-radiansX*Maff.RAD_TO_DEG, new Vector3D(1, 0, 0));
			return result;
		}

		public static function createRotateVec(degrees:Number3D):Matrix3D
		{
			return createRotate(degrees.x, degrees.y, degrees.z);
		}
		public static function createRotate(degreesX:Number, degreesY:Number, degreesZ:Number):Matrix3D
		{
			return createRotateWithRadians(degreesX*Maff.DEG_TO_RAD, degreesY*Maff.DEG_TO_RAD, degreesZ*Maff.DEG_TO_RAD);
		}
		
		public static function decomposeTransform(transform:Matrix3D, position:Number3D, orientation:Number3D, scale:Number3D):void
		{
			decomposeTransformToRadians(transform, position, orientation, scale);
			
			if (orientation != null)
			{
				orientation.x *= Maff.RAD_TO_DEG;
				orientation.y *= Maff.RAD_TO_DEG;
				orientation.z *= Maff.RAD_TO_DEG;
			}
		}
		public static function decomposeTransformToRadians(transform:Matrix3D, position:Number3D, orientationRadians:Number3D, scale:Number3D):void
		{
			if (transform.isIdentity)
			{
				if (position != null)
					position.assign(0, 0, 0);
				if (orientationRadians != null)
					orientationRadians.assign(0, 0, 0);
				if (scale != null)
					scale.assign(1, 1, 1);
			}
			else
			{
				var data:Vector.<Number> = transform.impl_.rawData;
				
				decomposeElementsToRadians(
					data[e11], data[e12], data[e13], data[e14],
					data[e21], data[e22], data[e23], data[e24],
					data[e31], data[e32], data[e33], data[e34],
					data[e41], data[e42], data[e43], data[e44], 
					position, orientationRadians, scale);
			}
		}
		
		public static function decomposeElements(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			n41:Number, n42:Number, n43:Number, n44:Number,
			position:Number3D, orientation:Number3D, scale:Number3D):void
		{
			decomposeElementsToRadians(
				n11, n12, n13, n14,
				n21, n22, n23, n24,
				n31, n32, n33, n34,
				n41, n42, n43, n44,
				position, orientation, scale);
				
			orientation.x *= Maff.RAD_TO_DEG;
			orientation.y *= Maff.RAD_TO_DEG;
			orientation.z *= Maff.RAD_TO_DEG;
		}
		public static function decomposeElementsToRadians(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			n41:Number, n42:Number, n43:Number, n44:Number,
			position:Number3D, orientationRadians:Number3D, scale:Number3D):void
		{
			var data:Vector.<Number> = new Vector.<Number>(16, true);
			data[e11] = n11; data[e21] = n21; data[e31] = n31; data[e41] = n41; 
			data[e12] = n12; data[e22] = n22; data[e32] = n32; data[e42] = n42;
			data[e13] = n13; data[e23] = n23; data[e33] = n33; data[e43] = n43;
			data[e14] = n14; data[e24] = n24; data[e34] = n34; data[e44] = n44;
			var decomp:Vector.<Vector3D> = (new flash.geom.Matrix3D(data)).decompose();
			if (position != null)
				position.impl_ = decomp[0];
			if (orientationRadians != null)
				orientationRadians.impl_ = decomp[1];
			if (scale != null)
				scale.impl_ = decomp[2];
		}
	
		public function transpose():void
		{
			if (!isIdentity)
				impl_.transpose();
		}
	
		public static const STATIC_IDENTITY:Matrix3D = new Matrix3D(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, true);
	
		public static function get IDENTITY():Matrix3D
		{
			return new Matrix3D(
				1, 0, 0, 0, 
				0, 1, 0, 0, 
				0, 0, 1, 0, 
				0, 0, 0, 1, true);
		}
		
		public function mulMat(b:Matrix3D):void
		{
			if (b.isIdentity)
				return;
			else if (this.isIdentity)
				assign(b);
			else
			{
				impl_.prepend(b.impl_);
				this.isIdentity = false;
			}
		}
		
		public function determinant():Number
		{
			return -impl_.determinant;
        }
		
		public function inverse():Matrix3D
		{
			if (isIdentity)
				return clone();
			else
			{
				var result:Matrix3D = clone();
				result.impl_.invert();
				return result;
		   }
		}

		public function assignElements(
			_11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
			_21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
			_31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
			_41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false):void
		{
			
			var data:Vector.<Number> = impl_.rawData;
			data[e11] = _11; data[e21] = _21; data[e31] = _31; data[e41] = _41;
			data[e12] = _12; data[e22] = _22; data[e32] = _32; data[e42] = _42;
			data[e13] = _13; data[e23] = _23; data[e33] = _33; data[e43] = _43; 
			data[e14] = _14; data[e24] = _24; data[e34] = _34; data[e44] = _44;
			impl_.rawData = data;
			
			this.isIdentity = isIdentity;
		}
		
		public function assign(m:Matrix3D):void
		{
			if (m.isIdentity && isIdentity)
				return;
			
			impl_.rawData = m.impl_.rawData;

			this.isIdentity = m.isIdentity;
		}

		public static function clone(m:Matrix3D):Matrix3D
		{
			var data:Vector.<Number> = m.impl_.rawData;
			return new Matrix3D
			(
				data[e11], data[e12], data[e13], data[e13],
				data[e21], data[e22], data[e23], data[e24],
				data[e31], data[e32], data[e33], data[e34],
				data[e41], data[e42], data[e43], data[e44], m.isIdentity
			);
		}
		
		public function mulMatMat(a:Matrix3D, b:Matrix3D):void
		{
			if (a.isIdentity && b.isIdentity)
			{
				assign(STATIC_IDENTITY);
				isIdentity = true;
			}
			else if (a.isIdentity)
			{
				assign(b);
				isIdentity = false;
			}
			else if (b.isIdentity)
			{
				assign(a);
				isIdentity = false;
			}
			else
			{
				impl_.rawData = a.impl_.rawData;
				impl_.prepend(b.impl_);
				
				isIdentity = false;
			}
		}
		
		public static function mulMatVec(m:Matrix3D, v:Number3D):void
		{
			if (!m.isIdentity)
				v.impl_ = m.impl_.transformVector(v.impl_);
		}
		
		public static function mulMatVecCopy(m:Matrix3D, v:Number3D):Number3D
		{
			if (m.isIdentity)
				return new Number3D(v.x, v.y, v.z);
			else
			{
				var result:Number3D = new Number3D();
				result.impl_ = m.impl_.transformVector(v.impl_);
				return result;
			}
		}
		
		public static function mulMatMatCopy(a:Matrix3D, b:Matrix3D):Matrix3D
		{
			if (a.isIdentity && b.isIdentity)
				return IDENTITY;
			else if (a.isIdentity)
				return b.clone();
			else if (b.isIdentity)
				return a.clone();
			else
			{
				var result:Matrix3D = clone(a);
				result.impl_.prepend(b.impl_);
				return result;
			}
		}
		
		public function toString():String
		{
			var data:Vector.<Number> = impl_.rawData;
			//var rd:Function = function(n:Number):Number{ return int(n*1000)*.001; }
			var rd:Function = function(n:Number):Number{ return n; };
			return '{{' 
				+ rd(data[e11]) + ' ' + rd(data[e12]) + ' ' + rd(data[e13]) + ' ' + rd(data[e14]) + '}{' 
				+ rd(data[e21]) + ' ' + rd(data[e22]) + ' ' + rd(data[e23]) + ' ' + rd(data[e24]) + '}{' 
				+ rd(data[e31]) + ' ' + rd(data[e32]) + ' ' + rd(data[e33]) + ' ' + rd(data[e34]) + '}{' 
				+ rd(data[e41]) + ' ' + rd(data[e42]) + ' ' + rd(data[e43]) + ' ' + rd(data[e44]) + '}}';
		}
		
		public function rawData():Vector.<Number>
		{
			return impl_.rawData;
		}

		private var arrayBuffer_:Array;
		public function toArray():Array
		{
			var data:Vector.<Number> = impl_.rawData;
			if (arrayBuffer_ == null)
				arrayBuffer_ = 
				[
					data[e11], data[e12], data[e13], data[e14], 
					data[e21], data[e22], data[e23], data[e24], 
					data[e31], data[e32], data[e33], data[e34], 
					data[e41], data[e42], data[e43], data[e44]
				];
			else
			{
				arrayBuffer_[e11] = data[e11]; 
				arrayBuffer_[e21] = data[e12]; 
				arrayBuffer_[e31] = data[e13];
				arrayBuffer_[e41] = data[e14];
				arrayBuffer_[e12] = data[e21]; 
				arrayBuffer_[e22] = data[e22]; 
				arrayBuffer_[e32] = data[e23]; 
				arrayBuffer_[e42] = data[e24],
				arrayBuffer_[e13] = data[e31]; 
				arrayBuffer_[e23] = data[e32]; 
				arrayBuffer_[e33] = data[e33]; 
				arrayBuffer_[e43] = data[e34];
				arrayBuffer_[e14] = data[e41]; 
				arrayBuffer_[e24] = data[e42]; 
				arrayBuffer_[e34] = data[e43]; 
				arrayBuffer_[e44] = data[e44];
			}
			
			return arrayBuffer_;
		}
		
		public static function interpolate(target:Matrix3D, src:Matrix3D, des:Matrix3D, percent:Number):Matrix3D
		{
			target.impl_.rawData = src.impl_.rawData;
			target.impl_.interpolateTo(des.impl_, percent);
			return target;
		}
	}
}
*/