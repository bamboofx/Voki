package flash {
	import flash.text.TextFormat;
	import flash.display.MovieClip;
	import flash.Lib;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getQualifiedClassName;
	public class Boot extends MovieClip {
		public function Boot(mc : MovieClip = null) : void { if( !Boot.skip_constructor ) {
			super();
			{
				var aproto : * = Array.prototype;
				aproto.copy = function() : * {
					return this.slice();
				}
				aproto.insert = function(i : *,x : *) : void {
					this.splice(i,0,x);
				}
				aproto.remove = function(obj : *) : Boolean {
					{
						var _g1 : int = 0, _g : int = this.length;
						while(_g1 < _g) {
							var i : int = _g1;
							++_g1;
							if(this[i] == obj) {
								this.splice(i,1);
								return true;
							}
						}
					}
					return false;
				}
				aproto.iterator = function() : * {
					return { cur : 0, arr : this, hasNext : function() : Boolean {
						return this.cur < this.arr.length;
					}, next : function() : * {
						return this.arr[this.cur++];
					}}
				}
				var cca : * = String.prototype.charCodeAt;
				String.prototype.charCodeAt = function(i : *) : * {
					var x : * = cca.call(this,i);
					if(isNaN(x)) return null;
					return x;
				}
			}
			Boot.lines = new Array();
			Lib.current = (mc == null?this:mc);
			if(Boot.init != null) init();
		}}
		private static function init() : void {{
			Math["NaN"] = Number.NaN;
			Math["NEGATIVE_INFINITY"] = Number.NEGATIVE_INFINITY;
			Math["POSITIVE_INFINITY"] = Number.POSITIVE_INFINITY;
			Math["isFinite"] = function(i : Number) : Boolean {
				return isFinite(i);
			}
			Math["isNaN"] = function(i : Number) : Boolean {
				return isNaN(i);
			}
		}}
		static protected var tf : TextField;
		static protected var lines : Array;
		static public var skip_constructor : Boolean = false;
		static public function enum_to_string(e : *) : String {
			if(e.params == null) return e.tag;
			return e.tag + "(" + e.params.join(",") + ")";
		}
		static public function __instanceof(v : *,t : *) : Boolean {
			try {
				if(t === Object) return true;
				return v is t;
			}
			catch( e : * ){
				null;
			}
			return false;
		}
		static public function __clear_trace() : void {
			if(Boot.tf == null) return;
			Lib.current.removeChild(tf);
			Boot.tf = null;
			Boot.lines = new Array();
		}
		static public function __set_trace_color(rgb : uint) : void {
			getTrace().textColor = rgb;
		}
		static public function getTrace() : TextField {
			var mc : MovieClip = Lib.current;
			if(Boot.tf == null) {
				Boot.tf = new TextField();
				var format : TextFormat = tf.getTextFormat();
				format.font = "_sans";
				tf.defaultTextFormat = format;
				tf.selectable = false;
				tf.width = mc.stage.stageWidth;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.mouseEnabled = false;
			}
			mc.addChild(tf);
			return tf;
		}
		static public function __trace(v : *,pos : *) : void {
			var tf : TextField = getTrace();
			var pstr : String = (pos == null?"(null)":pos.fileName + ":" + pos.lineNumber);
			Boot.lines = lines.concat((pstr + ": " + __string_rec(v,"")).split("\n"));
			tf.text = lines.join("\n");
			var stage : Stage = Lib.current.stage;
			if(stage == null) throw "Loaded movie not ready to trace, wait a few frames";
			while(tf.height > stage.stageHeight) {
				lines.shift();
				tf.text = lines.join("\n");
			}
		}
		static public function __string_rec(v : *,str : String) : String {
			var cname : String = getQualifiedClassName(v);
			switch(cname) {
			case "Object":{
				var k : Array = function() : Array {
					var $r : Array;
					$r = new Array();
					for(var $k : String in v) $r.push($k);
					return $r;
				}();
				var s : String = "{";
				var first : Boolean = true;
				{
					var _g1 : int = 0, _g : int = k.length;
					while(_g1 < _g) {
						var i : int = _g1;
						++_g1;
						{
							var key : String = k[i];
							if(first) first = false;
							else s += ",";
							s += " " + key + " : " + __string_rec(v[key],str);
						}
					}
				}
				if(!first) s += " ";
				s += "}";
				return s;
			}break;
			case "Array":{
				var s2 : String = "[";
				var i2 : *;
				var first2 : Boolean = true;
				{
					var _g12 : int = 0, _g2 : * = v.length;
					while(_g12 < _g2) {
						var i1 : int = _g12;
						++_g12;
						{
							if(first2) first2 = false;
							else s2 += ",";
							s2 += __string_rec(v[i1],str);
						}
					}
				}
				return s2 + "]";
			}break;
			default:{
				switch(typeof v) {
				case "function":{
					return "<function>";
				}break;
				}
			}break;
			}
			return new String(v);
		}
	}
}
