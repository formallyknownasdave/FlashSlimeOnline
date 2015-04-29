package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.utils.Draw;
	/**
	 * ...
	 * @author 
	 */
	public class PushBlock extends Entity
	{
		
		public function PushBlock(x:int,y:int,width:int,height:int) 
		{
			trace("woot")
			type = "solid";
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		public function can_slide(dir:int)
		{
			return !(collide("solid", x + dir, y));
		}
		override public function render():void
		{
			super.render();

			Draw.rect(x,y,width,height,0x003412,1,true);
		}
	}

}