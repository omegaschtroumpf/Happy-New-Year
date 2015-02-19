#define getCharacterInput
/// getCharacterInput(objectID)

switch (argument0.object_index) {
    case obj_player:
        getPlayerInput(argument0);
    break;
    case obj_enemy:
        getEnemyInput(argument0);
    break;
    case obj_enemyDUMB:
        getEnemyDUMBInput(argument0);
    break;
}

#define getPlayerInput
/// getPlayerInput(object_id)
with(argument0) {
    // player input
    // left stick input
    x_axisL = gamepad_axis_value(deviceID, gp_axislh); // -1 .. 1
    y_axisL = gamepad_axis_value(deviceID, gp_axislv);
    x_axisR = gamepad_axis_value(deviceID, gp_axisrh);
    y_axisR = gamepad_axis_value(deviceID, gp_axisrv);
    
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
    shoulder_r_pressed = gamepad_button_check_pressed(deviceID, gp_shoulderr);
    
    if (keyboard_check(vk_space)) || (keyboard_check(ord('X'))) {
        shoulder_r_pressed = 1;
    }
    else shoulder_r_pressed = 0;
    
    // blcok button - Left button
    shoulder_l_pressed = gamepad_button_check_pressed(deviceID, gp_shoulderl);
    shoulder_l_released = gamepad_button_check_released(deviceID, gp_shoulderl);
    
    if (keyboard_check_pressed(ord('C')) || keyboard_check_pressed(vk_alt)) {
        shoulder_l_pressed = 1;
    }
    else shoulder_l_pressed = 0;
    if (keyboard_check_released(ord('C')) || keyboard_check_pressed(vk_alt)) {
        shoulder_l_released = 1;
    }
    else shoulder_l_released = 0;
    
    // dash button - XBOX A Button
    dash_button_pressed = gamepad_button_check_pressed(deviceID, gp_face1);
    
    if (keyboard_check(ord('V'))) {
        dash_button_pressed = 1;
    }
    else dash_button_pressed = 0;
    
    // target cancel button
    target_cancel_button_pressed = gamepad_button_check_pressed(deviceID, gp_stickr) || gamepad_button_check_pressed(deviceID, gp_stickl);
    
    if (keyboard_check(ord('G'))) {
        target_cancel_button_pressed = 1;
    }
    else target_cancel_button_pressed = 0;
    
    // target keyboard button
    if (keyboard_check(ord('T'))) {
        target_button_pressed = 1;
    }
    else target_button_pressed = 0;
}

#define getEnemyInput
/// getEnemyInput(object_id)

#define getEnemyDUMBInput
/// getEnemyDUMBInput(objectID)

