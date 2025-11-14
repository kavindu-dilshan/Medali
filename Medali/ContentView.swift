//
//  ContentView.swift
//  Medali
//
//  Created by Kavindu Dilshan on 2025-11-13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Text("Medali")
                .navigationBarTitle("Medali", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
