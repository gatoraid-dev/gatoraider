package main

import "vendor:raylib"

alien :: struct {
    collisionBox: [dynamic]raylib.Rectangle,
    position: raylib.Vector2,
    image: raylib.Texture2D,
}
blast :: struct {
    collisionBox: raylib.Rectangle,
    position: raylib.Vector2,
    image: raylib.Texture2D,
}
ship :: struct {
    collisionBox: raylib.Rectangle,
    position: raylib.Vector2,
    image: raylib.Texture2D,
    blasting: bool,
}
