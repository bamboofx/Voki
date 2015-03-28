package com.voki.data {
	import com.oddcast.audio.AudioData;
	import com.voki.data.FAQQuestion;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class FAQConfiguration {
		public var questions:Array;
		private var _sBaseUrl:String;
		
		public function FAQConfiguration(_xml:XML = null,baseUrl:String=""):void {
			if (_xml != null) setFromXML(_xml,baseUrl);
			else questions = [];
		}
		
			/*<FAQ>
	<Q NAME="112" ID="19780" URL="user/070/1460/audio/1179957902042_1460">how+high+can+you+count%3F</Q>
	<Q NAME="3012" ID="13326" URL="user/070/1460/audio/1174324188898_1460">what%3F</Q>
	<Q NAME="a" ID="17913" URL="user/070/1460/audio/1174324094797_1460">what+turns+yorur+crank%3F</Q>
	<Q NAME="bish+test+05+23" ID="19778" URL="user/070/1460/audio/1179957396612_1460">live+or+staging%3F</Q>
	</FAQ>*/
		public function setFromXML(_xml:XML,baseUrl:String):void {
			questions=new Array();
			var qtxt:String;
			var audName:String;
			var audId:int;
			var audUrl:String;
			var node:XML;
			var audioResponse:AudioData;
			for (var i:uint=0;i<_xml.Q.length();i++) {
				node=_xml.Q[i];
				qtxt=unescape(decodeURI(node.toString()));
				audId = parseInt(node.@ID.toString());
				if (audId>0) {
					audName = unescape(node.@NAME);
					audUrl = baseUrl + node.@URL.toString();
					audioResponse=new AudioData(audUrl,audId,null,audName);
				}
				else audioResponse = null;
				questions.push(new FAQQuestion(qtxt, audioResponse));
			}
			_sBaseUrl = baseUrl;
		}
		
		public function getXML(sceneEditor:Boolean = false):XML {
			var node:XML=new XML("<FAQ />");
			var qnode:XML;
			var question:FAQQuestion;
			for (var i:uint = 0; i < questions.length; i++) {
				question = questions[i];
				qnode=new XML("<Q>"+encodeURI(question.question)+"</Q>");
				qnode.@INDEX=(i+1).toString();
				if (question.audio==null) {
					if (sceneEditor)
					{
						qnode.@AUID = "-1";
					}
					else
					{
						qnode.@ID="-1";
						qnode.@URL = "";
						qnode.@NAME = "";
					}
				}
				else {
					if (sceneEditor)
					{
						qnode.@AUID=question.audio.id.toString();
					}
					else
					{
						qnode.@ID = question.audio.id.toString();
						//remove the base url if present
						if (_sBaseUrl != null)
						{
							qnode.@URL = question.audio.url.split(_sBaseUrl).pop();
						}
						else
						{
							qnode.@URL = question.audio.url;
						}
						qnode.@NAME = escape(question.audio.name);
					}
				}
				node.appendChild(qnode);
			}
			return(node);
		}
				
	}
	
}