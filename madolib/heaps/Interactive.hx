package madolib.heaps;

import madolib.event.Signal0;
import madolib.event.Signal;

class Interactive {
    final interactive: h2d.Interactive;

    public var cursor(get, set): Null<hxd.Cursor>;

    inline function get_cursor(): Null<hxd.Cursor>
        return interactive.cursor;

    inline function set_cursor(v: Null<hxd.Cursor>): Null<hxd.Cursor>
        return interactive.cursor = v;

    public var allowMultiClick(get, set): Bool;

    inline function get_allowMultiClick(): Bool
        return interactive.allowMultiClick;

    inline function set_allowMultiClick(v: Bool): Bool
        return interactive.allowMultiClick = v;

    public var x(get, set): Float;

    inline function get_x(): Float
        return interactive.x;

    inline function set_x(v: Float): Float
        return interactive.x = v;

    public var y(get, set): Float;

    inline function get_y(): Float
        return interactive.y;

    inline function set_y(v: Float): Float
        return interactive.y = v;

    public var width(get, set): Float;

    inline function get_width(): Float
        return interactive.width;

    inline function set_width(v: Float): Float
        return interactive.width = v;

    public var height(get, set): Float;

    inline function get_height(): Float
        return interactive.height;

    inline function set_height(v: Float): Float
        return interactive.height = v;

    public var isEllipse(get, set): Bool;

    inline function get_isEllipse(): Bool
        return interactive.isEllipse;

    inline function set_isEllipse(v: Bool): Bool
        return interactive.isEllipse = v;

    public var cancelEvents(get, set): Bool;

    inline function get_cancelEvents(): Bool
        return interactive.cancelEvents;

    inline function set_cancelEvents(v: Bool): Bool
        return interactive.cancelEvents = v;

    public var propagateEvents(get, set): Bool;

    inline function get_propagateEvents(): Bool
        return interactive.propagateEvents;

    inline function set_propagateEvents(v: Bool): Bool
        return interactive.propagateEvents = v;

    public var enableRightButton(get, set): Bool;

    inline function get_enableRightButton(): Bool
        return interactive.enableRightButton;

    inline function set_enableRightButton(v: Bool): Bool
        return interactive.enableRightButton = v;

    public var backgroundColor(get, set): Null<Int>;

    inline function get_backgroundColor(): Null<Int>
        return interactive.backgroundColor;

    inline function set_backgroundColor(v: Null<Int>): Null<Int>
        return interactive.backgroundColor = v;

    public var shape(get, set): h2d.col.Collider;

    inline function get_shape(): h2d.col.Collider
        return interactive.shape;

    inline function set_shape(v: h2d.col.Collider): h2d.col.Collider
        return interactive.shape = v;

    public var shapeX(get, set): Float;

    inline function get_shapeX(): Float
        return interactive.shapeX;

    inline function set_shapeX(v: Float): Float
        return interactive.shapeX = v;

    public var shapeY(get, set): Float;

    inline function get_shapeY(): Float
        return interactive.shapeY;

    inline function set_shapeY(v: Float): Float
        return interactive.shapeY = v;

    public final onStartCapture = new Signal<hxd.Event>();
    public final onCancelCapture = new Signal0();
    public final onOver = new Signal<hxd.Event>();
    public final onOut = new Signal<hxd.Event>();
    public final onPush = new Signal<hxd.Event>();
    public final onRelease = new Signal<hxd.Event>();
    public final onReleaseOutside = new Signal<hxd.Event>();
    public final onClick = new Signal<hxd.Event>();
    public final onMove = new Signal<hxd.Event>();
    public final onWheel = new Signal<hxd.Event>();
    public final onFocus = new Signal<hxd.Event>();
    public final onFocusLost = new Signal<hxd.Event>();
    public final onKeyUp = new Signal<hxd.Event>();
    public final onKeyDown = new Signal<hxd.Event>();
    public final onCheck = new Signal<hxd.Event>();
    public final onTextInput = new Signal<hxd.Event>();
    public var disabled(default, set): Bool = false;

    inline function set_disabled(v: Bool): Bool {
        cancelEvents = v;
        disabled = v;
        return v;
    }

    public function new(interactive: h2d.Interactive) {
        this.interactive = interactive;
        interactive.onOver = e -> {
            if(disabled) return;
            onOver(e);
        }
        interactive.onOut = e -> {
            if(disabled) return;
            onOut(e);
        }
        interactive.onPush = e -> {
            if(disabled) return;
            onPush(e);
        }
        interactive.onRelease = e -> {
            if(disabled) return;
            onRelease(e);
        }
        interactive.onReleaseOutside = e -> {
            if(disabled) return;
            onReleaseOutside(e);
        }
        interactive.onClick = e -> {
            if(disabled) return;
            onClick(e);
        }
        interactive.onMove = e -> {
            if(disabled) return;
            onMove(e);
        }
        interactive.onWheel = e -> {
            if(disabled) return;
            onWheel(e);
        }
        interactive.onFocus = e -> {
            if(disabled) return;
            onFocus(e);
        }
        interactive.onFocusLost = e -> {
            if(disabled) return;
            onFocusLost(e);
        }
        interactive.onKeyUp = e -> {
            if(disabled) return;
            onKeyUp(e);
        }
        interactive.onKeyDown = e -> {
            if(disabled) return;
            onKeyDown(e);
        }
        interactive.onCheck = e -> {
            if(disabled) return;
            onCheck(e);
        }
        interactive.onTextInput = e -> {
            if(disabled) return;
            onTextInput(e);
        }
    }

    public inline function preventClick() {
        interactive.preventClick();
    }

    public inline function startCapture() {
        if(interactive.getScene() != null) {
            interactive.startCapture(onStartCapture.invoke, onCancelCapture.invoke);
        }
    }

    public inline function stopCapture() {
        interactive.stopCapture();
    }

    public inline function focus() {
        interactive.focus();
    }

    public inline function blur() {
        interactive.blur();
    }

    public inline function isOver(): Bool
        return interactive.isOver();

    public inline function hasFocus(): Bool
        return interactive.hasFocus();

    public inline function remove() {
        interactive.remove();
    }
}
