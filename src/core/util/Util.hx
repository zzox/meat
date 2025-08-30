package core.util;

function clamp (value:Float, min:Float, max:Float) {
    return Math.max(Math.min(value, max), min);
}
