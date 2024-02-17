package madolib.heaps.node;

import differ.shapes.Ray;
import hxmath.math.Vector2;
import madolib.Option;
import madolib.collider.Collide.HitPosition;
import madolib.collider.Collide;
import madolib.geom.Bounds;

abstract class Collider extends Node {
    public var node(default, default): Node = Node.empty;
    @:isVar public var top(get, set): Float = 0;
    @:isVar public var bottom(get, set): Float = 0;
    @:isVar public var left(get, set): Float = 0;
    @:isVar public var right(get, set): Float = 0;

    function get_top(): Float
        return top;

    function set_top(value: Float): Float
        return top = value;

    function get_bottom(): Float
        return bottom;

    function set_bottom(value: Float): Float
        return bottom = value;

    function get_left(): Float
        return left;

    function set_left(value: Float): Float
        return left = value;

    function get_right(): Float
        return right;

    function set_right(value: Float): Float
        return right = value;

    public var centerX(get, set): Float;
    public var centerY(get, set): Float;

    function get_centerX(): Float
        return left + width * .5;

    function set_centerX(value: Float): Float
        return left = value - width * .5;

    function get_centerY(): Float
        return top + height * .5;

    function set_centerY(value: Float): Float
        return top = value - height * .5;

    public var size(get, never): Vector2;
    public var halfSize(get, never): Vector2;

    inline function get_size(): Vector2
        return new Vector2(width, height);

    inline function get_halfSize(): Vector2
        return new Vector2(width * .5, height * .5);

    public var absolutePosition(get, never): Vector2;
    public var absoluteX(get, never): Float;
    public var absoluteY(get, never): Float;
    public var absoluteCenterX(get, never): Float;
    public var absoluteCenterY(get, never): Float;
    public var absoluteTop(get, never): Float;
    public var absoluteBottom(get, never): Float;
    public var absoluteLeft(get, never): Float;
    public var absoluteRight(get, never): Float;
    public var absoluteWidth(get, never): Float;
    public var absoluteHeight(get, never): Float;

    inline function get_absolutePosition(): Vector2
        return new Vector2(absoluteX, absoluteY);

    inline function get_absoluteX(): Float
        return x + node.pivotedX;

    inline function get_absoluteY(): Float
        return y + node.pivotedY;

    inline function get_absoluteCenterX(): Float
        return absoluteX + width * .5;

    inline function get_absoluteCenterY(): Float
        return absoluteY + height * .5;

    inline function get_absoluteTop(): Float
        return top * node.scaleY + node.pivotedY;

    inline function get_absoluteBottom(): Float
        return bottom * node.scaleY + node.pivotedY;

    inline function get_absoluteLeft(): Float
        return left * node.scaleX + node.pivotedX;

    inline function get_absoluteRight(): Float
        return right * node.scaleX + node.pivotedX;

    inline function get_absoluteWidth(): Float
        return width * node.scaleX;

    inline function get_absoluteHeight(): Float
        return height * node.scaleY;

    var innerBounds = new Bounds(0, 0, 0, 0);

    public var bounds(get, never): Bounds;

    function get_bounds(): Bounds {
        innerBounds.x = absoluteLeft;
        innerBounds.y = absoluteTop;
        innerBounds.width = absoluteWidth;
        innerBounds.height = absoluteHeight;
        return innerBounds;
    }

    public function new(?node: Node) {
        super();
        if(node != null) this.node = node;
    }

    public function collidePoint(point: Vector2): Bool {
        return point.x >= absoluteLeft && point.x <= absoluteRight && point.y >= absoluteTop && point.y <= absoluteBottom;
    }

    public function collideBounds(bounds: Bounds): Bool {
        return absoluteRight > bounds.left && absoluteBottom > bounds.top && absoluteLeft < bounds.right && absoluteTop < bounds.bottom;
    }

    public function intersectRay(ray: Ray): Option<HitPosition>
        return intersectLine(new Vector2(ray.start.x, ray.start.y), new Vector2(ray.end.x, ray.end.y));

    public function intersectLine(from: Vector2, to: Vector2): Option<HitPosition>
        return Collide.intersectBoundsVsLine(bounds, from, to);

    public function collideLine(from: Vector2, to: Vector2): Bool
        return Collide.boundsVsLine(bounds, from, to);

    public function collide(c: Collider): Bool
        return switch c {
            case c if(c is BoxCollider):
                collideBox(cast c);
            case c if(c is CircleCollider):
                collideCircle(cast c);
            case c if(c is PolygonCollider):
                collidePolygon(cast c);
            case c if(c is GridCollider):
                collideGrid(cast c);
            default:
                false;
        }

    @SuppressWarnings("checkstyle:Return")
    abstract public function debugDraw(g: h2d.Graphics): Void;

    abstract public function clone(): Collider;

    abstract function collideBox(box: BoxCollider): Bool;

    abstract function collideCircle(circle: CircleCollider): Bool;

    abstract function collidePolygon(polygon: PolygonCollider): Bool;

    abstract function collideGrid(grid: GridCollider): Bool;
}
