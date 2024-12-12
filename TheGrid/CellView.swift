//
//  CellView.swift
//  TheGrid
//
//  Created by Daniil Zolotarev on 27.09.24.
//

import SwiftUI

// Структура клетки на поле
struct Cell {
    var isWall: Bool = false
    var isTarget: Bool = false
    var hasBox: Bool = false
    var hasPlayer: Bool = false
}

struct CellView: View {
    @StateObject var viewModel = GameViewModel() // Используемый вами ViewModel
    let cell: Cell

    var body: some View {
        Rectangle()
            .fill(cell.isTarget ? Color.green : Color.gray.opacity(0.5))
            .overlay(
                Group {
                    if cell.isWall {
                        Rectangle().fill(Color.gray.opacity(0.5))
                        Text("🪨").font(.custom("Georgia", size: 45, relativeTo: .body))
                    }
                    if cell.isTarget {
                        Rectangle().fill(Color.gray.opacity(0.5))
                        if viewModel.isGameWon() {
                            Text("🪺").font(.custom("Georgia", size: 50, relativeTo: .body))
                        } else {
                            Text("🪹").font(.custom("Georgia", size: 50, relativeTo: .body))
                        }
                    }
                    
                    // Анимация для игрока
                    if cell.hasPlayer {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .overlay(
                                Text("🐔").font(.custom("Georgia", size: 50, relativeTo: .body))
                            )
                            .transition(.scale) // Появление с масштабированием
                    } else if cell.hasBox {
                        Rectangle().fill(Color.gray.opacity(0.5))
                        Text("🥚").font(.custom("Georgia", size: 40, relativeTo: .body))
                    }
                }
            )
            .frame(width: 50, height: 50)
            .animation(.easeInOut(duration: 0.3), value: cell.hasPlayer) // Анимация изменений
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        // Пример тестовой ячейки для предпросмотра
        let testCell = Cell(isWall: false, isTarget: false, hasBox: false, hasPlayer: true)
        CellView(cell: testCell)  // Теперь используется в структуре предпросмотра
    }
}
