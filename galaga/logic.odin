package main

import rl "vendor:raylib"
import "core:math/rand"
import "core:time"
drawingLogic :: proc() {
    using rl
    //If any spaceship bullets hit any aliens or the screen edge, disappear, otherwise keep going
    for b, i in &blasts {
        check: if (b.position.y == 0 && b.enabled) {
            //fmt.print("blast touched screen edge\n")
            b.enabled = false
            unordered_remove(&blasts, i)
            break check
        } else {
            for a, ii in &aliens {
                if (CheckCollisionRecs(a.collisionBox, b.collisionBox) && b.enabled) {
                    /*fmt.print("blast touched alien\n")
                    fmt.printf("alien.position: %s\n", a.position)
                    fmt.printf("blast.position: %s\n", b.position)*/
                    b.enabled = false
                    if (a.lives <= 0) {
                        a.enabled = false
                        a.collisionBox = Rectangle{}
                        unordered_remove(&aliens, ii)
                        spaceship.score += 1
                    } else {
                        a.lives -= 1
                    }
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
        DrawTextureV(blastB, b.position, WHITE)
            //fmt.printf("still going")
        }
    }
    //makes aliens move
    for a, i in &aliens {
        if (a.moving) {
            r := rand.create(u64(time.time_to_unix_nano(time.now())))
            if (rand.int63_max(i64(len(aliens)*2), &r) == 1) {
                r := rand.create(u64(time.time_to_unix_nano(time.now())))
                rint := rand.int63_max(5, &r)
                //checks if number = 5/5
                if (rint == 5 /*&& alien.position.x < screenWidth - alien.width*/) {
                    a.position.x = clamp(a.position.x + 15, f32(0), f32(screenWidth - alien.width))
                } else if (rint == 4 /*&& alien.position.x > 0*/) { //checks in number = 4/5
                    a.position.x = clamp(a.position.x - 15, f32(0), f32(screenWidth - alien.width))
                } else if (rint == 3 /*&& alien.position.x < screenWidth - alien.width*/) { //checks in number = 3/5
                    a.position.y = clamp(a.position.y + 15, f32(0), f32(200))
                } else if (rint == 2 /*&& alien.position.x > 0*/) { //checks in number = 2/5
                    a.position.y = clamp(a.position.y - 15, f32(0), f32(200))
                } else {
                    a.moving = false
                }
            }
        }
    }
}

inputLogic :: proc() {
    using rl
    //Spaceship input, moving left & right, shooting
    if (IsKeyDown(KeyboardKey.RIGHT) && !(spaceship.position.x >= screenWidth-f32(spaceship.image.width))) do spaceship.position.x += spaceship.speed
    if (IsKeyDown(KeyboardKey.LEFT) && !(spaceship.position.x <= 0)) do spaceship.position.x -= spaceship.speed
    if (IsKeyPressed(KeyboardKey.SPACE)) {
        //fmt.print("space pressed, started blast\n")
        newBlast := BlastPos{Rectangle{f32(spaceship.position.x+f32((spaceship.image.width/2))), f32(spaceship.position.y), f32(spaceship.image.width), f32(spaceship.image.height)}, Vector2{f32(spaceship.position.x+f32((spaceship.image.width/2))), f32(spaceship.position.y)}, true}
        append(&blasts, newBlast)
    }
}

alienLogic :: proc() {
            using rl
            //Gets a random int for each alien, if == 1 then fire they fire a bullet
            ab: for a, i in &aliens {
                if (a.blastDelay <= 0 && a.enabled) {
                    //fmt.printf("alien thing")
                    r := rand.create(u64(time.time_to_unix_nano(time.now())))
                    if (rand.int63_max(i64(f64(len(aliens))*10), &r) == 1) {
                        //fmt.print("new alien blast\n")
                        newBlast := BlastPos{Rectangle{f32(a.position.x+(f32(alien.width)/1.5)), f32(a.position.y+f32(alien.height/2)), f32(alien.width), f32(alien.height)}, Vector2{f32(a.position.x+(f32(alien.width)/1.5)), f32(a.position.y+f32(alien.height/2))}, true}
                        append(&aBlasts, newBlast)
                        a.blastDelay = 0.9 //shooting delay
                        break ab
                    }
                }
            }
            //makes an alien start moving
            ab2: for a, i in &aliens {
                if (!a.moving) {
                    r := rand.create(u64(time.time_to_unix_nano(time.now())))
                    if (rand.int63_max(i64(f64(len(aliens))*10), &r) == 1) {
                        a.moving = true
                        break ab2
                    }
                }
            }
            //adds new aliens to the screen
            if (len(aliens) <= 3 && len(aliens) > 0 && spaceship.lives > 0) {
                //fmt.print("new alien\n")
                r := rand.create(u64(time.time_to_unix_nano(time.now())))
                rint := rand.int63_max(i64(len(aliens)*50), &r)
                if (rint == 1) {
                    nAlien := Alien{Rectangle{}, Vector2{clamp(baseAlienPos.x + f32(rand.int63_max(i64(screenWidth-alien.width), &r)), f32(0), f32(screenWidth - alien.width)), clamp(f32(rand.int63_max(i64(200-alien.height), &r)), f32(0), f32(200))}, 0.1, true, false, 2}
                    append(&aliens, nAlien)
                }
            }
}