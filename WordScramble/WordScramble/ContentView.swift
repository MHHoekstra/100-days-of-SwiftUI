//
//  ContentView.swift
//  WordScramble
//
//  Created by Michel Henrique Hoekstra on 09/10/23.
//

import SwiftUI

struct ContentView: View {
    @State private var rootWord = ""
    @State private var typedWord = ""
    @State private var usedWords = [String]()
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var isShowingAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $typedWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $isShowingAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {Text(errorMessage)})
        }
    }
    
    func addWord() {
        let word = typedWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard word.count > 0 else { return }
        
        guard isOriginal(word: word) else {
            showWordError(title: "Word already used", message: "Be more original!")
            return
        }
        
        guard isPossible(word: word) else {
            showWordError(title: "Word not possible", message: "You can't spell that from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: word) else {
            showWordError(title: "Word not recognized", message: "Please, insert a real word!")
            return
        }
        
        withAnimation {
            usedWords.insert(word, at: 0)
        }
        
        typedWord = ""
    }
    
    func startGame() {
        if let wordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let words = try? String(contentsOf: wordsURL) {
                let allWords = words.components(separatedBy: .newlines)
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Couldnt load word from start.txt")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRage = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRage.location == NSNotFound
    }
    
    func showWordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        isShowingAlert = true
    }
    
}

#Preview {
    ContentView()
}
