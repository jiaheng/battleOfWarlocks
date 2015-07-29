# battleOfWarlocks

## Game Manual

### Objects and Spell
1. **Warlock** - Each player is controlling a single warlock, represented by a circle with a unique color.
A straight line from the center of the circle is representing the facing direction of the warlock.
All warlock has same movement speed and start with 100 heath points.
A warlock can cast two spell which are fireball and teleport.

2. **Lava** - The ring is surrounded by lava, players are advised to stay away from the lava pool.
If a player is step on the lava, they will lose 12 health point per second until they step back into the arena.
The damage is calculated 0.1 seconds per tick, which mean the damage done is updated every 0.1 seconds, so if the player is able to get out from the lava within 0.1 seconds, no damage is done.
As the game progress, the ring will become smaller and smaller and eventually the arena will be fully covered by lava, all the players will lose their health.

3. **Fireball** - spell cast by a warlock, which shoots a fireball towards a target point.
The fireball has a lifespan, which mean it will disappeared after a period of time.
The spell has 5 seconds cooldown, each warlock can cast a fireball every 5 seconds.
When a fireball hits a warlock, the warlock will receive damage and knocked backward, so the spell is often used as an offensive spell to push opponents into lava pool.
It can also used to be a defensive spell, a warlock can destroys an opponent's fireball by casting a fireball towards it.
This can protect himself/herself from being hit by the fireball and knocked into the lava pool.

4. **Teleport** - another spell cast by a warlock to teleport to a target point up to a certain range. This spell is very useful as it can be used to evade opponent's fireball and instantly teleport back into the ring if being knocked out into the lava pool. Though it often used as a defensive spell, it can also be used as an offensive spell for better positioning. A warlock can teleport into a good position and cast fireball toward his/her opponent. But remember that the teleport spell has a very long cooldown, so use it wisely.

### Goals
To win, you must get the highest points at the end of the game. 
In order to achieve the goal, players must fight to survive until the end of each round. Each round, the player who being eliminated first will get the lowest points and the player who survive at the end of the round will get the highest points. 
The most effective way of eliminating opponents is knocking them into the lava pool.
It is possible that the players eliminate the opponents by killing them with spells if the opponents have very low health.

### Controls
* **Fireball** - To cast a fireball, player can left click on the fireball button at the bottom of the window or press the hotkey 'F', then left click on a target point.The warlock will cast a fireball towards the target point.
* **Teleport** - To use teleport spell, player can left click on the teleport spell button at the bottom of the window or press the hotkey 'B', then left click on a target point.The warlock will teleport to the target point if the target point is within the maximum range.If the target point is outside of the maximum range, the warlock will teleport to the point where the point is the maximum range of the teleport spell.
* **Move** - By default, player can move the warlock by right clicking on a target point. Player also can press the hotkey 'M', then left click on a target point to command the warlock to move to the target point. If the player prefer to use left click to issue a move command, the player can change the setting in the main menu by clicking the "Current Setting: right click to move" button.

### How to Host a Game
1. In the main menu, type in a unique player name and click start game
2. In the lobby, wait for other players to join the game. 
Provide your player with your hostname so they can join into your lobby. hostname can be found by typing 'hostname' in the terminal.
3. When all players have joined into the lobby, click start button and enjoy the game.

### How to Join a Game
1. In the main menu, type in a unique player name and click join game.
2. Type in the hostname provided by the host, click on join button or press enter to join the game. Make sure you have a unique player name, if the name have been used, you will be rejected by host.
3. In the lobby, the colour of your name is the colour of the warlock you control in the game. Wait in the lobby until the host start the game.
