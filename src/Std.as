package  {
	import flash.Boot;
	public class Std {
		static public function _is(v : *,t : *) : Boolean {
			return Boot.__instanceof(v,t);
		}
		static public function string(s : *) : String {
			return Boot.__string_rec(s,"");
		}
		static public function _int(x : Number) : int {
			return int(x);
		}
		static public function bool(x : *) : Boolean {
			return (x !== 0 && x != null && x !== false);
		}
		static public function _parseInt(x : String) : * {
			{
				var v : * = parseInt(x);
				if(isNaN(v)) return null;
				return v;
			}
		}
		static public function _parseFloat(x : String) : Number {
			return parseFloat(x);
		}
		static public function chr(x : int) : String {
			return String.fromCharCode(x);
		}
		static public function ord(x : String) : * {
			if(x == "") return null;
			else return x["charCodeAt"](0);
		}
		static public function random(x : int) : int {
			return Math.floor(Math.random() * x);
		}
		static public function resource(name : String) : String {
			return function() : String {
				var $r : String;
				throw "Not supported in AS3";
				return $r;
			}();
		}
	}
}
