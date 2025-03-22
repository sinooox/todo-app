import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var pageManager: PageManager
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case username, password
    }

    var body: some View {
        ZStack {
            Color(red: 0.52, green: 0.39, blue: 0.58)
                .ignoresSafeArea()

            VStack {
                Text("Регистрация")
                    .font(.custom("PoiretOne-Regular", size: 42))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                    .foregroundColor(Color(red: 0.47, green: 0.33, blue: 0.53))

                VStack(spacing: 20) {
                    TextField(
                        "", text: $username,
                        prompt: Text("Логин")
                            .foregroundColor(.gray)
                            .font(.custom("PoiretOne-Regular", size: 16))
                    )
                    .accentColor(.gray)
                    .foregroundColor(.black)
                    .font(.custom("PoiretOne-Regular", size: 18))
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    SecureField(
                        "", text: $password,
                        prompt: Text("Пароль")
                            .foregroundColor(.gray)
                            .font(.custom("PoiretOne-Regular", size: 16))
                    )
                    .accentColor(.gray)
                    .foregroundColor(.black)
                    .font(.custom("PoiretOne-Regular", size: 18))
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 20)
                Button(action: {
                    if username.trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                        || password.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    {
                        alertMessage =
                            "Нельзя зарегистрироваться с пустыми данными"
                        showAlert = true
                        return
                    }
                    if password.count < 8 {
                        alertMessage =
                            "Пароль должен содержать не менее 8 символов"
                        showAlert = true
                        return
                    }
                    registerUser(login: username, password: password) {
                        result in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                alertMessage =
                                    "Пользователь зарегистрирован\nПеренаправление на страницу\nавторизации"
                                showAlert = true
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                alertMessage = "\(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }
                }) {
                    Text("Зарегистрироваться")
                        .font(.custom("PoiretOne-Regular", size: 24))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(red: 0.52, green: 0.39, blue: 0.58))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .padding(.top, 20)
                .frame(maxWidth: 400)
                Button(action: {
                    pageManager.page = .LoginView
                }) {
                    Text("Вход")
                        .font(.custom("PoiretOne-Regular", size: 24))
                        .padding()
                        .foregroundColor(
                            Color(red: 0.47, green: 0.33, blue: 0.53)
                        )
                        .background(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .padding(.top, 5)
                .frame(maxWidth: 400)
            }
            .padding(20)
            .background(Color(red: 0.9, green: 0.84, blue: 0.93))
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(maxWidth: 310, maxHeight: 70, alignment: .center)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Статус регистрации"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("ОК")) {
                        if alertMessage
                            == "Пользователь зарегистрирован\nПеренаправление на страницу\nавторизации"
                        {
                            pageManager.page = .LoginView
                        }
                    }
                )
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
