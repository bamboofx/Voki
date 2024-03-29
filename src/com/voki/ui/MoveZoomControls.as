/**
* ...
* @author Sam Myer
* @version 0.1
* 
* This class is associated with the move zoom controls UI.  It works with the MoveZoomUtil class.  If you set the
* pressAndHoldEnabled property of the BaseButtons to true, you can press and hold the buttons to have the image
* continuously move/zoom.  
* 
* usage:
* say you want to have these controls affect a Sprite called targetImage
* 
* var zoomer:MoveZoomUtil=new MoveZoomUtil(targetImage);
* myMoveZoomControls.setTarget(zoomer);
* 
* @see com.oddcast.utils.MoveZoomUtil
*/

package com.voki.ui {
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.Slider;
	import com.oddcast.utils.MoveZoomUtil;
	import com.oddcast.utils.TimerUtil;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	//import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;

	public class MoveZoomControls extends MovieClip {
		private static var moveAmt:Number=4;
		private static var zoomSteps:int=50;
		private static var zoomAmt:Number;
		
		public var upBtn:BaseButton;
		public var downBtn:BaseButton;
		public var leftBtn:BaseButton;
		public var rightBtn:BaseButton;
		//public var resetBtn:SimpleButton;
		public var zoomInBtn:BaseButton;
		public var zoomOutBtn:BaseButton;
		//public var rotateLeftBtn:BaseButton;
		//public var rotateRightBtn:BaseButton;
		//public var zoomSlider:Slider;
		
		protected var zoomer:MoveZoomUtil;
		//private var startPos:Matrix;
		protected var clickTarget:DisplayObject;
		
		public function MoveZoomControls() {
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseUp);
			//addEventListener(BaseButton.MOUSE_HOLD, onMouseDown);
		}
		
		private function onMouseDown(evt:MouseEvent) {
			trace("MoveZoomControls::onMouseDown - " + evt.target.name);
			
			clickTarget = evt.target as DisplayObject;
			doBtnAction(clickTarget);
			TimerUtil.setInterval(firstHold,750);
		}
		
		private function onMouseUp(evt:MouseEvent) {
			clickTarget = null;
			TimerUtil.stopInterval(firstHold);
			removeEventListener(Event.ENTER_FRAME, onMouseHold);
		}
		
		private function firstHold() {
			doBtnAction(clickTarget);
			addEventListener(Event.ENTER_FRAME, onMouseHold);
		}
		
		private function onMouseHold(evt:Event) {
			doBtnAction(clickTarget);
		}
		
		protected function doBtnAction(btn:DisplayObject) {
			if (btn==upBtn) zoomer.moveBy(0,-moveAmt);
			if (btn==downBtn) zoomer.moveBy(0,moveAmt);
			if (btn==leftBtn) zoomer.moveBy(-moveAmt,0);
			if (btn==rightBtn) zoomer.moveBy(moveAmt,0);
			if (btn==zoomInBtn) zoomer.scaleBy(zoomAmt, true);
			if (btn == zoomOutBtn) zoomer.scaleBy(1 / zoomAmt, true);
		}
		
		public function setTarget(in_zoomer:MoveZoomUtil) {
			zoomer=in_zoomer;
			trace("MoveZoomControls::setTarget "+zoomer);
			//startPos=zoomer.matrix;
			zoomAmt = Math.pow(zoomer.maxScale/zoomer.minScale,1/(zoomSteps - 1));
		}
		
		public function getZoomer():MoveZoomUtil
		{
			return zoomer;
		}
	}
	
}