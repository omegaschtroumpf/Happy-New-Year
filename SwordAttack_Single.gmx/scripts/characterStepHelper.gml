#define characterStepHelper
/// characterStepHelper() 

// Input, Movement, Attacking, Blocking

// call main input/AI script only if character can use input right now
if (!stunned || sword_lock) {
    characterInput();
}

/*
 *  All script calls after this point go to tabs in characterHelper
 */

// regenerate focus if appropriate
characterFocusRegen();

// adjust quickstep friction and maybe end quickstepping
characterQSFriction();

// soft-target, targetID, or input direction
characterTarget();

// attacking
characterAttack();

// move based on character input    
characterMove();

// move based on swinging a sword
characterSwordMove();

// blocking
characterBlock();

#define characterFocusRegen
/// characterFocusRegen() 

// Regenerate Focus
if (focus_regen) {
    if (character_focus < 0) {
        character_focus = 0;
        focus_regen = false;
        alarm[9] = FOCUS_REGEN_PENALTY;
        //break block if stamina is depleted
        block_lock = false;
        block_held = false;
    }
    else if (character_focus < character_focus_max) {
        if (character_focus < FOCUS_RATE_THRESHOLD) character_focus += FOCUS_REGEN_FAST;
        else character_focus += FOCUS_REGEN;
    }
}

#define characterQSFriction
/// characterQSFriction() 

// if quickstepping increase friction
if (speed > 0) {
    friction *= QUICKSTEP_FRICTION_MULTIPLIER;
    if (speed < QUICKSTEP_ATTACK_THRESHOLD && !quick_step_attack) {
        can_attack = true;
    }
}
else {
    if (quick_stepping && !swordID) {
        quick_stepping = false;
        quickstep_collided = false;
        can_move = true;
        can_block = true;
    }
}


#define characterTarget
/// characterTarget 

// Soft-Targeting, TargetID Targeting, and no target image direction

if (!stunned && can_target && !swordID) {
    // if right stick input without cancelling target, point that way as a starting point for soft targeting
    if ((x_axisR != 0 || y_axisR != 0) && !target_cancel_button_pressed) {
        soft_target = true;
        targetID = 0;
        image_angle = point_direction(0, 0, x_axisR, y_axisR);
    }
    if (target_button_pressed) {
        soft_target = true;
        targetID = 0;
    }
    if (target_cancel_button_pressed) {
        soft_target = false;
        targetID = 0;
    }
    if (soft_target) {
        // clear out angles list in case there's anything there.  we'll populate it here and potentially refer to it when attacking
        ds_list_clear(softTargetAngles);
        // look for enemies and calculate a new image_angle
        // go through the enemies' positions and see if they are in my line of sight
        num = ds_list_size(enemiesID);
        vector_x = 0;
        vector_y = 0;
        see_enemies = false;
        for (i = 0; i < num; i++) {
            enemy = ds_list_find_value(enemiesID, i);
            enemy_distance = point_distance(x, y, enemy.x, enemy.y);
            // only do more calculation with this enemy if he is in range
            if (enemy_distance <= TARGET_MAX_DISTANCE) {
                enemy_direction = point_direction(x, y, enemy.x, enemy.y);
                ds_list_add(softTargetAngles, enemy_direction);
                angle_diff = angle_difference(image_angle, enemy_direction);
                if ((angle_diff < TARGET_ANGLE / 2) && angle_diff > (-TARGET_ANGLE / 2)) {
                    // in my line of sight, add to my vector calculations
                    see_enemies = true;
                    // distance to enemy will weight the vectoring, the farther away, the lower the influence an enemy has on targeting
                    // enemy.x - x because I want to point from me at relative 0,0 towards enemy
                    vector_x += (enemy.x - x) / sqr(sqr(enemy_distance));
                    vector_y += (enemy.y - y) / sqr(sqr(enemy_distance));
                }
            }
        }
        // if I saw enemies, adjust my angle to face them.  If not, I'll keep my angle from right stick
        if (see_enemies) {
            // now I have a vector for the weighted direction towards enemies.
            image_angle = point_direction(0, 0, vector_x, vector_y);
        }
        else {
            soft_target = false;
        }
    }
    // If I have a specific enemy target, just look at him
    else if (targetID) {            
        image_angle = point_direction(x, y, targetID.x,targetID.y);
    }
    // I aint got no target
    else {
        // what the hell direction am I moving in then?
        if (x_axisL != 0 || y_axisL != 0) image_angle = point_direction(0, 0, x_axisL, y_axisL);
    }
}

