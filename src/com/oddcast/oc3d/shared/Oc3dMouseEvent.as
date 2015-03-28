package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.content.IAccessory;
	import com.oddcast.oc3d.content.INode;
	import com.oddcast.oc3d.core.INodeProxy;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Oc3dMouseEvent extends MouseEvent
	{
		private var sender_:INodeProxy;
		private var geometryName_:String;
		
		public function Oc3dMouseEvent(e:MouseEvent, sender:INodeProxy, geometryName:String)
		{
			super(e.type, e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta); 
			sender_ = sender;
			geometryName_ = geometryName;
		}
		
		public function sender():INodeProxy
		{
			return sender_;
		}
		
		public function geometryName():String
		{
			return geometryName_;
		}
	}
}