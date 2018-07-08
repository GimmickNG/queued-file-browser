# queued-file-browser
A static File browse() method which avoids the classic File Error #2041 (which usually occurs if you have one or more File or FileReference object(s) which call a `browse`, `browseForSave`, `browseForOpen`, `browseForOpenMultiple`, `download`, or `save` operation while another File or FileReference object is currently showing a browse dialog)

# Usage
## Parameters:
- `type` denotes the type of operation to be carried out.
  - SAVE: Starts a save dialog. Equivalent to calling the `browseForSave()` method for a File. Dispatches a regular `Event`.
	- OPEN: Starts an open dialog. Equivalent to calling the `browseForOpen()` method for a File. Dispatches a regular `Event`.
	- OPEN_MULTIPLE: Starts an open dialog with multiple selection. Equivalent to calling the `browseForOpenMultiple()` method for a File. Dispatches a `FileListEvent` for `onSelect`.
	- OPEN_DIRECTORY: Starts an open directory dialog. Equivalent to calling the `browseForDirectory()` method for a File. Dispatches a regular `Event`.
- `onSelect`, `onCancel` and `onError` are event callbacks which occur with respect to the current operation. All of these must accept an event. Setting these to null is equivalent to ignoring the result when the event occurs.
  - `onSelect`: Run when the user selects a file, multiple files, or a folder using the system dialog.
  - `onCancel`: Run when the user cancels the browse operation, usually by pressing the Cancel or X button, or the ESC key.
  - `onError`: Run when an error occurs in the operation (e.g. file not found, invalid permissions, etc.)
## Optional Parameters
Note: The `onError` callback is optional by default.
- `idIfCallUnique`: A unique ID which identifies the current function which is calling the browse operation. This can be used in instances where you do not want more than one browse operation to occur. For example, if a user clicks a button to start a browse operation rapidly, multiple operations can be queued (and normally, would result in an `Error #2041` if using a plain File.) By setting this ID, it ignores multiple calls from the same ID, leaving only one. The easiest ID to pass is a unique string, although `arguments.callee` also works.
- `defaultLocation`: The default location from which the browse operation should start. Generally, the starting folder of the browse dialog is the same as the URL specified for the file, reflected by the `defaultLocation` parameter. For example: If the `defaultLocation` is set to `File.desktopDirectory`, then the browse dialog will start showing all the contents of the desktop first.
- `typeFilter`: An Array of `FileFilter`s which are used in a browse operation. Is ignored for `SAVE` and `OPEN_DIRECTORY` calls.

# Example
The following example asks the user to select a JPG file from their computer; the starting directory is the user's desktop. When the user finishes selecting a file, the event is traced onto the console. Alternatively, if they cancel, or an error occurs, the relevant event is traced onto the console.

```
QueuedFileBrowser.waitAndBrowseFor(QueuedFileBrowser.OPEN, "Select JPG", trace, trace, trace, null, File.desktopDirectory.url, [new FileFilter("JPG Image", "*.jpg", "image/jpg")])
```
