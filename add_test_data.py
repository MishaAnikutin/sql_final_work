import os
import csv
import psycopg2


def read_series(path: str):
    """Возвращает поток данных из csv файла"""

    if not os.path.exists(path):
        raise ValueError(f"Файла по пути {path} не существует")
        
    with open(path) as f:
        yield from csv.DictReader(f)


@contextmanager
def get_connection():
    """Менеджер контекста соединений в Postgres"""
    
    try:
        conn = psycopg2.connect(database="local", user="postgres", password="postgres", host="localhost", port="5432")
    
        yield conn
    finally:
        conn.close()


INSERT_INTO_SERIES_STMT = """
WITH freq AS (
    SELECT id FROM data_frequency WHERE name = %s
)
INSERT INTO series (name, freq_id) 
SELECT %s, id 
FROM freq
RETURNING id
"""

INSERT_INTO_SERIES_VALUES_STMT = """
INSERT INTO 
    series_values (series_id, date, value) 
VALUES (%s, %s, %s)
"""


def add_series(cur, name: str, data_freq: str, data_path: str):
    # Получаем поток данных из файла
    stream = read_series(data_path)

    # создаем временной ряд
    cur.execute(INSERT_INTO_SERIES_STMT, (data_freq, name))

    # получаем id загруженного ряда
    series_id = cur.fetchone()[0]

    # загружаем все данные из файла
    for row in stream:
        cur.execute(INSERT_INTO_SERIES_VALUES_STMT, (series_id, row['date'], row['value']))

    return series_id


if __name__ == '__main__':
    series = (
        {'name': 'Цены на нефть марки Urals',                  'data_freq': 'MS', 'data_path': './urals.csv'},
        {'name': 'Курс доллара к рублю',                       'data_freq': 'MS', 'data_path': './dollar.csv'},
        {'name': 'ИПЦ, в % к соотв. периоду предыдущего года', 'data_freq': 'MS', 'data_path': './ipc.csv'},
    )
    
    with get_connection() as connection:
        with connection.cursor() as cur:
            for s in series:
                print(f'Добавляем {s["name"]}: ...')
                
                id_ = add_series(cur, name=s['name'], data_freq=s['data_freq'], data_path=s['data_path'])
                print(f'Добавили, его ID: {id_}')
        
        connection.commit()
