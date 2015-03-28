package com.voki.nav {
	import com.oddcast.ui.ButtonSelectorItem;
	import flash.display.MovieClip;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class NavButton extends ButtonSelectorItem {
		public var bg:MovieClip;
		private var _dynamicWidth:Number
		private var tfY:Number;
		
		public function NavButton():void {
			super();
			tfY = _tfCaption.y;
		}
		
		override protected function gotoFrame(frameName:String):void {
			if (frameName == PRESSED) {
				_tfCaption.textColor = 0xFFFFFF;
				bg.gotoAndStop("on");
			}
			else {
				_tfCaption.textColor = 0x666666;
				bg.gotoAndStop("off");
			}
			bg.alpha = (frameName == DISABLED?0.5:1);
			_tfCaption.alpha = (frameName == DISABLED?0.5:1);
		}
		
		public function set dynamicWidth(n:Number):void {
			var curBGWidth:Number = bg.width;
			var curTFWidth:Number = _tfCaption.width;
			bg.width = n;
			//trace("text width = " + (n - (curBGWidth - curTFWidth)));
			_tfCaption.width = n-(curBGWidth-curTFWidth);
		}
		public function get dynamicWidth():Number {
			return bg.width;
		}
		
		override public function set text(s:String):void		{			
			super.text = s;
			_tfCaption.y = tfY;
			if (_tfCaption.numLines > 1) _tfCaption.y-=6;
		}
	}
	
}