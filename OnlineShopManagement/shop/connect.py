import cx_Oracle
from shop.config import username, password, dsn, encoding

connection = None


def connect_to_oracle():
    global connection
    print('Connecting to Oracle...')
    try:
        connection = cx_Oracle.connect(
            username,
            password,
            dsn,
            encoding=encoding)
        print(f'Successfully connected to {username}! Oracle Database version: ', connection.version)
    except cx_Oracle.Error as error:
        print('Error: ', error)


connect_to_oracle()
