package com.oddcast.app {
	
	public class FrameUpdate {
		public function FrameUpdate() : void {  {
			this.lastStartTime = Math["POSITIVE_INFINITY"];
			this.imageGenerationDelayMilliSecs = this.imageDisplayedIntervalMilliSecs = this.sinceTalkingMillis = 0;
		}}
		public var imageGenerationDelayMilliSecs : Number;
		public var imageDisplayedIntervalMilliSecs : Number;
		public var mouseX : Number;
		public var mouseY : Number;
		public var deltamouseX : Number;
		public var deltamouseY : Number;
		public var timeSinceMouseMove : Number;
		public var sinceTalkingMillis : Number;
		public function setMouse(mouseX : Number,mouseY : Number) : void {
			this.deltamouseX = this.mouseX - mouseX;
			this.mouseX = mouseX;
			this.deltamouseY = this.mouseY - mouseY;
			this.mouseY = mouseY;
			if(this.mouseHasMoved()) this.resetMouseMoveTime();
		}
		public function mouseHasMoved() : Boolean {
			return this.deltamouseX * this.deltamouseX + this.deltamouseY + this.deltamouseY > 1.0;
		}
		public function beforeRender(time : Number) : void {
			this.imageDisplayedIntervalMilliSecs = Math.max(0,time - this.lastStartTime);
			this.lastStartTime = time;
		}
		public function afterRender(time : Number) : void {
			this.imageGenerationDelayMilliSecs = Math.max(0,time - this.lastStartTime);
			this.timeSinceMouseMove += this.getInterval();
		}
		public function getInterval() : Number {
			return this.imageDisplayedIntervalMilliSecs;
		}
		protected var lastStartTime : Number;
		protected function resetMouseMoveTime() : void {
			this.timeSinceMouseMove = 0;
		}
	}
}
