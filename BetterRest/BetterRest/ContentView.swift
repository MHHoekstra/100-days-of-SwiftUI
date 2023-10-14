//
//  ContentView.swift
//  BetterRest
//
//  Created by Michel Henrique Hoekstra on 08/10/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var sleepAmount = 8.0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please select a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                VStack(alignment: .leading) {
                    Text("How much do you want to sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted(.number)) hours", value: $sleepAmount, in: 4...14, step: 0.25)
                }

                VStack(alignment: .leading) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $isShowingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try BetterRest(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0)*3600
            let minutes = (components.minute ?? 0)*60
            
            let prediction = try model.prediction(input: BetterRestInput(wake: Int64(hour + minutes), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount)))
            
            let sleepAmount = wakeUpTime - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepAmount.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an error calculating your bedtime"
        }
        isShowingAlert = true
    }
}

#Preview {
    ContentView()
}
