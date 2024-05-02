package main

import rl "vendor:raylib"
import "core:fmt"

BARREL_SPEED :: 400

GRAVITY_CONSTANT :: 1500
PLAYER_MOVE_SPEED :: 400
PLAYER_JUMP_SPEED :: 400
PLAYER_LADDER_SPEED :: 200


Player :: struct {
    collider:   rl.Rectangle,
    color:      rl.Color,
    velocity:   rl.Vector2,
    can_jump:   bool,
    animation:  Animation
}

init_player :: proc() -> Player {
    collider := rl.Rectangle {
        100,
        850,
        BLOCK_SIZE,
        BLOCK_SIZE
    }


    idle_animation := init_player_idle_anim()
    color: rl.Color = rl.GREEN
    speed: rl.Vector2

    player := Player{
        collider,
        color,
        speed,
        true,
        idle_animation
    }
    return player
}

Env :: struct {
    fps:        i32,
    platforms:  [dynamic]Platform,
    ladders:    [dynamic]Ladder,
    barrels:    [dynamic]Barrel,
    flag:       Flag
}

init_env :: proc() -> Env {
    screenWidth :i32 = 1600;
    screenHeight :i32 = 900;
    env := Env {
        60,
        {},
        {},
        nil,
        {}
    }
    return env
}

Flag :: struct {
    rect:   rl.Rectangle,
    color:  rl.Color,
}

player_move :: proc(player: ^Player, env: Env) {

    if rl.IsKeyDown(.D) {
        player.velocity.x = PLAYER_MOVE_SPEED
        change_animation(player, .RUN)
    }
    else if rl.IsKeyDown(.A) {
        player.velocity.x = -PLAYER_MOVE_SPEED
        change_animation(player, .RUN)
        player.collider.width *= -1
    }
    else {
        player.velocity.x = 0
        change_animation(player, .IDLE)
    }

    if player.velocity.y < GRAVITY_CONSTANT {
        player.velocity.y += GRAVITY_CONSTANT * rl.GetFrameTime()
    }

    if player.can_jump && rl.IsKeyPressed(.W) {
        player.velocity.y = -PLAYER_JUMP_SPEED
        player.can_jump = false
    }

    for ladder in env.ladders {
        ladder_rect := rl.Rectangle {ladder.pos.x, ladder.pos.y, ladder.size.x, ladder.size.y}
        if rl.CheckCollisionRecs(ladder_rect, player.collider) {
            if rl.IsKeyDown(.W) {
                player.velocity.y = -PLAYER_LADDER_SPEED
            }
            player.can_jump = true
        }
    }

    player.collider.x += player.velocity.x * rl.GetFrameTime()
    player.collider.y += player.velocity.y * rl.GetFrameTime()

    for platform in env.platforms {
        platform_rect := rl.Rectangle {platform.pos.x, platform.pos.y, platform.size.x, platform.size.y}
        if rl.CheckCollisionRecs(player.collider, platform_rect) {
            player.collider.y = platform.pos.y - player.collider.height
            player.can_jump = true
        }
    }
    if player.collider.y > f32(rl.GetScreenHeight()) - player.collider.height {
        player.collider.y = f32(rl.GetScreenHeight()) - player.collider.height
        player.can_jump = true
    }
}

Platform :: struct {
    pos:    rl.Vector2,
    size:   rl.Vector2,
    color:  rl.Color
}

Ladder :: struct {
    pos:    rl.Vector2,
    size:   rl.Vector2,
    color:  rl.Color
}

Barrel :: struct {
    pos:        rl.Vector2,
    radius:     f32,
    color:      rl.Color,
    velocity:   rl.Vector2
}


init_barrel :: proc() -> Barrel {
    barrel := Barrel {{100,50}, BLOCK_SIZE / 2, rl.RED, {0, 0}}
    return barrel
}

barrel_move :: proc(barrel: ^Barrel, env: Env) {
    left_rect := rl.Rectangle {0, 0, 150, f32(rl.GetScreenHeight()) - barrel.radius * 3} // 3 because 2 wasn't enough :(
    right_rect := rl.Rectangle {f32(rl.GetScreenWidth()) - 150, 0, 150, f32(rl.GetScreenHeight())}

    if rl.CheckCollisionCircleRec(barrel.pos, barrel.radius, left_rect) {
        barrel.velocity.x = BARREL_SPEED
    } else if rl.CheckCollisionCircleRec(barrel.pos, barrel.radius, right_rect) {
        barrel.velocity.x = -BARREL_SPEED
    } 
    if barrel.velocity.y < GRAVITY_CONSTANT {
        barrel.velocity.y += GRAVITY_CONSTANT * rl.GetFrameTime()
    }
    barrel.pos += barrel.velocity * rl.GetFrameTime()

    for platform in env.platforms {
        platform_rect := rl.Rectangle {platform.pos.x, platform.pos.y, platform.size.x, platform.size.y}
        if rl.CheckCollisionCircleRec(barrel.pos, barrel.radius, platform_rect) {
            barrel.pos.y = platform.pos.y - barrel.radius
        }
    }
    if barrel.pos.y > f32(rl.GetScreenHeight()) - barrel.radius {
        barrel.pos.y = f32(rl.GetScreenHeight()) - barrel.radius
    }
    if barrel.pos.x <= 0 - barrel.radius {
        barrel.pos.y = -barrel.radius    
        barrel.pos.x = 50    
    }
}
