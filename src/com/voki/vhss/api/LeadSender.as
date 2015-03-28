package com.voki.vhss.api
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import com.voki.vhss.Constants;
	import com.voki.vhss.DataLoader;
	import com.voki.vhss.events.DataLoaderEvent;
	import com.voki.vhss.structures.SceneStruct;
	import com.voki.vhss.structures.SlideShowStruct;

	public class LeadSender extends EventDispatcher
	{
		private var lead_ldr:DataLoader;
		private var lead_xml:XML;
		
		public function LeadSender()
		{
			
		}
		
		public function sendLead($ld_obj:Object, $show:SlideShowStruct, $scene:SceneStruct):void
		{
			//for (var i:String in $ld_obj)
			lead_xml = <SKINLEAD SHOWID="" SLIDEID="" SKINID="" ACC="" DOOR="" ACCTYPE="" TITLE=""/>;
			lead_xml.@SHOWID = $show.show_id;
			lead_xml.@SLIDEID = $scene.id;
			lead_xml.@SKINID = $scene.skin.id;
			lead_xml.@ACC = $show.account_id;
			lead_xml.@DOOR = $show.door_id;
			lead_xml.@ACCTYPE = $show.edition_id;
			lead_xml.@TITLE = $scene.title;
			var t_xml:XML = $ld_obj.xml;
			for (var i:Number = 0; i < t_xml.child("F").length(); ++i)
			{
				if ($ld_obj["tf"+(i+1)] != null) 
				{
					t_xml.child("F")[i] = $ld_obj["tf"+(i+1)];
				}
			}
			lead_xml.appendChild(t_xml);
			lead_ldr = new DataLoader();
			var t_req:URLRequest = new URLRequest(Constants.VHSS_DOMAIN + Constants.SEND_LEAD_PHP);
			t_req.method = URLRequestMethod.POST;
			t_req.data = lead_xml.toXMLString();
			t_req.contentType = "text/xml";
			lead_ldr.addEventListener(DataLoaderEvent.ON_DATA_READY, e_dataReady);
			//----trace("LEADSENDER --- send lead : "+ lead_xml);
			lead_ldr.load(t_req, "lead");
		}
		
		private function e_dataReady($ev:DataLoaderEvent):void
		{
			//----trace("LEADSENDER --- RESPONSE -- "+$ev.data);
			dispatchEvent($ev);
		}
		
	}
}