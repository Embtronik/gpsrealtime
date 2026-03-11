import mysql.connector
from mysql.connector import Error

mydb = None  # Inicializar la variable

try:
    # Establecer la conexión
    mydb = mysql.connector.connect(
      host="localhost",  # Solo la IP, sin el puerto
      port=3306,  # El puerto se especifica aparte
      user="root",
      passwd="",  # Asegúrate de que la contraseña sea correcta
      database="mydb"  # Cambia a tu base de datos si es diferente
    )

    if mydb.is_connected():
        print("Conexión exitosa a la base de datos")

        # Crear un cursor
        mycursor = mydb.cursor()

        # Ejecutar una consulta simple para verificar la conexión
        mycursor.execute("SELECT DATABASE();")

        # Obtener el resultado de la consulta
        db_name = mycursor.fetchone()
        print("Base de datos conectada:", db_name)

except Error as e:
    print("Error al conectar a MySQL", e)

finally:
    if mydb is not None and mydb.is_connected():
        mycursor.close()
        mydb.close()
        print("Conexión MySQL cerrada")
