package  
{
	/**
	 * ...
	 * @author 
	 */
	public class OtherSlime extends BaseSlime
	{
		public function OtherSlime(username:String,id:int,x:int,y:int) 
		{
			super(username, id, x, y);
		}
		public override function update():void
		{
			super.update();
			keyUp = false;
		}
		public function updateKey(key:int, pressed:Boolean)
		{
			switch(key)
			{
				case 0: keyLeft  = pressed; break;
				case 1: keyRight = pressed; break;
				case 2: keyUp    = pressed; break;
				case 3: keyDown  = pressed; break;
			}
		}
	}

}