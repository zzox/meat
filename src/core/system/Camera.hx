package core.system;

import core.Const;
import core.gameobjects.GameObject;
import core.util.Util;

class Camera extends System {
    public var bgColor:Int = 0xff000000;

    public var scrollX:Float;
    public var scrollY:Float;
    public var width:Int;
    public var height:Int;

    public var followX:Null<GameObject>;
    public var followY:Null<GameObject>;

    public var boundsMinX:Int = -Const.RBN;
    public var boundsMinY:Int = -Const.RBN;
    public var boundsMaxX:Int = Const.RBN;
    public var boundsMaxY:Int = Const.RBN;

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

        final prescrollx = scrollX;
        scrollX = clamp(scrollX, boundsMinX, boundsMaxX - width);
        scrollY = clamp(scrollY, boundsMinY, boundsMaxY - height);
        trace(prescrollx, scrollX);
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
        boundsMinX = minX;
        boundsMinY = minY;
        boundsMaxX = maxX;
        boundsMaxY = maxY;
    }
}
