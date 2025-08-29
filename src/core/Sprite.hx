package core;

import kha.Image;
import kha.graphics2.Graphics;

// a selection of an image. not rotatable or scalable (presently)
class Sprite extends GameObject {

    public var tileIndex:Int = 0;
    var flipX:Bool = false;
    var flipY:Bool = false;

    public var image:Image;

    public function new (x:Float = 0.0, y:Float = 0.0, image:Image, ?sizeX:Int, ?sizeY:Int) {
        this.x = x;
        this.y = y;
        this.sizeX = sizeX ?? image.height;
        this.sizeY = sizeY ?? image.width;
        this.image = image;
    }

    override function update (delta:Float) {}

    override function render (g2:Graphics, camera:Camera) {
        // TODO: null check image? we need one, correct?
        // load placeholder? use asset filter in the beginning?

        // g2.color = Math.floor(alpha * 256) * 0x1000000 + color;

        // rotate, translate, then scale
        // g2.pushRotation(toRadians(angle), getMidpoint().x, getMidpoint().y);
        // g2.pushTranslation(-camera.scroll.x * scrollFactor.x, -camera.scroll.y * scrollFactor.y);
        // g2.pushScale(camera.scale.x, camera.scale.y);

        // draw a cutout of the spritesheet based on the tileindex
        final cols = Std.int(image.width / sizeX);
        // TODO: clamp all to int besides camera position
        // g2.drawScaledSubImage(
        //     image,
        //     (tileIndex % cols) * size.x,
        //     Math.floor(tileIndex / cols) * size.y,
        //     size.x,
        //     size.y,
        //     x + ((size.x - size.x * scale.x) / 2) + (flipX ? size.x * scale.x : 0),
        //     y + ((size.y - size.y * scale.y) / 2) + (flipY ? size.y * scale.y : 0),
        //     size.x * scale.x * (flipX ? -1 : 1),
        //     size.y * scale.y * (flipY ? -1 : 1)
        // );
        g2.drawSubImage(
            image,
            x + (flipX ? sizeX : 0),
            y + (flipY ? sizeY : 0),
            (tileIndex % cols) * sizeX,
            Math.floor(tileIndex / cols) * sizeY,
            sizeX,
            sizeY
        );

        // g2.popTransformation();
        // g2.popTransformation();
        // g2.popTransformation();
    }
}
