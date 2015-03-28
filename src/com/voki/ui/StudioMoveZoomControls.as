package com.voki.ui
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import com.voki.ui.MoveZoomControls;
	import flash.display.DisplayObject;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.utils.MoveZoomUtil;
	/**
	 * ...
	 * @author ...
	 */
	public class StudioMoveZoomControls extends MoveZoomControls
	{
		
		public var resetBtn:BaseButton;
		public var viewBtn:BaseButton;
		public var _tfZoom:TextField;
		public var _tfX:TextField;
		public var _tfY:TextField;
		
		private var initX:Number;
		private var initY:Number;
		private var initZoom:Number;
		
		public function StudioMoveZoomControls() 
		{			
			
			_tfX.addEventListener(FocusEvent.FOCUS_OUT, updateFromText);
			_tfY.addEventListener(FocusEvent.FOCUS_OUT, updateFromText);
			_tfZoom.addEventListener(FocusEvent.FOCUS_OUT, updateFromText);
			
			_tfX.restrict = "\\- 0-9";
			_tfY.restrict = "\\- 0-9";
			_tfZoom.restrict = "0-9";						
		}
		
		override public function setTarget(in_zoomer:MoveZoomUtil) 
		{
			super.setTarget(in_zoomer);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			zoomer.addEventListener("move", updateFromZoomer);
			zoomer.addEventListener("scale", updateFromZoomer);
			initX = zoomer.x;
			initY = zoomer.y;
			initZoom = zoomer.scale;
			
		}
		
		private function keyUp(evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.ENTER)
			{
				updateFromText(evt);
			}
		}
		
		public function updateFromZoomer(evt:Event):void
		{
			_tfX.text = zoomer.x.toFixed();
			_tfY.text = zoomer.y.toFixed();
			_tfZoom.text = (zoomer.scale*100).toFixed();
		}
		
		private function updateFromText(evt:Event):void
		{
			
			if (evt.target == _tfZoom)
			{
				var scaleVal:Number = Number(_tfZoom.text) / 100;
				var scaleBy:Number;
				trace("updateFromText scaleVal="+scaleVal+", zoomer.maxScale="+zoomer.maxScale+", zoomer.minScale="+zoomer.minScale);
				if (scaleVal > zoomer.maxScale)
				{
					scaleBy = zoomer.maxScale / zoomer.scale;
					zoomer.scaleBy(scaleBy);
					//zoomer.scale = zoomer.maxScale;
				}
				else if (scaleVal < zoomer.minScale)
				{
					scaleBy = zoomer.minScale / zoomer.scale;
					zoomer.scaleBy(scaleBy);
					//zoomer.scale = zoomer.minScale;
				}
				else
				{
					scaleBy = scaleVal / zoomer.scale;
					zoomer.scaleBy(scaleBy);
					//zoomer.scale = scaleVal;
				}
			}
			else if (evt.target == _tfX || evt.target== _tfY)
			{
				
				zoomer.x = Math.round(Number(_tfX.text));
				zoomer.y = Math.round(Number(_tfY.text));
				
			}
			//zoomer.forceInBounds();
			updateFromZoomer(null);
		}
		
		override protected function doBtnAction(btn:DisplayObject) 
		{
			if (btn == resetBtn) doReset();
			else if (btn == viewBtn) doViewChange();
			else
			{
				super.doBtnAction(btn);
			}
			
		}
		
		private function doViewChange():void
		{
			dispatchEvent(new Event("viewChange"));
		}
		
		private function doReset():void
		{
			zoomer.x = initX;
			zoomer.y = initY;
			zoomer.scale = initZoom;
		}
		
	}

}