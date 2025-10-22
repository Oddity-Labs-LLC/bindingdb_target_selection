#!/usr/bin/env python3
"""
BindingDB Target Selection Query Runner

This script executes the RAR-related targets query against a local MySQL BindingDB instance
and exports results to a TSV file.

Requirements:
    - MySQL server running locally with BindingDB loaded
    - mysql-connector-python package installed
    
Usage:
    python run_query.py [--output results/all_rar_targets.tsv] [--host 127.0.0.1] [--user root] [--password]
"""

import argparse
import mysql.connector
import csv
import sys
from pathlib import Path


def read_sql_file(sql_file):
    """Read SQL query from file."""
    with open(sql_file, 'r') as f:
        return f.read()


def execute_query(host, user, password, database, sql_query, output_file):
    """Execute SQL query and export to TSV."""
    
    print(f"Connecting to MySQL at {host}...")
    
    try:
        # Connect to MySQL
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
        cursor = conn.cursor()
        
        print("Executing query...")
        cursor.execute(sql_query)
        
        # Get column names
        columns = [desc[0] for desc in cursor.description]
        
        print(f"Writing results to {output_file}...")
        
        # Create output directory if needed
        Path(output_file).parent.mkdir(parents=True, exist_ok=True)
        
        # Write to TSV
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f, delimiter='\t')
            
            # Write header
            writer.writerow(columns)
            
            # Write data rows
            row_count = 0
            for row in cursor:
                writer.writerow(row)
                row_count += 1
                
                if row_count % 1000 == 0:
                    print(f"  Processed {row_count} rows...")
        
        print(f"\n✅ SUCCESS!")
        print(f"Total rows exported: {row_count}")
        print(f"Output file: {output_file}")
        
        cursor.close()
        conn.close()
        
        return row_count
        
    except mysql.connector.Error as e:
        print(f"\n❌ MySQL Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Execute BindingDB RAR targets query and export to TSV'
    )
    parser.add_argument(
        '--sql',
        default='queries/all_rar_targets.sql',
        help='Path to SQL query file (default: queries/all_rar_targets.sql)'
    )
    parser.add_argument(
        '--output',
        default='results/all_rar_targets.tsv',
        help='Output TSV file path (default: results/all_rar_targets.tsv)'
    )
    parser.add_argument(
        '--host',
        default='127.0.0.1',
        help='MySQL host (default: 127.0.0.1)'
    )
    parser.add_argument(
        '--user',
        default='root',
        help='MySQL user (default: root)'
    )
    parser.add_argument(
        '--password',
        default='',
        help='MySQL password (default: empty)'
    )
    parser.add_argument(
        '--database',
        default='bindingdb',
        help='MySQL database name (default: bindingdb)'
    )
    
    args = parser.parse_args()
    
    # Read SQL query
    print(f"Reading SQL query from {args.sql}...")
    sql_query = read_sql_file(args.sql)
    
    # Execute and export
    row_count = execute_query(
        args.host,
        args.user,
        args.password,
        args.database,
        sql_query,
        args.output
    )
    
    # Print summary stats
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")
    print(f"Query file:     {args.sql}")
    print(f"Output file:    {args.output}")
    print(f"Rows exported:  {row_count:,}")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()

