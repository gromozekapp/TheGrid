//
//  TheGame.swift
//  TheGrid
//
//  Created by Daniil Zolotarev on 26.09.24.
//

import SwiftUI

// Размеры игрового поля
let gridSize = 6

// Структура клетки на поле
struct Cell {
    var isWall: Bool = false
    var isTarget: Bool = false
    var hasBox: Bool = false
    var hasPlayer: Bool = false
}

class GameViewModel: ObservableObject {
    @Published var grid: [[Cell]] = []
    @Published var playerPosition: (x: Int, y: Int) = (0, 0)

    init() {
        // Создаем пустое поле
        resetGrid()
        
        // Устанавливаем игрока и объект в начальные позиции
        grid[1][1].hasPlayer = true
        playerPosition = (1, 1)
        
        grid[2][2].hasBox = true
        grid[4][4].isTarget = true
    }
    
    func resetGrid() {
        grid = Array(repeating: Array(repeating: Cell(), count: gridSize), count: gridSize)
        
        // Пример расставления стен (можно сделать по-своему)
        grid[1][3].isWall = true
        grid[2][3].isWall = true
        grid[3][3].isWall = true
        grid[3][4].isWall = true
    }
    
    func movePlayer(dx: Int, dy: Int) {
        let newX = playerPosition.x + dx
        let newY = playerPosition.y + dy
        
        // Проверяем, что новая позиция в пределах поля
        guard newX >= 0 && newX < gridSize && newY >= 0 && newY < gridSize else { return }
        
        // Проверяем, что на новой клетке нет стены
        if grid[newX][newY].isWall { return }
        
        // Проверяем, есть ли перед нами ящик
        if grid[newX][newY].hasBox {
            let boxNewX = newX + dx
            let boxNewY = newY + dy
            
            // Проверяем, что за ящиком свободное место и нет стены или другого ящика
            if boxNewX >= 0 && boxNewX < gridSize && boxNewY >= 0 && boxNewY < gridSize &&
                !grid[boxNewX][boxNewY].hasBox && !grid[boxNewX][boxNewY].isWall {
                // Двигаем ящик
                grid[boxNewX][boxNewY].hasBox = true
                grid[newX][newY].hasBox = false
            } else {
                return // Не можем толкнуть ящик
            }
        }
        
        // Двигаем игрока
        grid[playerPosition.x][playerPosition.y].hasPlayer = false
        playerPosition = (newX, newY)
        grid[playerPosition.x][playerPosition.y].hasPlayer = true
    }
    
    func isGameWon() -> Bool {
        // Игра выиграна, если все ящики на целевых местах
        for row in grid {
            for cell in row where cell.isTarget && !cell.hasBox {
                return false
            }
        }
        return true
    }
}

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()

    var body: some View {
        VStack {
            Text(viewModel.isGameWon() ? "You Won!" : "Push the box to the target")
                .font(.title)
                .padding()
            
            GridView(grid: viewModel.grid)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let translation = value.translation
                            
                            if abs(translation.width) > abs(translation.height) {
                                if translation.width > 0 {
                                    viewModel.movePlayer(dx: 1, dy: 0) // Вправо
                                } else {
                                    viewModel.movePlayer(dx: -1, dy: 0) // Влево
                                }
                            } else {
                                if translation.height > 0 {
                                    viewModel.movePlayer(dx: 0, dy: 1) // Вниз
                                } else {
                                    viewModel.movePlayer(dx: 0, dy: -1) // Вверх
                                }
                            }
                        }
                )
        }
    }
}

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

struct CellView: View {
    let cell: Cell

    var body: some View {
        Rectangle()
            .fill(cell.isWall ? Color.black : cell.isTarget ? Color.green : Color.gray)
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


