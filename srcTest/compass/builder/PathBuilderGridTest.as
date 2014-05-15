/**
 * User: booster
 * Date: 12/05/14
 * Time: 9:18
 */
package compass.builder {
import compass.navigation.grid.GridFinishNavigationNode;
import compass.navigation.grid.GridNavigationAgent;
import compass.navigation.grid.GridNavigationMap;
import compass.navigation.grid.GridNavigationNode;
import compass.navigation.grid.GridStartNavigationNode;

import medkit.collection.iterator.Iterator;
import medkit.util.StopWatch;

import org.flexunit.asserts.assertEquals;

import org.flexunit.asserts.assertTrue;

public class PathBuilderGridTest {
    private var _mapLayout:Vector.<int> = new <int>[
        0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,
        0,0,1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,0,0,0,
        0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,
        0,0,0,1,0,0,0,1,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,
        0,0,0,1,1,1,1,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,
        0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,1,1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,
        0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,1,0,0,0,1,1,1,1,1,0,0,0,1,0,0,0,
        0,0,0,0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,1,0,0,0,0,1,1,1,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,1,1,1,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,1,0,0,0,0,1,1,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,0,0,1,0,0,0,
        0,0,0,0,1,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,1,1,0,1,1,1,1,1,1,1,0,0,0,
        0,0,0,0,1,1,1,1,1,1,0,0,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,1,1,1,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,1,1,1,0,0,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,1,1,0,0,0,1,0,0,0,
        0,0,0,0,0,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,1,0,1,1,1,1,1,1,0,0,0,1,1,1,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,0,0,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,1,0,1,1,1,1,1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,1,0,1,1,1,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,1,1,1,0,0,
        0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1,1,1,1,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1,1,1,1,1,1,0,
        0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,1,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ];

    private var map:GridNavigationMap;

    [Before]
    public function setUp():void {
        map = new GridNavigationMap(new TestGridNavigationMapBuilder(50, 40, _mapLayout))
    }

    [After]
    public function tearDown():void {
        map = null;
    }

    [Test]
    public function testFindPath():void {
        var agent:GridNavigationAgent = new GridNavigationAgent();

        var start:GridStartNavigationNode;
        var finish:GridFinishNavigationNode;

        start   = new GridStartNavigationNode(map.getNodeAt(1, 1), map);
        finish  = new GridFinishNavigationNode(map.getNodeAt(46, 38), map);

        var pathBuilder:PathBuilder = new PathBuilder();

        StopWatch.startWatch("findPath");
        var path:Path = pathBuilder.findPath(start, finish, agent);
        trace("path found in: ", StopWatch.stopWatch("findPath"));

        assertTrue(path.complete);
        assertEquals(start.uniqueID, GridNavigationNode(path.navigationNodes.get(0)).uniqueID);
        assertEquals(finish.uniqueID, GridNavigationNode(path.navigationNodes.get(path.navigationNodes.size() - 1)).uniqueID);

        var node:GridNavigationNode = start, count:int = path.navigationNodes.size();
        for(var i:int = 1; i < count; ++i) {
            var next:GridNavigationNode = path.navigationNodes.get(i);

            var contains:Boolean = false;

            var it:Iterator = node.connectedNodes.iterator();
            while(! contains && it.hasNext()) {
                var otherNode:GridNavigationNode = it.next();

                contains = otherNode.uniqueID == next.uniqueID;
            }

            assertTrue(contains);

            node = next;
        }

        start   = new GridStartNavigationNode(map.getNodeAt(17, 35), map);
        finish  = new GridFinishNavigationNode(map.getNodeAt(25, 34), map);

        StopWatch.startWatch("findPath");
        pathBuilder.findPath(start, finish, agent, path);
        trace("path found in: ", StopWatch.stopWatch("findPath"));

        assertTrue(! path.complete);

        start   = new GridStartNavigationNode(map.getNodeAt(26, 14), map);
        finish  = new GridFinishNavigationNode(map.getNodeAt(46, 9), map);

        StopWatch.startWatch("findPath");
        pathBuilder.findPath(start, finish, agent, path);
        trace("path found in: ", StopWatch.stopWatch("findPath"));

        assertTrue(path.complete);
        assertEquals(start.uniqueID, GridNavigationNode(path.navigationNodes.get(0)).uniqueID);
        assertEquals(finish.uniqueID, GridNavigationNode(path.navigationNodes.get(path.navigationNodes.size() - 1)).uniqueID);
    }

    [Test]
    public function testContinueSearch():void {

    }
}
}
