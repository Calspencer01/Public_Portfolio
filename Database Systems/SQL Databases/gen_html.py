import mysql.connector
import sys

def generate_html(query_2_file, query_6_file):
    # connection = mysql.connector.connect(user='root', password='123456', host='localhost')
    # cursor = connection.cursor()
    # databaseName = "SenatorVotes"

    query_2_sql = open(query_2_file, 'r')
    query_2 = query_2_sql.read()
    query_2_sql.close()
    print(query_2)


    # # Use DB
    # try:
    #     cursor.execute("USE {}".format(databaseName))
    # except mysql.connector.Error as error_descriptor:
    #     print("Failed using database: {}".format(error_descriptor))
    #     exit(1)

    # try:
    #     cursor.execute(, multi=False)
    # except mysql.connector.Error as error_descriptor:
    #     print("Query failed: {}".format(error_descriptor))
    #     exit(1)


    # connection.commit()
    # cursor.close()
    # cursor = connection.cursor()

if len(sys.argv) < 2: # python script, 
    print("Missing argument.")
    print("Usage: gen_html.py <query_2.sql> <query_6.sql>")
    sys.exit(1)
else:
    query_2_file = sys.argv[1]
    query_6_file = sys.argv[2]
    print(query_2_file)
    generate_html(query_2_file, query_6_file)