//
//  ContentView.swift
//  SafeCrack Watch App
//
//  Created by Zaid Neurothrone on 2022-10-12.
//

import SwiftUI

struct ContentView: View {
  @State private var currentSafeValue: Double = 50
  @State private var targetSafeValue: Int = .zero
  @State private var allSafeNumbers: [Int] = []
  @State private var correctValues: [String] = []
  @State private var title = "Safe Crack"
  
  @State private var startTime: Date = .now
  @State private var currentTime: Date = .now
  
  @State private var isGameOver = false
  
  private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
  
  var isAnswerCorrect: Bool {
    Int(currentSafeValue) == targetSafeValue
  }
  
  var answerColor: Color {
    isAnswerCorrect ? .green : .red
  }
  
  var time: Int {
    let difference = currentTime.timeIntervalSince(startTime)
    return Int(difference)
  }
  
  var body: some View {
    VStack {
      Text(title)
        .font(.title2)
        .foregroundColor(answerColor)
      
      Slider(value: $currentSafeValue, in: 1...100, step: 1)
      
      Button("Enter \(currentSafeValue.formatted())", action: nextTapped)
        .disabled(!isAnswerCorrect || isGameOver)
      
      Text("Time: \(time)")
    }
    .alert("You win!", isPresented: $isGameOver) {
      Button("Play Again", action: startNewGame)
    } message: {
      Text("You took \(time) seconds.")
    }
    .onAppear(perform: startNewGame)
    .onReceive(timer) { newTime in
      currentTime = newTime
    }
  }
}

extension ContentView {
  private func startNewGame() {
    startTime = .now
    correctValues.removeAll()
    allSafeNumbers = Array(1...100).shuffled()
    currentSafeValue = 50
    pickNumber()
  }
  
  private func pickNumber() {
    targetSafeValue = allSafeNumbers.removeFirst()
  }
  
  private func nextTapped() {
    guard isAnswerCorrect else { return }
    
    correctValues.append(String(targetSafeValue))
    title = correctValues.joined(separator: ", ")
    
    if correctValues.count >= 4 {
      Task {
        try await Task.sleep(until: .now + .milliseconds(500), clock: .continuous)
        isGameOver = true
      }
    } else {
      pickNumber()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
