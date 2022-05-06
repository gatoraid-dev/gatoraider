package main

import "vendor:raylib"

Alien :: struct {
    collisionBox: raylib.Rectangle,
    position: raylib.Vector2,
    blastDelay: f32,
    enabled: bool,
    moving: bool,
    lives: int,
}
BlastPos :: struct {
    collisionBox: raylib.Rectangle,
    position: raylib.Vector2,
    enabled: bool,
}
Ship :: struct {
    collisionBox: raylib.Rectangle,
    position: raylib.Vector2,
    image: raylib.Texture2D,
    speed: f32,
    lives: int,
    blastDelay:f32,
    score: int,
}
