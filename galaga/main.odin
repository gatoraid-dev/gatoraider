package main

import "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:time"
import "core:strconv"
import "core:strings"


main :: proc() {
    using raylib
    screenHeight :: 800
    screenWidth :: 600
    baseAlienPos := Vector2{280, 130}
    aliensDied := 0
    InitWindow(screenWidth, screenHeight, "Gatoraider: Blast of the Gator")
    defer CloseWindow()
    SetTargetFPS(60)
    spaceship := Ship{Rectangle{}, Vector2{260, 700}, LoadTexture("assets/ship.png"), 5, 3, 1.0}
    blast := LoadTexture("assets/blast.png")
    blastB := LoadTexture("assets/blastB.png")
    alien := LoadTexture("assets/alien.png")
    blasts: [dynamic]BlastPos
    aBlasts: [dynamic]BlastPos
    aBlastDelays: [dynamic]f32
    blastDelays: [dynamic]f32
    deltaTime: f32
    //Add position to array to add new alien
    aliens := [dynamic]Alien{
        Alien{Rectangle{}, baseAlienPos, 1.5, true},
        Alien{Rectangle{}, Vector2{baseAlienPos.x - 70, baseAlienPos.y}, 1.5, true},
        Alien{Rectangle{}, Vector2{baseAlienPos.x + 70, baseAlienPos.y}, 1.5, true},
        Alien{Rectangle{}, Vector2{baseAlienPos.x - 140, baseAlienPos.y}, 1.5, true},
        Alien{Rectangle{}, Vector2{baseAlienPos.x + 140, baseAlienPos.y}, 1.5, true},
        Alien{Rectangle{}, Vector2{baseAlienPos.x - 210, baseAlienPos.y}, 1.5, true},
        Alien{Rectangle{}, Vector2{baseAlienPos.x + 210, baseAlienPos.y}, 1.5, true},
        }
    defer {
        UnloadTexture(spaceship.image)
        UnloadTexture(blast)
        UnloadTexture(alien)
        UnloadTexture(blastB)
    }
    for (!WindowShouldClose()) {
        PollInputEvents()   // Update input
        deltaTime = GetFrameTime()
        
        //Update hitboxes for all blasts, aliens, and spaceship//
        spaceship.collisionBox = Rectangle{f32(spaceship.position.x), f32(spaceship.position.y), f32(spaceship.image.width), f32(spaceship.image.height)}
        for a in &aliens {
            if (a.enabled) do a.collisionBox = Rectangle{f32(a.position.x), f32(a.position.y), f32(alien.width), f32(alien.height)}
        }
        for b in &blasts {
            b.collisionBox = Rectangle{f32(b.position.x), f32(b.position.y), f32(blast.width), f32(blast.height)}
        }
        for b in &aBlasts {
            b.collisionBox = Rectangle{f32(b.position.x), f32(b.position.y), f32(blastB.width), f32(blastB.height)}
        }
        //..//
        
        //Subtracts the current delay for each alien's shot by the current deltaTime
        for a in &aliens {
            if a.blastDelay >= 0 {
                a.blastDelay -= deltaTime
                //fmt.print("a.blastDelay: ", a.blastDelay, "\n")
            }
        }
        BeginDrawing()
            ClearBackground(BLACK)
            //Draws the current lives left
            bytes : [32]u8
            DrawText(cstring(strings.concatenate({"Lives: " + strconv.itoa(bytes[:], spaceship.lives)})), 0, screenHeight - MeasureText(cstring("Lives: " + l), 20), 20, WHITE)
            //Checks if all aliens are dead
            if (aliensDied == len(aliens)) {
                DrawText("You Win!", screenWidth / 2 - MeasureText("You Win!", 50) / 2, screenHeight / 2 - 50, 50, GREEN)
            }
            //Checks if player lives are 0 or less, if so then game over
            if (spaceship.lives <= 0) {
                DrawText("You Lose!", screenWidth / 2 - MeasureText("You Lose!", 50) / 2, screenHeight / 2 - 50, 50, RED)
            } else {
                //Updates spaceship position
                DrawTextureV(spaceship.image, spaceship.position, WHITE)
                //Checks if a is dead, if not then update position
                for a in aliens {
                    if (a.enabled) do DrawTextureV(alien, a.position, WHITE)
                }
                /*// For hitbox debugging
                for a in aliens {
                    DrawRectangleLinesEx(a.collisionBox, 3, GREEN)
                }
                //DrawRectangleLinesEx(blast.collisionBox, 3, RED)
                for b in aBlasts {
                    DrawRectangleLinesEx(b.collisionBox, 2, RED)
                }
                DrawRectangleLinesEx(spaceship.collisionBox, 3, BLUE)
                // -End hitbox debugging- //
                */
                //If any spaceship bullets hit any aliens or the screen edge, disappear, otherwise keep going
                for b, i in &blasts {
                    check: if (b.position.y == 0 && b.enabled) {
                        //fmt.print("blast touched screen edge\n")
                        b.enabled = false
                        unordered_remove(&blasts, i)
                        break check
                    } else {
                        for a in &aliens {
                            if (CheckCollisionRecs(a.collisionBox, b.collisionBox) && b.enabled) {
                                /*fmt.print("blast touched alien\n")
                                fmt.printf("alien.position: %s\n", a.position)
                                fmt.printf("blast.position: %s\n", b.position)*/
                                b.enabled = false
                                a.enabled = false
                                a.collisionBox = Rectangle{}
                                aliensDied += 1
                                unordered_remove(&blasts, i)
                                break check
                            }
                        }
                        b.position.y -= 10
                        DrawTextureV(blast, b.position, WHITE)
                        //fmt.printf("still going")
                    }
                }
                //If any alien bullets hit the player or touch the edge, then disappear, otherwise keep going
                for b, i in &aBlasts {
                    check2: if (b.position.y == screenHeight && b.enabled) {
                        //fmt.print("blast touched screen edge\n")
                        b.enabled = false
                        unordered_remove(&aBlasts, i)
                        break check2
                    } else {
                        if (CheckCollisionRecs(spaceship.collisionBox, b.collisionBox) && b.enabled) {
                            /*fmt.print("blast touched alien\n")
                            fmt.printf("spaceship.position: %s\n", spaceship.position)
                            fmt.printf("blast.position: %s\n", b.position)*/
                            b.enabled = false
                            unordered_remove(&aBlasts, i)
                            spaceship.lives -= 1
                            break check2
                        }
                    b.position.y += 10
                    //make seperate texture in assets for this blast, rotating at all changes hitbox offset
                    DrawTextureV(blastB, b.position, WHITE)
                        //fmt.printf("still going")
                    }
                }
            }
        EndDrawing()

        //Spaceship input, moving left & right, shooting
        if (IsKeyDown(KeyboardKey.RIGHT) && !(spaceship.position.x >= screenWidth-50)) do spaceship.position.x += spaceship.speed
        if (IsKeyDown(KeyboardKey.LEFT) && !(spaceship.position.x <= 0)) do spaceship.position.x -= spaceship.speed
        if (IsKeyPressed(KeyboardKey.SPACE)) {
            fmt.print("space pressed, started blast\n")
            newBlast := BlastPos{Rectangle{f32(spaceship.position.x+f32((spaceship.image.width/2))), f32(spaceship.position.y), f32(spaceship.image.width), f32(spaceship.image.height)}, Vector2{f32(spaceship.position.x+f32((spaceship.image.width/2))), f32(spaceship.position.y)}, true}
            append(&blasts, newBlast)
        }

        //Gets a random int for each alien, if == 1 then fire they fire a bullet
        ab: for a, i in &aliens {
            if (a.blastDelay <= 0 && a.enabled) {
                //fmt.printf("alien thing")
                r := rand.create(u64(time.time_to_unix_nano(time.now())))
                if (rand.int63_max(i64(f64(len(aliens))*1.5), &r) == 1) {
                    //fmt.print("new alien blast\n")
                    newBlast := BlastPos{Rectangle{f32(a.position.x+(f32(alien.width)/1.5)), f32(a.position.y+f32(alien.height/2)), f32(alien.width), f32(alien.height)}, Vector2{f32(a.position.x+(f32(alien.width)/1.5)), f32(a.position.y+f32(alien.height/2))}, true}
                    append(&aBlasts, newBlast)
                    a.blastDelay = 1.5
                    break ab
                }
            }
        }
    }
}
