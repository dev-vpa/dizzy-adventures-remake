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
| Treasure Island Dizzy | In development (prototype) |
| Other adventure games | Planned |

**Current milestone:** Phase 1 complete — pixel Dizzy, beach backdrop, inventory slots with drop/use, lives (TI: 1 life, fall = game over).

## Controls

| Action | Keys |
|--------|------|
| Move | A/D or ←/→ |
| Jump | Space or ↑ |
| Pick up | E or Enter |
| Cycle inventory | Tab |
| Drop item | R |
| Use item | U |
| Menu | HUD **Menu** button or Esc (menus) |

**Touch (Android / mobile):** on-screen **◀ ▶ Pick Jump** buttons; tap inventory slots to select; **Drop** / **Use** buttons in the HUD. The Tab/R/U hints are hidden on touch devices.

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
└── LICENSE                 # MIT — source code
```

Each adventure game lives under `games/<slug>/` with its own levels and config. Shared mechanics live in `core/`.

## Requirements

- [Godot 4.4+](https://godotengine.org/download) (GDScript, **GL Compatibility** renderer for Web/Android)

## Run locally

1. Clone the repository.
2. Open the project folder in Godot 4.
3. Press **F5** (main scene: `scenes/main.tscn`).

## Display

Retro **512×384** internal resolution (2× classic ZX Spectrum 256×192). On launch (exported or standalone run) the window fills the **usable screen area**; Godot **integer-scales** the viewport to the largest whole size that fits and adds **letterbox/pillarbox bars** as needed (`stretch/aspect=keep`). Resizing the window recalculates scale automatically.

**Godot editor (F5):** embedded play mode controls window size — `DisplayManager` does not resize it. For full-screen scaling test: **Game → Embedding options → disable “Embed Game on Next Play”**, then F5 again. The debug toolbar always shows **512×384** (internal viewport — that is normal). Game logic and flick-screens stay in 512×384 coordinates.

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
