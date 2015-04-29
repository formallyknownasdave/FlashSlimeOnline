package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.Mask;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.masks.Masklist;
	import net.flashpunk.masks.Pixelmask;
	/**
	 * ...
	 * @author 
	 */
	public class SolidBlock extends Entity
	{
		public var masklist:Masklist = new Masklist();
		public function SolidBlock(xml:XML) 
		{
			type = "solid";
			var block:XML;
			for each (block in xml.phys_layer.solid_slope_top_right)
				masklist.add(new Pixelmask(Assets.MSK_SLOPE_TOP_RIGHT, block.@x, block.@y));
			for each (block in xml.phys_layer.solid_slope_top_left)
				masklist.add(new Pixelmask(Assets.MSK_SLOPE_TOP_LEFT, block.@x, block.@y));
			for each (block in xml.phys_layer.solid_slope_bottom_right)
				masklist.add(new Pixelmask(Assets.MSK_SLOPE_BOTTOM_RIGHT, block.@x, block.@y));
			for each (block in xml.phys_layer.solid_slope_bottom_left)
				masklist.add(new Pixelmask(Assets.MSK_SLOPE_BOTTOM_LEFT, block.@x, block.@y));
				
			var grid:Grid = new Grid(xml.@width, xml.@height, 16, 16, 0, 0);
			for each (block in xml.phys_layer.solid_block)
				grid.setRect(block.@x / 16, block.@y / 16, block.@width / 16, block.@height / 16);
			masklist.add(grid);
			
			mask = masklist;
		}
		
	}

}