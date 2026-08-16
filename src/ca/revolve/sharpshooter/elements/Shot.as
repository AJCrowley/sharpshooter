package ca.revolve.sharpshooter.elements
{
	public class Shot
	{
		// the basis of our shot, power and angle, simple!
		public var angle:Number;
		public var power:Number;
		
		public function Shot(angle:Number = 0, power:Number = 0)
		{
			this.angle = angle;
			this.power = power;
		}
	}
}