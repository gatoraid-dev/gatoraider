package main

import "vendor:raylib"
import "core:fmt"
main :: proc() {
    using raylib
    screenHeight :: 800
    screenWidth :: 600
    InitWindow(screenWidth, screenHeight, "Gatoraider: Blast of the Gator")
    defer CloseWindow()
    SetTargetFPS(60)
    spaceship := ship{Rectangle{}, Vector2{260, 700}, LoadTexture("assets/ship.png"), false}
    alien := alien{[dynamic]Rectangle{}, Vector2{280, 130}, LoadTexture("assets/alien.png")}
    blast := blast{Rectangle{}, Vector2{}, LoadTexture("assets/blast.png")}
    alienPos := [dynamic]Vector2{alien.position, Vector2{alien.position.x - 70, alien.position.y}, Vector2{alien.position.x + 70, alien.position.y}}
    defer {
        UnloadTexture(spaceship.image)
        UnloadTexture(blast.image)
        UnloadTexture(alien.image)
    }
    for (!WindowShouldClose()) {
        PollInputEvents()   // Update input
        spaceship.collisionBox = Rectangle{f32(spaceship.position.x), f32(spaceship.position.y), f32(spaceship.image.width), f32(spaceship.image.height)}
        for pos in alienPos {
            append(&alien.collisionBox, Rectangle{f32(pos.x), f32(pos.y), f32(alien.image.width), f32(alien.image.height)})
        }
        blast.collisionBox = Rectangle{f32(blast.position.x), f32(blast.position.y), f32(blast.image.width), f32(blast.image.height)}
        if (IsKeyDown(KeyboardKey.RIGHT) && !(spaceship.position.x >= screenWidth-50)) do spaceship.position.x += 5
        if (IsKeyDown(KeyboardKey.LEFT) && !(spaceship.position.x <= 0)) do spaceship.position.x -= 5
        BeginDrawing()
            ClearBackground(BLACK)
            DrawTextureV(spaceship.image, spaceship.position, WHITE)
            for pos in alienPos {
                DrawTextureV(alien.image, pos, WHITE)
            }
            /*// -Scale hitbox to the images so that collision system works properly- //
            // For hitbox debugging
            DrawRectangleLinesEx(alien.collisionBox, 3, GREEN)
            DrawRectangleLinesEx(blast.collisionBox, 3, RED)
            DrawRectangleLinesEx(spaceship.collisionBox, 3, BLUE)
            // -End hitbox debugging- //
            */
            if (spaceship.blasting) {
                //if statement is just temporary fix for the delay time
                if (blast.position.y == 0 || CheckCollisionRecs(alien.collisionBox[0], blast.collisionBox) || CheckCollisionRecs(alien.collisionBox[1], blast.collisionBox) || CheckCollisionRecs(alien.collisionBox[2], blast.collisionBox)) {
                    spaceship.blasting = false
                    fmt.print("blast touched alien\n")
                    fmt.printf("alien.position: %s\n", alien.position)
                    fmt.printf("blast.position: %s\n", blast.position)
                } else {
                    blast.position.y -= 10
                    DrawTextureV(blast.image, blast.position, WHITE)
                }
            }
        EndDrawing()
        if (IsKeyPressed(KeyboardKey.SPACE)) {
            fmt.print("space pressed, started blast\n")
            if (!spaceship.blasting) {
                spaceship.blasting = true
                blast.position = Vector2{f32(spaceship.position.x), f32(spaceship.position.y)}
            }
        }
    }
}