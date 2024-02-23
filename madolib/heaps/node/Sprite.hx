package madolib.heaps.node;

import aseprite.AseAnim;
import aseprite.Aseprite;
import h2d.RenderContext;
import madolib.Option;
import madolib.event.Signal0;

using madolib.extensions.MapExt;
using madolib.heaps.extensions.AsepriteExt;
using madolib.heaps.extensions.AsepriteFrameExt;

class Sprite extends Node {
    public var currentAnimationName(default, null) = "";

    var animation: Option<AseAnim> = None;
    var animations: Map<String, AseAnim> = [];

    var isDirty = false;

    var oldPivotX = 0.;
    var oldPivotY = 0.;

    public var currentAnimationFrame(get, never): Int;

    inline function get_currentAnimationFrame(): Int
        return animation.map(anim -> anim.currentFrame).withDefault(0);

    public var timeScale(default, set): Float = 1.;

    inline function set_timeScale(v: Float): Float {
        isDirty = true;
        return timeScale = v;
    }

    public var xFlip(default, set) = false;

    inline function set_xFlip(v: Bool): Bool {
        isDirty = true;
        return xFlip = v;
    }

    public var yFlip(default, set) = false;

    inline function set_yFlip(v: Bool): Bool {
        isDirty = true;
        return yFlip = v;
    }

    public inline function setFlip(x: Bool, y: Bool) {
        xFlip = x;
        yFlip = y;
    }

    public final onAnimEnd = new Signal0();

    override function get_width(): Float
        return animation.map(anim -> anim.getFrame().tile.width).withDefault(0);

    override function get_height(): Float
        return animation.map(anim -> anim.getFrame().tile.height).withDefault(0);

    public function new() {
        super();
    }

    extern overload public inline function addAnimationWithSlice(ase: Aseprite, sliceName: String, loop: Bool = false): Sprite {
        addAnimationWithAseAnim(sliceName, ase.getSlices(sliceName).toAseAnim());
        return this;
    }

    extern overload public inline function addAnimation(ase: Aseprite, name: String, ?sliceName: String, loop: Bool = false): Sprite {
        addAnimationWithAseAnim(name, ase.getAnimationFromTag(name, sliceName, loop));
        return this;
    }

    extern overload public inline function addAnimation(ase: aseprite.res.Aseprite, name: String, ?sliceName: String, loop: Bool = false): Sprite {
        addAnimationWithAseAnim(name, ase.toAseprite().getAnimationFromTag(name, sliceName, loop));
        return this;
    }

    public inline function addAnimationWithAseAnim(name: String, aseAnim: AseAnim): Sprite {
        animations.set(name, aseAnim);
        if(animation.isNone()) setCurrentAnimation(aseAnim, name);
        return this;
    }

    public function changeAnim(name: String, ?loop: Bool, ?startFrame = 0) {
        if(name == currentAnimationName)
            return;

        switch animations.getOption(name) {
            case None:
                trace('Animation "$name" is not exists');
            case Some(v):
                animation.each(anim -> {
                    anim.remove();
                    @:nullSafety(Off) anim.onAnimEnd = null;
                });
                setCurrentAnimation(v, name, loop, startFrame);
        }
    }

    inline function setCurrentAnimation(aseAnim: AseAnim, name: String, ?loop: Bool, ?startFrame: Int) {
        animation = Some(aseAnim);
        addChild(aseAnim);
        aseAnim.loop = loop ?? aseAnim.loop;
        aseAnim.currentFrame = startFrame ?? 0;
        aseAnim.onAnimEnd = () -> onAnimEnd();
        currentAnimationName = name;
        isDirty = true;
    }

    inline function syncAnimation() {
        animation.each(anim -> {
            anim.timeScale = timeScale;
            for(frame in anim.frames) {
                frame.tile.xFlip = xFlip;
                frame.tile.yFlip = yFlip;
            }
        });
    }

    override function sync(ctx: RenderContext) {
        if(oldPivotX != pivotX || oldPivotY != pivotY)
            isDirty = true;
        if(isDirty) {
            syncAnimation();
            isDirty = false;
        }
        super.sync(ctx);
        oldPivotX = pivotX;
        oldPivotY = pivotY;
    }
}
