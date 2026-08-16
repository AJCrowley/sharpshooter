package ca.revolve.utils
{
	public class TrigTool
	{
		// convert degrees to radians
		public static function deg2rad(degrees:Number):Number
		{
			return degrees * (Math.PI / 180);
		}
		
		// convert radians to degrees
		public static function rad2deg(radians:Number):Number
		{
			return radians * (180 / Math.PI);
		}
	}
}