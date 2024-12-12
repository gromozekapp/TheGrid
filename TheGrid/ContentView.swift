////
////  ContentView.swift
////  TheGrid
////
////  Created by Daniil Zolotarev on 26.09.24.
////

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    var camera = CameraViewController()
    
    // Состояние для отображения алерта
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // CameraView будет фоном
            CameraView()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("steps: \(viewModel.score) game without steps: \(viewModel.gamesWithoutMove)")
                Text("lost game: \(viewModel.lostGame) won game total: \(viewModel.countWin)")
                
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
                                
                                // Проверка на победу после каждого перемещения
                                if viewModel.isGameWon() {
                                    // Увеличиваем количество побед
                                    viewModel.countWin += 1
                                    
                                    // Устанавливаем сообщение для алерта и показываем его
                                    alertMessage = """
🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓
🐓 Won! 🐣 saved: \(viewModel.countWin)   🐓
🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓🐓
"""
                                        
                                    showAlert = true
                                    
                                    // Автоматическое скрытие алерта через 2 секунды
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showAlert = false
                                        viewModel.resetGrid()
                                    }
                                }
                            }
                    )
                    .shadow(radius: 20)
                    .padding()
                Spacer()
                
                HStack {
                    Button("NEXT") { viewModel.resetGrid() }
                        .shadow(radius: 20)
                        .padding()
                        .background(.red, in: Capsule())
                        .foregroundStyle(.black)
                        .padding(5)
                    
                    Button("CAMERA") { camera.makeShot() }
                        .shadow(radius: 20)
                        .padding()
                        .background(.blue, in: Capsule())
                        .foregroundStyle(.black)
                        .padding(5)
                }
            }
        }
        // Отображение алерта
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("🥚 in a 🪺"),
                message: Text(alertMessage),
                dismissButton: .default(Text("🥚K"))
            )
        }//.font(.system(size: 20, weight: .semibold, design: .rounded))
    }
}

#Preview {
    ContentView()
}
