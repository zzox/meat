package core.components;

import core.gameobjects.GameObject;

class Component {
    public var destroyed:Bool = true;
    public var active:Bool = true;

    var obj:GameObject;

    public function new (obj:GameObject) {}

    public function update (time:Float) {
        throw 'Component::update not implemented';
    }
}

typedef Family = Array<Component>;
