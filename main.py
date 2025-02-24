import psycopg2

def get_data():
    conn_params = {"host":"localhost",
                   "port": 5432,
                   "database": "tododb",
                   "user": "postgres",
                   "password": "qwerty"}

    try:
        connection = psycopg2.connect(**conn_params)
        cursor = connection.cursor()
        print("Connected to the database successfully!")

        query = "SELECT * FROM notes;"
        cursor.execute(query)

        rows = cursor.fetchall()

        for row in rows:
            print(row)

    except Exception as error:
        print("Error while fetching data:", error)

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()
        print("PostgreSQL connection closed.")

if __name__ == "__main__":
    get_data()
