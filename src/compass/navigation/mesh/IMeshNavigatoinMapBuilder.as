/**
 * User: booster
 * Date: 16/05/14
 * Time: 16:27
 */
package compass.navigation.mesh {
import medkit.collection.Collection;
import medkit.geom.shapes.Point2D;

public interface IMeshNavigatoinMapBuilder {
    function get epsilon():Number
    function get locations():Collection

    function populateConnected(location:Point2D, map:MeshNavigationMap, resultNodes:Collection, resultPolygons:Collection):void
}
}
