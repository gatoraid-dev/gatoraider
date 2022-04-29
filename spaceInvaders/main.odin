package main

import "vendor:raylib"
import "core:fmt"
main :: proc() {
    using raylib
    screenHeight :: 800
    screenWidth :: 600
    blastDelayed := false
    InitWindow(screenWidth, screenHeight, "Gatoraider: Blast of the Gator")
    defer CloseWindow()
    SetTargetFPS(60)
    spaceship := ship{Rectangle{}, Vector2{260, 700}, LoadTexture("assets/ship.png"), false}
    alien := alien{Rectangle{}, Vector2{260, 130}, LoadTexture("assets/alien.png")}
    blast := blast{Rectangle{}, Vector2{spaceship.position.x, spaceship.position.y-60}, LoadTexture("assets/blast.png")}
    defer {
        UnloadTexture(spaceship.image)
        UnloadTexture(alien.image)
        UnloadTexture(blast.image)
    }
    for (!WindowShouldClose()) {
        PollInputEvents()   // Update input
        spaceship.collisionBox = raylib.Rectangle{spaceship.position.x, spaceship.position.y, f32(spaceship.image.width), f32(spaceship.image.height)}
        alien.collisionBox = raylib.Rectangle{f32(alien.position.x), f32(alien.position.y), f32(alien.image.width), f32(alien.image.height)}
        blast.collisionBox = raylib.Rectangle{blast.position.x, blast.position.y, f32(blast.image.width), f32(blast.image.height)}
        BeginDrawing()
            ClearBackground(BLACK)
            DrawTextureEx(spaceship.image, spaceship.position, 0.0, 0.05, WHITE)
            DrawTextureEx(alien.image, alien.position, 0.0, 0.05, WHITE)
            // -Scale hitbox to the images so that collision system works properly- //
            DrawRectangleLines(i32(alien.position.x), i32(alien.position.y), alien.image.width*0.05, alien.image.height*0.05, GREEN)
            DrawRectangleLines(i32(blast.position.x), i32(blast.position.y), blast.image.width*0.05, blast.image.height*0.05, RED)
            if (spaceship.blasting) {
                //fmt.print("blast is proceeding")
                if (!CheckCollisionRecs(alien.collisionBox, blast.collisionBox) || blast.position.y == 0) {
                    fmt.print("blast touched alien\n")
                    fmt.printf("alien.position: %s\n", alien.position)
                    fmt.printf("blast.position: %s\n", blast.position)
                    spaceship.blasting = false
                } else {
                    blast.position.y -= 10
                    BeginDrawing()
                        DrawTextureEx(blast.image, blast.position, 90, 0.15, WHITE)
                    EndDrawing()
                    //fmt.print("blast didnt touch alien")
                }
            }
        EndDrawing()
        if (IsKeyDown(KeyboardKey.RIGHT) && !(spaceship.position.x >= screenWidth-50)) do spaceship.position.x += 5
        if (IsKeyDown(KeyboardKey.LEFT) && !(spaceship.position.x <= 0)) do spaceship.position.x -= 5
        if (IsKeyPressed(KeyboardKey.SPACE)) {
            fmt.print("space pressed, started blast\n")
            if (!spaceship.blasting) {
                spaceship.blasting = true
                blast.position = Vector2{spaceship.position.x+50, spaceship.position.y-60}
            }
        }
    }
}
