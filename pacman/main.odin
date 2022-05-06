package main

import "core:fmt"
import rl "vendor:raylib"


screenWidth :: 1000
screenHeight :: 750
main :: proc() {
    using rl
    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
    defer CloseWindow()
    for (!WindowShouldClose()) {
        BeginDrawing()
            ClearBackground(BLUE)
        EndDrawing()
    }
}