import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: FacialCareView()) {
                    MenuRow(title: "Cuidado Facial", imageName: "facial_care")
                }
                NavigationLink(destination: HairCareView()) {
                    MenuRow(title: "Cuidado del Cabello", imageName: "hair_care")
                }
                NavigationLink(destination: BodyCareView()) {
                    MenuRow(title: "Cuidado Corporal", imageName: "body_care")
                }
                NavigationLink(destination: MakeupView()) {
                    MenuRow(title: "Maquillaje", imageName: "makeup")
                }
            }
            .navigationTitle("CosmoCaare 😛🧖🏼‍♀️")
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct MenuRow: View {
    var title: String
    var imageName: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .padding()
            Text(title)
                .font(.headline)
                .padding()
            Spacer()
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.vertical, 5)
        .shadow(color:.gray, radius: 2, x: 0, y: 2)
    }
}

struct FacialCareView: View {
    @State private var selectedDate = Date()
    @State private var selectedProducts: [Product] = []

    var body: some View {
        AppointmentView(title: "Cuidado Facial", imageName: "facial_care", description: "Aquí encontrarás información sobre el cuidado de la piel facial.", selectedDate: $selectedDate, selectedProducts: $selectedProducts)
    }
}

struct HairCareView: View {
    @State private var selectedDate = Date()
    @State private var selectedProducts: [Product] = []

    var body: some View {
        AppointmentView(title: "Cuidado del Cabello", imageName: "hair_care", description: "Aquí encontrarás información sobre el cuidado del cabello.", selectedDate: $selectedDate, selectedProducts: $selectedProducts)
    }
}

struct BodyCareView: View {
    @State private var selectedDate = Date()
    @State private var selectedProducts: [Product] = []

    var body: some View {
        AppointmentView(title: "Cuidado Corporal", imageName: "body_care", description: "Aquí encontrarás información sobre el cuidado del cuerpo.", selectedDate: $selectedDate, selectedProducts: $selectedProducts)
    }
}

struct MakeupView: View {
    @State private var selectedDate = Date()
    @State private var selectedProducts: [Product] = []

    var body: some View {
        AppointmentView(title: "Maquillaje", imageName: "makeup", description: "Aquí encontrarás información sobre técnicas y productos de maquillaje.", selectedDate: $selectedDate, selectedProducts: $selectedProducts)
    }
}

struct AppointmentView: View {
    var title: String
    var imageName: String
    var description: String
    @Binding var selectedDate: Date
    @Binding var selectedProducts: [Product]
    
    @State private var selectedTime = Date()
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
                Text(title)
                    .font(.largeTitle)
                    .padding()
                    .background(Color(UIColor.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Text(description)
                    .padding()
                
                DatePicker("Seleccione una fecha:", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                DatePicker("Seleccione una hora:", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                    .onChange(of: selectedTime) { newValue in
                        let calendar = Calendar.current
                        let hour = calendar.component(.hour, from: newValue)
                        if hour < 9 || hour > 19 {
                            let components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
                            let newComponents = DateComponents(
                                year: components.year,
                                month: components.month,
                                day: components.day,
                                hour: max(9, min(hour, 19))
                            )
                            selectedTime = calendar.date(from: newComponents) ?? selectedTime
                        }
                    }
                
                Text("Seleccione productos:")
                    .font(.headline)
                    .padding(.top)
                
                List(products) { product in
                    HStack {
                        Text(product.name)
                        Spacer()
                        Text("$\(product.price, specifier: "%.2f")")
                        Spacer()
                        Button(action: {
                            if let index = selectedProducts.firstIndex(where: { $0.id == product.id }) {
                                selectedProducts.remove(at: index)
                            } else {
                                selectedProducts.append(product)
                            }
                        }) {
                            Image(systemName: selectedProducts.contains(where: { $0.id == product.id }) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedProducts.contains(where: { $0.id == product.id }) ? .green : .gray)
                        }
                    }
                }
                .frame(height: 300)
                
                Text("Costo total: $\(totalCost, specifier: "%.2f")")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: PaymentView(selectedDate: $selectedDate, selectedTime: $selectedTime, selectedProducts: $selectedProducts, showAlert: $showAlert)) {
                    Text("Continuar a Pago")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(title)
        }
    }
    
    var totalCost: Double {
        selectedProducts.reduce(0) { $0 + $1.price }
    }
}

struct PaymentView: View {
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var selectedProducts: [Product]
    @Binding var showAlert: Bool
    
    @State private var selectedPaymentMethod: String = "Tarjeta de Crédito"
    
    var paymentMethods = ["Tarjeta de Crédito", "PayPal", "Efectivo"]
    
    var body: some View {
        VStack {
            Text("Seleccione una forma de pago")
                .font(.headline)
                .padding()
            
            Picker("Forma de Pago", selection: $selectedPaymentMethod) {
                ForEach(paymentMethods, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Text("Detalles de la cita:")
                .font(.headline)
                .padding()
            
            Text("Fecha: \(selectedDate, formatter: dateFormatter)")
                .padding()
            
            Text("Hora: \(selectedTime, formatter: timeFormatter)")
                .padding()
            
            Text("Productos Seleccionados:")
                .padding(.top)
            
            List(selectedProducts) { product in
                HStack {
                    Text(product.name)
                    Spacer()
                    Text("$\(product.price, specifier: "%.2f")")
                }
            }
            .frame(height: 200)
            
            Text("Costo total: $\(totalCost, specifier: "%.2f")")
                .font(.headline)
                .padding()
            
            Spacer()
            
            Button(action: {
                showAlert = true
            }) {
                Text("Pagar y Confirmar Cita")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Confirmación"),
                    message: Text("Su cita ha sido confirmada y el pago ha sido procesado correctamente."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.bottom)
        }
        .navigationTitle("Forma de Pago")
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var totalCost: Double {
        selectedProducts.reduce(0) { $0 + $1.price }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
}

let products = [
    Product(name: "Facial", price: 50.0),
    Product(name: "Corte de Cabello", price: 30.0),
    Product(name: "Masaje Corporal", price: 70.0),
    Product(name: "Maquillaje", price: 40.0)
]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
