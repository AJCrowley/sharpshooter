package ca.revolve.sharpshooter.elements
{
	import ca.revolve.utils.ExternalCommand;

	public class Score
	{
		public var command:String;
		public var stage:uint;
		public var points:int;
		public var badges:Vector.<String>;
		public var sessionID:String;
		
		public function submit():void
		{
			command = ExternalCommand.COMMAND_SAVE_SCORE;
			ExternalCommand.call(ExternalCommand.SERVER_COMMAND, JSON.stringify(this), true);
		}
	}
}