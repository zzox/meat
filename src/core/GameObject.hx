package core;

import core.Camera;
import core.Types;
import kha.graphics2.Graphics;

// is this necessary?
class GameObject implements IUpdateable implements IRenderable {
    public var destroyed:Bool = false;

    public var active:Bool = true;
    public var visible:Bool = true;

    public var x:Float;
    public var y:Float;
    public var sizeX:Int;
    public var sizeY:Int;

    public function start () {
        active = true;
        visible = true;
    }

    public function stop () {
        active = false;
        visible = false;
    }

    public function update (delta:Float) {
        throw 'GameObject::update not implemented';
    }

    public function render (g2:Graphics, camera:Camera) {
        throw 'GameObject::render not implemented';
    }
}
