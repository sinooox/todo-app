from connect import connect_to_db
from hash_password import get_hashed_password, verify_password
from insert import insert_data

conn, cursor = connect_to_db()


#основная функция для проверки зарегестрирован ли пользователь
def check_user():
    username = input("Введите имя пользователя: ")

    conn, cursor = connect_to_db()
    query = "SELECT password, salt FROM users WHERE username = %s;"
    cursor.execute(query, (username,))
    result = cursor.fetchone()

    if result is None:
        print("Пользователь не найден.")
        answer = input("Хотите зарегистрироваться? (да/нет): ")
        if answer.lower() == "да":
            username, hashed_password, salt = register_user()
            insert_data(username, hashed_password, salt)
        else:
            return
    else:
        password = input("Введите пароль: ")
        stored_hash, stored_salt = result
        if verify_password(stored_hash, stored_salt, password):
            print("Аутентификация успешна!")
            return True
        else:
            print("Неверный пароль.")
            return False


#функция регистрации пользователя
def register_user():
    username = input("Введите имя пользователя: ")
    password = input("Введите пароль: ")
    
    hashed_password, salt = get_hashed_password(password)
    return username, hashed_password, salt



if __name__ == "__main__":
     check_user()