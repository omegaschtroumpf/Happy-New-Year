#define characterAttitudes
/// characterAttitudes()

// does nothing, just title for the script group

#define removeAttitude
/// removeAttitude(character, remove)

character = argument0;
remove = argument1;


// is he there?
index = ds_list_find_index(character.attitudeList, remove);
if (index != -1) {
    // what happens stress-wise would be handled elsewhere        
    // remove him
    ds_list_delete(character.attitudeList, index);
}
