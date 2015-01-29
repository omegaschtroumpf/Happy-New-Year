///scr_get_gamepad_input(device)

var device = argument0;

// left stick input
x_axis = gamepad_axis_value(device, gp_axislh); // -1 .. 1
y_axis = gamepad_axis_value(device, gp_axislv);

// slash button - Right button
shoulder_r_pressed = gamepad_button_check_pressed(device, gp_shoulderr);

// blcok button - Left button
shoulder_l_pressed = gamepad_button_check_pressed(device, gp_shoulderl);
shoulder_l_released = gamepad_button_check_released(device, gp_shoulderl);
