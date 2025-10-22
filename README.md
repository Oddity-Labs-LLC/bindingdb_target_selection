# BindingDB Target Selection

This repository contains a complete analysis pipeline for extracting ligand-target binding data from BindingDB for specific therapeutic targets of interest. The pipeline queries a local MySQL BindingDB instance and exports comprehensive bioactivity data to TSV files.

## Overview

This analysis extracts **32,958+ ligand-target binding records** across **9 target groups** from the BindingDB MySQL database (October 2025 release). All results have been uploaded to S3 for downstream analysis.

### Target Groups Analyzed

| Target Group | Query File | Rows | File Size | Key Targets |
|--------------|-----------|------|-----------|-------------|
| **FASN** | `fasn.sql` | 9,821 | 24 MB | Fatty acid synthase variants |
| **APJ** | `apj.sql` | 14,059 | 16 MB | Apelin receptor |
| **RAR** | `all_rar_targets.sql` | 9,661 | 12 MB | Retinoic acid receptors |
| **NLRP3** | `nlrp3.sql` | 2,824 | 3.8 MB | NLRP3 inflammasome |
| **Adenosine A2A** | `adenosine_a2a.sql` | 2,886 | 2.8 MB | Adenosine A2A receptor |
| **Interleukin-1β** | `interleukin_1_beta.sql` | 1,606 | 1.6 MB | IL-1β, IL-1β converting enzyme |
| **CD38** | `cd38.sql` | 1,584 | 1.5 MB | CD38, cyclic ADP-ribose hydrolase |
| **RAGE** | `rage.sql` | 178 | 153 KB | Receptor for advanced glycation end products |
| **Interleukin-17A** | `interleukin_17a.sql` | 0 | - | IL-17A/IL-17RA complexes |

**Total:** 42,619 records across 9 target groups

## Repository Contents

```
bindingdb_target_selection/
├── README.md                      # This file
├── requirements.txt               # Python dependencies
├── run_query.py                   # Main script to execute queries
├── queries/                       # SQL query files
│   ├── adenosine_a2a.sql         # Adenosine A2A receptor variants
│   ├── all_rar_targets.sql       # All RAR-related targets
│   ├── apj.sql                   # Apelin receptor (APJ)
│   ├── cd38.sql                  # CD38 and related targets
│   ├── fasn.sql                  # Fatty acid synthase variants
│   ├── interleukin_1_beta.sql    # IL-1β targets
│   ├── interleukin_17a.sql       # IL-17A targets
│   ├── nlrp3.sql                 # NLRP3 inflammasome
│   └── rage.sql                  # RAGE receptor
└── results/                       # Query results (TSV files)
    ├── adenosine_a2a.tsv
    ├── all_rar_targets.tsv
    ├── apj.tsv
    ├── cd38.tsv
    ├── fasn.tsv
    ├── interleukin_1_beta.tsv
    ├── interleukin_17a.tsv
    ├── nlrp3.tsv
    └── rage.tsv
```

## S3 Data Location

All results have been uploaded to AWS S3:
```
s3://olx-dev-olplat-101-druglandscapedb-data/bindingdb/specific_targets/
```

To download results from S3:
```bash
aws s3 sync s3://olx-dev-olplat-101-druglandscapedb-data/bindingdb/specific_targets/ results/
```

## Prerequisites

### 1. MySQL Server with BindingDB

You need a local MySQL instance with the BindingDB database loaded.

#### Downloading BindingDB

