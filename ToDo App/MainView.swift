import SwiftUI

struct MainView: View {
    @EnvironmentObject var pageManager: PageManager
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var newTaskNote: String = ""
    @State private var isAddingTask: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            Color(red: 0.67, green: 0.61, blue: 0.69)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Text("ToDo App")
                        .font(.custom("PoiretOne-Regular", size: 32))
                        .foregroundColor(.white)
                        .shadow(
                            color: Color.black.opacity(0.25), radius: 4, x: 0,
                            y: 4)
                    Spacer()
                    Button(action: {
                        pageManager.page = .LoginView
                    }) {
                        HStack {
                            Image(systemName: "person.circle").foregroundColor(
                                Color(red: 0.47, green: 0.33, blue: 0.53))
                            Image(systemName: "arrow.right").foregroundColor(
                                Color(red: 0.47, green: 0.33, blue: 0.53))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal)
                HStack {
                    Text("Твои задачи")
                        .font(.custom("PoiretOne-Regular", size: 26))
                        .foregroundColor(
                            Color(red: 0.47, green: 0.33, blue: 0.53))
                    Spacer()
                    Button(action: {
                        if let credentials = pageManager.loginCredentials {
                            taskViewModel.isManualRefresh = true
                            taskViewModel.fetchTasks(
                                login: credentials.username,
                                password: credentials.password)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(
                                Color(red: 0.47, green: 0.33, blue: 0.53))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
                .padding(.horizontal)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(taskViewModel.tasks) { task in
                            TaskCard(task: task) { taskId in
                                if let credentials = pageManager
                                    .loginCredentials
                                {
                                    taskViewModel.deleteTask(
                                        noteID: taskId,
                                        login: credentials.username,
                                        password: credentials.password)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
                Button(action: {
                    isAddingTask.toggle()
                    if isAddingTask {
                        isTextFieldFocused = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.custom("PoiretOne-Regular", size: 24))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color(red: 0.47, green: 0.33, blue: 0.53))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding()
                if isAddingTask {
                    VStack(spacing: 16) {
                        TextField(
                            "", text: $newTaskNote,
                            prompt: Text("Новая задача").foregroundColor(.gray)
                                .font(.custom("PoiretOne-Regular", size: 20))
                        )
                        .foregroundColor(.black)
                        .font(.custom("PoiretOne-Regular", size: 20))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            addNewTask()
                        }
                        Button(action: {
                            addNewTask()
                        }) {
                            Text("Добавить задачу")
                                .font(.custom("PoiretOne-Regular", size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Color(red: 0.47, green: 0.33, blue: 0.53)
                                )
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            if let credentials = pageManager.loginCredentials {
                taskViewModel.fetchTasks(
                    login: credentials.username, password: credentials.password)
            }
        }
        .alert(item: $taskViewModel.alertType) { alert in
            switch alert {
            case .error(let message):
                return Alert(
                    title: Text("Ошибка"), message: Text(message),
                    dismissButton: .default(Text("ОК")))
            case .deleteSuccess:
                return Alert(
                    title: Text("Успех"),
                    message: Text("Задача успешно удалена"),
                    dismissButton: .default(Text("ОК")))
            case .addSuccess:
                return Alert(
                    title: Text("Успех"),
                    message: Text("Задача успешно добавлена"),
                    dismissButton: .default(Text("ОК")))
            case .fetchSuccess:
                return Alert(
                    title: Text("Успех"),
                    message: Text("Список задач обновлен"),
                    dismissButton: .default(Text("ОК"))
                )
            }
        }
    }

    private func addNewTask() {
        if newTaskNote.isEmpty {
            taskViewModel.alertType = .error("Нельзя создать пустую задачу")
            return
        }
        if let credentials = pageManager.loginCredentials {
            taskViewModel.addTask(
                note: newTaskNote, login: credentials.username,
                password: credentials.password)
        }
        isAddingTask = false
        newTaskNote = ""
        isTextFieldFocused = false
    }
}

struct TaskCard: View {
    let task: Task
    let onDelete: (Int) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .stroke(
                        Color(red: 0.47, green: 0.33, blue: 0.53), lineWidth: 2
                    )
                    .frame(width: 24, height: 24)
                Circle()
                    .fill(Color(red: 0.47, green: 0.33, blue: 0.53))
                    .frame(width: 10, height: 10)
            }
            Text(task.note)
                .font(.custom("PoiretOne-Regular", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(action: {
                onDelete(task.id)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(Color(red: 0.47, green: 0.33, blue: 0.53))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