#define characterAttack
/// characterAttack() 

// player attacking
if (!stunned && shoulder_r_pressed) {
    if (swordID = 0 && !block_held && !block_lock) {
        if (can_attack && character_focus > 0) {
            if (quick_stepping) quick_step_attack = true;
            can_attack = false;
            can_block = false;
            can_move = false;
            can_target = false;
            //var attack_speed = character_focus / 100 + .2;//minor tweaks for feel
            //if (attack_speed < .7) attack_speed = .7;
            character_focus -= (FIRST_ATTACK_FOCUS_COST + (attack_combo * SUCCESSIVE_ATTACK_FOCUS_MODIFIER))
            swordID = instance_create(x, y, obj_charactersword); // create a sword and keep its ID to ignore collisions
            swordID.attack_speed = 1; //attack_speed;
            //swordID.image_speed *= attack_speed;
            // set sword parentID so it can destroy itself and clear its parent's swordID;
            swordID.parentID = id;
            attack_combo++;
            
            swordID.image_xscale = image_xscale;
            if (attack_combo % 2 == 1) {
                swordID.image_yscale = image_yscale;
            }
            else {
                swordID.image_yscale = -image_yscale;
            }
            // if we are soft-targeting and have directional input, direct the attack
            // toward the soft-targeted enemy whose angle is closest to input angle
            if (soft_target && (x_axisL != 0 || y_axisL != 0)){
                stick_angle = point_direction(0, 0, x_axisL, y_axisL);
                num = ds_list_size(softTargetAngles);
                smallest_angle_diff = 181; // angle_difference() returns a value -180..180
                new_angle = image_angle; // Attack towards soft-target focus unless input points towards a soft-targeted enemy 
                for (i = 0; i < num; i++) {
                    target_angle = ds_list_find_value(softTargetAngles, i);
                    angle_diff = abs(angle_difference(stick_angle, target_angle));
                    if (angle_diff < smallest_angle_diff && angle_diff < TARGET_ANGLE) {
                        smallest_angle_diff = angle_diff;
                        new_angle = target_angle;
                    }
                }
                image_angle = new_angle;
            }    
            swordID.image_angle = image_angle;
        }
        else {
            if (!attack_penalty) {
                attack_penalty = true;
                alarm[0] += ATTACK_PENALTY_CAN_ATTACK_DELAY; // extend time to reset can_attack.
                alarm[2] += ATTACK_PENALTY_CAN_MOVE_DELAY; // still can't move
                // alarm[3] will not be reset.  Bad timing misses chance to combo
            }
        }
    }
}

#define characterMove
/// characterMove 

// Quickstepping and regular movement