1. Visit [BindingDB Downloads](https://www.bindingdb.org/bind/chemsearch/marvin/SDFdownload.jsp)
2. Download: **BDB-mySQL_All_202510_dmp.zip** (267.26 MB)
   - Updated: 2025-09-30
   - MD5: (verify on download page)

#### Installing BindingDB in MySQL

```bash
# 1. Extract the download
unzip BDB-mySQL_All_202510_dmp.zip

# 2. Start MySQL server (if not running)
# On macOS:
brew services start mysql
# On Linux:
sudo systemctl start mysql

# 3. Create the database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS bindingdb;"

# 4. Import the dump file
# This will take 10-30 minutes depending on your system
mysql -u root -p bindingdb < BDB-mySQL_All_202510_dmp.sql

# 5. Verify installation
mysql -u root -p bindingdb -e "SELECT COUNT(*) FROM ki_result;"
# Should return a large number (>2 million rows)

# 6. Check tables exist
mysql -u root -p bindingdb -e "SHOW TABLES;"
# Should show: article, entry, enzyme_reactant_set, ki_result, monomer, poly_name, polymer, etc.
```

#### MySQL Configuration Tips

For optimal performance with BindingDB queries:

```bash
# Edit MySQL configuration (my.cnf or my.ini)
# On macOS: /usr/local/etc/my.cnf
# On Linux: /etc/mysql/my.cnf

[mysqld]
innodb_buffer_pool_size = 4G          # Use 50-70% of available RAM
max_allowed_packet = 256M             # Handle large queries
innodb_log_file_size = 512M           # Improve write performance
```

After editing config:
```bash
# Restart MySQL
brew services restart mysql  # macOS
# or
sudo systemctl restart mysql  # Linux
```

### 2. Python Environment

**Python 3.7+** with dependencies:

```bash
# Install dependencies
pip install -r requirements.txt

# Or manually:
pip install mysql-connector-python
```

## Usage

### Running Queries

Each target group has a dedicated SQL query file. Use the Python script to execute any query:

```bash
# Run a specific target query
python run_query.py \
    --sql queries/nlrp3.sql \
    --output results/nlrp3.tsv

# Run all queries (bash loop)
for query in queries/*.sql; do
    target=$(basename "$query" .sql)
    python run_query.py \
        --sql "$query" \
        --output "results/${target}.tsv"
done
```

### Command-Line Options

```bash
python run_query.py [OPTIONS]

Options:
  --sql PATH             SQL query file (default: queries/all_rar_targets.sql)
  --output PATH          Output TSV file (default: results/all_rar_targets.tsv)
  --host HOST           MySQL host (default: 127.0.0.1)
  --user USER           MySQL user (default: root)
  --password PASS       MySQL password (default: empty)
  --database DB         MySQL database (default: bindingdb)
```

### Example: Custom Query

```bash
# Query with custom MySQL settings
python run_query.py \
    --host localhost \
    --user bindingdb_user \
    --password mypassword \
    --database bindingdb \
    --sql queries/fasn.sql \
    --output results/fasn_custom.tsv
```

## Data Schema

### Output TSV Format

Each results file contains **26 columns**:

#### Identifiers
- `Reactant_Set_ID` - Unique ID for ligand-target pair
- `Compound_Monomer_ID` - BindingDB compound ID
- `Target_Polymer_ID` - BindingDB target protein ID

#### Target Information
- `Target` - Target protein name
- `Target_Organism` - Source organism
- `UniProt_ID` - UniProt accession
- `PDB_IDs` - PDB structure IDs (if available)
- `Target_Sequence` - Protein sequence

#### Ligand Information
- `SMILES` - SMILES structure notation
- `InChI` - InChI identifier
- `InChI_Key` - InChI hash key
- `Compound_Name` - Compound name/description
- `ChEMBL_ID` - ChEMBL identifier (if available)
- `Ligand_HET_ID` - PDB ligand code

#### Binding Data
- `Ki_nM` - Inhibition constant (nM)
- `Kd_nM` - Dissociation constant (nM)
- `IC50_nM` - Half-maximal inhibitory concentration (nM)
- `EC50_nM` - Half-maximal effective concentration (nM)
- `kon_M1s1` - Association rate constant (M⁻¹s⁻¹)
- `koff_s1` - Dissociation rate constant (s⁻¹)
- `pH` - Assay pH
- `Temp_C` - Assay temperature (°C)

#### Literature
- `Article_DOI` - Publication DOI
- `Article_PMID` - PubMed ID
- `Article_Title` - Article title
- `Publication_Year` - Year published

### Query Structure

All queries follow this template:

```sql
SELECT 
    k.reactant_set_id as 'Reactant_Set_ID',
    pn.name as 'Target',
    -- ... (26 columns total)
FROM ki_result k
INNER JOIN enzyme_reactant_set ers ON k.reactant_set_id = ers.reactant_set_id
INNER JOIN poly_name pn ON ers.enzyme_polymerid = pn.polymerid
    AND pn.name IN (
        'target name 1',
        'target name 2',
        -- ... variant names
    )
LEFT JOIN polymer p ON ers.enzyme_polymerid = p.polymerid
LEFT JOIN monomer m ON ers.inhibitor_monomerid = m.monomerid
LEFT JOIN entry e ON k.entryid = e.entryid
LEFT JOIN entry_citation ec ON e.entryid = ec.entryid
LEFT JOIN article a ON ec.articleid = a.articleid
WHERE (k.ki IS NOT NULL OR k.kd IS NOT NULL OR k.ic50 IS NOT NULL OR k.ec50 IS NOT NULL)
ORDER BY pn.name, k.reactant_set_id;
```

## Creating New Queries

To extract data for a new target:

### 1. Find Target Names in BindingDB

```bash
# Search for target names (case-insensitive pattern matching)
mysql -u root -p bindingdb -e "
SELECT DISTINCT name 
FROM poly_name 
WHERE name LIKE '%YOUR_TARGET%'
ORDER BY name;
"
```

### 2. Create Query File

Copy an existing query template:

```bash
cp queries/nlrp3.sql queries/my_new_target.sql
```

Edit the `pn.name IN (...)` section with your target names.

### 3. Run Query

```bash
python run_query.py \
    --sql queries/my_new_target.sql \
    --output results/my_new_target.tsv
```

### 4. Upload to S3 (Optional)

```bash
aws s3 cp results/my_new_target.tsv \
    s3://olx-dev-olplat-101-druglandscapedb-data/bindingdb/specific_targets/
```

## Target Details

### FASN (Fatty Acid Synthase)
Target name variants:
- `fasn`
- `fasn/her2`
- `fatty acid synthase (fasn)`
- `fatty acid synthase`
- `fatty acid synthase [2202-2509]`

**Therapeutic relevance:** Cancer metabolism, obesity

### NLRP3 (NOD-like Receptor Protein 3)
Target name variants:
- `nlrp3`

**Therapeutic relevance:** Inflammation, autoinflammatory diseases

### Adenosine A2A Receptor
Target name variants:
- `adenosine a2a receptor (a2a)`
- `adenosine a2a receptor`
- `adenosine receptor a2a`

**Therapeutic relevance:** Parkinson's disease, cancer immunotherapy

### CD38
Target name variants:
- `cd38`
- `lymphocyte differentiation antigen cd38`
- `cyclic adp-ribose hydrolase 1`

**Therapeutic relevance:** Multiple myeloma, immune regulation

### APJ (Apelin Receptor)
Target name variants:
- `apj`
- `Apelin receptor`

**Therapeutic relevance:** Cardiovascular disease, diabetes

### Interleukin-1 Beta
Target name variants:
- `interleukin-1 beta`
- `interleukin-1 beta-converting enzyme`

**Therapeutic relevance:** Inflammation, autoinflammatory diseases

### RAGE (Receptor for Advanced Glycation End Products)
Target name variants:
- `rage`

**Therapeutic relevance:** Diabetes complications, Alzheimer's disease

## Troubleshooting

### MySQL Connection Errors

```bash
# Test MySQL connection
mysql -h 127.0.0.1 -u root -p -e "SELECT VERSION();"

# Verify BindingDB database exists
mysql -h 127.0.0.1 -u root -p -e "SHOW DATABASES LIKE 'bindingdb';"

# Check table accessibility
mysql -h 127.0.0.1 -u root -p bindingdb -e "SHOW TABLES;"
```

### Empty or Zero Results

Some target names may not exist in BindingDB (e.g., `interleukin_17a.sql` returned 0 rows). This means:
- Target name spelling doesn't match BindingDB exactly
- Target has no bioactivity data in BindingDB
- Target uses a different naming convention

**Solution:** Search for alternative names:
```bash
mysql -u root -p bindingdb -e "
SELECT DISTINCT name 
FROM poly_name 
WHERE name LIKE '%interleukin%17%'
ORDER BY name;
"
```

### Slow Queries

- Ensure MySQL has adequate RAM allocation (see Configuration Tips)
- Verify indexes exist: `SHOW INDEXES FROM ki_result;`
- Consider filtering by publication year or organism if dataset is too large

### Import Errors

If MySQL import fails:
```bash
# Check disk space
df -h

# Verify SQL dump file integrity
md5sum BDB-mySQL_All_202510_dmp.sql

# Try with error logging
mysql -u root -p bindingdb < BDB-mySQL_All_202510_dmp.sql 2> import_errors.log
```

## Performance Notes

- **Query execution time:** 10-120 seconds per query (depending on result size)
- **Import time:** 15-30 minutes for full BindingDB MySQL dump
- **Disk space required:** ~5-10 GB for BindingDB MySQL database
- **Memory recommended:** 8+ GB RAM for optimal query performance

## License

This query tooling is provided as-is for research purposes. BindingDB data is subject to [BindingDB's licensing terms](https://www.bindingdb.org/bind/info.jsp).

## Citation

If you use this data in publications, please cite:

**BindingDB:**
> Gilson MK, Liu T, Baitaluk M, Nicola G, Hwang L, Chong J. BindingDB in 2015: A public database for medicinal chemistry, computational chemistry and systems pharmacology. *Nucleic Acids Res.* 2016 Jan 4;44(D1):D1045-53. doi: 10.1093/nar/gkv1072

## Contact & Contributions

For questions about specific targets or to request new queries, please open an issue or contact the repository maintainer.

---

**Last Updated:** October 22, 2025  
**BindingDB Version:** October 2025 (202510) MySQL dump
