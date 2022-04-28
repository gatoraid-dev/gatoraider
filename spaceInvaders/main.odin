package main

import "vendor:raylib"

main :: proc() {
    using raylib
    screenHeight :: 800
    screenWidth :: 600
    blastDelayed := false
    InitWindow(screenWidth, screenHeight, "Gatoraider: Blast of the Gator")
    SetTargetFPS(60)
    spaceship := LoadTexture("assets/ship.png")
    alien := LoadTexture("assets/alien.png")
    blast := LoadTexture("assets/blast.png")
    shipPos: Vector2 = {265, 700}
    alienPos: Vector2 = {265, 130}
    blastPos: Vector2
    alienColRect := Rectangle{alienPos.x, alienPos.y, f32(alien.width), f32(alien.height)}
    for (!WindowShouldClose()) {
        PollInputEvents()   // Update input
        BeginDrawing()
            ClearBackground(BLACK)
            DrawTextureEx(spaceship, shipPos, 0.0, 0.05, WHITE)
            DrawTextureEx(alien, alienPos, 0.0, 0.05, WHITE)
        EndDrawing()
        if (blastDelayed) {
            blastPos.y -= 10
            blastColRect := Rectangle{blastPos.x, blastPos.y, f32(blast.width), f32(blast.height)}
            BeginDrawing()
                DrawTextureEx(blast, blastPos, 90, 0.15, WHITE)
            EndDrawing()
            if (CheckCollisionRecs(alienColRect, blastColRect) /*|| blastPos.y == 0*/) do blastDelayed = false
        }
        if (IsKeyDown(KeyboardKey.RIGHT) && !(shipPos.x >= screenWidth-50)) do shipPos.x += 5
        if (IsKeyDown(KeyboardKey.LEFT) && !(shipPos.x <= 0)) do shipPos.x -= 5
        if (IsKeyDown(KeyboardKey.SPACE) && !blastDelayed) {
            blastDelayed = true
            blastPos: Vector2 = {shipPos.x, shipPos.y-60}
            BeginDrawing()
                DrawTextureEx(blast, blastPos, 90, 0.15, WHITE)
            EndDrawing()
        }
    }
    UnloadTexture(spaceship)
    UnloadTexture(alien)
    CloseWindow()
}
