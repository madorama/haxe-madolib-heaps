package madolib.heaps;

import hxd.Key;

using madolib.extensions.ArrayExt;

class Input {
    public static var mouseX(default, null): Float = 0;
    public static var mouseY(default, null): Float = 0;

    public inline static function setMousePosition(x: Float, y: Float) {
        mouseX = x;
        mouseY = y;
        hxd.Window.getInstance().setCursorPos(Std.int(x), Std.int(y));
    }

    public inline static function isAnyDown(keys: Array<Int>): Bool
        return keys.any(Key.isDown);

    public inline static function isAnyPressed(keys: Array<Int>): Bool
        return keys.any(Key.isPressed);

    public inline static function isAnyReleased(keys: Array<Int>): Bool
        return keys.any(Key.isReleased);

    public inline static function isAllDown(keys: Array<Int>): Bool
        return keys.all(Key.isDown);

    public inline static function isAllPressed(keys: Array<Int>): Bool
        return keys.all(Key.isPressed);

    public inline static function isAllReleased(keys: Array<Int>): Bool
        return keys.all(Key.isReleased);

    public inline static function isShift(): Bool
        return Key.isDown(Key.SHIFT);

    public inline static function isCtrl(): Bool
        return Key.isDown(Key.CTRL);

    public inline static function isAlt(): Bool
        return Key.isDown(Key.ALT);
}
