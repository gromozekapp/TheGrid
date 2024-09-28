////
////  ContentView.swift
////  TheGrid
////
////  Created by Daniil Zolotarev on 26.09.24.
////
//
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    
    var body: some View {
        VStack {
            Button("New Grid") {
                viewModel.resetGrid()
                       }
            Text(viewModel.isGameWon() ? "You Won!" : "Push the box to the target")
                .font(.title)
                .padding()
            
            GridView(grid: viewModel.grid)
                .gesture(
                    DragGesture(minimumDistance: 10)  // Минимальное расстояние для распознавания жеста
                        .onEnded { value in
                            let translation = value.translation

                            // Пороговое значение для определения направления движения
                            let threshold: CGFloat = 20.0

                            // Проверяем, в каком направлении движение было сильнее
                            if abs(translation.width) > abs(translation.height) {
                                // Горизонтальное движение
                                if translation.width > threshold {
                                    viewModel.movePlayer(dx: 0, dy: 1)  // Вправо
                                } else if translation.width < -threshold {
                                    viewModel.movePlayer(dx: 0, dy: -1)  // Влево
                                }
                            } else {
                                // Вертикальное движение
                                if translation.height > threshold {
                                    viewModel.movePlayer(dx: 1, dy: 0)  // Вниз
                                } else if translation.height < -threshold {
                                    viewModel.movePlayer(dx: -1, dy: 0)  // Вверх
                                }
                            }
                        }
                )
        }
    }
}

#Preview {
    ContentView()
}
