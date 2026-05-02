# Tank Game

A top-down endless survival tank game built in Ruby using the [Gosu](https://www.libgosu.org/) game framework. Control a customisable tank, survive increasingly difficult waves of enemies, and rack up as high a score as possible.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation & Running](#installation--running)
- [Gameplay](#gameplay)
  - [Objective](#objective)
  - [Controls](#controls)
  - [Tank Configuration](#tank-configuration)
  - [Weapons](#weapons)
  - [Enemies](#enemies)
  - [Drops](#drops)
  - [Scoring](#scoring)
  - [Difficulty](#difficulty)
  - [HUD](#hud)
- [Developer Mode](#developer-mode)
- [Project Structure](#project-structure)
- [Known Bugs](#known-bugs)
- [Appendix — Suggested Improvements for the Unity Remake](#appendix--suggested-improvements-for-the-unity-remake)

---

## Overview

War Tank is a single-player, endless arena shooter. The player spawns in the centre of a 1920×1080 battlefield with a randomly assigned tank configuration and must survive waves of enemies that grow in number and aggression over time. Enemies drop loot on death, allowing the player to upgrade their weapon and chassis on the fly. The game ends when the player's health reaches zero.

The project was built as a school assignment and represents a first full game implementation. All sprites were hand-drawn in [Pixilart](https://www.pixilart.com/) and the audio assets were sourced externally.

---

## Requirements

- **Ruby** (tested on Ruby 2.x/3.x)
- **Gosu** gem

```bash
gem install gosu
```

---

## Installation & Running

1. Clone or download this repository.
2. Install the Gosu gem (see above).
3. From the project root, run:

```bash
ruby game.rb
```

The game opens in a 1920×1080 window. If you encounter an `undefined method 'to_blob'` error, this is a known device-specific issue — see [Known Bugs](#known-bugs).

---

## Gameplay

### Objective

Survive for as long as possible and accumulate the highest score by destroying enemies. There is no win condition — difficulty increases continuously until you die.

### Controls

| Input | Action |
|---|---|
| `W` | Move forward |
| `S` | Move backward |
| `A` | Turn left |
| `D` | Turn right |
| `Mouse` | Aim turret |
| `Left Click` | Fire |
| `H` | Toggle HUD hints |
| `Tab` | Toggle developer mode |
| `Enter` | Restart (on death screen) |
| `Escape` | Quit |

The tank body and turret are independently controlled — you steer with WASD while the turret always tracks your mouse cursor.

The player **wraps around** the screen edges; driving off one side brings you out the other.

### Tank Configuration

At the start of each game, the player's tank is randomly assigned a **chassis (bottom)** and a **turret (top)**. Both can be changed mid-game by picking up drops.

**Chassis types:**

| Chassis | Max HP | Max Speed | Notes |
|---|---|---|---|
| Normal | 100 | 5 | Balanced stats |
| Speed | 75 | Higher than normal | Lower HP; faster turning and acceleration |
| Armor | 800 | 1.5 | Very slow; extremely high health |

Switching chassis via a drop instantly resets current HP to the new chassis's max HP.

**Turret types:** see [Weapons](#weapons) below.

### Weapons

All weapons are aimed with the mouse and fired with left click. Each weapon has a distinct cursor that changes to reflect the equipped type.

| Weapon | Damage | Fire Rate | Notes |
|---|---|---|---|
| Single | 20 | Moderate | Standard cannon; bullets stop on hit |
| Double | 15 per shot | Moderate, fires twice per cycle | Two sequential shots per trigger pull |
| Sniper | 100 | Slow (long cooldown) | High damage, very fast projectile; larger hit radius |
| Shotgun | 10 per pellet | Moderate | Spread; pellets have limited range (600–800 px) |
| Minigun | 5 per bullet | Very fast | Low damage per shot; warm-up before full fire rate |
| Grenade | 300 (AOE) | Slow | Click-to-target arc; detonates at target location with a wide blast radius |

The **Sniper** displays a secondary cursor at the projected impact point. The **Grenade** shows a landing-zone indicator. The **Minigun** draws a red line from current aim to the cursor to indicate spread lag.

### Enemies

Two enemy types currently exist.

**Sentry**

A stationary turret that drops from above into a random position on the map. It plays an opening animation and sound on spawn, then tracks and fires at the player at a fixed interval. The sentry fires a burst of bullets over ~60 frames and then reloads for ~200 frames. On death it plays a destruction animation and has an 80% chance of dropping loot. Awards 10–20 points.

Difficulty cap: 1 sentry (Easy), 2 (Medium), 3 (Hard).

**Rammer**

A fast enemy tank that spawns off-screen from either the left or right edge and charges directly at the player. It follows a three-phase attack cycle: enter → lock on and wind up → charge. During the charge phase it leaves a visible dust trail. On collision with the player it deals 60 damage. On death it has a 60% chance of dropping loot. Awards 25–35 points.

Difficulty cap: 1 rammer (Easy), 2 (Medium), 4 (Hard).

### Drops

Enemies have a chance to drop items on death. Drops despawn after 500 frames if not collected. Walking over a drop (within 50 px) automatically picks it up.

Drop table (roughly 33% health / 50% top / 17% bottom):

| Drop | Effect |
|---|---|
| Health | +20 HP (capped at max) |
| Single / Double / Sniper / Shotgun / Minigun / Grenade | Replaces current turret |
| Normal / Speed / Armor | Replaces chassis and resets HP to new max |

### Scoring

Points are added each time an enemy is destroyed:

- Sentry: 10–20 points (random)
- Rammer: 25–35 points (random, only awarded while player is alive)

The score is displayed at the top centre of the screen and ticks up gradually to smooth out large jumps. The final score is shown on the death screen.

### Difficulty

Difficulty escalates automatically based on a timer that runs for the entire session.

| Timer (frames) | Difficulty | Sentries | Rammers |
|---|---|---|---|
| 0 – 9,000 | Easy | 1 | 1 |
| 9,001 – 18,000 | Medium | 2 | 2 |
| 18,001+ | Hard | 3 | 4 |

A gradient bar on the right side of the screen shows a pointer moving downward from Easy to Hard, giving the player a visual indication of how close the next difficulty escalation is.

### HUD

- **Health bar** — centred at the bottom of the screen. Grey background shows max HP; green fill shows current HP. Both values animate smoothly when they change. A skull icon replaces the HP text on death.
- **Score** — top centre, with a drop-shadow effect.
- **Difficulty bar** — right side; a green-to-red gradient with a moving pointer.
- **Key hints** — top-left (movement) and top-right (dev/hide). Press `H` to toggle.
- **Weapon cursor** — replaces the system cursor with a weapon-specific crosshair.

---

## Developer Mode

Press `Tab` to toggle developer mode. In this mode the system cursor is restored and an overlay is drawn showing all live game state:

- Player position, angle, speed, acceleration
- Current HP, max HP, top/bottom type
- Bullet, grenade, enemy, drop, and trail counts
- Current difficulty

**Dev mode hotkeys:**

| Key | Action |
|---|---|
| `1`–`6` | Switch turret to Single / Double / Sniper / Shotgun / Minigun / Grenade |
| `8` / `9` / `0` | Switch chassis to Normal / Speed / Armor |
| `I` | Spawn a Sentry |
| `O` | Spawn a Rammer |
| `P` | Spawn a random drop |
| `L` | Delete all entities |
| `` ` `` | Toggle invincibility |
| `↑` / `↓` | Manually raise / lower difficulty |

---

## Project Structure

```
Tank_game-main/
├── game.rb                  # Entire game source (~1,774 lines)
├── Layers.xlsx              # Z-order layer planning spreadsheet
├── graph.drawio             # Game design / flow diagram
├── README.md
├── media/
│   ├── Background.png
│   ├── audio/
│   │   ├── song.wav         # Background music
│   │   ├── player/top/      # Per-weapon fire/reload sounds
│   │   ├── player/death/
│   │   └── enemy/sentry/
│   ├── bullet/              # Bullet sprites + grenade animation frames
│   ├── difficulty/          # Difficulty bar labels and pointer
│   ├── display/             # Health bar corners and key hint icons
│   ├── enemy/
│   │   ├── rammer/          # Rammer sprites, death frames, trail
│   │   └── sentry/          # Sentry bottom, top animation frames, death
│   ├── item/                # Drop icons (top weapons + chassis + health)
│   └── player/
│       ├── cursor/          # Per-weapon crosshair sprites
│       ├── death/           # Player destruction animation frames
│       ├── player_bottom/   # Chassis animation frames (normal/speed/armor)
│       └── player_top/      # Turret animation frames (all 6 weapons)
├── pixilart/                # Source .pixil files for all hand-drawn sprites
└── error/                   # Screenshot of a known bug
```

The rendering system uses 13 Z-order layers (`LAY0`–`LAY12`) to correctly stack shadows, terrain, drops, enemies, bullets, the player, UI, and effects.

---

## Known Bugs

- **`undefined method 'to_blob'`** — occurs on some systems due to a Gosu/RMagick version conflict. Does not occur on all machines; cause not fully determined.
- **Incorrect turning at 0°** — the turret and enemy angle-interpolation logic has an edge case at exactly 0° that causes a brief snap in rotation direction.
- **Grenade vs. Sentry** — the grenade area-of-effect check contains a copy-paste error (`grenade.x + 200` is used for both the X and Y upper bounds), which causes the explosion to miss sentries in certain positions.

---

## Appendix — Suggested Improvements for the Unity Remake

The following ideas are worth considering when rebuilding this game in Unity with a roguelike focus.

### Core Roguelike Systems

**Run-based progression with meta-unlocks.** Each run is a single life. After dying, the player earns a persistent currency (e.g. salvage) that can be spent between runs to unlock new starting weapons, chassis, or passive upgrades — similar to how *Hades* handles Darkness. This gives the player a sense of progress even across failed runs.

**Between-wave upgrade choices.** After clearing a wave (or at score milestones), pause gameplay and present the player with 3 randomly drawn upgrade cards. Examples: +15% bullet speed, grenade splits into two on detonation, rammers drop double loot. Choosing one and discarding the rest creates interesting build decisions and replayability.

**Synergies.** Design upgrades that interact — e.g. "Explosive Rounds" does nothing on its own but triples grenade damage if the player also has "Oversized Payload". Discovering synergies becomes part of the game's depth.

### Enemy Improvements

**Boss waves.** Every 3–5 waves, spawn a named boss instead of the standard pool. A boss Sentry could have rotating shield segments that must be shot off before the core can be damaged. A boss Rammer could split into smaller rammers on death.

**New enemy types.** 
- *Sniper drone* — stays at max range and fires high-damage, slow projectiles; must be closed down quickly.
- *Shield carrier* — projects a directional shield that blocks bullets from the front; requires flanking.
- *Mine layer* — slowly drives around dropping proximity mines on the floor.
- *Swarm unit* — individually weak but spawns in groups of 8–12.

**Smarter AI.** Use Unity's NavMesh or a simple steering behaviour (seek, flee, arrive) so enemies navigate around each other rather than overlapping. Sentries could reposition when health drops below 50%.

### Weapon & Item System

**Weapon modifiers.** Instead of simply replacing the current weapon, drops could add modifiers to it: "Piercing" (bullets pass through enemies), "Chain" (on kill, one bullet fires at the nearest enemy), "Incendiary" (bullets leave a burning patch). This creates far more variety from the same base weapons.

**Passive items.** A separate inventory slot for passive items — shield regen, speed boost on kill, reduced cooldown — gives the player more to think about without cluttering the turret system.

**Ammo economy.** Add limited ammo for high-power weapons (sniper, grenade) with ammo drops separate from weapon drops. Forces rationing and tactical decisions.

### Quality of Life

**Proper main menu and pause screen.** The current game starts immediately. A menu with difficulty selection, keybind display, and high score tracking would make it feel complete.

**Persistent high score leaderboard.** Save top 10 scores locally. Display them on the death screen and main menu.

**Visual feedback on hit.** Flash enemies red briefly when damaged. Show floating damage numbers. Both give the player important feedback that their shots are connecting.

**Screen shake.** Add configurable camera shake on large impacts (grenade detonation, rammer collision, player death). Small effect, large perceived impact.

**Wave announcements.** Display a "Wave X" splash screen between spawn cycles so players know how far they've progressed. This also naturally creates a short breather between fights.

### Technical

**Object pooling.** In the Ruby version, every bullet and sprite is instantiated fresh each frame. In Unity, use object pools for bullets, trails, and enemies to avoid garbage collection hitches.

**Modular tank assembly in the inspector.** Make chassis and turret independent prefabs with a `TankConfig` ScriptableObject. This makes adding new combinations trivial without touching code.

**Seed-based randomness.** Store the RNG seed for each run so interesting or particularly unlucky runs can be shared and replicated.
