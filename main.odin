package main

import "vendor:raylib"
import "core:fmt"

main :: proc() {

    player := init_player()
    env := init_env()

    raylib.InitWindow(env.window_width, env.window_height, env.name)
    raylib.SetTargetFPS(env.fps)

    // main loop
    for !raylib.WindowShouldClose() {
        {
            raylib.BeginDrawing()
            defer raylib.EndDrawing()
            
            player_move(&player, env)
            for platform in env.platforms {
                raylib.DrawRectangleV(platform.pos, platform.size, platform.color)
            }
            for ladder in env.ladders {
                raylib.DrawRectangleV(ladder.pos, ladder.size, ladder.color)
            }
            raylib.DrawRectangleV(player.pos, player.size, player.color)
            raylib.DrawText("Window Open", 190, 200, 20, raylib.LIGHTGRAY)
            raylib.ClearBackground(raylib.GRAY)
        }
    }
    raylib.CloseWindow()
}
