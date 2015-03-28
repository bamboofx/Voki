package com.voki.vhss
{
	import com.oddcast.encryption.md5;
	import com.pagodaflash.math.Range;
	
	import flash.geom.Point;
	
	public class Constants
	{
		/** default value. if nothing else is specified, look for configuration here */
		private static var _vhssConfigUrl						:String = "http://api.oddcast.com/vhss/vhss_v5_config.xml";
		
		public static const VHSS_PLAYER_VERSION					:String = "5.1.15.0";
		public static const VHSS_PLAYER_DATE					:String = "02.22.11 -- 03:16  ";
		public static var FLASH_PLAYER_VERSION					:String;
		
		public static var VHSS_DOMAIN							:String = "http://vhost.oddcast.com";
		private static var _VHSS_DOMAIN_SECURE					:String = "https://vhost.oddcast.com";
		private static var _VHSS_DOMAIN_DEV						:String = "http://vhss-vd.oddcast.com";
		private static var _VHSS_DOMAIN_DEV_SECURE				:String = "https://vhss-vd.oddcast.com";
		private static var _VHSS_DOMAIN_STAGING					:String = "http://vhss-vs.oddcast.com";
		private static var _VHSS_DOMAIN_STAGING_SECURE			:String = "https://vhss-vs.oddcast.com";
		
		public static var TTS_DOMAIN							:String = "http://cache-a.oddcast.com";
		private static var _TTS_DOMAIN_SECURE					:String = "https://cache.oddcast.com";
		private static var _TTS_DOMAIN_DEV						:String = "http://cache-vd.oddcast.com";
		private static var _TTS_DOMAIN_DEV_SECURE				:String = "https://cache-vd.oddcast.com";
		private static var _TTS_DOMAIN_STAGING					:String = "http://cache-vs.oddcast.com";
		private static var _TTS_DOMAIN_STAGING_SECURE			:String = "https://cache-vs.oddcast.com";	
		
		public static var SCENE_STATUS_PHP						:String = "http://data.oddcast.com/scenestatus.php";
		private static var _SCENE_STATUS_PHP_SECURE				:String = "https://data.oddcast.com/scenestatus.php";
		private static var _SCENE_STATUS_PHP_DEV				:String = "http://data-vd.oddcast.com/scenestatus.php";
		private static var _SCENE_STATUS_PHP_DEV_SECURE			:String = "https://data-vd.oddcast.com/scenestatus.php";
		private static var _SCENE_STATUS_PHP_STAGING			:String = "http://data-vs.oddcast.com/scenestatus.php";
		private static var _SCENE_STATUS_PHP_STAGING_SECURE		:String = "https://data-vs.oddcast.com/scenestatus.php";
		
		public static var BAD_WORDS_PHP							:String = "http://vhss-d.oddcast.com/php/vhss_editors/getBadWords/acc=";
		private static var _BAD_WORDS_PHP_SECURE				:String = "https://vhost.oddcast.com/php/vhss_editors/getBadWords/acc=";
		private static var _BAD_WORDS_PHP_DEV					:String = "http://vhss-vd.oddcast.com/php/vhss_editors/getBadWords/acc=";
		private static var _BAD_WORDS_PHP_DEV_SECURE			:String = "https://vhss-vd.oddcast.com/php/vhss_editors/getBadWords/acc=";
		private static var _BAD_WORDS_PHP_STAGING				:String = "http://vhss-vs.oddcast.com/php/vhss_editors/getBadWords/acc=";
		private static var _BAD_WORDS_PHP_STAGING_SECURE		:String = "https://vhss-vs.oddcast.com/php/vhss_editors/getBadWords/acc=";
		
		public static var SITEPAL_BASE							:String;
		private static var _SITEPAL_BASE_DEV					:String;
		private static var _SITEPAL_BASE_STAGING				:String;
	
		public static var SAY_BY_NAME_PHP						:String = "/admin/getAudioByNameMP3.php";
		public static var AI_PHP								:String = "/ai/input.php";
		public static var BG_PHP								:String = "/admin/getBGByNameV2.php";
		public static var SEND_LEAD_PHP							:String = "/leads/post.php";
		public static var EXPORT_XML							:String = "play_scene.xml";
		public static var COMM_WINDOW							:String = "http://content.dev.oddcast.com/vhss_dev/vhss_voip_component.swf";
		public static var SET_COOKIE_PHP						:String;
	
		public static const EXP_AD_PERCENT						:Number = .25;
		public static const EXP_AD_MAX							:Number = 500;
		public static const BG_SCALE_DEFAULT					:Number = 1.33;
		public static const FLV_SCALE_DEFAULT					:Number = 1;
		public static const X_OFFSET_3D							:int = 110;
		public static const Y_OFFSET_3D							:int = -27;
		public static const SCALE_OFFSET_3D						:int = -7;
		
		private static var _PLAYER_CONTEXT						:String = "live";
		public static var IS_HTTPS								:Boolean = false;
		public static var IS_ENABLED_DOMAIN						:Boolean = false;
		public static var IS_AI_ENABLED							:Boolean = false;
		public static var IS_FILTERED							:Boolean = false;
		public static var PAGE_DOMAIN							:String = "";
		public static var PLAYER_DOMAIN							:String = "";
		public static var RELATIVE_URL							:String = "";
		public static var EMBED_ID								:String;
		public static var TRACKING_EMBED_ID						:String = "7";
		public static var SUPPRESS_TRACKING						:Boolean = false;
		public static var SUPPRESS_PLAY_ON_LOAD					:Boolean = false;
		public static var SUPPRESS_EXPORT_XML					:Boolean = false;
		public static var SUPPRESS_PLAY_ON_CLICK				:Boolean = false;
		public static var SUPPRESS_LINK							:Boolean = false;
		public static var SUPPRESS_AUTO_ADV						:Boolean = false;
		public static var ONLINE								:Boolean = false;
		public static var USE_3D_OFFSET							:Boolean = true;
		public static var PLAYER_URL							:String;
		public static var ERROR_REPORTING_ACTIVE				:Boolean = true;
		public static var INTERNAL_MODE							:String;
		
		public static const VOLUME_RANGE_PLAYER					:Range = new Range(0, 10);
		public static const VOLUME_RANGE_2D						:Range = new Range(0, 1);
		public static const VOLUME_RANGE_3D						:Range = new Range(0, 100);
		
		public static function set PLAYER_CONTEXT(url:String):void
		{
			//_IS_LIVE = !$b;
			PLAYER_URL = url;
			if (url.indexOf("https") == 0) {
				IS_HTTPS = true;
			}
			
			PLAYER_DOMAIN = url.substring(url.indexOf("://")+3, url.indexOf("/", url.indexOf("://")+3));
			if (PLAYER_DOMAIN.indexOf("dev.oddcast.com") != -1 || PLAYER_DOMAIN.indexOf("-vd.oddcast.com") != -1) {
				_PLAYER_CONTEXT = "dev";
			} else if (PLAYER_DOMAIN.indexOf("staging.oddcast.com") != -1 || PLAYER_DOMAIN.indexOf("-vs.oddcast.com") != -1) {
				_PLAYER_CONTEXT = "staging";
			} else if (PLAYER_DOMAIN.indexOf("oddcast.com") != -1) {
				_PLAYER_CONTEXT = "live";
			} else {
				_PLAYER_CONTEXT = "export";
			}
			switch (_PLAYER_CONTEXT) {
				case "staging":
					SCENE_STATUS_PHP = (IS_HTTPS) ? _SCENE_STATUS_PHP_STAGING_SECURE : _SCENE_STATUS_PHP_STAGING;
					VHSS_DOMAIN = (IS_HTTPS) ? _VHSS_DOMAIN_STAGING_SECURE : _VHSS_DOMAIN_STAGING;
					TTS_DOMAIN = (IS_HTTPS) ? _TTS_DOMAIN_STAGING_SECURE : _TTS_DOMAIN_STAGING;
					BAD_WORDS_PHP = (IS_HTTPS) ? _BAD_WORDS_PHP_STAGING_SECURE : _BAD_WORDS_PHP_STAGING;
					SITEPAL_BASE = _SITEPAL_BASE_STAGING;
					break;
				case "dev":
					SCENE_STATUS_PHP = (IS_HTTPS) ? _SCENE_STATUS_PHP_DEV_SECURE : _SCENE_STATUS_PHP_DEV; 
					VHSS_DOMAIN = (IS_HTTPS) ? _VHSS_DOMAIN_DEV_SECURE : _VHSS_DOMAIN_DEV;
					TTS_DOMAIN = (IS_HTTPS) ? _TTS_DOMAIN_DEV_SECURE : _TTS_DOMAIN_DEV;
					BAD_WORDS_PHP = (IS_HTTPS) ? _BAD_WORDS_PHP_DEV_SECURE : _BAD_WORDS_PHP_DEV;
					SITEPAL_BASE = _SITEPAL_BASE_DEV;
					break;
				default:
					if (IS_HTTPS) {
						SCENE_STATUS_PHP = _SCENE_STATUS_PHP_SECURE
						VHSS_DOMAIN = _VHSS_DOMAIN_SECURE;
						TTS_DOMAIN = _TTS_DOMAIN_SECURE;
						BAD_WORDS_PHP = _BAD_WORDS_PHP_SECURE;
					}
					break;
			}
		}
		
		public static function get PLAYER_CONTEXT():String
		{
			return _PLAYER_CONTEXT;
		}
		
		public static function get vhssConfigUrl():String
		{
			return _vhssConfigUrl;
		}
		
		public static function verifyDomains($xl:XMLList):void
		{
			//trace("Constants::verifyDomains - $xl='"+$xl+"'");
			var t_md5:md5 = new md5();
			var t_dom:String = PAGE_DOMAIN;
			var t_dom_ar:Array = t_dom.split(".");
			
			var t_dom_sub_wildcard_:String = "*." + t_dom_ar[t_dom_ar.length - 2] + "." + t_dom_ar[t_dom_ar.length - 1];
			var t_dom_sub_wildcard_hash:String = t_md5.hash(t_dom_sub_wildcard_);
			//trace("Constants::verifyDomains ---> subDomain wildcard = '" +t_dom_sub_wildcard_+"' hash='"+t_dom_sub_wildcard_hash+"'");
			
			var t_dom_sub_sub_wildcard:String = "*." + t_dom_ar[t_dom_ar.length - 3] + "." + t_dom_ar[t_dom_ar.length - 2] + "." + t_dom_ar[t_dom_ar.length - 1];
			var t_dom_sub_sub_wildcard_hash:String = t_md5.hash(t_dom_sub_sub_wildcard);
			//trace("Constants::verifyDomains ---> subDomain subDivison wildcard hash = '" +t_dom_sub_sub_wildcard+"' hash='"+t_dom_sub_sub_wildcard_hash+"'");
			
			
			if (t_dom_ar[t_dom_ar.length - 1] == "com" && t_dom_ar[t_dom_ar.length - 2] == "oddcast") {
				IS_ENABLED_DOMAIN = true;
				//trace("Constants::verifyDomains - IS_ENABLED_DOMAIN='"+IS_ENABLED_DOMAIN+"'");
			} else {
				if (t_dom_ar[0] != "www") { t_dom = "www." + t_dom;	}
				//trace("Constants::verifyDomains - t_dom='"+t_dom+"'");
				t_dom = t_md5.hash(t_dom);
				//trace("Constants::verifyDomains - md5='"+t_dom+"'");

				for (var i:Number = 0; i < $xl.length(); ++i) {
					//trace("Constants::verifyDomains -  DOMAIN CHECK '"+$xl[i].@V+"' == '"+t_dom+"' or '"+t_dom_sub_wildcard_hash+"' or '"+t_dom_sub_sub_wildcard_hash+"'");
					if ($xl[i].@V==t_dom) {
						trace("Constants::verifyDomains -  DOMAIN VERIFIED");
						//IS_DOMAIN_ENABLED = true;
						IS_ENABLED_DOMAIN = true;
						break;
					}
					if ($xl[i].@V==t_dom_sub_wildcard_hash) {
						trace("Constants::verifyDomains -  SUBDOMAIN VERIFIED");
						IS_ENABLED_DOMAIN = true;
						break;
					}
					if ($xl[i].@V==t_dom_sub_sub_wildcard_hash) {
						trace("Constants::verifyDomains -  SUBDOMAIN SUBDIVION VERIFIED");
						IS_ENABLED_DOMAIN = true;
						break;
					}
				}	
			}
		}
		
		public static function buildConfigUrl(loaderUrl:String):String
		{
			// change Constants.VHSS_CONFIG_URL according to loaderInfo.url to reflect dev/shadow/live and ssl vs nonsecure
			var secure:Boolean = loaderUrl.indexOf("https") >= 0;
			var start:int = secure ? 8 : 7; // https:// = 8, http:// = 7
			var subDomain:String = loaderUrl.substring(start); // cut off http[s]://
			subDomain = subDomain.substring(0, subDomain.indexOf("/")); // get content-vd.oddcast.com, removing trailing "/" and everything following
			var suffix:String = subDomain.indexOf("-vd") >= 0 ? "-vd" : 
				subDomain.indexOf("-vs") >= 0 ? "-vs" : 
				"";
			var url:String = _vhssConfigUrl.replace("api", "api" + suffix); // use api-vd, api-vs, or api
			var protocol:String = secure ? "https://" :"http://";
			url = url.replace("http://", protocol);	
			return url;
		}
		public static function parseConfiguration(xml:XML):void
		{
			VHSS_DOMAIN = xml.vhss_domain.toString();
			_VHSS_DOMAIN_SECURE = xml.vhss_domain_secure.toString();
			_VHSS_DOMAIN_DEV = xml.vhss_domain_dev.toString();
			_VHSS_DOMAIN_DEV_SECURE = xml.vhss_domain_dev_secure.toString();
			_VHSS_DOMAIN_STAGING = xml.vhss_domain_staging.toString();
			_VHSS_DOMAIN_STAGING_SECURE = xml.vhss_domain_staging_secure.toString();
			
			TTS_DOMAIN = xml.tts_domain.toString();
			_TTS_DOMAIN_SECURE = xml.tts_domain_secure.toString();
			_TTS_DOMAIN_DEV = xml.tts_domain_dev.toString();
			_TTS_DOMAIN_DEV_SECURE = xml.tts_domain_dev_secure.toString();
			_TTS_DOMAIN_STAGING = xml.tts_domain_staging.toString();
			_TTS_DOMAIN_STAGING_SECURE = xml.tts_domain_staging_secure.toString();
			
			SCENE_STATUS_PHP = xml.scene_status_php.toString();
			_SCENE_STATUS_PHP_SECURE = xml.scene_status_php_secure.toString();
			_SCENE_STATUS_PHP_DEV = xml.scene_status_php_dev.toString();
			_SCENE_STATUS_PHP_DEV_SECURE = xml.scene_status_php_dev_secure.toString();
			_SCENE_STATUS_PHP_STAGING = xml.scene_status_php_staging.toString();
			_SCENE_STATUS_PHP_STAGING_SECURE = xml.scene_status_php_staging_secure.toString();
			
			BAD_WORDS_PHP = xml.bad_words_php.toString();
			_BAD_WORDS_PHP_SECURE = xml.bad_words_php_secure.toString();
			_BAD_WORDS_PHP_DEV = xml.bad_words_php_dev.toString();
			_BAD_WORDS_PHP_DEV_SECURE = xml.bad_words_php_dev_secure.toString();
			_BAD_WORDS_PHP_STAGING = xml.bad_words_php_staging.toString();
			_BAD_WORDS_PHP_STAGING_SECURE = xml.bad_words_php_staging_secure.toString();
			
			SITEPAL_BASE = xml.sitepal_domain.toString();
			_SITEPAL_BASE_DEV = xml.sitepal_dev.toString();
			_SITEPAL_BASE_STAGING = xml.sitepal_staging.toString();
			
			SAY_BY_NAME_PHP = xml.say_by_name_php.toString();
			AI_PHP = xml.ai_php.toString();
			BG_PHP = xml.bg_php.toString();
			SEND_LEAD_PHP = xml.send_lead_php.toString();
			EXPORT_XML = xml.export_xml.toString();
			COMM_WINDOW = xml.comm_window.toString();
			SET_COOKIE_PHP = xml.set_cookie.toString();
		}
	}
}
