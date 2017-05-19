# Trenches

## TODO

* [] implement a game loop
* [] implement a game lobby where you can register and start
* [] nicer graphics wanted
* [] draw the castle of the user
* [] show stats about the players
* [] show stats about the living units (health bar)

### Proposal for the game loop

Proposal for the steps of the game loop

1. All units move at the same time
2. All units fire at the same time (based on range and strength of the weapon, damage is dealt)
3. Dead units after fire are marked as dead
4. Collisions are detected (unit strengths are substracted: for example u1: 1000, u2: 700, u1 wins and has 300 strength left) and dead units are marked as dead
5. players get new money for ... (units killed, damage done,...)
6. Check for winner/loser

There are still some problems with this game loop. If units first move and then fire, units may have passed each other, should they then fire backwards? Should the collision detect this. Thus a better game loop needs to be implemented. It think this can be solved by moving and detect collisions at the same time, thus:

1. Move units at the same time, detect collisions and update after collisions
2. Fire units at the same time and update units after firing
3. players get new money for...
4. check for winner/loser

We could also decide that units first fire and then move?

## Getting started

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.