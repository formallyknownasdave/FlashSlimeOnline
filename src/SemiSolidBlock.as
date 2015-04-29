package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.masks.Masklist;
	import net.flashpunk.masks.Grid;
	/**
	 * ...
	 * @author 
	 */
	public class SemiSolidBlock extends Entity
	{
		public var masklist:Masklist = new Masklist();
		public function SemiSolidBlock(xml:XML) 
		{
			type = "semisolid";
			var block:XML;
			var grid:Grid = new Grid(xml.@width, xml.@height, 16, 16, 0, 0);
			for each (block in xml.phys_layer.semisolid_block)
				grid.setRect(block.@x / 16, block.@y / 16, block.@width / 16, block.@height / 16);
			masklist.add(grid);
			mask = masklist;
		}
		
	}

}