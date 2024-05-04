package main

import rl "vendor:raylib"

Animation :: struct {
    texture:        rl.Texture2D,
    num_frames:     int,
    frame_timer:    f32,
    current_frame:  int,
    frame_length:   f32,
    name: Animation_Name,
}

Animation_Name :: enum {
    IDLE,
    RUN,
}

init_player_idle_anim :: proc() -> Animation {

    texture := rl.LoadTexture("player_idle.png")
    return Animation {
        texture = texture,
        num_frames = 4,
        frame_timer = 0,
        current_frame = 0,
        frame_length = 0.1,
        name = .IDLE
    }
}

init_player_run_animation :: proc() -> Animation {
    texture := rl.LoadTexture("player_run.png")
    return Animation {
        texture = texture,
        num_frames = 4,
        frame_timer = 0,
        current_frame = 0,
        frame_length = 0.1,
        name = .RUN
    }
}

change_animation :: proc(player: ^Player, anim_state: Animation_Name) {
    switch anim_state {
        case .RUN: {
            player.animation = init_player_run_animation()
        }
        case .IDLE: {
            player.animation = init_player_idle_anim()
        }
    }
}

animate :: proc(animation: ^Animation) {
    animation.frame_timer += rl.GetFrameTime()

    if animation.frame_timer > animation.frame_length {
        animation.current_frame += 1
        animation.frame_timer = 0
        
        if animation.current_frame == animation.num_frames {
            animation.current_frame = 0
        }
    }
}

get_source_rect :: proc(animation: Animation) -> rl.Rectangle {
    texture_width := f32(animation.texture.width / i32(animation.num_frames))
    texture_height := f32(animation.texture.height)
    x := texture_width * f32(animation.current_frame)

    source_rect := rl.Rectangle {
        x,
        0,
        texture_width,
        texture_height
    }

    return source_rect

}

draw_player :: proc(player: ^Player) {
    animate(&player.animation)
    source_rect := get_source_rect(player.animation)
    if player.velocity.x < 0 {
        source_rect.width *= -1
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
