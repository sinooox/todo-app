import psycopg2


#функция подключения к базе данных
def connect_to_db():
    conn_params = {"host":"localhost",
                   "port": 5432,
                   "database": "tododb",
                   "user": "postgres",
                   "password": "qwerty"}
    try:
            connection = psycopg2.connect(**conn_params)
            cursor = connection.cursor()
            print("Connected to the database successfully!")

    except Exception as error:
        print("Error while fetching data:", error)

    return connection, cursor