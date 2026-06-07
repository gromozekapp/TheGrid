# TheGrid

> Portfolio exercise — grid-based gameplay inspired by [Snowbound](https://www.kongregate.com/games/rec8bit/snowbound)

[![Swift](https://img.shields.io/badge/Swift-SwiftUI-F05138?logo=swift&logoColor=white)]()
[![Status](https://img.shields.io/badge/type-portfolio%20exercise-blue)]()

SwiftUI game prototype with MVVM architecture, camera integration, and interactive grid cells.

---

## Features

- Grid-based gameplay with interactive cells
- Camera capture integration (`CameraViewController`)
- MVVM pattern (`GameViewModel`, `GridView`, `CellView`)
- SwiftUI + UIKit bridge for camera

---

## Architecture

```
TheGrid/
├── ContentView.swift         # Main game screen
├── GameViewModel.swift       # Game state & logic
├── GridView.swift            # Grid layout
├── CellView.swift            # Cell UI
├── CameraViewController.swift # AVFoundation camera
└── TheGridApp.swift          # Entry point
```

**Stack:** SwiftUI · MVVM · AVFoundation

---

## Getting Started

```bash
git clone https://github.com/gromozekapp/TheGrid.git
cd TheGrid
open TheGrid.xcodeproj
```

Select scheme **TheGrid** → Run (`⌘R`).

---

## Note

Test task / portfolio project — Dec 2024.
