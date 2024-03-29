﻿package com.voki.data {
	import com.oddcast.audio.AudioData;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class LeadConfiguration {
		public var title:String;
		public var email:String;
		public var reporting:Boolean;
		public var fields:Array;
		public var btnText:String;
		public var progressText:String;
		public var errorText:String;
		public var successText:String;
		public var errorAudio:AudioData
		public var successAudio:AudioData;
		private var _sBaseUrl:String;
		public static const INVISIBLE_TOKEN:String = "~!vis";		
		
		
		public function LeadConfiguration(_xml:XML = null,baseUrl:String="") {
			trace("isaac LeadConfiguration::")
			title = "Leave your info"
			email = SessionVars.userEmail;		
			fields=["Email","Name","Phone","Comment"];
			btnText="Send"
			progressText="SENDING..."
			errorText="Error sending the message.  Please try again."
			successText = "Your message is submitted.  We will follow up shortly."
			
			if (_xml != null) setFromXML(_xml,baseUrl);
		}
		
/* <LEAD REPORTS="0" EMAIL="smyer@oddcast.com">
	<FIELDS MSG="adf">
<F ISEMAIL="1" REQ="1" NAME="Edf"/>
<F REQ="0" NAME="Name"/>
<F REQ="0" NAME="Comment"/>
</FIELDS>
<BUTTON>Send</BUTTON>
<PROGRESS>SENDING...</PROGRESS>
<ERROR NAME="" ID="-1">Error+sending+data</ERROR>
<SUCCESS NAME="112" ID="19780" URL="user/070/1460/audio/1179957902042_1460">Sent+Successfully%21+Thanks%21</SUCCESS>
</LEAD>*/
		public function setFromXML(_xml:XML,baseUrl:String):void {
			reporting=(_xml.@REPORTS=="1")
			email=_xml.@EMAIL;
			title = unescape(_xml.FIELDS.@MSG.toString());
			
			fields=new Array();
			for (var i:uint = 0; i < _xml.FIELDS.F.length(); i++) fields.push(unescape(_xml.FIELDS.F[i].@NAME));
			
			btnText=unescape(_xml.BUTTON.toString());
			progressText=unescape(_xml.PROGRESS.toString());
			errorText=unescape(_xml.ERROR.toString());
			successText = unescape(_xml.SUCCESS.toString());
			
			if (_xml.ERROR.@ID=="-1"||_xml.ERROR.@URL=="") errorAudio=null;
			else {
				errorAudio=new AudioData(baseUrl+_xml.ERROR.@URL,parseInt(_xml.ERROR.@ID.toString()));
				errorAudio.name = unescape(_xml.ERROR.@NAME.toString());
			}
			
			if (_xml.SUCCESS.@ID=="-1"||_xml.SUCCESS.@URL==undefined) successAudio=null;
			else {
				successAudio=new AudioData(baseUrl+_xml.SUCCESS.@URL,parseInt(_xml.SUCCESS.@ID.toString()));
				successAudio.name=unescape(_xml.SUCCESS.@NAME.toString());
			}
			_sBaseUrl = baseUrl;
		}
		
		
		public function getXML(sceneEditor:Boolean = false):XML {
			var node:XML=new XML("<LEAD />");
			node.@EMAIL = email;
			
			var fieldArrNode:XML=new XML("<FIELDS />");
			fieldArrNode.@MSG=escape(title);
			var fieldNode:XML;
			for (var i:uint = 0; i < fields.length; i++) {
				if (fields[i].indexOf(INVISIBLE_TOKEN) == 0)
					continue;
				fieldNode=new XML("<F />");
				fieldNode.@NAME=escape(fields[i]);
				fieldNode.@REQ=(i==0?"1":"0");
				if (i==0) fieldNode.@ISEMAIL="1";
				fieldArrNode.appendChild(fieldNode);
			}
			node.appendChild(fieldArrNode);
			
			node.BUTTON = escape(btnText);
			node.PROGRESS = escape(progressText)
			
			node.ERROR = escape(errorText);
			if (errorAudio == null) {
				if (sceneEditor)
				{
					node.ERROR.@AUID="-1";					
				}
				else
				{
					node.ERROR.@NAME="";
					node.ERROR.@ID="-1";
					node.ERROR.@URL = "";
				}
			}
			else {
				if (sceneEditor)
				{
					node.ERROR.@AUID = errorAudio.id.toString();
					if (_sBaseUrl != null)
					{
						node.ERROR.@URL = errorAudio.url.split(_sBaseUrl).pop();
					}
					else
					{
						node.ERROR.@URL = errorAudio.url
					}					
					node.ERROR.appendChild(errorAudio.name);
				}
				else
				{
					node.ERROR.@NAME = errorAudio.name;
					node.ERROR.@ID = errorAudio.id.toString();
					if (_sBaseUrl != null)
					{
						node.ERROR.@URL = errorAudio.url.split(_sBaseUrl).pop();
					}
					else
					{
						node.ERROR.@URL = errorAudio.url
					}										
				}
			}
			
			node.SUCCESS = escape(successText);
			if (successAudio == null) {
				if (sceneEditor)
				{
					node.SUCCESS.@AUID="-1";
				}
				else
				{
					node.SUCCESS.@NAME="";
					node.SUCCESS.@ID="-1";
					node.SUCCESS.@URL = "";
				}
			}
			else {
				if (sceneEditor)
				{					
					node.SUCCESS.@AUID = successAudio.id.toString();
					if (_sBaseUrl != null)
					{
						node.SUCCESS.@URL = successAudio.url.split(_sBaseUrl).pop();
					}
					else
					{
						node.SUCCESS.@URL = successAudio.url;
					}								
					node.SUCCESS.appendChild(successAudio.name);
				}
				else
				{
					node.SUCCESS.@NAME = successAudio.name;
					node.SUCCESS.@ID = successAudio.id.toString();
					if (_sBaseUrl != null)
					{
						node.SUCCESS.@URL = successAudio.url.split(_sBaseUrl).pop();
					}
					else
					{
						node.SUCCESS.@URL = successAudio.url;
					}									
				}
			}
			
			return node;
		}
		
	}
	
}