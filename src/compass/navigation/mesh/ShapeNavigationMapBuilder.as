/**
 * User: booster
 * Date: 11/06/14
 * Time: 11:20
 */
package compass.navigation.mesh {
import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.CollectionUtil;
import medkit.collection.List;
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

    public function ShapeNavigationMapBuilder(shapes:Collection, epsilon:Number) {
        var polys:List  = new ArrayList(shapes.size());
        var points:List = new ArrayList(shapes.size() * 4);

        populatePolysAndPoints(shapes, polys, points);
        //var minDistance:Number = calculateMinimumDistance(points);

        var edge:Line2D = new Line2D(), tempPoly:Polygon2D = new Polygon2D(), tempPoints:List = new ArrayList();

        var polyCount:int = polys.size();
        for(var i:int = 0; i < polyCount; ++i) {
            var poly:Polygon2D = polys.get(i);
            tempPoly.reset();

            var coords:Vector.<Point2D> = new <Point2D>[new Point2D(), new Point2D(), new Point2D()];

            for(var pathIt:PathIterator = poly.getPathIterator(); ! pathIt.isDone(); pathIt.next()) {
                var segType:SegmentType = pathIt.currentSegment(coords);

                if(segType == SegmentType.MoveTo) {
                    edge.x2 = coords[0].x;
                    edge.y2 = coords[0].y;

                    continue; // edge not initialized yet
                }
                else if(segType == SegmentType.LineTo) {
                    edge.x1 = edge.x2;
                    edge.y1 = edge.y2;
                    edge.x2 = coords[0].x;
                    edge.y2 = coords[0].y;
                }
                else if(segType == SegmentType.Close) {
                    edge.x1 = edge.x2;
                    edge.y1 = edge.y2;
                    edge.x2 = poly.getPoint2D(0).x;
                    edge.y2 = poly.getPoint2D(0).y;
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

    public function get epsilon():Number { return _epsilon; }

    public function get locations():Collection { return null; }

    public function populateConnected(location:Point2D, map:MeshNavigationMap, resultNodes:Collection, resultPolygons:Collection):void {
    }

    private function populatePolysAndPoints(shapes:Collection, polys:List, points:List):void {
        var it:Iterator = shapes.iterator();
        while(it.hasNext()) {
            var shape2D:Shape2D = it.next();
            var poly:Polygon2D = new Polygon2D();

            var coords:Vector.<Point2D> = new <Point2D>[new Point2D(), new Point2D(), new Point2D()];

            for(var pathIt:PathIterator = shape2D.getPathIterator(null, 1); !pathIt.isDone(); pathIt.next()) {
                var segType:SegmentType = pathIt.currentSegment(coords);

                if(segType == SegmentType.QuadTo || segType == SegmentType.CubicTo)
                    throw new ArgumentError("quad and cubic segments not supported");

                if(segType == SegmentType.LineTo || segType == SegmentType.MoveTo) {
                    poly.addPoint2D(coords[0]);
                    points.add(poly.getPoint2D(poly.pointCount - 1)); // this one is not cloned
                }
            }

            if(poly.pointCount < 3)
                throw new ArgumentError("line or point shapes are not allowed");

            polys.add(poly);
        }
    }

    private function calculateMinimumDistance(points:List):Number {
        var smallestDistance:Number = Number.MAX_VALUE;

        var pointCount:int = points.size();
        for(var i:int = 0; i < pointCount; ++i) {
            var point:Point2D = points.get(i);

            for(var j:int = 0; j < pointCount; ++j) {
                if(j == i) continue;

                var otherPoint:Point2D = points.get(j);
                var distance:Number = point.distanceSq(otherPoint);

                if(smallestDistance > distance)
                    smallestDistance = distance;
            }
        }

        return Math.sqrt(smallestDistance) * 0.05;
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
