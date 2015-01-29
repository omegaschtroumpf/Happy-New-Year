/// scr_attack(id)

if (swordID = -1) {
    if (can_attack) {
        swordID = instance_create(x, y, obj_player1sword); // create a sword and keep its ID to ignore collisions
        
        /*
        Reference an object with it's object ID
        This next line translates to:
        Store this object's (character's) object ID in the parentID field
        of the object identified by swordID.
        That way, when the sword is done doing its thing, it can destroy itself and clear
        its parentID.swordID to -1;
        */
        swordID.parentID = id;
        attack_combo += 1;
        
        swordID.image_xscale = 3;
        if (attack_combo % 2 == 1) {
            swordID.image_yscale = 3;
        }
        else {
            swordID.image_yscale = -3;
        }
                
        can_attack = false;
        can_move = false;
        alarm[0] = 12; // time to reset can_attack for combo attacks
        alarm[2] = 7; // time to reset can_move
        alarm[3] = 15; // time for combo to expire
    }
    else {
        alarm[0] = 12; // extend time to reset can_attack.
        // alarm[3] will not be reset.  Bad timing misses chance to combo
    }
}
