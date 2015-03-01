#define characterDeath
/// characterDeath()

switch (object_index) {
    case obj_player:
        playerDeath();
    break;
    case obj_enemy:
        enemyDeath();
    break;
    case obj_enemyDumb:
        enemyDumbDeath();
    break;
    default: // no input is set
} 

#define playerDeath
/// playerDeath()

game_restart(); 

#define enemyDeath
/// enemyDeath()
// remove myself from all characters' lists list
characterCount = instance_number(obj_character);
for (i = 0; i < characterCount; i++){
    currentCharacter = instance_find(obj_character, i);
    if (currentCharacter != id) {
        removeAlly(currentCharacter, id);
        removeNeutral(currentCharacter, id);
        removeProtected(currentCharacter, id);
        removeTarget(currentCharacter, id);    
    }
}

#define enemyDumbDeath
/// enemyDumbDeath()
enemyDeath(); 