// adjust character position based on input
if (!stunned && can_move) {
    if (can_quickstep && dash_button_pressed && character_focus > 0) {
        // do we have quickstep input?
        if (abs(x_axisL) > .25 || abs(y_axisL) > .25) {
            if (character_focus >= QUICKSTEP_FOCUS_COST + 1) {
                stick_dir = point_direction(0, 0, x_axisL, y_axisL);
                // what is the difference from character direction to input direction
                calc_dir = angle_difference(stick_dir, image_angle);
                // if close enough to it, adjust calc_dir to directly forward or directly backward
                abs_calc_dir = abs(calc_dir)
                if (abs_calc_dir < 30) calc_dir = 0;
                if (abs_calc_dir > 150) calc_dir = 180;
                
                // calculate magnitude for direction
                calc_mag = 0;
                if (calc_dir == 0) calc_mag = QUICKSTEP_FORWARD_MULTIPLIER;
                else if (calc_dir == 180) calc_mag = QUICKSTEP_BACK_MULTIPLIER;
                else {
                    // x component
                    if (abs_calc_dir < 90) x_mag = abs(dcos(calc_dir)) * QUICKSTEP_FORWARD_MULTIPLIER;
                    else x_mag = abs(dcos(calc_dir)) * QUICKSTEP_BACK_MULTIPLIER;
                    // y component
                    y_mag = abs(dsin(calc_dir)) * QUICKSTEP_SIDE_MULTIPLIER;
                    // resulting magnitude
                    calc_mag = point_distance(0, 0, x_mag, y_mag);
                }
                
                // set motion with direction and magnitude
                motion_set((image_angle + calc_dir), QUICKSTEP_SPEED_BASE * calc_mag);
                
                // set starting friction and then each step it will increase
                friction = QUICKSTEP_FRICTION_BASE;
                
                // adjust state variables
                quick_stepping = true;
                can_quickstep = false;
                can_move = false;
                can_attack = false;
                can_block = false;
                alarm[7] = QUICKSTEP_COOLDOWN;
                character_focus -= QUICKSTEP_FOCUS_COST;
                audio_play_sound(snd_dash, 1, false);
            }
        }
    } // end if (can_quickstep)
    
    // not quickstepping
    if (block_lock || block_held) {
        var new_x = x + x_axisL * MOVEMENT_SPEED * BLOCK_MOVEMENT_MULTIPLIER;
        var new_y = y + y_axisL * MOVEMENT_SPEED * BLOCK_MOVEMENT_MULTIPLIER;
    }
    else {
        var new_x = x + x_axisL * MOVEMENT_SPEED;
        var new_y = y + y_axisL * MOVEMENT_SPEED;
    }
    
    if (place_empty(new_x, new_y)) {
        x = new_x;
        y = new_y;
    } else if (place_empty(new_x, y)) x = new_x;
    else if (place_empty(x, new_y)) y = new_y;
}

#define characterSwordMove
/// characterSwordMove 

// player and sword moving
if (!stunned && swordID) {
    // advance to target while attacking as long as not quickstepping
    if(!quick_step_attack) {
        var x_adj;
        var y_adj;
        if (swordID.hit_blocked) {
            // both this object and the target would move back at half speed
            x_adj = dcos(image_angle - 180) * MOVEMENT_SPEED * ATTACK_MOVEMENT_MULTIPLIER;
            y_adj = dsin(image_angle - 180) * MOVEMENT_SPEED * ATTACK_MOVEMENT_MULTIPLIER;
            
            // collision detection for target
            
            // movement if no collision
            targetID.x -= x_adj;
            targetID.y += y_adj;
            
            // collision detection for me backing up
            
            // movement if no collision
            x += x_adj;
            y -= y_adj;
        }
        else {
            // free swing or hitting target
            var mult = swordID.speed_multiplier;
            x_adj = dcos(image_angle) * mult * MOVEMENT_SPEED;
            y_adj = dsin(image_angle) * mult * MOVEMENT_SPEED;
            // if collision with opponent
            if (place_meeting(x + x_adj, y - y_adj, targetID)) {
                // if opponent can move back, push at half speed
                x_adj *= ATTACK_PUSH_MULTIPLIER;
                y_adj *= ATTACK_PUSH_MULTIPLIER;
                with (targetID) {
                    // but only if space behind him is open
                    if (place_free(x + x_adj, y - y_adj)) {
                        // push him back!
                        x += x_adj;
                        y -= y_adj;
                    }
                    else {
                        // no one will move
                        x_adj = 0;
                        y_adj = 0;
                    }
                }
            }
            x += x_adj;
            y -= y_adj;
        }
    }
    // always adjust sword position to player position
    swordID.x = x;
    swordID.y = y;
    swordID.image_angle = image_angle;
}

#define characterBlock
/// characterBlock() 

// Blocking states
if(!stunned) {
    if (shoulder_l_pressed) {
        if (can_block) {
            can_attack = false;
            can_block = false;
            can_quickstep = false;
            block_held = true;
            block_lock = true;
            alarm[4] = BLOCK_RAISE_DELAY;
            alarm[5] = BLOCK_LOCK_DELAY;
        }
        else if (block_lock) {
            block_held = true;
        }
    }
    
    if (shoulder_l_released) {
        block_held = false;
        if (!block_lock) {
            can_attack = true;
            blocking = false;
            can_block = true;
            // only enable quickstep if the timer is not set
            if (alarm[7] == -1) can_quickstep = true;
            invincible = false;
            image_index = NORMAL_IMAGE;
        }
    }
}