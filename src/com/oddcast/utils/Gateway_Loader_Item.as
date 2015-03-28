package com.oddcast.utils
{
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*
	
	/**
	 * Item meant for downloading multiple types of data and casting for return
	 * @author Me^
	 */

	public class Gateway_Loader_Item implements IGateway_Item
	{
		public static const LOADER_TYPE_ASCII	:String = 'LOADER_TYPE_ASCII';
		public static const LOADER_TYPE_DISPLAY	:String = 'LOADER_TYPE_DISPLAY';
		
		/* keep track of the current loaded percent for this item, meant for overall process calculation */
		public var current_percent		:int				= 0;
		/* loader meant for ascii type files */
		private var urlloader			:URLLoader;
		/* loader meant for display type objects */
		private var loader				:Loader;
		/* since we have 2 loaders we attach listeners to this object */
		private var listener_dispatcher	:Object;
		/* listener manager for this single location */
		private var listener_manager	:Listener_Manager 	= new Listener_Manager();
		/* keeps track of how many times we have tried to load the object */
		private var current_load_attempt:int				= 0;
		/* loader request, which contains sending data as well */
		private var url_request			:URLRequest;
		/* requests are expected to timeout if not returned */
		private var event_expiration	:Event_Expiration	= new Event_Expiration();
		/* name of the event to use for the Event_Expiration class */
		private const EVENT_NAME		:String				= 'EXPIRATION EVENT NAME';
		
		public function Gateway_Loader_Item();
		public function get cur_percent():int
		{
			return current_percent;
		}
		/**
		 * downloads an object meant for display
		 * @param	_request	loading request
		 */
		public function start( _request:Gateway_Request, _progress_updated:Function, _loader_type:String ):void
		{
			if ( !request_is_valid() )
			{	
				if (_request.cb.error != null )	_request.cb.error('Invalid request.');	// notify caller
			}
			else
			{	
				build_request();
				build_loader();
				load();
				
				/**
				 * build the request for the loader and add the data to be sent if applicable based on type
				 */
				function build_request(  ):void 
				{	url_request = new URLRequest( _request.url );
					// if there is data for uploading add it to the request based on type
					if (_request.data_to_send)
					{	url_request.method = URLRequestMethod.POST;	// post the variables
						if 		(_request.data_to_send is URLVariables)	
																		{	url_request.data 		= _request.data_to_send;
																		}
						else if (_request.data_to_send is XML)
																		{	url_request.data		= _request.data_to_send.toXMLString();
																			url_request.contentType	= "text/xml";
																		}
						else if (_request.data_to_send is ByteArray)
																		{	url_request.data		= _request.data_to_send;
																			url_request.contentType	= "application/octet-stream";
																		}
					}
				}
				/**
				 * prepares the loader type for the intended type
				 */
				function build_loader():void 
				{	switch (_loader_type) 
					{	case LOADER_TYPE_DISPLAY:	loader = new Loader();
													listener_dispatcher = loader.contentLoaderInfo;
												break;
												
						case LOADER_TYPE_ASCII:		urlloader = new URLLoader();
													listener_dispatcher = urlloader;
													
													switch ( _request.type )
													{	case URLVariables:		urlloader.dataFormat = URLLoaderDataFormat.VARIABLES;		break;
														case ByteArray:			urlloader.dataFormat = URLLoaderDataFormat.BINARY;			break;
														default:				urlloader.dataFormat = URLLoaderDataFormat.TEXT;
													}
												break;
						default:	throw new Error('Gateway_Loader_Item :: Invalid loader type');
					}
				}
				/**
				 * request the loading of the item based on the loader type
				 */
				function load(  ):void 
				{	add_load_listeners();
					processing_started();
					try
					{	switch (_loader_type) 
						{	case LOADER_TYPE_DISPLAY:	loader.load( url_request, _request.context );
														break;
							case LOADER_TYPE_ASCII:		urlloader.load( url_request );
														break;
							default:	throw new Error('Gateway_Loader_Item :: Invalid loader type');
						}
						event_started();
					}
					catch (err:Error)	
					{	error(new ErrorEvent(ErrorEvent.ERROR, false, false, err.message));	}
				}
			}
			/**
			 * item has successfully downloaded
			 * @param	_e
			 */
			function loaded( _e:Event ):void 
			{	remove_listeners();
				event_occurred();
				if (_request.cb.fin != null)	// if we have fin function expecting the loaded object
				{	try		// try to build the object for the intended return type
					{	var loaded_obj:*;
						switch ( _request.type )	// different objects different casting/instantiating mechanisms
						{	case XML:			loaded_obj = new XML(urlloader.data);			break;
							case URLVariables:	loaded_obj = urlloader.data as URLVariables;	break;
							case ByteArray:		loaded_obj = urlloader.data as ByteArray;		break;
							case String:		loaded_obj = urlloader.data as String;			break;
							case Object:		loaded_obj = loader.content as Object;			break;
							case Loader:		loaded_obj = loader;							break;
							case URLLoader:		loaded_obj = urlloader;							break;
							case Bitmap:		loaded_obj = loader.content as Bitmap;			break;
							default:			switch ( _loader_type )	// usually for uploads
												{	case LOADER_TYPE_DISPLAY:	loaded_obj = loader;			break;
													case LOADER_TYPE_ASCII:		loaded_obj = urlloader.data;	break;	// type is String usually
													default:					loaded_obj = null;	// ok i give up
												}
						}
					}
					catch (_e:Error)
					{
						error( new ErrorEvent(ErrorEvent.ERROR, false, false, 'cannot create intended object ' + _request.type) );
					}
						
					if (loaded_obj &&	// if we have a valid object instantiated
						custom_caller_evaluation_passed( loaded_obj ))	// the callers function approves this response
					{	
						// end all processing and notify caller with results
						processing_complete();
						{	if (_request.key)	_request.cb.fin( loaded_obj, _request.key );
							else				_request.cb.fin( loaded_obj );
						}
						destroy_references();
						
						function destroy_references():void
						{
							_request = null;
							_loader_type = null;
							_progress_updated = null;
							listener_dispatcher = null;
							listener_manager = null;
							event_expiration = null;
							url_request = null;
							loaded_obj = null;
							loader = null;
							urlloader = null;
						}
					}
				}
				/**
				 * loading progrress has updates
				 * @param	_e
				 */
				function progress( _e:ProgressEvent ):void 
				{	current_percent = (_e.bytesTotal == 0) ? 0 : (_e.bytesLoaded / _e.bytesTotal) * 100;	// store current percantage
					if (_request.cb.progress != null)	_request.cb.progress( current_percent );	// notify caller
					if (_progress_updated != null)		_progress_updated();	// notify factory class to update overall percentage
				}
				/**
				 * an error loading has occurred
				 * @param	_e
				 */
				function error( _e:Event ):void 
				{	event_occurred();
					remove_listeners();
					if (++current_load_attempt > _request.retries)	// no retries left
					{	processing_complete();
						if (_request.cb.error != null )	
							_request.cb.error(_e.toString());	// notify caller
					}
					else	
						setTimeout(load, _request.retry_delay);	// retry again with a delay
				}
			}
			/**
			 * loading progrress has updates
			 * @param	_e
			 */
			function progress( _e:ProgressEvent ):void 
			{	current_percent = (_e.bytesTotal == 0) ? 0 : (_e.bytesLoaded / _e.bytesTotal) * 100;	// store current percantage
				if (_request.cb.progress != null)	_request.cb.progress( current_percent );	// notify caller
				if (_progress_updated != null)		_progress_updated();	// notify factory class to update overall percentage
			}
			/**
			 * an error loading has occurred
			 * @param	_e
			 */
			function error( _e:Event ):void 
			{	event_occurred();
				remove_listeners();
				if (++current_load_attempt > _request.retries)	// no retries left
				{	processing_complete();
					if (_request.cb.error != null )	_request.cb.error(_e.toString());	// notify caller
				}
				else	setTimeout(load, _request.retry_delay);	// retry again with a delay
			}
			/**
			 * needed to catch events when the network is diconnected
			 * @param	_e
			 */
			function http_status( _e:HTTPStatusEvent ):void { }
			
			function add_load_listeners(  ):void 
			{	listener_manager.add(listener_dispatcher, Event.COMPLETE					, loaded		, this);
				listener_manager.add(listener_dispatcher, IOErrorEvent.IO_ERROR				, error			, this);
				listener_manager.add(listener_dispatcher, IOErrorEvent.NETWORK_ERROR		, error			, this);
				listener_manager.add(listener_dispatcher, SecurityErrorEvent.SECURITY_ERROR	, error			, this);
				listener_manager.add(listener_dispatcher, ProgressEvent.PROGRESS			, progress		, this);
				listener_manager.add(listener_dispatcher, HTTPStatusEvent.HTTP_STATUS		, http_status	, this);
			}
			function remove_listeners():void 
			{	listener_manager.remove_all_listeners_on_object( listener_dispatcher );
			}
			/**
			 * set processing and notify factory to calculate overall processing
			 */
			function processing_started(  ):void 
			{	current_percent = 0;
				if (_progress_updated != null)	_progress_updated();	// notify factory class if available
			}
			/**
			 * this is mainly meant for the factory class (Gateway) to know what the status of each item is
			 * for calculating the overall percent.... this should be called on error and on complete
			 */
			function processing_complete(  ):void 
			{	if (current_percent < 100)	// we dont have to tell them its done if its already at 100... it means factory was already been notified
				{	current_percent = 100;	// indicates that the loading for this item has finished
					if (_progress_updated != null)	_progress_updated();	// notify factory class if available
				}
			}
			/**
			 * validate the usability of the request
			 * @return
			 */
			function request_is_valid():Boolean
			{	var is_valid:Boolean = 
				(
					_loader_type &&
					( 	_loader_type == LOADER_TYPE_ASCII ||
						_loader_type == LOADER_TYPE_DISPLAY
					) &&
					_request &&
					_request.url &&
					_request.url.length > 0
				)
				return is_valid;
			}
			/**
			 * start the timer if one is present
			 */
			function event_started(  ):void 
			{	if (_request.timeout_ms > 0)
				{	event_expiration.add_event( EVENT_NAME, _request.timeout_ms, event_timed_out );
				}
			}
			/**
			 * the request has produced an error or completed successfully
			 */
			function event_occurred(  ):void 
			{	event_expiration.remove_event( EVENT_NAME );
			}
			/**
			 * we have not received a response from the request in the allowed time frame
			 */
			function event_timed_out(  ):void 
			{	error( new ErrorEvent(ErrorEvent.ERROR, false, false, 'request has timed out') );
			}
		}
	}
}