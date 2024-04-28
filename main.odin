package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:mem"

BARREL_SPAWN_RAND :: .005

reset_game :: proc(env: ^Env, player: ^Player) {
    player.pos = {100, 850}
    clear(&env.barrels)
}

main :: proc() {
    // memory leaks tracking
    when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)
        defer {
            if len(track.allocation_map) == 0 {
                fmt.println("no leaks :)")
            }
            if len(track.allocation_map) > 0 {
                fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
                for _, entry in track.allocation_map {
                    fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
                }
            }
            if len(track.bad_free_array) > 0 {
                fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
                for entry in track.bad_free_array {
                    fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
                }
            }
            mem.tracking_allocator_destroy(&track)
        }
    }

    player := init_player()

    env := init_env()
    defer delete(env.barrels)
    defer delete(env.platforms)
    defer delete(env.ladders)

    barrel := init_barrel()
    append(&env.barrels, barrel)
    spawn_barrel_buffer := 180
    spawn_barrel_timer := 0

    init_map(&env, &player)
    is_end_game := false
    is_win_game := false

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, env.name)
    rl.SetTargetFPS(env.fps)

    // main loop
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        if is_end_game {
            rl.DrawText("You lost press space to reset", 190, 200, 64, rl.PINK)
            if rl.IsKeyPressed(.SPACE) {
                reset_game(&env, &player)
                is_end_game = false
            } 
        } else if is_win_game {
            rl.DrawText("You won! Press space to reset", 190, 200, 64, rl.BLUE)
            if rl.IsKeyPressed(.SPACE) {
                reset_game(&env, &player)
                is_win_game = false
            } 
        } else {
            
            player_move(&player, env)
            player_rect := rl.Rectangle {player.pos.x, player.pos.y, player.size.x, player.size.y}

            for platform in env.platforms {
                rl.DrawRectangleV(platform.pos, platform.size, platform.color)
            }
            for ladder in env.ladders {
                rl.DrawRectangleV(ladder.pos, ladder.size, ladder.color)
            }
            for &barrel, i in env.barrels {
                barrel_move(&barrel, env)
                if rl.CheckCollisionCircleRec(barrel.pos, barrel.radius, player_rect){
                    is_end_game = true
                }
                rl.DrawCircleV(barrel.pos, barrel.radius, barrel.color)
            }

            if rl.CheckCollisionRecs(player_rect, env.flag.rect) {
                is_win_game = true
            }
            if spawn_barrel_timer == 0 || rand.float32() < BARREL_SPAWN_RAND {
                append(&env.barrels, init_barrel())
                spawn_barrel_timer = spawn_barrel_buffer
            }
            rl.DrawRectangleV(player.pos, player.size, player.color)
            rl.DrawRectangleRec(env.flag.rect, env.flag.color)
            
            rl.ClearBackground(rl.GRAY)
            spawn_barrel_timer -= 1
        }
    }
    rl.CloseWindow()
}

