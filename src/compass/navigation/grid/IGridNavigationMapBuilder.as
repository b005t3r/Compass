/**
 * User: booster
 * Date: 12/05/14
 * Time: 11:46
 */
package compass.navigation.grid {
import medkit.collection.Collection;

public interface IGridNavigationMapBuilder {
    function getWidth(map:GridNavigationMap):int
    function getHeight(map:GridNavigationMap):int

    function getTravelCost(x:int, y:int, map:GridNavigationMap):Number

    function populateConnectedNodes(x:int, y:int, map:GridNavigationMap, result:Collection):void
}
}
