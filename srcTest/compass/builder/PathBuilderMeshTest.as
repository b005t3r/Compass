/**
 * User: booster
 * Date: 12/06/14
 * Time: 14:58
 */
package compass.builder {
import compass.navigation.mesh.MeshNavigationMap;
import compass.navigation.mesh.ShapeNavigationMapBuilder;

import medkit.collection.ArrayList;
import medkit.collection.List;
import medkit.geom.shapes.Rectangle2D;

public class PathBuilderMeshTest {
    private var rects:List = new ArrayList();

    private var builder:ShapeNavigationMapBuilder;
    private var map:MeshNavigationMap;

    public function PathBuilderMeshTest() {
        var r1:Rectangle2D = new Rectangle2D(0, 0, 7, 4);
        var r2:Rectangle2D = new Rectangle2D(2, 4, 2, 4);
        var r3:Rectangle2D = new Rectangle2D(4, 7, 4, 1);
        var r4:Rectangle2D = new Rectangle2D(7, 6, 1, 1);
        var r5:Rectangle2D = new Rectangle2D(7, 8, 1, 1);

        rects.add(r1);
        rects.add(r2);
        rects.add(r3);
        rects.add(r4);
        rects.add(r5);
    }

    [Before]
    public function setUp():void {
        builder = new ShapeNavigationMapBuilder(rects, 0.5);
        map     = new MeshNavigationMap(builder);
    }

    [After]
    public function tearDown():void {
        builder = null;
        map     = null;
    }

    [Test]
    public function testMapCreation():void {

    }
}
}
