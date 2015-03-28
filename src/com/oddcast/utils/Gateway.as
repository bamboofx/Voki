package com.oddcast.utils
{
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	/**
	 * purpose is meant for downloading any images, swfs etc
	 * @author Me^
	 */
	public class Gateway
	{
		/* minimum requirement for XML uploads */
		private static var min_xml_retries		:int = 1;
		/* delay between retries */
		private static var retry_delay			:Number = 1000;
		/* function to be notified of the overall percentage for current active items */
		private static var overall_progress_cb	:Function;
		/* list of active items meant for calculating overall percentage */
		private static var arr_loader_items		:Array = [];
		private static var upload_image_script	:String;
		private static var get_uploaded_image_script:String;
		private static var max_file_byte_size	:Number;
		private static var min_file_byte_size	:Number;
		private static var max_file_pixel_size	:Number;
		private static var min_file_pixel_size	:Number;
		private static var convert_uploaded_images	:Boolean;
		
		public static const ERROR_FILESIZE_TOO_SMALL_BYTES	:String = 'ERROR_FILESIZE_TOO_SMALL_BYTES';
		public static const ERROR_FILESIZE_TOO_BIG_BYTES	:String = 'ERROR_FILESIZE_TOO_BIG_BYTES';
		public static const ERROR_FILE_REF_NOT_INITIALIZED	:String = 'ERROR_FILE_REF_NOT_INITIALIZED';
		public static const ERROR_SECURITY_UPLOADING		:String = 'ERROR_SECURITY_UPLOADING';
		public static const ERROR_UPLOADING_TO_SERVER		:String = 'ERROR_UPLOADING_TO_SERVER';
		public static const ERROR_TOO_MANY_FILES_SELECTED	:String = 'ERROR_TOO_MANY_FILES_SELECTED';
		/*                 
		*
		*
		*
		*
		*
		*
		******************************** INIT ****/
		/**
		 * initialization
		 * @param	_overall_progress_cb	sets the method which will be notified of the total percent of current status
		 * @param	_retry_delay			milliseconds for the delay between retries
		 */
		public static function init(
										_overall_progress_cb:Function, 
										_retry_delay:Number = 1000, 
										_min_xml_retries:int = 1,
										_upload_image_script:String = null,			// http://host.staging.oddcast.com/api/upload_v3.php?sessId=cd2ca5a7184eaf36f00c3e5b1e9d8839&convertImage=true&minW=64&minH=64&maxW=5000&maxH=5000
										_get_uploaded_image_script:String = null,	// http://host.staging.oddcast.com/api/getUploaded_v3.php?sessId=cd2ca5a7184eaf36f00c3e5b1e9d8839
										_max_file_byte_size:Number = 6 * 1024 * 1024, // 6MB
										_min_file_byte_size:Number = 10 * 1024, // 10KB
										_max_file_pixel_size:Number = 5000,
										_min_file_pixel_size:Number = 64,
										_convert_uploaded_images:Boolean = true
									):void 
		{	
			overall_progress_cb 		= _overall_progress_cb;
			min_xml_retries				= _min_xml_retries;
			retry_delay					= _retry_delay;
			upload_image_script			= _upload_image_script;
			get_uploaded_image_script	= _get_uploaded_image_script;
			max_file_byte_size			= _max_file_byte_size;
			min_file_byte_size			= _min_file_byte_size;
			max_file_pixel_size			= _max_file_pixel_size;
			min_file_pixel_size			= _min_file_pixel_size;
			convert_uploaded_images		= _convert_uploaded_images;
		}   
		/*************************************
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		******************************** DOWNLOAD API ****/
		/**
		 * downloads the url and provides an XML type object in the callback.fin method
		 * @param	_url		url to be requested
		 * @param	_callbacks	callbacks { fin(XML) | progress(int) | error(String) }
		 * @param	_response_eval_method	custom method used to pre-evaluate the XML response before calling fin
		 * eg: see Gateway_Request.response_eval_method for syntax
		 * @param	_background_process		the processing screen will not be notified of this progress
		 */
		public static function retrieve_XML( _url:String, _callbacks:Callback_Struct, _response_eval_method:Function = null, _background_process:Boolean = false ):void 
		{
			var request:Gateway_Request = new Gateway_Request( _url, _callbacks );
			request.type					= XML;
			request.response_eval_method	= _response_eval_method;
			request.background				= _background_process;
			if (request.retries < min_xml_retries)	// minimum retries
				request.retries = min_xml_retries;
			start_request( request, Gateway_Loader_Item.LOADER_TYPE_ASCII );
		}
		/**
		 * downloads the url and provides a Bitmap type object in the callback.fin method
		 * NOTE: this works only for same domain loads, for external domains use retrieve_Loader(..)
		 * @param	_url		url to be requested
		 * @param	_callbacks	callbacks { fin(Bitmap) | progress(int) | error(String) }
		 */
		public static function retrieve_Bitmap( _url:String, _callbacks:Callback_Struct ):void 
		{
			var request:Gateway_Request = new Gateway_Request( _url, _callbacks );
			request.type = Bitmap;
			start_request( request, Gateway_Loader_Item.LOADER_TYPE_DISPLAY );
		}
		/**
		 * downloads the url and provides a Loader type object in the callback.fin method for accessing the content for more control over casting
		 * @param	_url		url to be requested
		 * @param	_callbacks	callbacks { fin(Loader) | progress(int) | error(String) }
		 */
		public static function retrieve_Loader( _request:Gateway_Request ):void 
		{
			_request.type = Loader;
			start_request( _request, Gateway_Loader_Item.LOADER_TYPE_DISPLAY );
		}
		/**
		 * downloads the url and provides an URLLoader type object in the callback.fin method for accessing the content for more control over casting
		 * @param	_url		url to be requested
		 * @param	_callbacks	callbacks { fin(URLLoader) | progress(int) | error(String) }
		 */
		public static function retrieve_URLLoader( _request:Gateway_Request ):void 
		{
			_request.type = URLLoader;
			start_request( _request, Gateway_Loader_Item.LOADER_TYPE_ASCII );
		}
		/**
		 * downloads the url and provides an URLLoader type object in the callback.fin method for accessing the content for more control over casting
		 * @param	_url		url to be requested
		 * @param	_callbacks	callbacks { fin(URLLoader) | progress(int) | error(String) }
		 */
		public static function retrieve_URLVariables( _request:Gateway_Request ):void 
		{
			_request.type = URLVariables;
			start_request( _request, Gateway_Loader_Item.LOADER_TYPE_ASCII );
		}
		/*************************************
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		******************************** UPLOAD API ****/
		/**
		 * send data to the server and retrieve a response
		 * @param	_upload_data	data such as URLVariables | XML | ByteArray
		 * @param	_request		upload data information regarding this request
		 */		
		public static function upload( _upload_data:*, _request:Gateway_Request ):void 
		{	_request.type = null;
			_request.data_to_send = _upload_data;
			start_request( _request, Gateway_Loader_Item.LOADER_TYPE_ASCII );
		}
		/**
		 * creates and uploads a fileReferenceList object 
		 * @param _callbacks	fin(array of urls), error, progress
		 * @param _max_files	int of max allowed files
		 * @param _file_filter	type fo files
		 * @param _cancel_handler	callback if the user selects cancel on the browse window
		 * 
		 */		
		public static function upload_fileReferenceList( 
															_callbacks	:Callback_Struct, 
															_max_files	:int = 1,
															_file_filter:FileFilter = null,
															_cancel_handler:Function = null
														):void
		{
			if (!_file_filter)
				_file_filter = new FileFilter("Images (*.jpg *.jpeg *.gif *.png)", "*.jpg;*.jpeg;*.gif;*.png")
				
			var fileref_list_uploader_item:Gateway_FileReferenceList_Item = new Gateway_FileReferenceList_Item();
			arr_loader_items.push( fileref_list_uploader_item );
			fileref_list_uploader_item.start(
												_callbacks, 
												_cancel_handler,
												_file_filter, 
												_max_files, 
												item_progress_changed, 
												upload_image_script, 
												get_uploaded_image_script, 
												max_file_byte_size, 
												min_file_byte_size, 
												max_file_pixel_size, 
												min_file_pixel_size,
												convert_uploaded_images
											);
		}
		/*************************************
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		*
		******************************** PRIVATEEEERS ****/
		/**
		 * process a specific request
		 * @param	_request
		 * @param	_loader_type
		 */
		private static function start_request( _request:Gateway_Request, _loader_type:String ):void 
		{	// add init defaults.. retries etc
			if (_request.background)	
			{	new Gateway_Loader_Item().start( _request, null, _loader_type );// we dont notify the processing screen of its progress
			}
			else
			{	var loader_item:Gateway_Loader_Item =  new Gateway_Loader_Item()
				arr_loader_items.push( loader_item );	// notify the processing screen of its progress
				loader_item.start( _request, item_progress_changed, _loader_type );
			}
		}
		/**
		 * an item out of the lists progress has been updated
		 */
		private static  function item_progress_changed(  ):void 
		{	
			if (overall_progress_cb != null &&	// only if we have something that cares about this
				arr_loader_items.length > 0)	// only if we have items in the list... its a bahhh (bug) when the loader finishes it calls 100% several times and the item list is cleared
			{	
				var total_percent:int;
				for (var n:int = arr_loader_items.length , i:int = 0; i < n; i++)
				{	
					var cur_item:IGateway_Item = arr_loader_items[i];
					total_percent += cur_item.cur_percent;
				}
				var overall_percent:int = total_percent / arr_loader_items.length;
				overall_progress_cb( overall_percent );
				trace('(Oo) :: com.oddcast.utils.Gateway.item_progress_changed() :: overall_percent=',overall_percent);
				
				// clear list if all items are loaded or errored
				if (overall_percent == 100)
				{
					arr_loader_items = [];
					overall_percent = 0;
				}
			}
		}
		/*************************************
		*
		*
		*
		*
		*
		*
		*/
	}

}