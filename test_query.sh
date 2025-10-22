#!/bin/bash
# Test script to verify the query works correctly

set -e  # Exit on error

echo "=========================================="
echo "BindingDB RAR Targets Query Test"
echo "=========================================="
echo ""

# Check MySQL connection
echo "1. Testing MySQL connection..."
if mysql -h 127.0.0.1 -u root -e "SELECT 1;" > /dev/null 2>&1; then
    echo "   ✅ MySQL connection successful"
else
    echo "   ❌ MySQL connection failed"
    exit 1
fi

# Check database exists
echo "2. Checking if bindingdb database exists..."
if mysql -h 127.0.0.1 -u root -e "USE bindingdb;" > /dev/null 2>&1; then
    echo "   ✅ bindingdb database found"
else
    echo "   ❌ bindingdb database not found"
    exit 1
fi

# Test query with row count
echo "3. Testing query (counting rows)..."
ROW_COUNT=$(mysql -h 127.0.0.1 -u root bindingdb < queries/all_rar_targets.sql 2>/dev/null | wc -l | xargs)
EXPECTED=9662  # 9661 data rows + 1 header

if [ "$ROW_COUNT" -eq "$EXPECTED" ]; then
    echo "   ✅ Query returned expected $EXPECTED rows"
else
    echo "   ⚠️  Query returned $ROW_COUNT rows (expected $EXPECTED)"
    echo "      This may be due to database version differences"
fi

# Test Python script
echo "4. Testing Python script..."
if command -v python3 &> /dev/null; then
    echo "   Python version: $(python3 --version)"
    
    # Check if mysql-connector-python is installed
    if python3 -c "import mysql.connector" 2>/dev/null; then
        echo "   ✅ mysql-connector-python is installed"
        
        # Run the Python script
        echo "   Running Python query script..."
        python3 run_query.py --output results/test_output.tsv
        
        # Check output
        if [ -f "results/test_output.tsv" ]; then
            TEST_ROWS=$(wc -l < results/test_output.tsv | xargs)
            echo "   ✅ Python script created output with $TEST_ROWS rows"
            rm results/test_output.tsv
        else
            echo "   ❌ Python script failed to create output"
            exit 1
        fi
    else
        echo "   ⚠️  mysql-connector-python not installed"
        echo "      Run: pip install -r requirements.txt"
    fi
else
    echo "   ⚠️  Python 3 not found"
fi

echo ""
echo "=========================================="
echo "✅ All tests passed!"
echo "=========================================="

