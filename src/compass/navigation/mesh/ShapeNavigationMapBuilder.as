/**
 * User: booster
 * Date: 11/06/14
 * Time: 11:20
 */
package compass.navigation.mesh {
import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.CollectionUtil;
import medkit.collection.HashMap;
import medkit.collection.HashSet;
import medkit.collection.List;
import medkit.collection.Map;
import medkit.collection.Set;
import medkit.collection.iterator.Iterator;
import medkit.geom.GeomUtil;
import medkit.geom.shapes.Line2D;
import medkit.geom.shapes.PathIterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Polygon2D;
import medkit.geom.shapes.Shape2D;
import medkit.geom.shapes.enum.SegmentType;
import medkit.object.CloningContext;
import medkit.object.ObjectUtil;

public class ShapeNavigationMapBuilder implements IMeshNavigatoinMapBuilder {
    private var _epsilon:Number;
    private var _locations:Map;

    public function ShapeNavigationMapBuilder(shapes:Collection, epsilon:Number) {
        _epsilon = epsilon;

        var polys:List = createPolygons(shapes);
        snapPolygons(polys, epsilon);

        _locations = mapPointsToPolygons(polys);
    }

    public function get epsilon():Number { return _epsilon; }

    public function get locations():Collection { return _locations.keySet(); }

    public function populateConnected(location:Point2D, map:MeshNavigationMap, resultNodes:Collection, resultPolygons:Collection):void {
        var polys:List = _locations.get(location);

        if(polys == null)
            throw new ArgumentError("invalid location provided - no polygons registered for this location: " + location);

        resultPolygons.addAll(polys);

        var connectedPoints:Set = new HashSet();

        var count:int = polys.size();
        for(var i:int = 0; i < count; ++i) {
            var poly:Polygon2D = polys.get(i);

            var pointCount:int = poly.pointCount;
            for(var j:int = 0; j < pointCount; ++j) {
                var p:Point2D = poly.getPoint2D(j);

                if(p.equals(location))
                    continue;

                connectedPoints.add(p);
            }
        }

        var it:Iterator = connectedPoints.iterator();
        while(it.hasNext()) {
            var connectedLocation:Point2D = it.next();
            var connectedNode:MeshNavigationNode = map.getNodeAt(connectedLocation.x, connectedLocation.y);

            if(connectedNode == null)
                throw new Error("node for given location does not exist: " + connectedLocation);

            resultNodes.add(connectedNode);
        }
    }

    private function createPolygons(shapes:Collection):List {
        var polys:List = new ArrayList(shapes.size());

        var it:Iterator = shapes.iterator();
        while(it.hasNext()) {
            var shape2D:Shape2D = it.next();
            var poly:Polygon2D = new Polygon2D();

            var coords:Vector.<Point2D> = new <Point2D>[new Point2D(), new Point2D(), new Point2D()];

            for(var pathIt:PathIterator = shape2D.getPathIterator(null, 1); !pathIt.isDone(); pathIt.next()) {
                var segType:SegmentType = pathIt.currentSegment(coords);

                if(segType == SegmentType.QuadTo || segType == SegmentType.CubicTo)
                    throw new ArgumentError("quad and cubic segments not supported");

                if(segType == SegmentType.LineTo || segType == SegmentType.MoveTo)
                    poly.addPoint2D(coords[0]);
            }

            if(poly.pointCount < 3)
                throw new ArgumentError("line or point shapes are not allowed");

            polys.add(poly);
        }

        return polys;
    }

    private function snapPolygons(polys:List, epsilon:Number):void {
        var edge:Line2D = new Line2D(), tempPoly:Polygon2D = new Polygon2D(), tempPoints:List = new ArrayList();

        var polyCount:int = polys.size();
        for(var i:int = 0; i < polyCount; ++i) {
            var poly:Polygon2D = polys.get(i);
            tempPoly.reset();

            var coords:Vector.<Point2D> = new <Point2D>[new Point2D(), new Point2D(), new Point2D()];

            for(var pathIt:PathIterator = poly.getPathIterator(); !pathIt.isDone(); pathIt.next()) {
                var segType:SegmentType = pathIt.currentSegment(coords);

                if(segType == SegmentType.MoveTo) {
                    edge.x2 = Math.round(coords[0].x / epsilon) * epsilon;
                    edge.y2 = Math.round(coords[0].y / epsilon) * epsilon;

                    continue; // edge not initialized yet
                }
                else if(segType == SegmentType.LineTo) {
                    edge.x1 = edge.x2;
                    edge.y1 = edge.y2;
                    edge.x2 = Math.round(coords[0].x / epsilon) * epsilon;
                    edge.y2 = Math.round(coords[0].y / epsilon) * epsilon;
                }
                else if(segType == SegmentType.Close) {
                    edge.x1 = edge.x2;
                    edge.y1 = edge.y2;
                    edge.x2 = Math.round(poly.getPoint2D(0).x / epsilon) * epsilon;
                    edge.y2 = Math.round(poly.getPoint2D(0).y / epsilon) * epsilon;
                }
                else {
                    throw new Error("only MoveTo, LineTo and Close SegmentTypes are supported");
                }

                tempPoints.clear();

                for(var j:int = 0; j < polyCount; ++j) {
                    if(i == j) continue;

                    var otherPoly:Polygon2D = polys.get(j);

                    var pointCount:int = otherPoly.pointCount;
                    for(var k:int = 0; k < pointCount; ++k) {
                        var point:Point2D = otherPoly.getPoint2D(k);
                        var distanceToSegment:Number = edge.point2DSegmentDistance(point);

                        // skip point not close enough for snapping to poly's edge
                        // but also skip those that are identical to segment's end
                        if(distanceToSegment > epsilon
                        || GeomUtil.distanceBetweenPoints(edge.x1, edge.y1, point.x, point.y) < epsilon * 0.01
                        || GeomUtil.distanceBetweenPoints(edge.x2, edge.y2, point.x, point.y) < epsilon * 0.01)
                            continue;

                        var angle1:Number = GeomUtil.normalizeLocalAngle(GeomUtil.angleBetweenPoints(edge.x1, edge.y1, point.x, point.y) - edge.angle);
                        var angle2:Number = GeomUtil.normalizeLocalAngle(GeomUtil.angleBetweenPoints(edge.x2, edge.y2, point.x, point.y) - edge.reversedAngle);

                        // snap to (x1, y1)
                        if(Math.abs(angle1) > Math.PI / 2) {
                            point.x = edge.x1;
                            point.y = edge.y1;
                        }
                        // snap to (x2, y2)
                        else if(Math.abs(angle2) > Math.PI / 2) {
                            point.x = edge.x2;
                            point.y = edge.y2;
                        }
                        // snap to segment between (x1, y1) and (x2, y2)
                        else {
                            var distanceToPoint:Number = GeomUtil.distanceBetweenPoints(edge.x1, edge.y1, point.x, point.y);
                            var projectionDistance:Number = Math.sqrt(distanceToPoint * distanceToPoint - distanceToSegment * distanceToSegment);

                            GeomUtil.projectPoint(edge.x1, edge.y1, edge.angle, projectionDistance, point);

                            tempPoints.add(point);
                        }

                        // round point's coords to epsilon
                        point.x = Math.round(point.x / epsilon) * epsilon;
                        point.y = Math.round(point.y / epsilon) * epsilon;

                        otherPoly.invalidate();
                    }
                }

                CollectionUtil.sort(tempPoints, new TempPointsComparator(edge));

                tempPoly.add(edge.x1, edge.y1);

                var tempPointCount:int = tempPoints.size();
                for(var p:int = 0; p < tempPointCount; ++p)
                    tempPoly.addPoint2D(tempPoints.get(p));
            }

            polys.set(i, ObjectUtil.clone(tempPoly, new CloningContext()));
        }
    }

    private function mapPointsToPolygons(polys:List):Map {
        var points:Map = new HashMap();

        var count:int = polys.size();
        for(var i:int = 0; i < count; ++i) {
            var poly:Polygon2D = polys.get(i);

            var polyPointCount:int = poly.pointCount;
            for(var j:int = 0; j < polyPointCount; ++j) {
                var point:Point2D = poly.getPoint2D(j);

                var mappedPolys:List = points.get(point);

                if(mappedPolys == null)
                    points.put(point, mappedPolys = new ArrayList());

                mappedPolys.add(poly);
            }
        }

        return points;
    }
}
}

import medkit.geom.GeomUtil;
import medkit.geom.shapes.Line2D;
import medkit.geom.shapes.Point2D;
import medkit.object.Comparator;
import medkit.object.Equalable;

class TempPointsComparator implements Comparator {
    private var _edge:Line2D;

    public function TempPointsComparator(edge:Line2D) {
        _edge = edge;
    }

    public function compare(o1:*, o2:*):int {
        var p1:Point2D = o1;
        var p2:Point2D = o2;

        return GeomUtil.distanceBetweenPoints(_edge.x1, _edge.y1, p1.x, p1.y) - GeomUtil.distanceBetweenPoints(_edge.x1, _edge.y1, p2.x, p2.y);
    }

    public function equals(object:Equalable):Boolean {
        return false;
    }

    public function hashCode():int {
        return 0;
    }
}
