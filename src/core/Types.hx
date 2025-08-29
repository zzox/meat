package core;

import kha.graphics2.Graphics;

interface IDestroyable {
    public var destroyed:Bool;
    public var x:Float;
    public var y:Float;
}

interface IUpdateable extends IDestroyable {
    public var active:Bool;
    public function update (time:Float):Void;
}

interface IRenderable extends IDestroyable {
    public var visible:Bool;
    public function render (g2:Graphics, cam:Camera):Void;
}

class IntVec2 {
    public static inline function make (x:Int, y:Int) {
        // TODO: pooling
        return new IntVec2(x, y);
    }

    public var x:Int;
    public var y:Int;

    public function new (x:Int, y:Int) {
        set(x, y);
    }

    public function set (x:Int, y: Int) {
        this.x = x;
        this.y = y;
    }
}

class Vec2 {
    public static inline function make (x:Float, y:Float) {
        // TODO: pooling
        return new Vec2(x, y);
    }

    public var x:Float;
    public var y:Float;

    public function new (x:Float, y:Float) {
        set(x, y);
    }

    public function set (x:Float, y: Float) {
        this.x = x;
        this.y = y;
    }
}
