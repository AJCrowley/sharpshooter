package ca.revolve.utils
{
	public class FileTools
	{
		public static function getPath(file:String):String
		{
			// start with empty path
			var path:String = "";
			// split passed value for file into sections
			var pathSections:Array = file.split("/");
			// for each section
			for(var i:uint = 0; i < pathSections.length - 1; i++)
			{
				// append to path
				path += pathSections[i] + "/";
			}
			return path;
		}
	}
}