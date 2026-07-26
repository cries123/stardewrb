# StardewRB

A Stardew Valley-style cozy farming simulation for Roblox, built around an **instanced hub-and-spoke universe** so players never compete for map space.

## Architecture

```
Universe
├── Hub Place (public, 30–50 players)   → shops, NPCs, social town
└── Farm Place (reserved, 1–4 players) → private farm instances via portal
```

| Pillar | Module(s) | Status |
|--------|-----------|--------|
| Hub & Spoke teleport | `Server/Teleport/FarmTeleportService`, `Server/Hub/PortalService` | MVP |
| ProfileService data | `Server/Data/DataService`, `Shared/ProfileTemplate` | MVP |
| Math grid farming | `Shared/Grid/*`, `Server/Farm/FarmGridService` | MVP |
| Global time sync | `Shared/Time/TimeMath`, `Server/Time/TimeService` | MVP |

## Prerequisites

- [Roblox Studio](https://create.roblox.com/)
- [Aftman](https://github.com/LPGhatguy/aftman) (recommended) or manual install of Rojo 7.x
- [Rojo](https://rojo.space/) 7.x

```bash
aftman install
```

## Project layout

```
src/
  Shared/          # Replicated modules (config, grid math, time math)
  Server/          # Server-only services
  Client/          # Client controllers
  ReplicatedFirst/ # Loading scripts
vendor/
  ProfileService.lua
default.project.json   # Hub place Rojo config
farm.project.json      # Farm place Rojo config
```

## Roblox Studio setup

### 1. Create the Universe

1. Create a **Universe** in the [Creator Dashboard](https://create.roblox.com/dashboard/creations).
2. Create two places inside it:
   - **Hub** — main town (public servers)
   - **Farm** — private farm template (reserved servers)
3. Copy both Place IDs into `src/Shared/GameConfig.lua`:

```lua
Places = {
    Hub = { PlaceId = YOUR_HUB_ID, MaxPlayers = 50 },
    Farm = { PlaceId = YOUR_FARM_ID, MaxPlayers = 4 },
},
```

4. Enable **Allow Third Party Teleports** in Game Settings for both places.

### 2. Sync with Rojo

**Hub place:**
```bash
rojo serve default.project.json
```

**Farm place (separate Studio window or after publishing):**
```bash
rojo serve farm.project.json
```

Connect each open place file to its matching Rojo port.

### 3. Hub scene setup

Tag a portal part with the CollectionService tag **`FarmPortal`**. Studio auto-creates one if none exists.

Players touch the portal (or fire `TeleportToFarm` via a GUI button named `FarmPortalButton`) to spin up / rejoin their reserved farm server.

### 4. Invite friends

From the Hub, call the `InviteToFarm` RemoteFunction on the server (wire to a UI button in a later pass):

```lua
-- Server example (already implemented in FarmTeleportService)
Remotes.getFunction("InviteToFarm"):InvokeServer(targetPlayer)
```

The guest is teleported into the host's reserved server using the stored `FarmState.PrivateServerCode`.

## Data model (ProfileService)

```lua
{
    Inventory = {
        Tools = { Hoe = 1, WateringCan = 1 },
        Seeds = { TomatoSeed = 5 },
        Harvest = { Tomato = 0 },
    },
    FarmState = {
        PrivateServerCode = nil, -- reserved server access code
        Grid = { ... },          -- 2D matrix [x][y]
    },
}
```

Session locking: profiles are **released before every cross-place teleport** (`DataService.releaseForTeleport`) so data cannot duplicate across Hub ↔ Farm transitions.

## Farm gameplay (MVP)

All placement logic runs on a **2D array matrix** — not physical hitboxes.

| Key | Tool | Action |
|-----|------|--------|
| `1` | Hoe | Till empty cell |
| `2` | Watering Can | Water planted crop |
| `3` | Tomato Seeds | Plant on tilled soil |
| `4` | Harvest | Collect ready crop |
| Click | — | Use selected tool on targeted cell |

Growth loop: **Plant → Water → (next in-game day) → Ready → Harvest**

## Hub town (Pelican Town MVP)

The hub is built procedurally by `HubWorldService` when you serve `default.project.json`.

**Included POIs:**
- Town Square with notice board
- Pierre's General Store, Stardrop Saloon, Blacksmith
- Museum & Library, Community Center, JojaMart
- Harvey's Clinic, Mayor's Manor
- 1 & 2 Willow Lane homes, River Road houses (Pam/Penny trailer, George & Evelyn)
- The River (west side), Playground (north)
- Cobblestone walkways connecting districts
- Trees, bushes, and flower patches around town

**Seasons:** `HubSeasonService` recolors grass, paths, trees, flowers, and the river when the in-game season changes (synced with `TimeMath` — Spring → Summer → Fall → Winter).

**Farm travel:** purple bus portal at the south exit (touch) or **Visit My Farm** in the hub UI.

Edit layout in `src/Shared/Hub/HubLayout.lua` and colors in `src/Shared/Hub/HubSeasonPalettes.lua`.

## Global time sync

`TimeMath` derives the in-game clock from `os.time()` and a shared `TimeEpoch` in `GameConfig`. Every server computes identical `gameDay`, `dayProgress`, and `clockTime`, so Hub and Farm lighting stay aligned.

Adjust pacing in `GameConfig`:
- `TimeEpoch` — anchor timestamp for day 0
- `RealSecondsPerGameDay` — real seconds per in-game day (default: 1200 = 20 min)
- `DayStartHour` — hour when the visual day begins (default: 6 AM)

## Studio-only testing

When Place IDs are still `0`, set in `GameConfig.lua`:

```lua
StudioPlaceTypeOverride = "Farm", -- or "Hub"
```

Or connect Rojo with the matching project file (`farm.project.json` injects `PlaceType = Farm` automatically).

> TeleportService reserved servers require published places and cannot be fully tested in unpublished Studio sessions.

## Farm place shows nothing in Studio

1. **Use the farm Rojo project** — `rojo serve farm.project.json` (not `default.project.json`).
2. **Reconnect Rojo** after pulling — you should see `ReplicatedStorage.PlaceConfig` in Explorer.
3. **Press Play** and open **Output**. You want:
   - `[Bootstrap] StardewRB server started as Farm`
   - `Project=Farm` in the debug line
4. **Verify place IDs** — in the farm place Command Bar run `print(game.PlaceId)` and paste that exact number into `GameConfig.Places.Farm.PlaceId`. Use **place** IDs, not universe IDs.
5. **Do not put the farm place id in the Hub slot** — that makes the farm resolve as Hub and skips farm world generation.
6. After Studio shows the green platform + grid + HUD, **publish** the farm place again.

## Git workflow

```bash
# Hub development
rojo serve default.project.json

# Farm development
rojo serve farm.project.json

git checkout -b feature/my-feature
# ... edit, commit, push, open PR
```

## License

MIT (add your license as needed)
