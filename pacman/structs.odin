package main

import rl "vendor:raylib"

pacman :: struct {
    position: rl.Vector2,
    image: rl.Texture2D,
    hitbox: rl.Rectangle,
    maxFrames: int,
    currentFrame: int,
    frameTime: f32,
    frameWidth: f32,
    direction: direction,
}