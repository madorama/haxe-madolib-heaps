package madolib.heaps.node;

import differ.math.Vector;
import hxmath.math.Vector2;
import madolib.Option;
import madolib.collider.Collide.HitPosition;
import madolib.collider.Collide;
import madolib.geom.Bounds;

class PolygonCollider extends Collider {
    var minX = Math.DOUBLE_MAX;
    var minY = Math.DOUBLE_MAX;
    var maxX = Math.DOUBLE_MIN;
    var maxY = Math.DOUBLE_MIN;

    var vertices: Array<differ.math.Vector> = [];
    var polygon: differ.shapes.Polygon;

    public inline function setRotation(v: Float): Float {
        rotation = v;
        calcBounds();
        return v;
    }

    public function new(x: Float, y: Float, vertices: Array<Vector2>) {
        super();
        this.vertices = vertices.map(v -> new Vector(v.x, v.y));

        // Get width and height
        minX = Math.DOUBLE_MAX;
        minY = Math.DOUBLE_MAX;
        maxX = Math.DOUBLE_MIN;
        maxY = Math.DOUBLE_MIN;
        for(v in vertices) {
            if(v.x <= minX) minX = v.x;
            if(v.y <= minY) minY = v.y;
            if(v.x >= maxX) maxX = v.x;
            if(v.y >= maxY) maxY = v.y;
        }

        polygon = new differ.shapes.Polygon(0, 0, []);
        width = maxX - minX;
        height = maxY - minY;

        calcBounds();

        this.x = x;
        this.y = y;
    }

    function calcBounds() {
        final dx = node.pivotX * width;
        final dy = node.pivotY * height;
        final vs = vertices.map(v -> new Vector(v.x - dx, v.y - dy));
        polygon = new differ.shapes.Polygon(dx, dy, vs);
        polygon.rotation = rotation;

        minX = Math.DOUBLE_MAX;
        minY = Math.DOUBLE_MAX;
        maxX = Math.DOUBLE_MIN;
        maxY = Math.DOUBLE_MIN;
        for(v in polygon.transformedVertices) {
            if(v.x <= minX) minX = v.x;
            if(v.y <= minY) minY = v.y;
            if(v.x >= maxX) maxX = v.x;
            if(v.y >= maxY) maxY = v.y;
        }
    }

    function getAbsoluteVertices(): Array<Vector2> {
        polygon.scaleX = node.scaleX;
        polygon.scaleY = node.scaleY;
        final vs = polygon.transformedVertices.map(v -> new Vector2(v.x + x * (node.scaleX - 1), v.y + y * (node.scaleY - 1)));
        polygon.scaleX = 1;
        polygon.scaleY = 1;
        return vs;
    }

    override function get_bounds(): Bounds {
        innerBounds.x = absoluteX + minX;
        innerBounds.y = absoluteY + minY;
        innerBounds.width = maxX - minX;
        innerBounds.height = maxY - minY;
        return innerBounds;
    }

    override function get_width(): Float
        return maxX - minX;

    override function get_height(): Float
        return maxY - minY;

    override function get_left(): Float
        return x + minX;

    override function set_left(v: Float): Float
        return x = v + minX;

    override function get_top(): Float
        return y + minY;

    override function set_top(v: Float): Float
        return y = v + minY;

    override function get_right(): Float
        return x + maxX;

    override function set_right(v: Float): Float
        return x = v + maxX;

    override function get_bottom(): Float
        return y + maxY;

    override function set_bottom(v: Float): Float
        return y = v + maxY;

    override function collidePoint(p: Vector2): Bool
        return Collide.polyVsPoint(absolutePosition, polygon, p);

    override function collideBounds(bounds: Bounds): Bool
        return Collide.polyVsRect(absolutePosition, polygon, { x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height, rotation: 0 });

    override function intersectLine(from: Vector2, to: Vector2): Option<HitPosition>
        return Collide.intersectPolyVsLine(absolutePosition, polygon, from, to);

    override function collideLine(from: Vector2, to: Vector2): Bool
        return Collide.polyVsLine(absolutePosition, polygon, from, to);

    function debugDraw(graphics: h2d.Graphics) {
        final vs = getAbsoluteVertices();
        for(v in vs.concat([vs[0]])) {
            graphics.lineTo(absoluteX + v.x, absoluteY + v.y);
        }
    }

    function clone(): Collider {
        final poly = new PolygonCollider(x, y, vertices.map(v -> new Vector2(v.x, v.y)));
        poly.setRotation(rotation);
        return poly;
    }

    function collideBox(box: BoxCollider): Bool
        return collideBounds(box.bounds);

    function collideCircle(circle: CircleCollider): Bool
        return Collide.polyVsCircle(absolutePosition, polygon, circle.absolutePosition, circle.radius);

    function collidePolygon(polygon: PolygonCollider): Bool
        return Collide.polyVsPoly(absolutePosition, this.polygon, polygon.absolutePosition, polygon.polygon);

    function collideGrid(grid: GridCollider): Bool {
        final testBounds = grid.collideBounds(this.bounds);
        return testBounds;
    }

    public inline static function rect(x: Float, y: Float, width: Float, height: Float, rotation: Float = 0): PolygonCollider {
        final vs = [
            new Vector2(x, y),
            new Vector2(x + width, y),
            new Vector2(x + width, y + height),
            new Vector2(x, y + height),
        ];
        final poly = new PolygonCollider(x, y, vs);
        poly.setRotation(rotation);
        return poly;
    }
}
