package madolib.heaps.node;

import hxmath.math.Vector2;
import madolib.collider.Collide;
import madolib.geom.Bounds;

class CircleCollider extends Collider {
    public var radius: Float;

    public function new(radius: Float, x: Float = 0, y: Float = 0, ?node: Node) {
        super(node);
        this.radius = radius;
        this.x = x;
        this.y = y;
    }

    override function get_width(): Float
        return radius * 2;

    override function set_width(value: Float): Float
        return radius = value * .5;

    override function get_height(): Float
        return radius * 2;

    override function set_height(value: Float): Float
        return radius = value * .5;

    public var scaledRadius(get, never): Float;

    inline function get_scaledRadius(): Float
        return radius * Math.max(node.scaleX, node.scaleY);

    override function get_left(): Float
        return x - radius;

    override function set_left(value: Float): Float
        return x = value + radius;

    override function get_top(): Float
        return y - radius;

    override function set_top(value: Float): Float
        return y = value + radius;

    override function get_right(): Float
        return x + radius;

    override function set_right(value: Float): Float
        return x = value - radius;

    override function get_bottom(): Float
        return y + radius;

    override function set_bottom(value: Float): Float
        return y = value - radius;

    override function collidePoint(point: Vector2): Bool
        return Collide.circleVsPoint(absolutePosition, scaledRadius, point);

    override function collideBounds(bounds: Bounds): Bool
        return Collide.boundsVsCircle(bounds, absolutePosition, scaledRadius);

    override function intersectLine(from: Vector2, to: Vector2): Option<HitPosition>
        return Collide.intersectCircleVsLine(absolutePosition, scaledRadius, from, to);

    override function collideLine(from: Vector2, to: Vector2): Bool
        return Collide.circleVsLine(absolutePosition, scaledRadius, from, to);

    function clone(): Collider
        return new CircleCollider(radius, x, y, node);

    function debugDraw(g: h2d.Graphics) {
        g.drawCircle(absoluteX, absoluteY, scaledRadius);
    }

    function collideBox(box: BoxCollider): Bool
        return box.collideCircle(this);

    function collideCircle(circle: CircleCollider): Bool
        return Collide.circleVsCircle(absolutePosition, scaledRadius, circle.absolutePosition, circle.scaledRadius);

    function collidePolygon(polygon: PolygonCollider): Bool
        return polygon.collideCircle(this);

    function collideGrid(grid: GridCollider): Bool
        return grid.collideCircle(this);
}
