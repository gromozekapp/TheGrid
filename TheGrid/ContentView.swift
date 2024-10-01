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
        ZStack {
            // CameraView будет фоном
            CameraView()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("steps: \(viewModel.score) game without steps: \(viewModel.gamesWithoutMove)")
                Text("lost game: \(viewModel.lostGame) won game total: \(viewModel.countWin)")
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
                    .shadow(radius: 20)
                    .padding()
                    Spacer()
                
                Button("New Grid") { viewModel.resetGrid() }
                    .shadow(radius: 20)
                    .padding()
                    .background(.red,in: Capsule())
                    .foregroundStyle(.white)
                    .padding(5)
            }
        }
    }
}

#Preview {
    ContentView()
}
