package com.oddcast.oc3d.data
{
	import com.oddcast.oc3d.shared.Maff;
	import com.oddcast.oc3d.shared.Util;
	
	import flash.display.Scene;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	public class ContentUtil
	{
		public static function makeAssociations(pairs:Array):Vector.<ContentAssociationData>
		{
			var result:Vector.<ContentAssociationData> = new Vector.<ContentAssociationData>(pairs.length>>1, true);
			var counter:uint = 0;
			for (var i:uint=0; i<pairs.length; i+=2)
			{
				var assoc:ContentAssociationData = result[counter++] = new ContentAssociationData();
				assoc.ParentId = pairs[i+0];
				assoc.ChildId = pairs[i+1];
			}
			return result;
		}
		
		public static function createMatrixData(
			n11:Number,   n12:Number,   n13:Number,   n14:Number,
			n21:Number,   n22:Number,   n23:Number,   n24:Number,
			n31:Number,   n32:Number,   n33:Number,   n34:Number,
			n41:Number=0, n42:Number=0, n43:Number=0, n44:Number=1):MatrixData
		{
			var m:MatrixData = new MatrixData();
			m.n11 = n11; m.n12 = n12; m.n13 = n13; m.n14 = n14;
			m.n21 = n21; m.n22 = n22; m.n23 = n23; m.n24 = n24;
			m.n31 = n31; m.n32 = n32; m.n33 = n33; m.n34 = n34;
			m.n41 = n41; m.n42 = n42; m.n43 = n43; m.n44 = n44;
			m.flags = 0;
			return m;
		}
		public static function makeNode(name:String, type:uint, parentIndex:int, transform:Array, meshIndex:int):NodeData
		{
			var result:NodeData =  new NodeData();
			result.Name = name
			result.Type = type;
			result.ParentIndex = parentIndex;
			var tf:Array = transform;
			result.Transform = createMatrixData(tf[0], tf[1], tf[2], tf[3], tf[4], tf[5], tf[6], tf[7], tf[8], tf[9], tf[10], tf[11]);
			result.MeshIndex = meshIndex;
			return result;
		}
		public static function makeDeltas(count:uint, vs:Array):Vector.<DeltaEntryData>
		{
			var vi:uint = 0;
			var result:Vector.<DeltaEntryData> = new Vector.<DeltaEntryData>(count, true);
			for (var i:uint=0; i<count; ++i)
			{
				var deltaEntry:DeltaEntryData = result[i] = new DeltaEntryData();
				deltaEntry.VertexIndex = vs[vi++];
				deltaEntry.DeltaX = vs[vi++];
				deltaEntry.DeltaY = vs[vi++];
				deltaEntry.DeltaZ = vs[vi++];
			}
			return result;
		}
		public static function makeVertexBuffer(count:uint, vs:Array):Vector.<Vector3D>
		{
			var vi:uint = 0;
			var result:Vector.<Vector3D> = new Vector.<Vector3D>(count, true);
			for (var i:uint=0; i<count; ++i)
				result[i] = new Vector3D(vs[vi++], vs[vi++], vs[vi++]);
			return result;
		}
		public static function makeUVSetBuffer(count:uint, vs:Array):Vector.<UVData>
		{
			var vi:uint = 0;
			var result:Vector.<UVData> = new Vector.<UVData>(count, true);
			for (var i:uint=0; i<count; ++i)
			{
				var uv:UVData = result[i] = new UVData();
				uv.u = vs[vi++];
				uv.v = vs[vi++];
			}
			return result;
		}
		public static function makeTriangleBuffer(count:uint, vs:Array):Vector.<TriangleData>
		{
			var vi:uint = 0;
			var result:Vector.<TriangleData> = new Vector.<TriangleData>(count, true);
			for (var i:uint=0; i<count; ++i)
			{
				var tri:TriangleData = result[i] = new TriangleData();
				tri.VertexIndex0 = vs[vi++];
				tri.VertexIndex1 = vs[vi++];
				tri.VertexIndex2 = vs[vi++];
				tri.UVIndex0 = vs[vi++];
				tri.UVIndex1 = vs[vi++];
				tri.UVIndex2 = vs[vi++];
				tri.MaterialIndex = vs[vi++];
			}
			return result;
		}
		public static function makeUIntBuffer(count:uint, vs:Array):Vector.<uint>
		{
			var vi:uint = 0;
			var result:Vector.<uint> = new Vector.<uint>(count, true);
			for (var i:uint=0; i<count; ++i)
				result[i] = vs[i];
			return result;
		}
		public static function makeBlendedVertices(count:uint, vs:Array):Vector.<BlendedVertexData>
		{
			var result:Vector.<BlendedVertexData> = new Vector.<BlendedVertexData>(count, true);
			for (var i:uint=0; i<count; ++i)
			{
				var blend:BlendedVertexData = result[i] = new BlendedVertexData();
				var values:Array = vs[i];
				
				blend.VertexIndex = values[0];
				blend.JointEntries = new Vector.<JointEntryData>((values.length-1)>>1, true);
				for (var j:uint=1; j<values.length; j+=2)
				{
					var entry:JointEntryData = blend.JointEntries[(j-1)>>1] = new JointEntryData();
					entry.JointIndex = values[j];
					entry.Weight = values[j+1];
				}
			}
			return result;
		}
		public static function makeBindMatrixBuffer(count:uint, vs:Array):Vector.<MatrixData>
		{
			var vi:uint = 0;
			var result:Vector.<MatrixData> = new Vector.<MatrixData>(count, true);
			for (var i:uint=0; i<count; ++i)
				result[i] = createMatrixData(vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++], vs[vi++]);
			return result;
		}
		
		public static function makeChannel(type:uint, targetPath:String, frameData:Array, duration:Number):ChannelData
		{
			var result:ChannelData = new ChannelData();
			result.Type = type;
			result.TargetPath = targetPath;
			var frames:Vector.<FrameData> = result.Frames = new Vector.<FrameData>(frameData.length, true);
			for (var fi:uint=0; fi<frameData.length; ++fi)
			{
				var frame:FrameData  = frames[fi] = new FrameData();
				var fd:Array = frameData[fi];
				frame.FrameNumber = fd[0];
				if (fd.length == 2) // Number case
					frame.Value = fd[1];
				else // MatrixData case
					frame.Value = createMatrixData(fd[1], fd[2], fd[3], fd[4], fd[5], fd[6], fd[7], fd[8], fd[9], fd[10], fd[11], fd[12], 0, 0, 0, 1);
			}
			result.Duration = duration;
			return result;
		}
		
		public static function computeAnimationDuration(channels:Vector.<ChannelData>):Number
		{
			if (channels == null)
				return 0;
			
			var min:Number = Number.MAX_VALUE;
			var max:Number = Number.MIN_VALUE;
			var isValid:Boolean = false;
			for each (var channel:ChannelData in channels)
			{
				if (channel.Frames.length > 0)
				{
					var f0:Number = channel.Frames[0].FrameNumber;
					var f1:Number = channel.Frames[channel.Frames.length-1].FrameNumber;
					min = f0 < min ? f0 : min;
					max = f1 > max ? f1 : max;
					isValid = true;
				}
			}
			return max - min;
		}
	}
}