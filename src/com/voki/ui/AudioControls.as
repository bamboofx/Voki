package com.voki.ui {
	import com.oddcast.ui.BaseButton;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AudioControls extends MovieClip {
		public var playBtn:BaseButton;
		public var stopBtn:BaseButton;
		public var processingMC:MovieClip;
		public var equalizerMC:MovieClip;
		public var tf_status:TextField;
		
		private var _state:String;
		
		public static const PLAYING:String="PLAYING";
		public static const RECORDING:String="RECORDING";
		public static const STOPPED:String="STOPPED";
		public static const NOAUDIO:String="READY";
		public static const PROCESSING:String="PROCESSING";
		
		public function AudioControls() {
			playBtn.addEventListener(MouseEvent.CLICK, onPlay);
			stopBtn.addEventListener(MouseEvent.CLICK, onStop);
			
			state = NOAUDIO;
		}
		
		public function get state():String {
			return(_state);
		}
		
		public function set state(s:String) {
			_state = s;
			
			showProcessing(_state == PROCESSING);
			showEqualizer(_state == PLAYING);
			
			if (_state == PLAYING) {
				playBtn.disabled = true;
				stopBtn.disabled = false;
			}
			else if (_state == STOPPED) {
				playBtn.disabled = false;
				stopBtn.disabled = true;
			}
			else {
				playBtn.disabled = true;
				stopBtn.disabled = true;
			}
			
			if (tf_status != null) {
				tf_status.text = _state;
			}
		}
		
		private function showProcessing(b:Boolean) {
			processingMC.visible = b;
			if (b) processingMC.play();
			else processingMC.stop();
		}
		
		private function showEqualizer(b:Boolean) {
			if (b) equalizerMC.play();
			else equalizerMC.gotoAndStop(1);
		}
		
		private function onPlay(evt:MouseEvent) {
			dispatchEvent(new Event("play"));
		}
		private function onStop(evt:MouseEvent) {
			dispatchEvent(new Event("stop"));
			//dispatchEvent(new Event("stopRec"));
		}
	}
	
}