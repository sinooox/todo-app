import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.67, green: 0.61, blue: 0.69)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Text("To-Do App")
                        .font(Font.custom("Poppins", size: 24))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "person.circle")
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Твои задачи")
                        .font(Font.custom("Poppins", size: 18))
                        .foregroundColor(Color(red: 0.47, green: 0.33, blue: 0.53))
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.47, green: 0.33, blue: 0.53))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    TaskCard(taskTitle: "Задача 1")
                    TaskCard(taskTitle: "Задача 2")
                    TaskCard(taskTitle: "Задача 3")
                }
                
                Spacer()
            }
        }
    }
}

struct TaskCard: View {
    let taskTitle: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(Color.purple, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                Circle()
                    .fill(Color.purple)
                    .frame(width: 10, height: 10)
            }
            
            Text(taskTitle)
                .font(Font.custom("Poppins", size: 18))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "trash")
                    .foregroundColor(Color.purple)
            }
            .padding(.bottom, 18)
        }
        .padding()
        .frame(width: 314, height: 60)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("ДД.ММ.ГГ.")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                        .padding(.trailing, 12)
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
