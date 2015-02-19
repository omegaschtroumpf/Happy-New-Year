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

#define enemyDumbDeath
/// enemyDumbDeath()
