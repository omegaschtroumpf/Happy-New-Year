#define characterAttitudes
/// characterAttitudes()

// does nothing, just title for the script group

#define removeAttitude
/// removeAttitude(character, remove)

character = argument0;
remove = argument1;


// is he there?
// need to loop through this character's attitudes to see if one of them is for remove
attitudeCount = ds_list_size(character.attitudesList);
for (i = 0; i < attitudeCount; i++) {
    attitude = ds_list_find_value(character.attitudesList, i);
    if (attitude && instance_exists(attitude) && attitude.characterID == remove) {
        ds_list_delete(character.attitudesList, i);
    }
}
