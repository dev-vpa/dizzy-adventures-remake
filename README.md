# Dizzy Adventures Remake

Unofficial, non-commercial fan remake of classic **Dizzy** adventure games.  
Built with [Godot 4](https://godotengine.org/) and **GDScript**.

**Not affiliated with or endorsed by Codemasters or the Oliver Twins.**

## Disclaimer

> "Dizzy", "The Yolkfolk" and all related characters and titles are trademarks of  
> Oliver Twins Limited and The Codemasters Software Company Limited. All rights reserved.

This project is a free fan recreation for preservation and enjoyment. It is not an official product.

## Status

| Part | Status |
|------|--------|
| Treasure Island Dizzy | **Phase 3 content playable** — 51 screens, puzzles, 30 coins, win chain |
| Other adventure games | Planned |

**Current milestone:** **Phase 3** — full map content in; next is a start-to-win playthrough + art/audio (Phase 4).

### Phase 3 progress (Treasure Island)

- **51 level scenes** + `screen_map.md` / `items.json` (trade chain, coin map)
- **Regions:** west/tree/mine, ocean, east/shop/pier, cavern/kitchen/bridge
- **Puzzles:** axe→bridge↓, sword→grave↓, spade→bubbles↑, key→kitchen, dynamite+detonator→mine, bible→treasure, shop Use-trades
- **Hazards:** path-height `hazard_zone` (patrol fish/crab/cuttlefish) + WaterZone (snorkel)
- **Optional junk:** `tree_rail_coin`, `tree_magazine`
- **Coins:** exactly **30** (guarded by `test_coin_layout`)
- **Win:** boat parts on `pier_boat` (order) → Taxman on `taxman_dock` with 30 coins

### Phase 2 gameplay (still available on east path)

- **8 screens:** beach_start → beach_right → beach_jetty → village_path → shop_exterior / shop_interior → underwater_shallow, cave_entrance
- **Snorkel:** pick up on starting beach; required to survive water (Dizzy shows mask when held)
- **Coins:** 5 coins on the slice map; HUD shows `Coins: N/30`; collected coins stay collected when revisiting screens
- **Shop:** enter with **E** at the door on shop_exterior; talk to shopkeeper with **E** inside
- **Vertical exits:** **↑ / W** — cave (village stump), surface (underwater); **↓ / S** — dive at jetty (left water, snorkel equipped)
- **Water:** shallow water on jetty — death without snorkel (1 life)

## Controls

| Action | Keys |
|--------|------|
| Move | A/D or ←/→ |
| Jump | Space |
| Screen up / down | ↑↓ or W/S (cave, dive, surface — stand in marked zone) |
| Pick up / talk / enter | E or Enter |
| Cycle inventory | Tab |
| Drop item | R |
| Use item | U |
| Menu | HUD **Menu** button (Esc closes quit prompt) |

**Touch (Android / mobile):** on-screen **◀ ▶ Pick Jump** buttons; tap inventory slots to select; **Drop** / **Use** buttons in the HUD. The Tab/R/U hints are hidden on touch devices.

All UI screens must provide tap/button paths — see `core/ui/platform_ui.gd`. **Quit** is hidden on mobile and web builds.

Releases (Windows, Linux, Web, Android) will be published on [GitHub Releases](https://github.com/Slider540/dizzy-adventures-remake/releases) when available.  
The game is and will remain **free** — no purchases, no ads, no royalties.

## Project structure

```
dizzy-adventures-remake/
├── core/                   # Shared engine: player, screens, inventory, autoloads
├── shared/                 # Assets reused across games (Dizzy sprite, UI, audio)
├── games/
│   └── treasure-island/    # First game: levels, config, game-specific assets
├── scenes/                 # Main menu, loading screen, game shell
├── assets/                 # Legal info and app icons
│   ├── icons/              # 512×512 pixel-art icons for project & export
│   └── LICENSE.md          # CC BY-NC 4.0 for game assets
├── project.godot
├── export_presets.cfg      # Windows, Linux, Web, Android export config
├── tests/                  # Headless autotests (see below)
├── scripts/run_tests.sh    # Run tests (bash)
└── LICENSE                 # MIT — source code
```

Each adventure game lives under `games/<slug>/` with its own levels and config. Shared mechanics live in `core/`.

## Requirements

- [Godot 4.4+](https://godotengine.org/download) (GDScript, **GL Compatibility** renderer for Web/Android)

## Run locally

1. Clone the repository.
2. Open the project folder in Godot 4.
3. Press **F5** (main scene: `scenes/main.tscn`).

## Automated tests

Headless unit/integration tests (no plugins — pure GDScript):

```bash
# Bash (Git Bash / Linux) — set GODOT if not in PATH
GODOT="/path/to/Godot_v4.exe" ./scripts/run_tests.sh

# Windows cmd
scripts\run_tests.bat
```

Or in Godot: open `tests/test_runner.tscn` and run the scene (F6).

**Coverage:** autoloads (`Inventory`, `Collectibles`, `WorldState`), `ItemCatalog`, `items.json`, `GameScreen` API, TI level registry (all `.tscn` load, exits resolve), `ScreenManager` transitions. Exit code `0` = pass, `1` = fail.

## Display

Retro **512×384** internal resolution (2× classic ZX Spectrum 256×192). On launch (exported or standalone run) the window fills the **usable screen area**; Godot **integer-scales** the viewport to the largest whole size that fits and adds **letterbox/pillarbox bars** as needed (`stretch/aspect=keep`). Resizing the window recalculates scale automatically.

**Godot editor (F5):** embedded play mode controls window size — `DisplayManager` does not resize it. For full-screen scaling test: **Game → Embedding options → disable “Embed Game on Next Play”**, then F5 again. The debug toolbar always shows **512×384** (internal viewport — that is normal). Game logic and flick-screens stay in 512×384 coordinates.

### Debug playtest shortcuts (debug builds / F5 only)

| Action | How |
|--------|-----|
| Reload current screen from disk | **F9** (respawns at center; picks up `.tscn` edits) |
| Start on a specific screen | In `scenes/game_world.gd` set `DEBUG_START_SCREEN` (e.g. `"cavern_kitchen_door"`); `""` = normal start. Optional `DEBUG_GIVE_ITEMS`. Puzzle screens auto-seed key items. |
| Skip menus on F5 | Debug builds boot straight into TI gameplay. To see menus: Main Run Args `-- --menu` |

## Export targets

| Platform | Format |
|----------|--------|
| Windows | `.exe` |
| Linux | binary / `.x86_64` |
| Web | HTML5 |
| Android | `.apk` |

Export presets are in `export_presets.cfg` (**Project → Export**). Build artifacts go to `export/` (gitignored).

| Platform | Icon source |
|----------|-------------|
| Windows | `assets/icons/app_icon_512.png` (nearest-neighbor scaling) |
| Linux / Web | Project icon |
| Android | Main: `app_icon_512.png`; adaptive foreground: `android_foreground_512.png` (transparent); background: `android_background_512.png` |

## License

| Content | License |
|---------|---------|
| Source code | [MIT](LICENSE) |
| Original game assets (sprites, audio, etc.) | [CC BY-NC 4.0](assets/LICENSE.md) |

Third-party Dizzy characters and names remain property of their respective rights holders. This project does not grant any rights to those trademarks.

## Contributing

Contributions welcome via pull requests. Please keep the project **non-commercial** and include the trademark disclaimer in any user-facing screen you add.
