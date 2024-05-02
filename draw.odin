package main

import rl "vendor:raylib"

Animation :: struct {
    texture:        rl.Texture2D,
    num_frames:     int,
    frame_timer:    f32,
    current_frame:  int,
    frame_length:   f32,
}

Player_Animation_States :: enum {
    IDLE,
    RUN,
}

init_player_idle_anim :: proc() -> Animation {

    texture := rl.LoadTexture("player_idle.png")
    return Animation {
        texture = texture,
        num_frames = 4,
        frame_timer = 0,
        current_frame = 1,
        frame_length = 10
    }
}

init_player_run_animation :: proc() -> Animation {
    texture := rl.LoadTexture("player_run.png")
    return Animation {
        texture = texture,
        num_frames = 4,
        frame_timer = 0,
        current_frame = 1,
        frame_length = 10
    }
}

change_animation :: proc(player: ^Player, anim_state: Player_Animation_States) {
    switch anim_state {
        case .RUN: {
            player.animation = init_player_run_animation()
        }
        case .IDLE: {
            player.animation = init_player_idle_anim()
        }
    }
}

draw_player :: proc(player: ^Player) {
    if player.animation.frame_timer < 1 {
        player.animation.frame_timer += player.animation.frame_length * rl.GetFrameTime()
    } else {
        if player.animation.current_frame == player.animation.num_frames {
            player.animation.current_frame = 1
        } else {
            player.animation.current_frame += 1
        }
        player.animation.frame_timer = 0
    }
    
    texture_width := f32(player.animation.texture.width / i32(player.animation.num_frames))
    texture_height := f32(player.animation.texture.height)
    x := texture_width * f32(player.animation.current_frame)

    source_rect := rl.Rectangle {
        x,
        0,
        texture_width,
        texture_height
    }

    rl.DrawTexturePro(
        player.animation.texture,
        source_rect,
        player.collider,
        0,
        0,
        rl.WHITE
    )
}

draw :: proc(player: ^Player, env: ^Env) {
    draw_player(player) 
}
