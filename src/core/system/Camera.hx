package core.system;

import core.gameobjects.GameObject;

class Camera extends System {
    public var bgColor:Int = 0xff000000;

    public var scrollX:Float;
    public var scrollY:Float;
    public var width:Int;
    public var height:Int;

    public var followX:Null<GameObject>;
    public var followY:Null<GameObject>;

    public var boundsOn:Bool = false;
    public var boundsMinX:Null<Int>;
    public var boundsMinY:Null<Int>;
    public var boundsMaxX:Null<Int>;
    public var boundsMaxY:Null<Int>;

    public var offsetX:Int;
    public var offsetY:Int;

    public function new (width:Int, height:Int) {
        super();
        this.width = width;
        this.height = height;
    }

    override function update (delta:Float) {
        if (followX != null) {
            scrollX = Math.floor(followX.getMiddleX() - width / 2);
        }

        if (followY != null) {
            scrollY = Math.floor(followY.getMiddleY() - height / 2);
        }
    }

    public function startFollow (sprite:GameObject, offsetX:Int = 0, offsetY:Int = 0) {
        followX = sprite;
        followY = sprite;

        this.offsetX = offsetX;
        this.offsetY = offsetY;

        // TODO: lerp
    }

    public function stopFollow () {
        followX = null;
        followY = null;
    }

    public function setBounds (minX:Int, minY:Int, maxX:Int, maxY:Int) {
        boundsOn = true;

        boundsMinX = minX;
        boundsMinY = minY;
        boundsMaxX = maxX;
        boundsMaxY = maxY;
    }
}
