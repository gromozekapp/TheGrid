//
//  GridView.swift
//  TheGrid
//
//  Created by Daniil Zolotarev on 27.09.24.
//

import SwiftUI

struct GridView: View {
    let grid: [[Cell]]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<grid.count, id: \.self) { rowIndex in
                HStack(spacing: 2) {
                    ForEach(0..<grid[rowIndex].count, id: \.self) { colIndex in
                        CellView(cell: grid[rowIndex][colIndex])
                    }
                }
            }
        }
    }
}

#Preview {
    GridView(grid: Array(repeating: Array(repeating: Cell(), count: 6), count: 8))
}
