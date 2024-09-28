//
//  GameViewModel.swift
//  TheGrid
//
//  Created by Daniil Zolotarev on 26.09.24.
//

import SwiftUI

// Размеры игрового поля
private let gridSize = 6

final class GameViewModel: ObservableObject {
    @Published var grid: [[Cell]] = []
    @Published var playerPosition: (x: Int, y: Int) = (0, 0)

    init() {
        // Создаем пустое поле
        resetGrid()
        // Устанавливаем игрока и объект в начальные позиции
        if playerPosition.x == 0 && playerPosition.y == 0 {
            grid[1][1].hasPlayer = true
            playerPosition = (1, 1)
            
            grid[2][2].hasBox = true
            grid[4][4].isTarget = true
        }
    }
    
    func resetGrid() {
        if grid.isEmpty {
            grid = Array(repeating: Array(repeating: Cell(), count: gridSize), count: gridSize)
            // Пример расставления стен (можно сделать по-своему)
            grid[1][3].isWall = true
            grid[2][3].isWall = true
            grid[3][3].isWall = true
            grid[3][4].isWall = true
        } else {
            grid = Array(repeating: Array(repeating: Cell(), count: gridSize), count: gridSize)
            // Заполнение поля стенами и пустыми ячейками
            for x in 1..<(gridSize-2) {
                for y in 1..<(gridSize-2) {
                    let isWall = Bool.random() // Случайная стенка
                    grid[x][y] = Cell(isWall: isWall, isTarget: false, hasBox: false, hasPlayer: false)
                }
            }
            // Установка игрока в случайной позиции
            let playerX = Int.random(in: 0..<gridSize)
            let playerY = Int.random(in: 0..<gridSize)
            grid[playerX][playerY].hasPlayer = true
            playerPosition = (playerX, playerY)
            // Установка цели в случайной позиции, не занимая место игрока
            var targetPlaced = false
            while !targetPlaced {
                let targetX = Int.random(in: 0..<gridSize)
                let targetY = Int.random(in: 0..<gridSize)
                if !grid[targetX][targetY].hasPlayer && !grid[targetX][targetY].isWall {
                    grid[targetX][targetY].isTarget = true
                    targetPlaced = true
                }
            }
            // Установка ящика в случайной позиции, не занимая место игрока или цели
            var boxPlaced = false
            while !boxPlaced {
                let boxX = Int.random(in: 1..<(gridSize-1))
                let boxY = Int.random(in: 1..<(gridSize-1))
                if !grid[boxX][boxY].hasPlayer && !grid[boxX][boxY].isTarget && !grid[boxX][boxY].isWall {
                    grid[boxX][boxY].hasBox = true
                    boxPlaced = true
                }
            }
        }
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