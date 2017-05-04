# Trenches

## TODO

* [] implement a game loop


### Proposal for the game loop

Proposal for the steps of the game loop

1. All units move at the same time
2. All units fire at the same time (based on range and strength of the weapon, damage is dealt)
3. Dead units after fire are marked as dead
4. Collisions are detected (unit strengths are substracted: for example u1: 1000, u2: 700, u1 wins and has 300 strength left) and dead units are marked as dead
5. players get new money for ... (units killed, damage done,...)
6. Check for winner/loser

## Getting started

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
