package core.components;

import core.gameobjects.Sprite;

typedef AnimItem = {
    var name:String;
    var vals:Array<Int>;
    var frameTime:Int;
    var repeats:Bool;
}

class FrameAnim {
    public var sprite:Sprite;

    var _animations:Map<String, AnimItem> = new Map();

    var animTime:Float;
    var currentAnim:AnimItem;

    public function new () {}

    public function add (name:String, vals:Array<Int>, frameTime:Int, repeats:Bool = true) {
        _animations[name] = {
            name: name,
            vals: vals,
            frameTime: frameTime,
            repeats: repeats
        };
    }

    public function update (delta:Float) {
        animTime++;

        final frameAnimTime = Math.floor(animTime / currentAnim.frameTime);

        if (!currentAnim.repeats && frameAnimTime >= currentAnim.vals.length) {
            sprite.tileIndex = currentAnim.vals[currentAnim.vals.length - 1];
            // if (!completed) {
            //     onComplete(currentAnim.name);
            //     completed = true;
            // }
        } else {
            sprite.tileIndex = currentAnim.vals[frameAnimTime % currentAnim.vals.length];
        }
    }
}
