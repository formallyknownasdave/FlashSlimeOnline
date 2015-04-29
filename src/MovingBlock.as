package  
{
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Draw;
	/**
	 * ...
	 * @author 
	 */
	public class MovingBlock extends Entity
	{
		public var vspeed:int=0, hspeed:int=0;
		public function MovingBlock(x:int,y:int,width:int,height:int,hspeed:int,vspeed:int) 
		{
			trace("new blocky"+hspeed+","+vspeed);
			type = "jtsolid";
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.hspeed = hspeed;
			this.vspeed = vspeed;
		}
		public override function update():void
		{
			if ((collide("solid", x + hspeed, y) || collide("jtsolid", x + hspeed, y)) && hspeed != 0)
				hspeed = -hspeed;
			if ((collide("solid", x, y + vspeed) || collide("jtsolid", x, y + vspeed)) && vspeed != 0)
				vspeed = -vspeed;
			
			y += vspeed;
			x += hspeed;
		}
		override public function render():void
		{
			super.render();
			 
			Draw.rect(x,y,width,height,0xff0000,1,true);
		}
	}

}