package madolib.heaps;

import madolib.Option;

enum abstract PadKey(Int) from Int to Int {
    final A;
    final B;
    final X;
    final Y;
    final SELECT;
    final START;
    final LT;
    final RT;
    final LB;
    final RB;
    final LSTICK;
    final RSTICK;
    final DPAD_UP;
    final DPAD_DOWN;
    final DPAD_LEFT;
    final DPAD_RIGHT;
    final AXIS_LEFT_X;
    final AXIS_LEFT_X_NEG;
    final AXIS_LEFT_X_POS;
    final AXIS_LEFT_Y;
    final AXIS_LEFT_Y_NEG;
    final AXIS_LEFT_Y_POS;
    final AXIS_RIGHT_X;
    final AXIS_RIGHT_X_NEG;
    final AXIS_RIGHT_X_POS;
    final AXIS_RIGHT_Y;
    final AXIS_RIGHT_Y_NEG;
    final AXIS_RIGHT_Y_POS;
    public static final LENGTH = 28;

    public inline function new(v: Int)
        this = v;
}

private enum abstract PadKeyStatus(Int) to Int {
    final Release;
    final Pressed;
    final Down;
    final Released;

    public inline function new(v: Int) {
        this = v;
    }

    @:op(A < B) static function lt(a: PadKeyStatus, b: PadKeyStatus): Bool;

    @:op(A > B) static function gt(a: PadKeyStatus, b: PadKeyStatus): Bool;

    @:op(A <= B) static function lte(a: PadKeyStatus, b: PadKeyStatus): Bool;

    @:op(A >= B) static function gte(a: PadKeyStatus, b: PadKeyStatus): Bool;

    @:op(A == B) static function eq(a: PadKeyStatus, b: PadKeyStatus): Bool;

    @:op(A != B) static function ne(a: PadKeyStatus, b: PadKeyStatus): Bool;
}

class GamePad implements Disposable {
    public static final allGamepads: Array<GamePad> = [];
    public static final allDevices: Array<hxd.Pad> = [];

    var device: Option<hxd.Pad> = None;
    var stats: Array<PadKeyStatus> = [];

    public final index: Int;

    public var deadZone = 0.2;
    public var axisAsButtonDeadZone = 0.7;
    public var lastActivity(default, null): Float = 0;

    static var mapping = [
        hxd.Pad.DEFAULT_CONFIG.A,
        hxd.Pad.DEFAULT_CONFIG.B,
        hxd.Pad.DEFAULT_CONFIG.X,
        hxd.Pad.DEFAULT_CONFIG.Y,
        hxd.Pad.DEFAULT_CONFIG.back,
        hxd.Pad.DEFAULT_CONFIG.start,
        hxd.Pad.DEFAULT_CONFIG.LT,
        hxd.Pad.DEFAULT_CONFIG.RT,
        hxd.Pad.DEFAULT_CONFIG.LB,
        hxd.Pad.DEFAULT_CONFIG.RB,
        hxd.Pad.DEFAULT_CONFIG.analogClick,
        hxd.Pad.DEFAULT_CONFIG.ranalogClick,
        hxd.Pad.DEFAULT_CONFIG.dpadUp,
        hxd.Pad.DEFAULT_CONFIG.dpadDown,
        hxd.Pad.DEFAULT_CONFIG.dpadLeft,
        hxd.Pad.DEFAULT_CONFIG.dpadRight,
        hxd.Pad.DEFAULT_CONFIG.analogX,
        hxd.Pad.DEFAULT_CONFIG.analogX,
        hxd.Pad.DEFAULT_CONFIG.analogX,
        hxd.Pad.DEFAULT_CONFIG.analogY,
        hxd.Pad.DEFAULT_CONFIG.analogY,
        hxd.Pad.DEFAULT_CONFIG.analogY,
        hxd.Pad.DEFAULT_CONFIG.ranalogX,
        hxd.Pad.DEFAULT_CONFIG.ranalogX,
        hxd.Pad.DEFAULT_CONFIG.ranalogX,
        hxd.Pad.DEFAULT_CONFIG.ranalogY,
        hxd.Pad.DEFAULT_CONFIG.ranalogY,
        hxd.Pad.DEFAULT_CONFIG.ranalogY
    ];

