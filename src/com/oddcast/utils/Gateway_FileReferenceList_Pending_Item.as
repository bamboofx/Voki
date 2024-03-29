﻿package com.oddcast.utils 
{
	import com.oddcast.encryption.*;
	import com.oddcast.workshop.*;
	import flash.net.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Gateway_FileReferenceList_Pending_Item
	{
			public var file:FileReference;
			public var percent:int = 0;
			public var uploaded_url:String;
			public var uploaded_url_thumb:String;
			private var session:String;
		
		public function Gateway_FileReferenceList_Pending_Item(_file:FileReference) 
		{
			file = _file;
		}
		public function session_key(  ):String
		{
			if (!session)
			{
				var cur_time:Number = (new Date()).time;
				var rand:String = Math.floor(Math.random() * 1000).toString();
				session = (new md5().hash(cur_time.toString() + rand));
			}
			return session;
		}
		public function retrieve_url( _get_uploaded_image_script:String, _callbacks:Callback_Struct ):void
		{
			var get_uploaded_url:String = _get_uploaded_image_script + '?sessId=' + session_key() + '&build_thumb=1';
			//var request:Gateway_Request = new Gateway_Request( get_uploaded_url, new Callback_Struct( fin, null, _callbacks.error ))
			//request.background = true;
			//request.response_eval_method = function(_response:XML):Boolean	{ return (_response && (_response.name() == "FILE" || (_response.@CODE && _response.@ERRORSTR))); };
			//Gateway.download_XML( request );
			
			Gateway.retrieve_XML
			( 
				get_uploaded_url, 
				new Callback_Struct( fin, null, _callbacks.error ),
				function(_response:XML):Boolean	{ return (_response && (_response.name() == "FILE" || (_response.@CODE && _response.@ERRORSTR))); },
				true
			);
			function fin( _content:XML ):void 
			{	
				if (_content.name() == 'FILE')
				{
					uploaded_url = _content.@URL.toString();
					if (_content.@THUMB)
						uploaded_url_thumb = _content.@THUMB.toString();
					if (_callbacks && _callbacks.fin != null)
						_callbacks.fin();
				}
				else
				{
					var err_code:String = _content.@CODE.toString() 	? _content.@CODE.toString() 	: 'f9tp532';	// if the response is blank
					var err_msg	:String = _content.@ERRORSTR.toString() ? _content.@ERRORSTR.toString() : 'blank response from script: ' + get_uploaded_url;
					if (_callbacks && _callbacks.error != null)
						_callbacks.error( null, { code:err_code, msg:err_msg } );
				}
			}
		}
	}
}