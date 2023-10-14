//
//  ContentView.swift
//  WeSplit
//
//  Created by Michel Henrique Hoekstra on 24/08/23.
//

import SwiftUI

struct ContentView: View {
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 20
    
    @FocusState private var amountIsFocused
    
    let tipPercentages = [10, 15, 20, 25, 0]
    
    var totalPerPerson: Double {
        let peopleCount = Double(numberOfPeople)
        let tip = checkAmount * Double(tipPercentage) / 100
        
        return (checkAmount + tip) / peopleCount
    }
     
    var body: some View {
        Form{
            Section {
                TextField("Amount", value: $checkAmount,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .focused($amountIsFocused)
                    .keyboardType(.decimalPad)
                Picker("Number of People", selection: $numberOfPeople) {
                    ForEach(2..<100,id: \.self) {
                        Text("\($0) people")
                    }
                }
            }
            Section("How much tip do you want to leave?") {
                Picker("Tip percentage", selection: $tipPercentage) {
                    ForEach(tipPercentages, id: \.self) {
                        Text($0, format: .percent)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section {
                Text(totalPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            } header: {
                Text("Value per person")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    amountIsFocused = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
