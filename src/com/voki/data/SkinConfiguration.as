package com.voki.data {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.EmailValidator;
	import com.voki.data.SessionVars;
	
	import flash.xml.XMLNode;
	/**
	* ...
	* @author Sam Myer
	*/
	public class SkinConfiguration {
		public var type:String;
		public var title:String;
		public var email:String;
		public var align:String;
		public var showTitle:Boolean;
		public var showVolume:Boolean;
		public var showPlay:Boolean;
		public var showMute:Boolean;
		public var colorArr:Array;
		
		public var showPrev:Boolean;
		public var showNext:Boolean;
		
		public var lead:LeadConfiguration;
		public var ai:AIConfiguration;
		public var faq:FAQConfiguration;
		
		public function SkinConfiguration($type:String = null) {
			if ($type == null) type = SPSkinStruct.STANDARD_TYPE;
			else type = $type;
			title = "";
			email = null;
			align = "center";
			showTitle = true;
			showMute = true;
			showPlay = true;
			showVolume = true;
			colorArr = new Array();
			
			if (type == SPSkinStruct.AI_TYPE) ai = new AIConfiguration();
			if (type == SPSkinStruct.FAQ_TYPE) faq = new FAQConfiguration();
			if (type == SPSkinStruct.LEAD_TYPE) lead = new LeadConfiguration();
			
			if (SessionVars.editorMode == "SceneEditor")
			{
				showNext = true;
				showPrev = true;
			}
			else
			{
				showNext = false;
				showPrev = false;
			}
			
		}
		
		public function setFromXML(_xml:XML, baseUrl:String = ""):void {
			trace("SkinConfiguration::setFromXML - " + _xml.toXMLString());
			if (_xml.hasOwnProperty("@TITLE")) title = decodeURI(_xml.@TITLE);
			if (_xml.hasOwnProperty("@EMAIL")) email = _xml.@EMAIL;
			//align = left,center,or right
			if (_xml.hasOwnProperty("@ALIGN")) align = _xml.@ALIGN;
			
			showTitle=(_xml.@VTITLE!="0");
			showVolume=(_xml.@VOL!="0");
			showPlay=(_xml.@PLAY!="0");
			showMute = (_xml.@MUTE != "0");
			if (SessionVars.editorMode == "SceneEditor")
			{
				showNext = _xml.@PREV!="0";
				showPrev = _xml.@NEXT!="0";
			}
			else
			{
				showNext = false;
				showPrev = false;
			}
			
			colorArr = new Array();
			var colVal:String;
			for (var i:int = 1; i <= 4; i++) {
				colVal = _xml.attribute("C" + i.toString());
				if (colVal.length>2) colorArr.push(parseInt(colVal,16))
				//else colArr.push(0);
			}
			
			if (_xml.hasOwnProperty("LEAD")) {
				type = SPSkinStruct.LEAD_TYPE;
				lead = new LeadConfiguration(_xml.LEAD[0], baseUrl);
				lead.email = email;
			}
			else if (_xml.hasOwnProperty("FAQ")) {
				type = SPSkinStruct.FAQ_TYPE;
				faq = new FAQConfiguration(_xml.FAQ[0], baseUrl);
			}
			else if (_xml.hasOwnProperty("AI")) {
				type = SPSkinStruct.AI_TYPE;
				ai = new AIConfiguration(_xml.AI[0]);
			}
			else type = SPSkinStruct.STANDARD_TYPE;
		}
		
		public function setFromSkin(skin:SPSkinStruct):void {
			if (skin == null) return;
			if (skin.type == null) return;			
			type = skin.type;
			colorArr = skin.selectedColorArr.slice();
			if (type == SPSkinStruct.AI_TYPE && ai == null) ai = new AIConfiguration();
			//else ai = null;
			if (type == SPSkinStruct.FAQ_TYPE && faq == null) faq = new FAQConfiguration();
			//else faq = null;
			if (type == SPSkinStruct.LEAD_TYPE && lead == null) lead = new LeadConfiguration();
			//else lead = null;
		}
		/*
		public function setXML(node:XML):void
		{
			align = node.@ALIGN;
			title = decodeURI(node.@TITLE);
			showTitle = node.@VTITLE == "1";
			showVolume = node.@VOL == "1";
			showPlay = node.@PLAY == "1";
			showMute = node.@MUTE == "1";
			
			if (SessionVars.editorMode == "SceneEditor")
			{
				showPrev = node.@PREV == "1";
				showNext = node.@NEXT == "1";				
			}
			else
			{
				showPrev = false;
				showNext = false;				
			}
			
			
			var colVal:String;
			for (var i:int = 1; i <= 4; i++) {
				colVal = node.attribute("C" + i.toString());
				if (colVal.length>2) colorArr.push(parseInt(colVal,16))
				//else colArr.push(0);
			}			
		}
		*/
		public function getXML():XML {
			var node:XML=new XML("<SKINCONF />");
			node.@ALIGN=align;
			node.@TITLE=encodeURI(title);
			node.@VTITLE=showTitle?"1":"0";
			node.@VOL=showVolume?"1":"0";
			node.@PLAY=showPlay?"1":"0";
			node.@MUTE=showMute?"1":"0";
			
			if (SessionVars.editorMode == "SceneEditor")
			{
				node.@PREV= showPrev?"1":"0";
				node.@NEXT = showNext?"1":"0";
			}
			else
			{
				node.@PREV="0";
				node.@NEXT = "0";
			}
			
			
			for (var i:int=0;i<colorArr.length;i++) {
				node["@C"+(i+1).toString()]="0x"+colorArr[i].toString(16);
			}
			//node.attributes.EMAIL=email;
			trace("type in getXMLNode: " + type)
			if (lead != null) node.appendChild(lead.getXML());
			if (faq != null) node.appendChild(faq.getXML());
			if (ai != null) node.appendChild(ai.getXML());
			
			return node;
		}
		
		private function strIsBlank(s:String):Boolean {
			if (s == null || s == "") return(true);
			else return(false);
		}
		
		public function validateConfig():AlertEvent {
			//returns null if skin passes validation, or an AlertEvent if there is a problem
			var alertEvt:AlertEvent = null;
			if (type == SPSkinStruct.FAQ_TYPE) {
				if (faq == null) trace("ERROR : SKIN IS FAQ TYPE BUT HAS NO FAQ DATA");
				if (faq.questions.length == 0) alertEvt = new AlertEvent(AlertEvent.ERROR, "sp502", "You must create at least one FAQ question");
				for (var i:uint=0;i<faq.questions.length;i++) {
					if (strIsBlank(faq.questions[i].question)) alertEvt = new AlertEvent(AlertEvent.ERROR, "sp503", "FAQ question name is blank");
					if (faq.questions[i].audio == null) alertEvt = new AlertEvent(AlertEvent.ERROR, "sp504","Please make sure you choose an audio for each FAQ question");
				}
			}
			else if (type == SPSkinStruct.LEAD_TYPE) {
				if (faq == null) trace("ERROR : SKIN IS LEAD TYPE BUT HAS NO LEAD DATA");				
				if (!EmailValidator.validate(lead.email)) alertEvt = new AlertEvent(AlertEvent.ERROR, "sp505","The lead skin requires a Recipient Email. Use the Functions tab to define");
				else if (strIsBlank(lead.btnText)) alertEvt = new AlertEvent(AlertEvent.ERROR, "sp506","Lead Send Button field is blank");
			}
			else if (type==SPSkinStruct.AI_TYPE) {
				if (faq == null) trace("ERROR : SKIN IS AI TYPE BUT HAS NO AI DATA");
				if (strIsBlank(ai.btnText)) alertEvt = new AlertEvent(AlertEvent.ERROR, "sp507","AI Button field is blank");
				else if (ai.voice == null)  alertEvt = new AlertEvent(AlertEvent.ERROR, "sp508","Please choose a voice for the AI Skin from the Skin Functions panel");
			}
			return(alertEvt);
		}
	}
	
}