package
{
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	
	/**
	 * A queue-based static file browser which avoids Error #2041 when performing File browsing operations.
	 * @author Gimmick
	 */
	public class QueuedFileBrowser 
	{
		public static const SAVE:String = "saveFile";
		public static const OPEN:String = "openFile";
		public static const OPEN_MULTIPLE:String = "openMultiple";
		public static const OPEN_DIRECTORY:String = "openDirectory";
		
		private static var b_available:Boolean;
		private static const arr_queue:Array = [];
		private static const fl_browser:File = new File()
		
		static:
		{
			b_available = true;
			fl_browser.addEventListener(Event.CANCEL, bindEventFunction(function(data:FileBrowserData):Function { 
				return data.onCancel;
			}));
			fl_browser.addEventListener(Event.SELECT, bindEventFunction(function(data:FileBrowserData):Function { 
				return data.onSelect;
			}));
			fl_browser.addEventListener(IOErrorEvent.IO_ERROR, bindEventFunction(function(data:FileBrowserData):Function { 
				return data.onError;
			}));
			fl_browser.addEventListener(FileListEvent.SELECT_MULTIPLE, bindEventFunction(function(data:FileBrowserData):Function { 
				return data.onSelect;
			}));
			fl_browser.addEventListener(SecurityErrorEvent.SECURITY_ERROR, bindEventFunction(function onError(data:FileBrowserData):Function { 
				return data.onError;
			}));
		}
		
		public function QueuedFileBrowser() { }
		
		private static function tryRunNext():void 
		{
			if (!(isAvailable && arr_queue.length)) {
				return;
			}
			const currMethod:FileBrowserData = arr_queue[0];
			const defaultLocation:String = currMethod.defaultLocation
			if (defaultLocation)
			{
				try {
					fl_browser.url = defaultLocation
				}
				catch(err:Error) {	/*do nothing if file url is invalid*/ }
			}
			
			const typeFilter:Array = currMethod.typeFilter;
			const title:String = currMethod.title;
			try
			{
				b_available = false;
				switch(currMethod.type)
				{
					case OPEN:
						fl_browser.browseForOpen(title, typeFilter)
						break;
					case OPEN_MULTIPLE:
						fl_browser.browseForOpenMultiple(title, typeFilter)
						break;
					case SAVE:
						fl_browser.browseForSave(title)
						break;
					case OPEN_DIRECTORY:
						fl_browser.browseForDirectory(title)
						break;
				}
			}
			catch (err:Error) { 
				b_available = true;	/*for some reason, it has failed; not in use*/
			}
		}
		
		private static function bindEventFunction(getter:Function):Function
		{
			return function(evt:Event):void
			{
				if (!arr_queue.length) {
					return;
				}
				const callFunction:Function = getter.call(null, arr_queue.shift());
				callFunction != null && callFunction.call(null, evt);
				b_available = true
				tryRunNext()
			}
		}
		
		public static function waitAndBrowseFor(type:String, title:String, onSelect:Function, onCancel:Function, onError:Function = null, idIfCallUnique:Object = null, defaultLocation:String = null, typeFilter:Array = null):void
		{
			const exists:Boolean = idIfCallUnique && arr_queue.some(function findSimilar(item:FileBrowserData, index:int, array:Array):Boolean {
				return item.id == idIfCallUnique && item.type == type;	//don't add similar IDs in the queue
			});
			
			if (!exists) {
				arr_queue.push(new FileBrowserData(type, title, typeFilter, idIfCallUnique, defaultLocation, onSelect, onCancel, onError));
			}
			tryRunNext();
		}
		
		public static function get isAvailable():Boolean {
			return b_available
		}
	}

}

/**
 * Data class for storing information about pending browse operation
 */
internal class FileBrowserData
{
	public var id:Object;
	public var type:String;
	public var title:String;
	public var onError:Function;
	public var typeFilter:Array;
	public var onCancel:Function;
	public var onSelect:Function;
	public var defaultLocation:String
	public function FileBrowserData(type:String, title:String, typeFilter:Array, id:Object, defaultLocation:String, onSelect:Function, onCancel:Function, onError:Function)
	{
		this.defaultLocation = defaultLocation
		this.typeFilter = typeFilter
		this.onSelect = onSelect
		this.onCancel = onCancel
		this.onError = onError
		this.title = title
		this.type = type;
		this.id = id;
	}
}
