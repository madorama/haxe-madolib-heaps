package madolib.heaps;

import hxd.Window;
import madolib.event.Signal0;
import madolib.event.Signal;

class App extends hxd.App {
    public var window: Window;

    static var disposedNodes: Array<Node> = [];

    public var ftime(default, null): Float = 0;

    public var elapsedFrames(get, never): Int;

    inline function get_elapsedFrames(): Int
        return Std.int(ftime);

    public var elapsedSeconds(get, never): Float;

    inline function get_elapsedSeconds(): Float
        return ftime / hxd.Timer.wantedFPS;

    public static var tmod(default, null): Float = 1 / hxd.Timer.wantedFPS;

    public static var FIXED_UPDATE_FPS(default, default): Int = 60;

    public var defaultFrameRate(get, never): Float;

    inline function get_defaultFrameRate(): Float
        return hxd.Timer.wantedFPS;

    public final onWindowEvent = new Signal<hxd.Event>();
    public final onFocus = new Signal0();
    public final onMouseLeave = new Signal0();
    public final onMouseEnter = new Signal0();
    public final onBlur = new Signal0();

    public inline function getFixedUpdateAccumRatio(): Float
        return fixedUpdateAccum / (defaultFrameRate / FIXED_UPDATE_FPS);

    public function new() {
        super();
        window = Window.getInstance();
        centerWindow();
    }

    public inline function centerWindow() {
        #if(hldx || hlsdl)
        @:privateAccess window.window.center();
        #end
    }

    public inline function setWindow(?width: Int, ?height: Int, displayMode: DisplayMode = DisplayMode.Windowed) {
        window.displayMode = displayMode;

        width = width ?? window.width;
        height = height ?? window.height;
        window.resize(width ?? window.width, height ?? window.height);

        engine.resize(width, height);
    }

    override function init() {
        super.init();
        window.addEventTarget(e -> onWindowEvent(e));

        onWindowEvent.add(e -> {
            switch e.kind {
                case EOver: onMouseEnter();
                case EOut: onMouseLeave();
                case EFocus: onFocus();
                case EFocusLost: onBlur();
                default:
            }
        });
    }

    override function update(dt: Float) {
        super.update(dt);
        App.tmod = hxd.Timer.tmod;
        GamePad.update();
    }

    var fixedUpdateAccum = 0.;

    public final runUpdate = new Signal<Float>();
    public final runFixedUpdate = new Signal0();
    public final runAfterUpdate = new Signal<Float>();

    @:access(madolib.heaps.Node)
    inline function doUpdate(dt: Float) {
        ftime += App.tmod;

        fixedUpdateAccum += dt;
        while(fixedUpdateAccum >= defaultFrameRate / FIXED_UPDATE_FPS) {
            runFixedUpdate();
            fixedUpdateAccum -= defaultFrameRate / FIXED_UPDATE_FPS;
        }

        runUpdate(dt);

        runAfterUpdate(dt);

        for(node in disposedNodes) {
            if(!node.onDisposed) {
                node.onDispose();
            }
        }
        disposedNodes = [];
    }
}
