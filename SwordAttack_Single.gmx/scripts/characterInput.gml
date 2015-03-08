#define characterInput
/// getCharacterInput() 

// Input depends on object type
switch (object_index) {
    case obj_player:
        playerInput();
    break;
    case obj_enemy:
        enemyBasicAI();
    break;
    case obj_enemyDumb:
        enemyDumbAI();
    break;
}

#define playerInput
/// playerInput() 

if (gamepad_is_connected(deviceID)) { 
    // Gamepad Input
    
    // left stick input
    x_axisL = gamepad_axis_value(deviceID, gp_axislh); // -1 .. 1
    y_axisL = gamepad_axis_value(deviceID, gp_axislv);
    x_axisR = gamepad_axis_value(deviceID, gp_axisrh);
    y_axisR = gamepad_axis_value(deviceID, gp_axisrv);

    // slash button - Right button
    shoulder_r_pressed = gamepad_button_check_pressed(deviceID, gp_shoulderr);

    // blcok button - Left button
    shoulder_l_pressed = gamepad_button_check_pressed(deviceID, gp_shoulderl);
    shoulder_l_released = gamepad_button_check_released(deviceID, gp_shoulderl);
    
    // dash button - XBOX A Button
    dash_button_pressed = gamepad_button_check_pressed(deviceID, gp_face1);
    
    // target cancel button
    target_cancel_button_pressed = gamepad_button_check_pressed(deviceID, gp_face3) || gamepad_button_check_pressed(deviceID, gp_stickl);
    
    // cursor button
    cursor_button_pressed = gamepad_button_check(deviceID, gp_face4);
    cursor_button_released = gamepad_button_check_released(deviceID, gp_face4);
    
    // gesture buttons
    aggressive_button_pressed = gamepad_button_check_released(deviceID, gp_shoulderrb);
    placating_button_pressed = gamepad_button_check_released(deviceID, gp_shoulderlb);

}
else {
    x_axisL = 0;
    y_axisL = 0;
    // Keyboard Input
    if (keyboard_check(vk_right)) {
        x_axisL = 1;
    }
    if (keyboard_check(vk_left)) {
        x_axisL = -1;
    }
    if (keyboard_check(vk_up)) {
        y_axisL = -1;
    }
    if (keyboard_check(vk_down)) {
        y_axisL = 1;
    }
    
    // slash button - Right button
    shoulder_r_pressed = keyboard_check_pressed(vk_space);

    // block button - Left button
    shoulder_l_pressed = keyboard_check_pressed(ord('C'));
    shoulder_l_released = keyboard_check_released(ord('C'));

    // dash button - XBOX A Button
    dash_button_pressed = keyboard_check_pressed(ord('V'));
    
    // target cancel button
    target_cancel_button_pressed = keyboard_check_pressed(ord('G'));
    
    // target keyboard button
    target_button_pressed = keyboard_check_pressed(ord('T'));
    
    // cursor keyboard button
    cursor_button_pressed = keyboard_check(ord('Y'));
    
    cursor_button_released = keyboard_check_released(ord('Y'));
    
    // gesture buttons
    aggressive_button_pressed = keyboard_check_released(ord('Z'));
    placating_button_pressed = keyboard_check_released(ord('X'));

           
}

#define enemyBasicAI
/// enemyBasicAI() 

// basic AI to create input
shoulder_r_pressed = false;
if (character_focus < random_range(10,60) && alarm[11] < 0) { // focus feels low to me
    // time to start moving away
    alarm[11] = random_range(15,20);  // count down that thing
    random_move = random(180);
}
if (alarm[11] > 0) {
    // i gotta keep moving
    x_axisL = dcos(image_angle - 90 - random_move);
    y_axisL = dsin(image_angle - 90 - random_move) * -1;
    
}
else {
    if (point_distance(x,y,targetID.x,targetID.y) < 240 && (random(100) < 6)) shoulder_r_pressed = true;
    else shoulder_r_pressed = false;

    x_axisL = dcos(image_angle);
    y_axisL = dsin(image_angle) * -1;
}


#define enemyDumbAI
/// getEnemyDumbAI() 

// do nothing