    public function new(?deadZone: Float, ?onEnable: GamePad -> Void) {
        allGamepads.push(this);
        index = allGamepads.length - 1;

        if(deadZone != null) this.deadZone = deadZone;
        if(onEnable != null) this.onEnable = onEnable;

        if(allDevices.length == 0)
            hxd.Pad.wait(onDevice);
        else
            enableDevice(allDevices[0]);

        lastActivity = haxe.Timer.stamp();
    }

    static function onDevice(p: hxd.Pad) {
        for(i in allGamepads) {
            if(i.device.isNone()) {
                i.enableDevice(p);
                return;
            }
        }
        allDevices.push(p);
        p.onDisconnect = () -> allDevices.remove(p);
    }

    public dynamic function onEnable(pad: GamePad) {}

    public dynamic function onDisable(pad: GamePad) {}

    public inline function isEnabled(): Bool
        return !device.isNone();

    inline function enableDevice(p: hxd.Pad) {
        if(isEnabled())
            return;
        allDevices.remove(p);
        p.onDisconnect = () -> disable();
        device = Some(p);
        onEnable(this);
    }

    public function dispose() {
        allGamepads.remove(this);
        device.each(device -> onDevice(device));
        device = None;
    }

    function disable() {
        if(device.isNone()) return;
        device = None;
        onDisable(this);
    }

    public inline function rumble(strength: Float, timeSec: Float) {
        device.each(device -> device.rumble(strength, timeSec));
    }

    inline function getControlValue(index: Int, simplified: Bool, overrideDeadZone: Float = -1): Float {
        return switch device {
            case None: 0;
            case Some(device):
                final v = if(Math.inRange(index, 0, device.values.length)) device.values[index] else 0;
                final deadZone = if(overrideDeadZone < 0) this.deadZone else overrideDeadZone;

                if(simplified)
                    if(v < -deadZone) -1 else if(v > deadZone) 1 else 0;
                else if(Math.abs(v) > deadZone)
                    v;
                else
                    0;
        }
    }

    public inline function getValue(k: PadKey, simplified: Bool = false, overrideDeadZone: Float = -1): Float
        return if(isEnabled()) getControlValue(mapping[k], simplified, overrideDeadZone) else 0;

    public inline function getAxis(k: PadKey, simplified: Bool = false, overrideDeadZone: Float = -1): Float {
        final v = getValue(k, simplified, overrideDeadZone);
        return switch k {
            case AXIS_LEFT_X_NEG, AXIS_LEFT_Y_NEG, AXIS_RIGHT_X_NEG, AXIS_RIGHT_Y_NEG:
                if(v < 0) Math.abs(v) else 0;
            case AXIS_LEFT_X_POS, AXIS_LEFT_Y_POS, AXIS_RIGHT_X_POS, AXIS_RIGHT_Y_POS:
                if(v > 0) v else 0;
            default:
                v;
        }
    }

    public inline function checkDownStatus(k: PadKey): Bool
        return switch k {
            case AXIS_LEFT_X_NEG, AXIS_LEFT_Y_NEG, AXIS_RIGHT_X_NEG, AXIS_RIGHT_Y_NEG:
                getValue(k, true, axisAsButtonDeadZone) < 0;
            case AXIS_LEFT_X_POS, AXIS_LEFT_Y_POS, AXIS_RIGHT_X_POS, AXIS_RIGHT_Y_POS:
                getValue(k, true, axisAsButtonDeadZone) > 0;
            default:
                getValue(k, true) != 0;
        }

    public inline function isDown(k: PadKey): Bool {
        final v = stats[k];
        return isEnabled() && v > Release && v < Released;
    }

    public inline function isPressed(k: PadKey): Bool
        return isEnabled() && stats[k] == Pressed;

    public inline function isReleased(k: PadKey): Bool
        return isEnabled() && stats[k] == Released;

    public static function update() {
        for(d in allGamepads) {
            var hasToggle = false;
            d.device.each(device -> {
                for(i in 0...PadKey.LENGTH) {
                    final t = d.stats[i];
                    if(d.checkDownStatus(i)) {
                        hasToggle = true;
                        d.stats[i] = if(t >= Pressed) Down else Pressed;
                        continue;
                    }
                    if(t > Release && t < Released)
                        d.stats[i] = Released;
                    else if(t == Released)
                        d.stats[i] = Release;
                }
            });
            if(hasToggle)
                d.lastActivity = haxe.Timer.stamp();
        }
    }
}
