package flash {
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.system.fscommand;
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.net.navigateToURL;
	public class Lib {
		static public var current : MovieClip;
		static public function _getTimer() : Number {
			return getTimer();
		}
		static public function eval(path : String) : * {
			var p : Array = path.split(".");
			var fields : Array = new Array();
			var o : * = null;
			while(p.length > 0) {
				try {
					o = getDefinitionByName(p.join("."));
				}
				catch( e : * ){
					fields.unshift(p.pop());
				}
				if(o != null) break;
			}
			if(o == null) {
				return null;
			}
			{ var $it : * = fields.iterator();
			while( $it.hasNext() ) { var f : String = $it.next();
			o = o[f];
			}}
			return o;
		}
		static public function getURL(url : URLRequest,target : String = null) : void {
			var f : Function = navigateToURL;
			if(target == null) f(url);
			else (f)(url,target);
		}
		static public function fscommand(cmd : String,param : * = null) : void {
			fscommand(cmd,param);
		}
		static public function trace(arg : *) : void {
			trace(arg);
		}
	}
}
