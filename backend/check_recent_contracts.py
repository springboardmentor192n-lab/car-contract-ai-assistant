
import sqlite3
import pandas as pd

def check_contracts():
    conn = sqlite3.connect("sql_app.db")
    
    print("--- Recent Contracts ---")
    df = pd.read_sql_query("SELECT id, filename, status, upload_date FROM contracts ORDER BY id DESC LIMIT 10", conn)
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', 1000)
    print(df.to_string())
    
    # print("\n--- Recent SLAs ---")
    # df_sla = pd.read_sql_query("SELECT id, contract_id, risk_level FROM extracted_slas ORDER BY id DESC LIMIT 5", conn)
    # print(df_sla)
    
    conn.close()

if __name__ == "__main__":
    check_contracts()
