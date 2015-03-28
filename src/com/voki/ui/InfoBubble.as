package com.voki.ui 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class InfoBubble extends MovieClip
	{
		//public var _tfDesc:TextField;
		public var _mcBubble:MovieClip;
		private var _nMinWidth:Number;
		private var _nMinHeight:Number;
		private var _mcContainer:MovieClip;
		private var _tf:TextField;
		
		public static var MARGIN_WIDTH:Number = 6;
		public static var MARGIN_HEIGHT:Number = 4;
		public static var MAX_WIDTH:Number = 350;
		public static var TEXT_SIZE:Number = 10;
		
		public function InfoBubble() 
		{						
			_nMinWidth = _mcBubble.width;
			_nMinHeight = _mcBubble.height;
		}
		
		public function setText(s:String):void
		{
			if (_tf == null)
			{
				_tf = new TextField();
				_tf.autoSize = "left";
				var fmt:TextFormat = _tf.getTextFormat();
				fmt.size = TEXT_SIZE;
				_tf.setTextFormat(fmt);
				_tf.x = MARGIN_WIDTH;
				_tf.y = MARGIN_HEIGHT;
				this.addChild(_tf);
			}
			
			_tf.text = s;
			_tf.wordWrap = true;
			_tf.width = MAX_WIDTH;
			//trace("InfoBubble _tf.width=" + _tf.width + ", _tf.height=" + _tf.height+" MAX_WIDTH="+MAX_WIDTH);
			
			_mcBubble.width = _tf.width > _nMinWidth?_tf.width + MARGIN_WIDTH:_mcBubble.width;
			_mcBubble.height = _tf.height > _nMinHeight?_tf.height + MARGIN_HEIGHT:_mcBubble.height;
			
			
			_mcBubble.height += (MARGIN_HEIGHT * 6);
			
			trace("InfoBubble this.x="+this.x+", this.width="+this.width+", _mcContainer.x="+_mcContainer.x+", _mcContainer.width="+_mcContainer.width);
			/*
			if ((this.x + this.width) > (_mcContainer.x + _mcContainer.width))
			{
				this.x -= (MARGIN_WIDTH + ((this.x + this.width) - (_mcContainer.x + _mcContainer.width)));
			}
			*/
			
		}
						
		public function setContainer(mc:MovieClip):void
		{
			_mcContainer = mc;
		}
		
	}
	
}