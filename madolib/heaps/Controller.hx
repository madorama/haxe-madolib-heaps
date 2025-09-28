package madolib.heaps;

import madolib.heaps.GamePad;
import madolib.heaps.Input;

using madolib.extensions.ArrayExt;

private enum abstract BindingState(Int) to Int {
    final Release;
    final Pressed;
    final Down;
    final Released;

    public inline function new(v: Int) {
        this = v;
    }

    @:op(A < B) static function lt(a: BindingState, b: BindingState): Bool;

    @:op(A > B) static function gt(a: BindingState, b: BindingState): Bool;

    @:op(A <= B) static function lte(a: BindingState, b: BindingState): Bool;

    @:op(A >= B) static function gte(a: BindingState, b: BindingState): Bool;

    @:op(A == B) static function eq(a: BindingState, b: BindingState): Bool;

    @:op(A != B) static function ne(a: BindingState, b: BindingState): Bool;
}

class KeyBinding {
    final keys: Array<Int> = [];
    final pads: Array<PadKey> = [];
    final pad: GamePad;
    var state: BindingState = Release;

    public function new(pad: GamePad) {
        this.pad = pad;
    }

    public inline function resetKey(): KeyBinding {
        keys.resize(0);
        return this;
    }

    public inline function resetPad(): KeyBinding {
        pads.resize(0);
        return this;
    }

    public inline function reset(): KeyBinding {
        resetKey();
        return resetPad();
    }

    public inline function setKey(...keys: Int): KeyBinding {
        for(key in keys)
            if(!this.keys.contains(key)) this.keys.push(key);
        return this;
    }

    public inline function setPad(...padKeys: PadKey): KeyBinding {
        for(padKey in padKeys)
            if(!pads.contains(padKey)) pads.push(padKey);
        return this;
    }

    public inline function removeKey(...keys: Int): KeyBinding {
        for(key in keys)
            keys.remove(key);
        return this;
    }

    public inline function removePad(...padKeys: PadKey): KeyBinding {
        for(padKey in padKeys)
            pads.remove(padKey);
        return this;
    }

    public inline function isPressed(): Bool
        return state == Pressed;

    public inline function isDown(): Bool
        return state == Down;

    public inline function isReleased(): Bool
        return state == Released;

    public inline function getValue(): Float
        return if(Input.isAnyDown(keys)) {
            1.0;
        } else {
            pads.maxValue(k -> pad.getAxis(k)).withDefault(0);
        }

    public function update() {
        if(Input.isAnyDown(keys) || pads.any(pad.isDown)) {
            state = if(state >= Pressed) Down else Pressed;
            return;
        }
        if(state > Release && state < Released) {
            state = Released;
        } else if(state == Released) {
            state = Release;
        }
    }
}

@:structInit
@:access(madolib.heaps.Controller)
class GameKey {
    final binding: KeyBinding;
    final keys: Array<Int> = [];
    final pads: Array<PadKey> = [];
    final pad: GamePad;
    var bufferTime: Float;
    var bufferCount: Float = 0.;
    var consumed = false;

    public function new(?pad: GamePad, bufferTime: Float = 0) {
        final pad = pad ?? GamePad.allGamepads[0];
        binding = new KeyBinding(pad);
        this.pad = pad;
        this.bufferTime = bufferTime;

        Controller.gameKeys.push(this);
    }

    public inline function unregister() {
        Controller.gameKeys.remove(this);
    }

    public inline function resetKey(): GameKey {
        binding.resetKey();
        return this;
    }

    public inline function resetPad(): GameKey {
        binding.resetPad();
        return this;
    }

    public inline function reset(): GameKey {
        binding.reset();
        return this;
    }

    public inline function setKey(...keys: Int): GameKey {
        binding.setKey(...keys);
        return this;
    }

    public inline function setPad(...padKeys: PadKey): GameKey {
        binding.setPad(...padKeys);
        return this;
    }

    public inline function removeKey(...key: Int): GameKey {
        binding.removeKey(...key);
        return this;
    }

    public inline function removePad(...padKeys: PadKey): GameKey {
        binding.removePad(...padKeys);
        return this;
    }

    public inline function getValue(): Float
        return binding.getValue();

    public inline function isPressed(): Bool
        return !this.consumed && (bufferCount > 0 || binding.isPressed());

    public inline function isDown(): Bool
        return binding.isDown();

    public inline function isReleased(): Bool
        return binding.isReleased();

    public var holdTime = 16;
    public var firstRepeatInterval = 16;
    public var nextRepeatInterval = 4;

    var firstRepeated = false;
    var repeatStart = false;

    var holdCount: Float = 0;
    var repeatCount: Float = 0;

    public inline function isHold(): Bool
        return holdCount >= holdTime;

    public inline function holdProgress(): Float
        return Math.clamp(holdCount / holdTime, 0, 1);

    public inline function isRepeat(): Bool
        return repeatStart && repeatCount == 0;

    public inline function checkDown(): Bool
        return isDown() || isPressed();

    public inline function update(dt: Float) {
        binding.update();

        consumed = false;
        if(bufferCount > 0) {
            bufferCount -= dt;
        }

        final flag = if(binding.isPressed()) {
            bufferCount = bufferTime;
            true;
        } else if(binding.isDown()) {
            true;
        } else {
            false;
        }
        if(!flag) {
            holdCount = 0;
            repeatCount = 0;
            bufferCount = 0;
            firstRepeated = false;
            repeatStart = false;
        } else {
            holdCount += dt;
            repeatCount += dt;
            final interval = if(firstRepeated) nextRepeatInterval else firstRepeatInterval;

            if(repeatCount >= interval) {
                repeatCount = 0;
                firstRepeated = true;
            }
            if(!repeatStart) {
                repeatCount = 0;
                repeatStart = true;
            }
        }
    }

    public inline function consumeBuffer() {
        bufferCount = 0.;
    }

    public inline function consumePress() {
        bufferCount = 0.;
        consumed = true;
    }
}

class Controller {
    static final gameKeys: Array<GameKey> = [];

    public inline static function update(dt: Float) {
        for(gameKey in gameKeys) {
            gameKey.update(dt);
        }
    }
}
