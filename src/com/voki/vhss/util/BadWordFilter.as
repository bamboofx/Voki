package com.voki.vhss.util
{
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.XMLLoader;
	
	import flash.events.EventDispatcher;
	
	import com.voki.vhss.Constants;

	public class BadWordFilter extends EventDispatcher
	{
		private var is_ready			:Boolean = false;
		private var word_array			:Array;
		//private var url_ldr:URLLoader;
		private var badwords_xml		:XML;
		private var xml_loader			:XMLLoader;
		private var lang_badwords_xml	:XMLList;
		//private var filter_str:String = "";
		private var filters				:Object;
		private var _onCompleteCallback	:Function;
		private var _onErrorCallback	:Function;
		private var _xmlUrl				:String;
		
		public function get wordsXmlUrl():String
		{
			return _xmlUrl;
		}
		public function get isReady():Boolean
		{
			return is_ready;
		}
		
		public function BadWordFilter(accountId:String)
		{
			_xmlUrl = Constants.BAD_WORDS_PHP + accountId;
		}
		
		public function load(onComplete:Function = null, onError:Function = null):void
		{
			_onCompleteCallback = onComplete;
			_onErrorCallback = onError;
			XMLLoader.loadXML(_xmlUrl, e_xmlLoaded);
		}
		
		private function e_xmlLoaded($xml:XML):void
		{
			var c:Function;
			var t_alert:AlertEvent = XMLLoader.checkForAlertEvent();
			if (t_alert != null) {
				//trace("BAD WORD FILTER :: xml error -- "+t_alert.moreInfo.details);
				c = _onErrorCallback;
			} else {
				filters = new Object();
				badwords_xml = $xml;
				for each (var lang:XML in badwords_xml.lang) {
					//trace("BAD WORDS -- lang \n"+lang);
					var t_filter_str:String = "";
					for each(var i:XML in lang.i)
					{
						//trace("BAD WORDS -- w "+i.@w);
						t_filter_str += i.@w + "|";
					}
					t_filter_str = t_filter_str.substr(0, t_filter_str.length-1);
					t_filter_str = "\\b("+t_filter_str+")\\b";
					//var t_pre_rx:String = "(?<=\\s)(";
					//var t_post_rx:String = ")(?=(\\s|\\,|\\.|\\?|\\!|\\@|\\$|\\*|\\&|\\%|\\;|\\:|\\\"|\\'|\\+|\\=))";
					//var t_pre_rx:String = "(?<!([a-z]|[0-9]|\%))(";
					//var t_post_rx:String = ")(?!([a-z]|[0-9]|\%))";
					//(?<=\s)(дрофа|fuck|shit)(?=(\s|\,|\.|\?|\!|\@|\$|\*|\&|\%|\;|\:|\"|\'|\+|\=))
					//t_filter_str = t_pre_rx+t_filter_str+t_post_rx;
					//(?<![a-zA-Z])(дрофа|fuck|shit)(?![a-zA-z])
					//trace("BAD WORDS -- filter "+t_filter_str);
					filters[lang.@id] = t_filter_str;
				}
				is_ready = true;
				badwords_xml = $xml;
				c = _onCompleteCallback;
			}
			_onCompleteCallback = null;
			_onErrorCallback = null;
			if (c != null) {
				c();
			}
		}
		
		private function replacer():String
		{
			//trace("replacer -- "+arguments);
			var t_word:String = arguments[0];
			var t_replace:String = unescape(lang_badwords_xml.i.(@w == t_word).@r.toString());
			var t_default:String = unescape(lang_badwords_xml.@rep.toString());
			if (t_replace.length > 0) {
				return t_replace;
			} else if (t_default.length > 0) {
				return t_default;
			} else {
				return t_word;
			}
		}
		
		public function filter($str:String, $language:String):String
		{
			if (!is_ready) return $str;
			//$str = encodeURI($str);
			//trace("BAD WORDS -- filter :: "+$str+"  lang: "+$language);
			if ($language.length > 0 && filters[$language] != null) {
				lang_badwords_xml = badwords_xml.lang.(@id == $language);
				var t_filter_str:String = filters[$language];
				var t_rx:RegExp = new RegExp(t_filter_str, "gi");
				//trace("BAD WORDS -- use filter : "+t_filter_str);
				var t_str:String = $str.replace(t_rx, replacer)
				//trace("BADWORDS ____ 1 filter "+t_str);
				return t_str;
			} else {
				//trace("BADWORDS ____ 2 filter "+decodeURI($str));
				return $str;
				//return decodeURI($str);
			}
		}

		public function destroy():void
		{
			XMLLoader.destroy();
		}
	}
}
