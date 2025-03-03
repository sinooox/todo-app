from connect import connect_to_db


conn, cursor = connect_to_db()


#функция для регистрации пользователя в базе данных
def insert_data(username, hashed_password, salt):
        query = """INSERT INTO users (username, password, salt) VALUES (%s, %s, %s);"""
        data_to_insert = (username, hashed_password, salt)
        print(username, '\n', hashed_password, '\n', salt)
        cursor.execute(query, data_to_insert)

        conn.commit()

        print("insert data succefuly")

