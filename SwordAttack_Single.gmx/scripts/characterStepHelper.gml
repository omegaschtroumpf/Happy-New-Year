#define characterStepHelper
/// characterStepHelper() 

// Movement, Attacking, Blocking

/*
 *  All script calls after this point go to tabs in characterHelper
 */

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

#define characterStepBeginHelper
/// characterStepBeginHelper()

/*
 *  All script calls after this point go to tabs in characterHelper
 */

// get Input if appropriate
characterInput();

// regenerate focus if appropriate
characterFocusRegen();

// adjust quickstep friction and maybe end quickstepping
characterQSFriction();

#define characterFocusRegen
/// characterFocusRegen() 

// Regenerate Focus
if (focus_regen) {
    if (character_focus < FOCUS_PENALTY_THRESHOLD) {
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
        if (character_focus > character_focus_max) character_focus = character_focus_max;
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
    effect_create_below(ef_smoke, x, y, 1, make_colour_hsv(0, 16, 96));
}
else {
    if (quick_stepping && !swordID) {
        quick_stepping = false;
        last_collided_with = 0;
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
        // only do more with soft-target if I let go of the stick
        if (x_axisR == 0 || y_axisR == 0) {
            // clear out angles list in case there's anything there.  we'll populate it here and potentially refer to it when attacking
            ds_list_clear(softTargetAngles);
            // look for enemies and calculate a new image_angle
            // go through the enemies' positions and see if they are in my line of sight
            num = ds_list_size(attitudesList);
            vector_x = 0;
            vector_y = 0;
            see_enemies = false;
            for (i = 0; i < num; i++) {
                character_attitude = ds_list_find_value(attitudesList, i);
                character = character_attitude.characterID;
                attitude = character_attitude.attitude;
                // don't consider 
                if (character == id || attitude > ATTITUDE_ENEMY_MAX) continue; // don't evaluate self
                character_distance = point_distance(x, y, character.x, character.y);
                // only do more calculation with this enemy if he is in range
                if (character_distance <= TARGET_MAX_DISTANCE) {
                    character_direction = point_direction(x, y, character.x, character.y);
                    angle_diff = angle_difference(image_angle, character_direction);
                    if ((angle_diff < TARGET_ANGLE / 2) && angle_diff > (-TARGET_ANGLE / 2)) {
                        // in my line of sight, add to my vector calculations and softTargetAngles list
                        see_enemies = true;
                        ds_list_add(softTargetAngles, character_direction);
                        // distance to enemy will weight the vectoring, the farther away, the lower the influence an enemy has on targeting
                        // character.x - x because I want to point from me at relative 0,0 towards enemy
                        vector_x += (character.x - x) / sqr(sqr(character_distance));
                        vector_y += (character.y - y) / sqr(sqr(character_distance));
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
    }
    // If I have a specific target, just look at him
    else if (targetID && instance_exists(targetID)) {            
        image_angle = point_direction(x, y, targetID.x,targetID.y);
    }
    // I aint got no target and no right stick input
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
            // clear out attack related alarms
            alarm[0] = -1;
            alarm[2] = -1;
            alarm[3] = -1;
            
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
        if (abs(x_axisL) > QUICKSTEP_MINIMUM_INPUT || abs(y_axisL) > QUICKSTEP_MINIMUM_INPUT) {
            if (character_focus >= QUICKSTEP_FOCUS_COST + 1) {
                stick_angle = point_direction(0, 0, x_axisL, y_axisL);
                
                // like with attacks, if soft targeting, see if we're pointing at one of the dudes.
                // if we are soft-targeting and have directional input, direct the attack
                // toward the soft-targeted enemy whose angle is closest to input angle
                if (soft_target){
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
                
                // what is the difference from character direction to input direction
                calc_dir = angle_difference(stick_angle, image_angle);
                // if close enough to it, adjust calc_dir to directly forward or directly backward
                abs_calc_dir = abs(calc_dir)
                if (abs_calc_dir < QUICKSTEP_FORWARD_ANGLE_RANGE) calc_dir = 0;
                if (abs_calc_dir > 180 - QUICKSTEP_BACK_ANGLE_RANGE) calc_dir = 180;
                
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
    position_check = characterCheckPosition(new_x, new_y);
    if (position_check == 1) {
        x = new_x;
        y = new_y;
    }
    else if (position_check == 2) x = new_x;
    else if (position_check == 3) y = new_y;
}

#define characterSwordMove
/// characterSwordMove 

// player and sword moving
if (!stunned && swordID) {

    my_push_direction = image_angle;
    push_speed = MOVEMENT_SPEED;
    // did I hit anyone?  push them first
    hit_characters = ds_list_size(swordID.hit_characters);
    if (hit_characters) {
        push_speed *= ATTACK_PUSH_MULTIPLIER;
    
        // if anyone blocked, cut my push in half and I'm pushed backwards
        if (swordID.hit_blocked) {
            push_speed *= .5;
            my_push_direction -= 180;
        }
        
        // in order to push them back, I need to put them in priority of distance from me.
        // push furthest characters first to make way for those closer to me to be pushed back
        priority_characters = ds_priority_create();
        for (i = 0; i < hit_characters; i++) {
            current = ds_list_find_value(swordID.hit_characters, i);
            // in case current died
            if (instance_exists(current)) {
                distance = point_distance(x, y, current.x, current.y);
                ds_priority_add(priority_characters, current, distance);
            }
        }
        
        // now deal with the priority queue and push people if I can
        while (!ds_priority_empty(priority_characters)) {
            current = ds_priority_delete_max(priority_characters);
            push_direction = point_direction(x, y, current.x, current.y);
            new_x = current.x + dcos(push_direction) * push_speed;
            new_y = current.y - dsin(push_direction) * push_speed;
            current.new_x = new_x;
            current.new_y = new_y;
            with (current) {
                position_check = characterCheckPosition(new_x, new_y);
                if (position_check == 1) {
                    x = new_x;
                    y = new_y;
                }
                else if (position_check == 2) x = new_x;
                else if (position_check == 3) y = new_y;
            }
        }
        ds_priority_destroy(priority_characters);
    }
    // now I push or get pushed
    if(!quick_step_attack) {           
        new_x = x + dcos(my_push_direction) * push_speed;
        new_y = y - dsin(my_push_direction) * push_speed;
        position_check = characterCheckPosition(new_x, new_y);
        if (position_check == 1) {
            x = new_x;
            y = new_y;
        }
        else if (position_check == 2) x = new_x;
        else if (position_check == 3) y = new_y;
    }
    // always adjust sword position to player position
    swordID.x = x;
    swordID.y = y;
    swordID.image_angle = image_angle;
}

#define characterCheckPosition
/// characterCheckPosition(x, y);

// check for collisions to see if we can place character at (x, y)
new_x = argument0;
new_y = argument1;
// get the list of obj_character_solids.  If I'd collide with one that isn't me, don't move forward
num = instance_number(obj_character_solids);
collision_xy = false;
collision_x = false;
collision_y = false;
for (i = 0; i < num && !(collision_xy && collision_x && collision_y); i++) {
    check_instance = instance_find(obj_character_solids, i);
    // not checking for a collision with myself.  if match, then go to next i value
    if (check_instance == id) continue;
    if (!collision_xy) {
        if (place_meeting(new_x, new_y, check_instance)) {
            collision_xy = true;
        }
    }
    if (collision_xy && !collision_x) {
        if (place_meeting(new_x, y, check_instance)) {
            collision_x = true;
        }
    }
    if (collision_xy && collision_x && !collision_y) {
        if (place_meeting(x, new_y, check_instance)) {
            collision_y = true;
        }
    }
}
if (!collision_xy) return 1;
if (!collision_x) return 2;
if (!collision_y) return 3;
return 0;

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
#define characterActionHelper
/// characterActionHelper()