//
//  ContentView.swift
//  cptest
//
//  Created by Shubham on 12/6/20.
//  Copyright © 2020 torus. All rights reserved.
//

import SwiftUI
import FetchNodeDetails

struct ContentView: View {
    @State private var showingAlert = false
    @State private var currentEpoch = 0
    var body: some View {
        NavigationView{
            List {
                Section(header: Text("APIs")) {
                    Group{
                        Button(action: {
                            let fnd = FetchNodeDetails(proxyAddress: "0x4023d2a0D330bF11426B12C6144Cfb96B7fa6183", network: EthereumNetwork.ROPSTEN, logLevel: .info);
                            self.currentEpoch = fnd.getCurrentEpoch();
                            self.showingAlert = true
                            print(self.currentEpoch)
                        }, label: {
                            Text("Get current epoch")
                        }).alert(isPresented: $showingAlert) {
                            Alert(title: Text("Current Epoch"), message: Text(self.currentEpoch.description), dismissButton: .default(Text("Got it!")))
                        }
                    }
                    
                }
                
            }.navigationBarTitle(Text("Fetch node details"))
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
