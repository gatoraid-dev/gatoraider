package main

import "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:time"


main :: proc() {
    using raylib
    screenHeight :: 800
    screenWidth :: 600
    InitWindow(screenWidth, screenHeight, "Gatoraider: Blast of the Gator")
    defer CloseWindow()
    SetTargetFPS(60)
    spaceship := ship{Rectangle{}, Vector2{260, 700}, LoadTexture("assets/ship.png")}
    alien := alien{[dynamic]Rectangle{}, Vector2{280, 130}, LoadTexture("assets/alien.png")}
    blast := LoadTexture("assets/blast.png")
    blastB := LoadTexture("assets/blastB.png")
    blasts: [dynamic]blastPos
    aBlasts: [dynamic]blastPos
    //Add position to array to add new alien
    alienPos := [dynamic]Vector2{alien.position, Vector2{alien.position.x - 70, alien.position.y}, Vector2{alien.position.x + 70, alien.position.y}, Vector2{alien.position.x - 140, alien.position.y}, Vector2{alien.position.x + 140, alien.position.y}, Vector2{alien.position.x - 140, alien.position.y}, Vector2{alien.position.x + 210, alien.position.y}, Vector2{alien.position.x - 210, alien.position.y}}
    defer {
        UnloadTexture(spaceship.image)
        UnloadTexture(blast)
        UnloadTexture(alien.image)
        UnloadTexture(blastB)
    }
    for (!WindowShouldClose()) {
        PollInputEvents()   // Update input
        spaceship.collisionBox = Rectangle{f32(spaceship.position.x), f32(spaceship.position.y), f32(spaceship.image.width), f32(spaceship.image.height)}
        for pos in alienPos {
            append(&alien.collisionBox, Rectangle{f32(pos.x), f32(pos.y), f32(alien.image.width), f32(alien.image.height)})
        }
        for b in &blasts {
            b.collisionBox = Rectangle{f32(b.position.x), f32(b.position.y), f32(blast.width), f32(blast.height)}
        }
        for b in &aBlasts {
            b.collisionBox = Rectangle{f32(b.position.x), f32(b.position.y), f32(blastB.width), f32(blastB.height)}
        }
        BeginDrawing()
            ClearBackground(BLACK)
            DrawTextureV(spaceship.image, spaceship.position, WHITE)
            for pos in alienPos {
                DrawTextureV(alien.image, pos, WHITE)
            }
            /*// For hitbox debugging
            DrawRectangleLinesEx(alien.collisionBox[1], 3, GREEN)
            //DrawRectangleLinesEx(blast.collisionBox, 3, RED)
            for b in aBlasts {
                DrawRectangleLinesEx(b.collisionBox, 2, RED)
            }
            DrawRectangleLinesEx(spaceship.collisionBox, 3, BLUE)
            // -End hitbox debugging- //
            */
            for b, i in &blasts {
                check: if (b.position.y == 0 && b.enabled) {
                    fmt.print("blast touched screen edge\n")
                    b.enabled = false
                    unordered_remove(&blasts, i)
                    break check
                } else {
                    for box in alien.collisionBox {
                        if (CheckCollisionRecs(box, b.collisionBox) && b.enabled) {
                            fmt.print("blast touched alien\n")
                            fmt.printf("alien.position: %s\n", alien.position)
                            fmt.printf("blast.position: %s\n", b.position)
                            b.enabled = false
                            unordered_remove(&blasts, i)
                            break check
                        }
                    }
                    b.position.y -= 10
                    DrawTextureV(blast, b.position, WHITE)
                    //fmt.printf("still going")
                }
            }
            for b, i in &aBlasts {
                check2: if (b.position.y == screenHeight && b.enabled) {
                    fmt.print("blast touched screen edge\n")
                    b.enabled = false
                    unordered_remove(&aBlasts, i)
                    break check2
                } else {
                    if (CheckCollisionRecs(spaceship.collisionBox, b.collisionBox) && b.enabled) {
                        fmt.print("blast touched alien\n")
                        fmt.printf("spaceship.position: %s\n", spaceship.position)
                        fmt.printf("blast.position: %s\n", b.position)
                        b.enabled = false
                        unordered_remove(&aBlasts, i)
                        break check2
                    }
                b.position.y += 10
                //make seperate texture in assets for this blast, rotating at all changes hitbox offset
                DrawTextureV(blastB, b.position, WHITE)
                    //fmt.printf("still going")
                }
            }
        EndDrawing()
        if (IsKeyDown(KeyboardKey.RIGHT) && !(spaceship.position.x >= screenWidth-50)) do spaceship.position.x += 5
        if (IsKeyDown(KeyboardKey.LEFT) && !(spaceship.position.x <= 0)) do spaceship.position.x -= 5
        if (IsKeyPressed(KeyboardKey.SPACE)) {
            fmt.print("space pressed, started blast\n")
            newBlast := blastPos{Rectangle{f32(spaceship.position.x), f32(spaceship.position.y), f32(spaceship.image.width), f32(spaceship.image.height)}, Vector2{f32(spaceship.position.x), f32(spaceship.position.y)}, true}
            append(&blasts, newBlast)
        }
        ab: for a, i in &alienPos {
            r := rand.create(u64(time.time_to_unix_nano(time.now())))
            if (rand.int63_max(i64(len(alienPos)), &r) == 1) {
                fmt.print("new alien blast\n")
                newBlast := blastPos{Rectangle{f32(a.x), f32(a.y), f32(alien.image.width), f32(alien.image.height)}, Vector2{f32(a.x), f32(a.y)}, true}
                append(&aBlasts, newBlast)
                break ab
            }
        }
    }
}