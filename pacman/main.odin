package main

import "core:fmt"
import rl "vendor:raylib"


screenWidth :: 1000
screenHeight :: 750
plr: pacman
direction :: distinct enum{
    Up = -90,
    Down = 90,
    Left = 0,
    Right = 180,
}
main :: proc() {
    using rl
    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
    defer CloseWindow()
    SetTargetFPS(60)
    plr = pacman{Vector2{screenWidth/2, screenHeight/2}, LoadTexture("assets/pacman.png"), Rectangle{}, 4, 1, 0, 0, direction.Left}
    plr.frameWidth = cast(f32)plr.image.width/4
    defer UnloadTexture(plr.image)
    for (!WindowShouldClose()) {
        PollInputEvents()
        
        BeginDrawing()
            ClearBackground(RAYWHITE)
            DrawTexturePro(plr.image, Rectangle{plr.frameWidth * cast(f32)plr.currentFrame, 0, plr.frameWidth, cast(f32)plr.image.height}, Rectangle{plr.position.x, plr.position.y, plr.frameWidth, cast(f32)plr.image.height}, Vector2{plr.position.x/2,plr.position.y/2}, plr.direction, WHITE)
        EndDrawing()
    }
}

updatePlr :: proc() {
    using rl
    if plr.frameTime >= 0.1 {
        plr.frameTime = 0
        plr.currentFrame += 1
    } else {
        plr.frameTime += GetFrameTime()
    }
    clamp(plr.currentFrame, plr.currentFrame, plr.maxFrames)
}

getInput :: proc() {
    using rl
    if IsKeyDown(KeyboardKey.LEFT) {
        plr.position.x -= 1
        
    }
}