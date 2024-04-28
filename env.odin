package main

import rl "vendor:raylib"
import "core:fmt"

GRAVITY_CONSTANT :: 2000
PLAYER_MOVE_SPEED :: 400
PLAYER_JUMP_SPEED :: 400
PLAYER_LADDER_SPEED :: 200


Player :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color,
    velocity: rl.Vector2,
    can_jump: bool
}

init_player :: proc() -> Player {
    position: rl.Vector2 = {100, 850}
    size: rl.Vector2 = {BLOCK_SIZE, BLOCK_SIZE}
    color: rl.Color = rl.GREEN
    speed: rl.Vector2

    player := Player{
        position, 
        size,
        color,
        speed,
        true
    }
    return player
}

Env :: struct {
    name: cstring,
    fps: i32,
    platforms: [dynamic]Platform,
    ladders: [dynamic]Ladder,
    barrels: [dynamic]Barrel
}

init_env :: proc() -> Env {
    screenWidth :i32 = 1600;
    screenHeight :i32 = 900;
    env := Env {
        "game",
        60,
        {},
        {},
        nil
    }
    return env
}

Gravity :: struct {
    constant: f32,
    time: int,
}

init_gravity :: proc() -> Gravity {
    return Gravity{5, 1}
}

Object :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
}

player_move :: proc(player: ^Player, env: Env) {

    if rl.IsKeyDown(.D) {
        player.velocity.x = PLAYER_MOVE_SPEED
    }
    else if rl.IsKeyDown(.A) {
        player.velocity.x = -PLAYER_MOVE_SPEED
    }
    else {
        player.velocity.x = 0
    }

    if player.velocity.y < GRAVITY_CONSTANT {
        player.velocity.y += GRAVITY_CONSTANT * rl.GetFrameTime()
    }

    if player.can_jump && rl.IsKeyPressed(.W) {
        player.velocity.y = -PLAYER_JUMP_SPEED
        player.can_jump = false
    }

    for ladder in env.ladders {
        player_rect := rl.Rectangle {player.pos.x, player.pos.y, player.size.x, player.size.y}
        ladder_rect := rl.Rectangle {ladder.pos.x, ladder.pos.y, ladder.size.x, ladder.size.y}
        if rl.CheckCollisionRecs(ladder_rect, player_rect) {
            if rl.IsKeyDown(.W) {
                player.velocity.y = -PLAYER_LADDER_SPEED
            }
            player.can_jump = true
        }
    }

    player.pos += player.velocity * rl.GetFrameTime()

    for platform in env.platforms {
        player_rect := rl.Rectangle {player.pos.x, player.pos.y, player.size.x, player.size.y}
        platform_rect := rl.Rectangle {platform.pos.x, platform.pos.y, platform.size.x, platform.size.y}
        if rl.CheckCollisionRecs(player_rect, platform_rect) {
            player.pos.y = platform.pos.y - player.size.y
            player.can_jump = true
        }
    }
    if player.pos.y > f32(rl.GetScreenHeight()) - player.size.y {
        player.pos.y = f32(rl.GetScreenHeight()) - player.size.y
        player.can_jump = true
    }
}

Platform :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color
}


init_platforms :: proc() -> [dynamic]Platform {
        return {
            {{200, 100}, {900, 15}, rl.BROWN},
            {{450, 200}, {900, 15}, rl.BROWN},
            {{200, 300}, {900, 15}, rl.BROWN},
            {{450, 400}, {900, 15}, rl.BROWN},
            {{200, 500}, {900, 15}, rl.BROWN},
            {{450, 600}, {900, 15}, rl.BROWN},
            {{200, 700}, {900, 15}, rl.BROWN},
            {{450, 800}, {900, 15}, rl.BROWN},
        }
}

Ladder :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color
}

init_ladders :: proc() -> [dynamic]Ladder {
    return {
        {{500, 815}, {25, 85}, rl.ORANGE},
        {{1000, 715}, {25, 85}, rl.ORANGE},
        {{600, 615}, {25, 85}, rl.ORANGE},
        {{900, 515}, {25, 85}, rl.ORANGE},
        {{500, 415}, {25, 85}, rl.ORANGE},
        {{1000, 315}, {25, 85}, rl.ORANGE},
        {{500, 215}, {25, 85}, rl.ORANGE},
        {{900, 115}, {25, 85}, rl.ORANGE},
    }
}

BARREL_SPEED :: 200

Barrel :: struct {
    pos: rl.Vector2,
    radius: f32,
    color: rl.Color,
    velocity: rl.Vector2
}


init_barrel :: proc() -> Barrel {
    barrel := Barrel {{200,50}, BLOCK_SIZE / 2, rl.RED, {0, 0}}
    return barrel
}

barrel_move :: proc(barrel: ^Barrel, env: Env) {
    left_rect := rl.Rectangle {0, 0, 350, f32(rl.GetScreenWidth()) - barrel.radius}
    right_rect := rl.Rectangle {f32(rl.GetScreenWidth()) - 350, 0, 350, f32(rl.GetScreenHeight())}

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
