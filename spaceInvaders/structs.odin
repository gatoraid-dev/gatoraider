package main

import "vendor:raylib"

alien :: struct {
    collisionBox: [dynamic]raylib.Rectangle,
    position: raylib.Vector2,
    image: raylib.Texture2D,
}
blastPos :: struct {
    collisionBox: raylib.Rectangle,
    position: raylib.Vector2,
    enabled: bool,
}
ship :: struct {
    collisionBox: raylib.Rectangle,
    position: raylib.Vector2,
    image: raylib.Texture2D,
}
