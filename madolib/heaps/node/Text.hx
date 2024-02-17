package madolib.heaps.node;

import h2d.Font;
import h2d.RenderContext;
import h2d.Text.Align;

class Text extends Node {
    static var internalDefaultFont: Option<Font> = None;

    public static var defaultFont(get, set): Font;

    inline static function get_defaultFont(): Font
        return internalDefaultFont.withDefault(hxd.res.DefaultFont.get());

    inline static function set_defaultFont(v: Font): Font {
        internalDefaultFont = Some(v);
        return v;
    }

    var _text: h2d.Text;

    public var text(get, set): String;

    inline function get_text(): String
        return _text.text;

    inline function set_text(v: String): String {
        _text.text = v;
        width = _text.textWidth;
        height = _text.textHeight;
        return v;
    }

    public var color(get, set): Color;

    inline function get_color(): Color
        return Color.fromVector(_text.color);

    inline function set_color(v: Color): Color {
        _text.color = v.toVector4();
        return v;
    }

    public var font(get, set): h2d.Font;

    inline function get_font(): h2d.Font
        return _text.font;

    inline function set_font(v: h2d.Font): h2d.Font
        return _text.font = v;

    public var dropShadow(get, set): Null<{color: Color, dx: Float, dy: Float}>;

    inline function get_dropShadow(): Null<{color: Color, dx: Float, dy: Float}> {
        return if(_text.dropShadow == null) {
            null;
        } else {
            var c = Color.fromInt(_text.dropShadow.color);
            c.a = _text.dropShadow.alpha;
            {
                color: c,
                dx: _text.dropShadow.dx,
                dy: _text.dropShadow.dy,
            };
        }
    }

    inline function set_dropShadow(?v: {color: Color, dx: Float, dy: Float}): Null<{color: Color, dx: Float, dy: Float}>
        @:nullSafety(Off)
        return if(v == null) {
            _text.dropShadow = null;
        } else {
            _text.dropShadow = {
                dx: v.dx,
                dy: v.dy,
                alpha: v.color.a,
                color: v.color.withoutAlpha(),
            }
        }

    public var letterSpacing(get, set): Float;

    inline function get_letterSpacing(): Float
        return _text.letterSpacing;

    inline function set_letterSpacing(v: Float): Float
        return _text.letterSpacing = v;

    public var lineSpacing(get, set): Float;

    inline function get_lineSpacing(): Float
        return _text.lineSpacing;

    inline function set_lineSpacing(v: Float): Float
        return _text.lineSpacing = v;

    public var lineBreak(get, set): Bool;

    inline function get_lineBreak(): Bool
        return _text.lineBreak;

    inline function set_lineBreak(v: Bool): Bool
        return _text.lineBreak = v;

    public var maxWidth(get, set): Null<Float>;

    inline function get_maxWidth(): Null<Float>
        return _text.maxWidth;

    inline function set_maxWidth(?v: Float): Null<Float>
        return _text.maxWidth = v;

    public var align(get, set): Align;

    inline function get_align(): Align
        return _text.textAlign;

    inline function set_align(v: Align): Align
        return _text.textAlign = v;

    public function new(text: String, ?font: h2d.Font, ?parent: h2d.Object) {
        super();
        final font = font ?? madolib.heaps.node.Text.defaultFont;
        _text = new h2d.Text(font, parent);
        this.text = text;
        addChild(_text);
    }

    public inline function calcTextWidth(text: String): Float
        return _text.calcTextWidth(text);

    public inline function splitText(text: String)
        return _text.splitText(text);

    public inline function getTextProgress(text: String, progress: Float): String
        return _text.getTextProgress(text, progress);

    public static inline function create(text: String, ?font: h2d.Font, ?parent: h2d.Object): Text
        return new Text(text, font, parent);
}
