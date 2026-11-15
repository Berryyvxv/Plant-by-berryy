import SwiftUI
import Playgrounds

struct ContentView: View {
    @State private var viewModel = PlantsViewModel()
    @State private var showingSetReminder = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Plants 🌱")
                .font(.largeTitle.bold())
                .padding(.horizontal)

            Divider()
                .padding(.horizontal)
                .padding(.top, 8)

            if viewModel.isEmpty {
                EmptyStateView { showingSetReminder = true }
            } else {
            
                List(viewModel.plants) { plant in
                    Text(plant.name)
                }
            }
        }
        .sheet(isPresented: $showingSetReminder) {
            SetReminderView { plant in
                viewModel.add(plant)
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

#Playground {
    _ = 1 + 2
}
