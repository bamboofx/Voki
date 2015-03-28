package  {
	import flash.Boot;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import haxe.Log;
	public dynamic class Model extends MovieClip {
		public function Model() : void { 
			super();
			this.gotoAndStop(2);
			this.timer = new Timer(1000);
			this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
			this.timer.start();
		}
		protected var timer : Timer;
		protected var host : MovieClip;
		protected var backhair : MovieClip;
		protected var body : MovieClip;
		protected function init() : void {
			this.host.stop();
			this.traceMC(this);
		}
		public function getSomething() : String {
			return "something";
		}
		public function getHost() : MovieClip {
			return this.host;
		}
		protected function onTimer(evt : TimerEvent) : void {
			this.timer.stop();
			this.init();
		}
		protected function traceMC(m : MovieClip) : void {
			{
				var _g1 : int = 0, _g : int = m.numChildren;
				while(_g1 < _g) {
					var j : int = _g1;
					++_g1;
					{
						var dObj : DisplayObject = m.getChildAt(j);
						//Log.trace("-> " + dObj.name + "(in " + dObj.parent.name,{ fileName : "GenerateHost.hx", lineNumber : 54, className : "Model", methodName : "traceMC"});
						try {
							var mc : MovieClip = function($this:Model) : MovieClip {
								var $r : MovieClip;
								var tmp : DisplayObject = dObj;
								$r = (Std._is(tmp,MovieClip)?tmp as MovieClip :function($this:Model) : DisplayObject {
									var $r2 : DisplayObject;
									throw "Class cast error";
									return $r2;
								}($this));
								return $r;
							}(this);
							this.traceMC(mc);
						}
						catch( e : * ){
							null;
						}
					}
				}
			}
		}
	}
}
