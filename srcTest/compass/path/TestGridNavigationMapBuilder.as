/**
 * User: booster
 * Date: 12/05/14
 * Time: 12:18
 */
package compass.path {
import compass.navigation.grid.GridNavigationMap;
import compass.navigation.grid.IGridNavigationMapBuilder;

import medkit.collection.Collection;

public class TestGridNavigationMapBuilder implements IGridNavigationMapBuilder {
    private var _grid:Vector.<int>;
    private var _width:int;
    private var _height:int;

    public function TestGridNavigationMapBuilder(w:int, h:int, grid:Vector.<int>) {
        _width = w;
        _height = h;
        _grid = grid;
    }

    public function getWidth(map:GridNavigationMap):int { return _width; }
    public function getHeight(map:GridNavigationMap):int { return _height; }

    public function getTravelCost(x:int, y:int, map:GridNavigationMap):Number {
        var value:int = _grid[x + y * _width];

        return value == 0 ? NaN : 1;
    }

    public function populateConnectedNodes(x:int, y:int, map:GridNavigationMap, result:Collection):void {
        var left:int    = x - 1;
        var right:int   = x + 1;
        var top:int     = y - 1;
        var bottom:int  = y + 1;

        if(left >= 0)           result.add(map.getNodeAt(left, y));
        if(right < _width)      result.add(map.getNodeAt(right, y));
        if(top >= 0)            result.add(map.getNodeAt(x, top));
        if(bottom < _height)    result.add(map.getNodeAt(x, bottom));
    }
}
}
