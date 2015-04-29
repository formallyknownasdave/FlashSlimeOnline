package  
{
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.masks.Hitbox;
	import net.flashpunk.masks.Masklist;
	import net.flashpunk.masks.Pixelmask;
	import net.flashpunk.Sfx;
	/**
	 * ...
	 * @author 
	 */
	public class SlimePoint extends Entity
	{
		private var sprite:Image = new Image(Assets.SPR_SLIME_POINT);
		private var glow:Spritemap = new Spritemap(Assets.SPR_SLIME_POINT_GLOW, 24, 24);
		private var sound:Sfx = new Sfx(Assets.SND_SLIME_POINT);
		private var pulseCounter:int = 0;
		private var id:int = 0;
		public function SlimePoint(id:int,x:int,y:int) 
		{
			type = "point";
			graphic = new Graphiclist(glow,sprite);
			glow.add("glow", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,0],0.4, false);
			glow.alpha = 0.3;
			glow.play("glow");
			sprite.alpha = 0.9;
			mask = new Pixelmask(Assets.SPR_SLIME_POINT);
			sprite.originX = -3;
			sprite.originY = -3;
			glow.originX = 4;
			glow.originY = 4;
			this.id = id;
			this.x = x;
			this.y = y;
		}
		public override function update():void
		{
			pulseCounter++;
			if (pulseCounter > 120)
			{
				glow.play("glow",true);
				pulseCounter = 0;
			} else {
				glow.alpha = 0.3-(pulseCounter / 120);
			}
			if (collide("slime", x, y))
			{
				PointCounter.add();
				sound.play();
				if (Main.connection != null && Main.connection.connected)
					Main.connection.send("Point", id);
				this.world.remove(this);
			}
		}
		
	}

}