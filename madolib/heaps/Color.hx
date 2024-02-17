package madolib.heaps;

/**
 * Inspired:
 *
 * deepnightLibs/Col.hx
 * MIT LICENSE - https://github.com/deepnight/deepnightLibs/blob/master/LICENSE
 *
 * noahzgordon/elm-color-extra
 * MIT LICENSE - https://github.com/noahzgordon/elm-color-extra/blob/master/LICENSE
**/
abstract Color(Int) from Int to Int {
    public static var White = fromRgba(1, 1, 1);
    public static var Black = fromRgba(0, 0, 0);

    public inline function new(argb: Int): Color {
        this = argb;
    }

    public inline static function fromInt(c: Int): Color
        return new Color(c | 0xFF000000);

    public inline static function fromIntWithAlpha(c: Int): Color
        return new Color(c);

    public inline static function fromRgbaInt(r: Int, g: Int, b: Int, a: Int = 255): Color {
        return new Color((a << 24) | (r << 16) | (g << 8) | b);
    }

    public inline static function fromRgba(r: Float, g: Float, b: Float, a: Float = 1): Color {
        return Color.fromRgbaInt(Math.round(r * 255), Math.round(g * 255), Math.round(b * 255), Math.round(a * 255));
    }

    public inline static function fromHsla(h: Float, s: Float, l: Float, a: Float = 1): Color {
        final m2 = if(l <= 0.5) l * (s + 1) else l + s - l * s;
        final m1 = l * 2 - m2;
        final hueToRgb = (h: Float) -> {
            h = if(h < 0)
                h + 1
            else if(h > 1)
                h - 1
            else
                h;
            return if(h * 6 < 1)
                m1 + (m2 - m1) * h * 6
            else if(h * 2 < 1)
                m2
            else if(h * 3 < 2)
                m1 + (m2 - m1) * (2 / 3 - h) * 6
            else
                m1;
        }
        return fromRgba(hueToRgb(h + 1 / 3), hueToRgb(h), hueToRgb(h - 1 / 3), a);
    }

    public inline static function fromHsva(h: Float, s: Float, v: Float, a: Float = 1) {
        return if(s == 0) {
            Color.gray(v);
        } else {
            h = h * 6;
            final i = Math.floor(h);
            final c1 = v * (1 - s);
            final c2 = v * (1 - s * (h - i));
            final c3 = v * (1 - s * (1 - (h - i)));

            switch i {
                case 0, 6: fromRgba(v, c3, c1);
                case 1: fromRgba(c2, v, c1);
                case 2: fromRgba(c1, v, c3);
                case 3: fromRgba(c1, c2, v);
                case 4: fromRgba(c3, c1, v);
                default: fromRgba(v, c1, c2);
            }
        }
    }

    public inline static function gray(v: Float): Color
        return fromRgba(v, v, v);

    public inline static function fromVector(v: h3d.Vector4): Color
        return fromRgba(v.r, v.g, v.b, v.a);

    @:to public inline function toVector4(): h3d.Vector4
        return new h3d.Vector4(r, g, b, a);

    static final sharp = "#".charCodeAt(0);
    static final hexChars = "0123456789ABCDEFabcdef".split("").map(c -> c.charCodeAt(0));
    static final doubleHexValues = {
        final m = new Map();
        for(c in hexChars) {
            final h = @:nullSafety(Off) String.fromCharCode(c);
            m.set(c, Std.parseInt('0x${h}${h}'));
        }
        m;
    }
    static final tripleHexValues = {
        final m = new Map();
        for(c in hexChars) {
            final h = @:nullSafety(Off) String.fromCharCode(c);
            final hh = '${h}${h}';
            m.set(h, Std.parseInt('0x${hh}${hh}${hh}'));
        }
        m;
    }

    extern overload public inline static function parse(hex: String): Option<Color> {
        if(hex.length == 0) return None;

        final start = if(StringTools.fastCodeAt(hex, 0) == sharp) 1 else 0;
        final l = hex.length - start;
        @:nullSafety(Off)
        return if(l == 6 || l == 8) {
            #if js
            final v: Null<UInt> = Std.parseInt('0x${if(start > 0) hex.substr(start) else hex}');
            if(v == null) None else Some(cast(v, Int) & 0xffffffff);
            #else
            final v = Std.parseInt('0x${if(start > 0) hex.substr(start) else hex}');
            if(v == null) None else Some(v);
            #end
        } else if(l == 3) {
            Some(fromRgbaInt(doubleHexValues.get(StringTools.fastCodeAt(hex, start)), doubleHexValues.get(StringTools.fastCodeAt(hex, start + 1)),
                doubleHexValues.get(StringTools.fastCodeAt(hex, start + 2)),));
        } else if(l == 4) {
            Some(fromRgbaInt(doubleHexValues.get(StringTools.fastCodeAt(hex, start + 1)), doubleHexValues.get(StringTools.fastCodeAt(hex, start + 2)),
                doubleHexValues.get(StringTools.fastCodeAt(hex, start + 3)), doubleHexValues.get(StringTools.fastCodeAt(hex, start))));
        } else {
            None;
        }
    }

    extern overload public inline static function parse(hex: String, defaultColor: Color): Color
        return parse(hex).withDefault(defaultColor);

    public var ri(get, set): Int;

    inline function get_ri(): Int
        return (this >> 16) & 0xFF;

    inline function set_ri(v: Int): Int {
        this = fromRgbaInt(v, gi, bi, ai);
        return v;
    }

    public var gi(get, set): Int;

    inline function get_gi(): Int
        return (this >> 8) & 0xFF;

    inline function set_gi(v: Int): Int {
        this = fromRgbaInt(ri, v, bi, ai);
        return v;
    }

    public var bi(get, set): Int;

    inline function get_bi(): Int
        return this & 0xFF;

    inline function set_bi(v: Int): Int {
        this = fromRgbaInt(ri, gi, v, ai);
        return v;
    }

    public var ai(get, set): Int;

    inline function get_ai(): Int
        return (this >> 24) & 0xFF;

    inline function set_ai(v: Int): Int {
        this = fromRgbaInt(ri, gi, bi, v);
        return v;
    }

    public var r(get, set): Float;

    inline function get_r(): Float
        return ri / 255;

    inline function set_r(v: Float): Float {
        this = fromRgba(v, g, b, a);
        return v;
    }

    public var g(get, set): Float;

    inline function get_g(): Float
        return gi / 255;

    inline function set_g(v: Float): Float {
        this = fromRgba(r, v, b, a);
        return v;
    }

    public var b(get, set): Float;

    inline function get_b(): Float
        return bi / 255;

    inline function set_b(v: Float): Float {
        this = fromRgba(r, g, v, a);
        return v;
    }

    public var a(get, set): Float;

    inline function get_a(): Float
        return ai / 255;

    inline function set_a(v: Float): Float {
        this = fromRgba(r, g, b, v);
        return v;
    }

    var maxColor(get, never): Float;

    inline function get_maxColor(): Float
        return Math.max(r, Math.max(g, b));

    var minColor(get, never): Float;

    inline function get_minColor(): Float
        return Math.min(r, Math.min(g, b));

    public var hue(get, set): Float;

    inline function get_hue(): Float {
        final delta = maxColor - minColor;
        return if(delta == 0) {
            0;
        } else {
            var h = if(maxColor == r) {
                ((g - b) / delta) / 6;
            } else if(maxColor == g) {
                (2 + (b - r) / delta) / 6;
            } else {
                (4 + (r - g) / delta) / 6;
            }
            return if(Math.isNaN(h)) {
                0;
            } else if(h < 0) {
                h + 1;
            } else {
                h;
            }
        }
    }

    inline function set_hue(v: Float): Float {
        this = fromHsla(v, saturation, lightness, a);
        return v;
    }

    public var saturation(get, set): Float;

    inline function get_saturation(): Float {
        return if(minColor == maxColor) {
            0;
        } else if(lightness < 0.5) {
            (maxColor - minColor) / (maxColor + minColor);
        } else {
            (maxColor - minColor) / (2 - maxColor - minColor);
        }
    }

    inline function set_saturation(v: Float): Float {
        this = fromHsla(hue, v, lightness, a);
        return v;
    }

    public var lightness(get, set): Float;

    inline function get_lightness(): Float {
        return (maxColor + minColor) / 2;
    }

    inline function set_lightness(v: Float): Float {
        this = fromHsla(hue, saturation, v, a);
        return v;
    }

    public var brightness(get, set): Float;

    inline function get_brightness(): Float
        return maxColor;

    inline function set_brightness(v: Float): Float {
        this = fromHsva(hue, saturation, v, a);
        return v;
    }

    public var fastLuminance(get, never): Float;

    static final redLumaI = 2126;
    static final greenLumaI = 7152;
    static final blueLumaI = 722;

    inline function get_fastLuminance(): Float
        return (redLumaI * ri + greenLumaI * gi + blueLumaI * bi) / 10000 / 255;

    public var luminance(get, never): Float;

    static final redLuma = 0.2126;
    static final greenLuma = 0.7152;
    static final blueLuma = 0.0722;

    inline function get_luminance(): Float
        return Math.sqrt(redLuma * (ri * ri) + greenLuma * (gi * gi) + blueLuma * (bi * bi)) / 255;

    public inline function getGrayscaleFactor(): Float
        return luminance;

    public inline function toGraysacle(): Color {
        final f = getGrayscaleFactor();
        return fromRgba(f, f, f, a);
    }

    public inline function invert(): Color
        return fromRgba(1 - r, 1 - g, 1 - b, a);

    public inline function clone(): Color
        return new Color(this);

    inline function scale(max: Float, scale: Float, value: Float): Float {
        scale = Math.clamp(scale, -1, 1);
        value = Math.clamp(value, 0, max);
        final diff = if(scale > 0) max - value else value;
        return value + diff * scale;
    }

    public inline function scaleHsl(saturationScale: Float, lightnessScale: Float, alphaScale: Float): Color {
        final s = scale(1, saturationScale, saturation);
        final l = scale(1, lightnessScale, lightness);
        final a = scale(1, alphaScale, a);
        return fromHsla(hue, s, l, a);
    }

    public inline function lighten(pct: Float): Color
        return scaleHsl(0, pct, 0);

    public inline function darken(pct: Float): Color
        return scaleHsl(0, -pct, 0);

    public inline function interpolate(to: Color, ratio: Float): Color
        return fromRgbaInt(Math.round(Math.lerp(ri, to.ri, ratio)), Math.round(Math.lerp(gi, to.gi, ratio)), Math.round(Math.lerp(bi, to.bi, ratio)),
            Math.round(Math.lerp(ai, to.ai, ratio)),);

    public static inline function graduate(min: Color, med: Color, max: Color, ratio: Float)
        return if(ratio < 0.5) min.interpolate(med, ratio * 2) else med.interpolate(max, (ratio - 0.5) * 2);

    public inline function withoutAlpha(): Color
        return this & 0xFFFFFF;

    public inline function toHex(withSharp = true): String {
        final s = StringTools.hex(withoutAlpha(), 6);
        return if(withSharp) '#${s}' else s;
    }

    public inline function toArgbHex(withSharp = true): String {
        final s = StringTools.hex(this, 8);
        return if(withSharp) '#${s}' else s;
    }
}
