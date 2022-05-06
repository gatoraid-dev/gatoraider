package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:time"
import "core:strconv"
import "core:strings"


screenHeight :: 800
screenWidth :: 600
aMaxHeight :: 200
baseAlienPos := rl.Vector2{280, 130}

spaceship: Ship
blast: rl.Texture2D
blastB: rl.Texture2D
alien: rl.Texture2D
blasts: [dynamic]BlastPos
aBlasts: [dynamic]BlastPos
aBlastDelays: [dynamic]f32
blastDelays: [dynamic]f32
deltaTime: f32
//Add position to array to add new alien
aliens := [dynamic]Alien{
    Alien{rl.Rectangle{}, rl.Vector2{clamp(baseAlienPos.x, f32(0), f32(screenWidth - alien.width)), clamp(baseAlienPos.y, f32(0), f32(200))}, 0.1, true, false, 2},
    Alien{rl.Rectangle{}, rl.Vector2{clamp(baseAlienPos.x - 70, f32(0), f32(screenWidth - alien.width)), clamp(baseAlienPos.y, f32(0), f32(200))}, 0.1, true, false, 2},
    Alien{rl.Rectangle{}, rl.Vector2{clamp(baseAlienPos.x + 70, f32(0), f32(screenWidth - alien.width)), clamp(baseAlienPos.y, f32(0), f32(200))}, 0.1, true, false, 2},
    Alien{rl.Rectangle{}, rl.Vector2{clamp(baseAlienPos.x - 140, f32(0), f32(screenWidth - alien.width)), clamp(baseAlienPos.y, f32(0), f32(200))}, 0.1, true, false, 2},
    Alien{rl.Rectangle{}, rl.Vector2{clamp(baseAlienPos.x + 140, f32(0), f32(screenWidth - alien.width)), clamp(baseAlienPos.y, f32(0), f32(200))}, 0.1, true, false, 2},
    Alien{rl.Rectangle{}, rl.Vector2{clamp(baseAlienPos.x - 210, f32(0), f32(screenWidth - alien.width)), clamp(baseAlienPos.y, f32(0), f32(200))}, 0.1, true, false, 2},
    Alien{rl.Rectangle{}, rl.Vector2{clamp(baseAlienPos.x + 210, f32(0), f32(screenWidth - alien.width)), clamp(baseAlienPos.y, f32(0), f32(200))}, 0.1, true, false, 2},
}

main :: proc() {
    using rl
    InitWindow(screenWidth, screenHeight, "Gatoraider: Blast of the Gator")
    blast = LoadTexture("assets/blast.png")
    blastB = LoadTexture("assets/blastB.png")
    alien = LoadTexture("assets/alien.png")
    spaceship = Ship{rl.Rectangle{}, rl.Vector2{260, 700}, rl.LoadTexture("assets/ship.png"), 5, 3, 1.0, 0}
    defer CloseWindow()
    SetTargetFPS(60)

    defer {
        UnloadTexture(spaceship.image)
        UnloadTexture(blast)
        UnloadTexture(alien)
        UnloadTexture(blastB)
    }
    for (!WindowShouldClose()) {
        PollInputEvents()   // Update input
        deltaTime = GetFrameTime()
        
        //Subtracts the current delay for each alien's shot by the current deltaTime
        for a in &aliens {
            if a.blastDelay >= 0 {
                a.blastDelay -= deltaTime
                //fmt.print("a.blastDelay: ", a.blastDelay, "\n")
            }
        }
        updateHitboxes()
        BeginDrawing()
            ClearBackground(BLACK)
            updateTextures()
            //Checks if all aliens are dead
            if (len(aliens) <= 0) {
                DrawText("You Win!", screenWidth / 2 - MeasureText("You Win!", 50) / 2, screenHeight / 2 - 50, 50, GREEN)
            }
            //Checks if player lives are 0 or less, if so then game over
            if (spaceship.lives <= 0) {
                DrawText("You Lose!", screenWidth / 2 - MeasureText("You Lose!", 50) / 2, screenHeight / 2 - 50, 50, RED)
            } else {
                drawingLogic()
            }
        EndDrawing()
        alienLogic() //alien moving, adding and shooting
        inputLogic() //needs to be last or spaceship cant shoot
        fmt.println("Hello joe")
    }
}



updateTextures :: proc() {
    using rl
    //Draws the current lives left and current score
    bytes : [64]u8
    DrawText(strings.clone_to_cstring(strings.concatenate({"Lives: ", strconv.itoa(bytes[:], spaceship.lives)})), 0, screenHeight-30, 20, WHITE)
    DrawText(strings.clone_to_cstring(strings.concatenate({"Score: ", strconv.itoa(bytes[:], spaceship.score)})), 100, screenHeight-30, 20, WHITE)
    //..//
    //Updates spaceship position
    DrawTextureV(spaceship.image, spaceship.position, WHITE)
    //Checks if a is dead, if not then update position
    if (spaceship.lives > 0) {
        for a in aliens {
            if (a.enabled) do DrawTextureV(alien, a.position, WHITE)
        }
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
}

updateHitboxes :: proc() {
            using rl
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
}