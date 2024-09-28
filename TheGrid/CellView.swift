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
    let cell: Cell

    var body: some View {
        Rectangle()
            .fill(cell.isWall ? Color.black : cell.isTarget ? Color.green : Color.gray.opacity(0.5))
            .overlay(
                Group {
                    if cell.hasPlayer {
                        Circle().fill(Color.blue)
                    } else if cell.hasBox {
                        Rectangle().fill(Color.orange)
                    }
                }
            )
            .frame(width: 50, height: 50)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        // Пример тестовой ячейки для предпросмотра
        let testCell = Cell(isWall: false, isTarget: false, hasBox: false, hasPlayer: true)
        CellView(cell: testCell)  // Теперь используется в структуре предпросмотра
    }
}
