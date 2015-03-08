#define characterRelationships
/// characterRelationships()

// does nothing, just title for the script group

#define removeAlly
/// removeAlly(character, lostAlly)

character = argument0;
lostAlly = argument1;


// is he there?
index = ds_list_find_index(character.allyList, argument1);
if (index != -1) {
    // what happens stress-wise?
    
        
    // remove him
    ds_list_delete(character.allyList, index);
}

#define removeProtected
/// removeProtected(character, lostProtected)

character = argument0;
lostProtected = argument1;


// is he there?
index = ds_list_find_index(character.allyList, lostProtected);
if (index != -1) {
    // what happens stress-wise?
    
        
    // remove him
    ds_list_delete(character.allyList, index);
}

#define removeTarget
/// removeTarget(character, lostTarget)

character = argument0;
lostTarget = argument1;


// is he there?
index = ds_list_find_index(character.targetList, lostTarget);
if (index != -1) {
    // what happens stress-wise?
    
        
    // remove him
    ds_list_delete(character.targetList, index);
}

#define removeNeutral
/// removeNeutral(character, lostNeutral)

character = argument0;
lostNeutral = argument1;


// is he there?
index = ds_list_find_index(character.neutralList, lostNeutral);
if (index != -1) {
    // what happens stress-wise?
    
        
    // remove him
    ds_list_delete(character.neutralList, index);
}
