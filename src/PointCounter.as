package  
{
	import flash.sampler.NewObjectSample;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	/**
	 * ...
	 * @author 
	 */
	public class PointCounter extends Entity
	{
		private var point:Image = new Image(Assets.SPR_SLIME_POINT);
		private static var text:Text = new Text("x 0", 13, -1, { size:"10", font:"arial bold", color:0x00E701, outline:true } );
		private static var points:Number = 0;
		public function PointCounter() 
		{
			point.x = 3;
			point.y = 3;
			addGraphic(point);
			addGraphic(text);
			layer = -98;
			graphic.scrollX = graphic.scrollY = 0;
			x = 0;
			y = FP.height - 16;
		}
		public static function add() {
			points ++;
			text.text = "x " + points;
		}
		
	}

}