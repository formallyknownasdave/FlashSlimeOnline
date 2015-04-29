package  
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.ui.Multitouch;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.ParticleType;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.Sfx;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import playerio.Message;
	/**
	 * ...
	 * @author 
	 */
	public class BaseSlime extends Entity
	{
		public var MAX_HSPEED:Number = 1.60;
		public var ACC_HSPEED:Number = 0.3;
		public var sprite:Spritemap = new Spritemap(Assets.SPR_KIRBY, 32, 32);
		public var vspeed:Number = 0, hspeed:Number = 0;
		public var friction:Number = 0.3;
		public var jumpHeight:Number = 5.65;
		private var vrep:Number = 0;
		private var hrep:Number  = 0;
		public var main:Boolean = false;
		public var id:int = 0;
		private var sound_jump:Sfx = new Sfx(Assets.SND_JUMP);
		private var textUsername:Text = new Text("", 0, -46, { size:"10", font:"arial bold", color:0xFFFFFF, outline:true } );
		private var textGuild:Text = new Text("", 0, -36, { size:"10", font:"arial bold", color:0xdfda44, outline:true } );
		public var username:String, guild:String = "Programmerz";
		protected var keyLeft:Boolean, keyRight:Boolean, keyUp:Boolean, keyDown:Boolean;
		private var clipTo:MovingBlock = null;
		private var dirt:Emitter = new Emitter(Assets.PART_CIRCLE);
		public function BaseSlime(username:String,id:int,x:int,y:int)
		{
			type = "slime";
			this.username = username;
			this.id = id;
			this.x = x - 9;
			this.y = y - 8;
			layer = 0;
			/* Add animations */
			sprite.add("walk", [8, 9, 10, 11],0.4);
			sprite.add("stand", [4]);
			sprite.add("duck", [12]);
			sprite.add("fly_up", [1]);
			sprite.add("fly_down", [0]);
			graphic = sprite;
			textUsername.text = username;
			textUsername.centerOrigin();
			addGraphic(textUsername);
			textGuild.text = "[" + guild + "]"
			var test:ParticleType = dirt.newType("test", [0]);
			test.setGravity( -1, 0.1);
			textGuild.centerOrigin();
			addGraphic(textGuild);
			sprite.originX = 16;
			sprite.originY = 28;
			sprite.play("stand");
			setHitbox(18, 12);
			setOrigin(9, 8);
		}
		public override function update():void
		{
			dirt.emit("test", x, y);
			if (clipTo != null) {
				hrep += clipTo.hspeed;
				move_vertically(clipTo.vspeed);
				solid_below = true;
			}
			var solid_below:Boolean = collide_vertical(1);
			if (!solid_below)
				vspeed += (Level)(FP.world).gravity;
			if ((keyLeft || keyRight) && !(keyLeft && keyRight))
			{
				var direction:int = keyLeft?-1:1;
				if (!keyDown && (!collide("solid", x + direction, y) || !collide("solid",x + direction,y - 1)))
				{	
					if (hspeed * direction < MAX_HSPEED)
					{
						hspeed += ACC_HSPEED * direction;
						var other:Entity = collide("slime", x, y - 1);
						hspeed = FP.clamp(hspeed, -MAX_HSPEED, MAX_HSPEED);
						if (other != null)
						{
							(other as BaseSlime).hspeed += (ACC_HSPEED+friction) * direction;
							(other as BaseSlime).hspeed = FP.clamp(hspeed, -MAX_HSPEED, MAX_HSPEED);
						}
					}
					sprite.play("walk");
				}
				else if (!keyDown)
					sprite.play("stand");
				sprite.scaleX = direction;
			} else if (solid_below) {
				if (keyDown) {
					sprite.play("duck");
					hspeed = 0;
				} else
					sprite.play("stand");
				if (Math.abs(hspeed) < friction) {
					hspeed = 0;
				} else
					hspeed -= friction * ((hspeed > 0)?1: -1);
			} else {
				if (Math.abs(hspeed) < friction) {
					hspeed = 0;
				} else
					hspeed -= friction / 20 * ((hspeed > 0)?1: -1);
				}
			if (vspeed > 0)
				sprite.play("fly_down");
			else if (vspeed < 0)
				sprite.play("fly_up");
			
				
			if (keyUp && vspeed == 0 && solid_below)
			{
				vspeed = -jumpHeight;
				sound_jump.play();
			}

			hrep += hspeed;
			vrep += vspeed;
			
			if (!move_vertically(int(vrep))) {
				vspeed = 0;
				vrep = 0;
				}
			else
				vrep -= int(vrep);
			for (var i:int = 0; i < Math.floor(Math.abs(hrep)); i++)
			{
				var dir:int = (hrep > 0) ? 1 : ((hrep < 0) ? -1 : 0);
				if (!collide("solid", x + dir, y)) {
					if (collide("solid", x, y + 1) && !collide("solid", x + dir, y + 1) && !collide("semisolid", x + dir, y + 1) && !collide("jtsolid", x + dir, y + 1))
						y++;
					x += dir;
				}
				else if (collide("solid", x, y + 1) && !collide("solid", x + dir, y - 1)) {
					x += dir;
					y--;
				} else
				{
					var block:Entity = collide("solid", x + dir, y);
					if (block is PushBlock && (block as PushBlock).can_slide(dir)) {
						block.x += dir;
						x += dir;
					} else {
						hspeed = 0;
						hrep = 0;
						break;
					}
				}
			}
			hrep -= int(hrep);
		}
		public function move_vertically(dist:int):Boolean
		{
			var dir:int = dist / Math.abs(dist);
			var solid:Boolean = false;
			for (var i:int = 0; i < Math.abs(dist); i++)
			{
				if (collide_vertical(dir))
					return false;
				else{
				y+=dir;
				}
			}
			return true;
		}
		public function collide_vertical(dir:int):Boolean
		{
			var solid:Boolean = false;
			if (dir > 0)
			{
				var blocks:Array = [];
				var flag:Boolean = false;
				collideInto("jtsolid", x, y + 1, blocks);
				for each (var block in blocks)
				{
					if (!collideWith(block, x, y)) {
						solid = true;
						if (block is MovingBlock) {
							clipTo = block as MovingBlock;
							flag = true;
						}
					}
				}
				if (!flag)
					clipTo = null;
				if (!collide("semisolid", x, y) && collide("semisolid", x, y + 1) && vspeed == 0)
					solid = true;
			}
			if (collide("solid", x, y + dir))
				solid = true;
			return solid;
		}
	}

}