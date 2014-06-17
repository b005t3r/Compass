/**
 * User: booster
 * Date: 12/06/14
 * Time: 14:58
 */
package compass.builder {
import compass.navigation.IFinishNavigationNode;
import compass.navigation.IStartNavigationNode;
import compass.navigation.mesh.MeshNavigationAgent;
import compass.navigation.mesh.MeshNavigationMap;
import compass.navigation.mesh.MeshNavigationNode;
import compass.navigation.mesh.ShapeNavigationMapBuilder;

import flash.utils.describeType;

import medkit.collection.ArrayList;
import medkit.collection.List;
import medkit.collection.iterator.Iterator;
import medkit.geom.shapes.Rectangle2D;
import medkit.util.StopWatch;

import org.flexunit.asserts.assertEquals;

import org.flexunit.asserts.assertTrue;

public class PathBuilderMeshTest {
    private var rects:List = new ArrayList();

    private var builder:ShapeNavigationMapBuilder;
    private var map:MeshNavigationMap;

    public function PathBuilderMeshTest() {
        rects.add(new Rectangle2D(0, 0, 7, 4));
        rects.add(new Rectangle2D(2, 4, 2, 4));
        rects.add(new Rectangle2D(4, 7, 4, 1));
        rects.add(new Rectangle2D(7, 6, 1, 1));
        rects.add(new Rectangle2D(7, 8, 1, 1));

        rects.add(new Rectangle2D(2.5, 8, 1, 5));
        rects.add(new Rectangle2D(-1.5, 10.5, 4, 1));
        rects.add(new Rectangle2D(-4.5, 7.5, 3, 7));
        rects.add(new Rectangle2D(3.5, 12, 1, 1));
        rects.add(new Rectangle2D(4.5, 12, 1, 1));

        rects.add(new Rectangle2D(4.5, 11, 1, 1));
        rects.add(new Rectangle2D(4.5, 13, 1, 1));
        rects.add(new Rectangle2D(5.5, 12, 1, 1));
        rects.add(new Rectangle2D(6.5, 11, 4, 3));
        rects.add(new Rectangle2D(10.5, 11, 6, 1));

        rects.add(new Rectangle2D(15.5, 6, 1, 5));
        rects.add(new Rectangle2D(11.5, 6, 4, 1));
        rects.add(new Rectangle2D(11.5, 7, 1, 3));
        rects.add(new Rectangle2D(12.5, 9, 2, 1));
        rects.add(new Rectangle2D(13.5, 8, 1, 1));
    }

    [Before]
    public function setUp():void {
        builder = new ShapeNavigationMapBuilder(rects, 0.5);
        map = new MeshNavigationMap(builder);
    }

    [After]
    public function tearDown():void {
        builder = null;
        map = null;
    }

    [Test]
    public function testBasicPath():void {
        var agent:MeshNavigationAgent = new MeshNavigationAgent();
        var pathBuilder:PathBuilder = new PathBuilder();

        var start:IStartNavigationNode = map.createStartNode(1, 1);
        var finish:IFinishNavigationNode = map.createFinishNode(7.5, 7.5);

        StopWatch.startWatch("findPath");
        var path:Path = pathBuilder.findPath(start, finish, agent);
        trace(getFunctionName(arguments.callee, this) + ": ", StopWatch.stopWatch("findPath"));

        checkPathCoherency(start, finish, path);
    }

    [Test]
    public function testSamePolygonPath():void {
        var agent:MeshNavigationAgent = new MeshNavigationAgent();
        var pathBuilder:PathBuilder = new PathBuilder();

        var start:IStartNavigationNode = map.createStartNode(1, 1);
        var finish:IFinishNavigationNode = map.createFinishNode(3, 3);

        StopWatch.startWatch("findPath");
        var path:Path = pathBuilder.findPath(start, finish, agent);
        trace(getFunctionName(arguments.callee, this) + ": ", StopWatch.stopWatch("findPath"));

        checkPathCoherency(start, finish, path, 2);

        start = map.createStartNode(0, 0);
        finish = map.createFinishNode(3, 3);

        StopWatch.startWatch("findPath");
        path = pathBuilder.findPath(start, finish, agent);
        trace(getFunctionName(arguments.callee, this) + ": ", StopWatch.stopWatch("findPath"));

        checkPathCoherency(start, finish, path, 2);

        start = map.createStartNode(1, 1);
        finish = map.createFinishNode(7, 4);

        StopWatch.startWatch("findPath");
        path = pathBuilder.findPath(start, finish, agent);
        trace(getFunctionName(arguments.callee, this) + ": ", StopWatch.stopWatch("findPath"));

        checkPathCoherency(start, finish, path, 2);

        start = map.createStartNode(0, 0);
        finish = map.createFinishNode(7, 4);

        StopWatch.startWatch("findPath");
        path = pathBuilder.findPath(start, finish, agent);
        trace(getFunctionName(arguments.callee, this) + ": ", StopWatch.stopWatch("findPath"));

        checkPathCoherency(start, finish, path, 2);
    }

    [Test]
    public function testLongPath():void {
        var agent:MeshNavigationAgent = new MeshNavigationAgent();
        var pathBuilder:PathBuilder = new PathBuilder();

        var start:IStartNavigationNode = map.createStartNode(1, 1);
        var finish:IFinishNavigationNode = map.createFinishNode(14, 8.5);

        StopWatch.startWatch("findPath");
        var path:Path = pathBuilder.findPath(start, finish, agent);
        trace(getFunctionName(arguments.callee, this) + ": ", StopWatch.stopWatch("findPath"));

        checkPathCoherency(start, finish, path);

        start = map.createStartNode(-4.5, 7.5);
        finish = map.createFinishNode(14.5, 8);

        StopWatch.startWatch("findPath");
        path = pathBuilder.findPath(start, finish, agent);
        trace(getFunctionName(arguments.callee, this) + ": ", StopWatch.stopWatch("findPath"));

        checkPathCoherency(start, finish, path);
    }

    private function checkPathCoherency(start:IStartNavigationNode, finish:IFinishNavigationNode, path:Path, pathLength:int = 0):void {
        assertTrue(path.complete);

        assertEquals(start.uniqueID, MeshNavigationNode(path.navigationNodes.get(0)).uniqueID);
        assertEquals(finish.uniqueID, MeshNavigationNode(path.navigationNodes.get(path.navigationNodes.size() - 1)).uniqueID);

        if(pathLength > 0)
            assertEquals(pathLength, path.navigationNodes.size());

        var node:MeshNavigationNode = start as MeshNavigationNode, count:int = path.navigationNodes.size();
        for(var i:int = 1; i < count - 1; ++i) { // start and finish nodes are not available in any node's connectedNodes collection
            var next:MeshNavigationNode = path.navigationNodes.get(i);

            var contains:Boolean = false;

            var it:Iterator = node.connectedNodes.iterator();
            while(!contains && it.hasNext()) {
                var otherNode:MeshNavigationNode = it.next();

                contains = otherNode.uniqueID == next.uniqueID;
            }

            assertTrue(contains);

            node = next;
        }
    }

    private function getFunctionName(callee:Function, parent:Object):String {
        for each (var m:XML in describeType(parent)..method)
            if(parent[m.@name] == callee)
                return m.@name;

        return "[private]";
    }
}
}
