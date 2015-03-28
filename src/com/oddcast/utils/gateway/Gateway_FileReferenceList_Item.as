package com.oddcast.utils.gateway 
{
	import com.oddcast.utils.Listener_Manager;
	import com.oddcast.workshop.*;
	
	import flash.events.*;
	import flash.net.*;

	/**
	 * ...
	 * @author Me^
	 */
	public class Gateway_FileReferenceList_Item implements IGateway_Item
	{
		/* current overall percent of all uploads */
		private var current_percent		:int = 0;
		private var file_ref_list		:FileReferenceList;
		/* listener manager for this single location */
		private var listener_manager	:Listener_Manager 	= new Listener_Manager();
		/* array of Gateway_FileReferenceList_Pending_Item */
		private var pending_files		:Array;
		
		public function Gateway_FileReferenceList_Item() 
		{}
		/**
		 * external call to get this processes progress
		 * @return
		 */
		public function get cur_percent(  ):int
		{
			return current_percent;
		}
		/**
		 * 
		 * @param	_callbacks
		 * @param	_cancel_callback
		 * @param	_max_files
		 * @param	_progress_updated
		 * @param	_upload_image_script
		 * @param	_get_uploaded_image_script
		 * @param	_max_file_byte_size
		 * @param	_min_file_byte_size
		 * @param	_max_file_pixel_size
		 * @param	_min_file_pixel_size
		 */
		public function start(
								_callbacks:Callback_Struct,
								_cancel_callback:Function,
								_file_filter:FileFilter,
								_max_files:int,
								_progress_updated:Function, 
								_upload_image_script:String,
								_get_uploaded_image_script:String,
								_max_file_byte_size:Number,
								_min_file_byte_size:Number,
								_max_file_pixel_size:Number,
								_min_file_pixel_size:Number,
								_convert_uploaded_images:Boolean
							):void
		{
			if ( request_is_valid() )
			{
				//_callbacks.fin(['http://www.freddysrevenge.co.uk/Finny.jpg']); // FAKE CALLBACK
				
				file_ref_list = new FileReferenceList();
				manage_browse_listeners( true );
				try // usually fails bc its not on a UIA (mouse click)
				{
					file_ref_list.browse( [_file_filter] );
				}
				catch(_e:Error)
				{
					browse_event_handler(new Event(Event.CANCEL));// handle it silently
				}
			}
			else
				error( Gateway.ERROR_FILE_REF_NOT_INITIALIZED );
				
			/**
			 * validates if we have enough information to proceed with the process
			 * @return
			 */
			function request_is_valid(  ):Boolean
			{
				return (
							_callbacks &&
							_callbacks.fin &&
							_file_filter &&
							_max_files &&
							_upload_image_script &&
							_upload_image_script.indexOf('://') > 0 &&
							_get_uploaded_image_script &&
							_get_uploaded_image_script.indexOf('://') > 0 &&
							_max_file_byte_size &&
							_min_file_byte_size &&
							_max_file_pixel_size &&
							_min_file_pixel_size
						);
			}
			function manage_browse_listeners( _add:Boolean ):void
			{
				if (_add)
				{
					listener_manager.add( file_ref_list, Event.SELECT, browse_event_handler, this);
					listener_manager.add( file_ref_list, Event.CANCEL, browse_event_handler, this);
				}
				else
				{
					listener_manager.remove( file_ref_list, Event.SELECT, browse_event_handler);
					listener_manager.remove( file_ref_list, Event.CANCEL, browse_event_handler);
				}
			}
			function browse_event_handler( _e:Event ):void
			{
				manage_browse_listeners( false );
				switch ( _e.type )
				{	
					case Event.SELECT:	
						upload_selected_files();	
						break;
					case Event.CANCEL:
						processing_complete();
						if (_cancel_callback != null)
							_cancel_callback();
						destroy();
						break;
				}
			}
			function error( _msg:String, _error_obj:Object = null ):void
			{
				processing_complete();
				if (_callbacks && _callbacks.error != null)
					_callbacks.error( _msg, _error_obj );	
				destroy();
			}
			function upload_selected_files(  ):void
			{
				if (selected_files_are_valid())
				{
					pending_files = new Array();
					for (var n:int = file_ref_list.fileList.length, i:int = 0; i < n; i++)
						store_and_start_pending_file(file_ref_list.fileList[i]);
				}
				
				function store_and_start_pending_file( _file:FileReference ):void
				{
					var pending_file:Gateway_FileReferenceList_Pending_Item = new Gateway_FileReferenceList_Pending_Item( _file )
					pending_files.push( pending_file );
					manage_file_ref_listeners( _file, true );
					var upload_api:String = _upload_image_script + 
											'?sessId=' + pending_file.session_key() + 
											'&minW=' + _min_file_pixel_size + 
											'&minH=' + _min_file_pixel_size +
											'&maxW=' + _max_file_pixel_size + 
											'&maxH=' + _max_file_pixel_size +
											'&convertImage=' + _convert_uploaded_images.toString();
					_file.upload( new URLRequest(upload_api) );
				}
				
				function manage_file_ref_listeners( _file:FileReference, _add:Boolean ):void
				{
					if (_add)
					{
						listener_manager.add( _file, Event.OPEN, handler_file_ref_open, this);
						listener_manager.add( _file, Event.COMPLETE, handler_file_ref_complete, this);
						listener_manager.add( _file, IOErrorEvent.DISK_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, IOErrorEvent.IO_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, IOErrorEvent.NETWORK_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, IOErrorEvent.VERIFY_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, ProgressEvent.PROGRESS, handler_file_ref_progress, this);
						listener_manager.add( _file, SecurityErrorEvent.SECURITY_ERROR, handler_file_ref_security_error, this);
					}
					else
					{
						listener_manager.remove( _file, Event.OPEN, handler_file_ref_open);
						listener_manager.remove( _file, Event.COMPLETE, handler_file_ref_complete);
						listener_manager.remove( _file, IOErrorEvent.DISK_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, IOErrorEvent.IO_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, IOErrorEvent.NETWORK_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, IOErrorEvent.VERIFY_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, ProgressEvent.PROGRESS, handler_file_ref_progress);
						listener_manager.remove( _file, SecurityErrorEvent.SECURITY_ERROR, handler_file_ref_security_error);
					}
				}
				
				function handler_file_ref_open( _e:Event ):void
				{
					var file:FileReference	= FileReference(_e.target);
				}
				function handler_file_ref_complete( _e:Event ):void
				{
					var file:FileReference	= FileReference(_e.target);
					for (var n:int = pending_files.length, i:int = 0; i < n; i++)
					{
						var pending_file_item:Gateway_FileReferenceList_Pending_Item = pending_files[i];
						if (pending_file_item.file.name == file.name)
						{
							pending_file_item.retrieve_url( _get_uploaded_image_script, new Callback_Struct(item_url_retrieved, null, error ) );
							return;
						}
					}
					
					function item_url_retrieved(  ):void
					{
						var uploaded_url_list:Array = new Array();
						if (pending_files) // this could have been destroyed previously due to an error
							for (var n:int = pending_files.length, i:int = 0; i < n; i++)
							{
								var pending_file:Gateway_FileReferenceList_Pending_Item = pending_files[i];
								if (pending_file.uploaded_url)
									uploaded_url_list.push( { url:pending_file.uploaded_url, thumb:pending_file.uploaded_url_thumb } );
								else
									return;
							}
						if (_callbacks && _callbacks.fin != null)
							_callbacks.fin( uploaded_url_list );
						processing_complete();
						destroy();
					}
				}
				/**
				 * independent files progress has been updated
				 * @param	_e
				 */
				function handler_file_ref_progress( _e:ProgressEvent ):void
				{
					var file:FileReference	= FileReference(_e.target);
					var item_percent:int	= ( _e.bytesLoaded * 100 ) / _e.bytesTotal;
					var total_percent:int	= 0;
					
					for (var n:int = pending_files.length, i:int = 0; i < n; i++)
					{
						// find the file whos progress was update it and save the percent for that file
						var pending_file_item:Gateway_FileReferenceList_Pending_Item = pending_files[i];
						if (pending_file_item.file.name == file.name)
							pending_file_item.percent = item_percent;
						
						// tally up all files percentages
						total_percent += pending_file_item.percent;
					}
					// calculate total percent per how many files exist
					total_percent = total_percent / pending_files.length;
					if (total_percent == 100)	total_percent = 99;	// a little hack to keep the loader on screen
					// save the total percent for querying by the UI
					current_percent = total_percent;
					if (_progress_updated != null)
						_progress_updated();
				}
				function handler_file_ref_io_error( _e:IOErrorEvent ):void
				{
					error( Gateway.ERROR_UPLOADING_TO_SERVER );
				}
				function handler_file_ref_security_error( _e:SecurityErrorEvent ):void
				{
					error( Gateway.ERROR_SECURITY_UPLOADING );
				}
				
				function selected_files_are_valid(  ):Boolean
				{
					var files_meet_byte_restriction:Boolean = true;
					var files_meet_number_restriction:Boolean = true;
					var fileslist:Array = file_ref_list.fileList;		// 4 DEBUGING... REMOVE WHEN DONE
					if (file_ref_list && file_ref_list.fileList)
					{
						for (var n:int = file_ref_list.fileList.length, i:int = 0; i < n; i++)
						{
							var file:FileReference = file_ref_list.fileList[i];
							if		(file.size <= _min_file_byte_size)	{	error( Gateway.ERROR_FILESIZE_TOO_SMALL_BYTES );	files_meet_byte_restriction = false;	break; }
							else if (file.size > _max_file_byte_size)	{	error( Gateway.ERROR_FILESIZE_TOO_BIG_BYTES );		files_meet_byte_restriction = false;	break; }
						}
					}
					if (
							file_ref_list && 
							file_ref_list.fileList && 
							file_ref_list.fileList.length > _max_files
						)
					{
						files_meet_number_restriction = false;
						error( Gateway.ERROR_TOO_MANY_FILES_SELECTED );
					}
					return (
								files_meet_byte_restriction &&
								file_ref_list &&
								file_ref_list.fileList &&
								file_ref_list.fileList.length <= _max_files
							);
				}
			}
			function destroy(  ):void
			{
				if (listener_manager)
					listener_manager.remove_all_listeners_ever_added();
				listener_manager = null;
				file_ref_list = null;
				pending_files = null;
				_callbacks = null;
				_cancel_callback = null;
				_file_filter = null;
				_progress_updated = null;
			}
			function processing_complete(  ):void 
			{	if (current_percent < 100)	// we dont have to tell them its done if its already at 100... it means factory was already been notified
				{	current_percent = 100;	// indicates that the loading for this item has finished
					if (_progress_updated != null)	_progress_updated();	// notify factory class if available
				}
			}
		}
		
	}

}