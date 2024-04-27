package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

main :: proc() {

    player := init_player()
    env := init_env()
    append(&env.barrels, init_barrel())
    spawn_barrel_buffer := 180
    spawn_barrel_timer := 0

    is_end_game := false

    rl.InitWindow(env.window_width, env.window_height, env.name)
    rl.SetTargetFPS(env.fps)

    // main loop
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        if is_end_game {
            rl.DrawText("You lost press space to continue", 190, 200, 64, rl.PINK)
            if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
                player.pos = {100, 850}
                delete(env.barrels)
                env.barrels = {}
                is_end_game = false
            } 
        } else {
            
            player_move(&player, env)

            for platform in env.platforms {
                rl.DrawRectangleV(platform.pos, platform.size, platform.color)
            }
            for ladder in env.ladders {
                rl.DrawRectangleV(ladder.pos, ladder.size, ladder.color)
            }
            for &barrel, i in env.barrels {
                rl.DrawCircleV(barrel.pos, barrel.radius, barrel.color)
                barrel_move(&barrel, env)
                if objects_are_colliding({barrel.pos, {barrel.radius, barrel.radius}}, {player.pos, player.size}) {
                    is_end_game = true
                }
            }
            if spawn_barrel_timer == 0 || rand.float32() < .005 {
                append(&env.barrels, init_barrel())
                spawn_barrel_timer = spawn_barrel_buffer
            }
            rl.DrawRectangleV(player.pos, player.size, player.color)
            
            rl.ClearBackground(rl.GRAY)
            spawn_barrel_timer -= 1
        }
    }
    rl.CloseWindow()
}

