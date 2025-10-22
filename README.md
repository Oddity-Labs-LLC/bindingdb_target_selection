# BindingDB Target Selection - RAR Related Targets

This repository contains a complete analysis pipeline for extracting ligand-target binding data for Retinoic Acid Receptor (RAR) related targets from BindingDB.

## Overview

This analysis extracts **9,661 ligand-target pairs** across **14 RAR-related targets** from the BindingDB MySQL database, including:
- Retinoic acid receptors (alpha, beta, gamma)
- RXR receptors and heterodimers
- RAR-related nuclear receptors
- Cellular retinoic acid-binding proteins

## Repository Contents

```
bindingdb_target_selection/
├── README.md                      # This file
├── requirements.txt               # Python dependencies
├── run_query.py                   # Main script to execute query
├── target_list.txt                # List of target names queried
├── queries/
│   └── all_rar_targets.sql       # SQL query for all RAR targets
└── results/
    └── all_rar_targets.tsv       # Query results (9,661 rows, 12 MB)
```

## Prerequisites

1. **MySQL Server** running locally with BindingDB database loaded
   - Database name: `bindingdb`
   - Default connection: `127.0.0.1:3306`
   - User: `root` (or configured user)

2. **Python 3.7+** with required packages

## Installation

```bash
# Install Python dependencies
pip install -r requirements.txt
```

## Usage

### Option 1: Run with Python Script (Recommended)

```bash
# Basic usage (uses defaults)
python run_query.py

# Custom configuration
python run_query.py \
    --host 127.0.0.1 \
    --user root \
    --password your_password \
    --database bindingdb \
    --sql queries/all_rar_targets.sql \
    --output results/all_rar_targets.tsv
```

### Option 2: Run with MySQL CLI

```bash
# Direct MySQL execution
mysql -h 127.0.0.1 -u root bindingdb < queries/all_rar_targets.sql > results/all_rar_targets.tsv

# Check results
wc -l results/all_rar_targets.tsv
# Should show: 9662 lines (9661 data rows + 1 header)
```

## Query Details

### Targets Included

The query searches for **27 target name variations**, with **14 targets found** in the database:

| Target | Rows | Unique Compounds |
|--------|------|------------------|
| Retinoic acid receptor RXR-alpha/gamma | 2,550 | 1,652 |
| Nuclear receptor subfamily 4 group A member 2/Retinoic acid receptor RXR-alpha | 1,944 | 1,377 |
| Retinoic acid receptor RXR-alpha/Vitamin D3 receptor | 1,207 | 791 |
| Retinoid X receptor gamma/retinoic acid receptor alpha | 950 | 564 |
| Retinoic acid receptor gamma | 623 | 437 |
| Retinoic acid receptor beta | 590 | 378 |
| Retinoic acid receptor alpha | 576 | 388 |
| Others | 1,221 | - |

See `target_list.txt` for the complete list of queried target names.

### Data Fields

The output TSV contains **26 columns**:

**Identifiers:**
- Reactant_Set_ID
- Compound_Monomer_ID
- Target_Polymer_ID

**Target Information:**
- Target (name)
- Target_Organism
- UniProt_ID
- PDB_IDs
- Target_Sequence

**Ligand Information:**
- SMILES
- InChI
- InChI_Key
- Compound_Name
- ChEMBL_ID
- Ligand_HET_ID

**Binding Data:**
- Ki_nM
- Kd_nM
- IC50_nM
- EC50_nM
- kon_M1s1
- koff_s1
- pH
- Temp_C

**Literature:**
- Article_DOI
- Article_PMID
- Article_Title
- Publication_Year

### Query Performance

- **Rows returned:** 9,661
- **Unique compounds:** 2,558
- **File size:** 12 MB
- **Execution time:** ~72 seconds (on local MySQL)

### Binding Data Statistics

- Ki values: 1,573 rows
- IC50 values: 2,884 rows
- Kd values: 1,316 rows
- EC50 values: 3,888 rows

## Results Summary

The query retrieves ligand-target pairs where at least one binding affinity measurement (Ki, Kd, IC50, or EC50) is available. Results are ordered by target name and reactant set ID for easy analysis.

## Modifying the Query

To add or remove targets:

1. Edit `queries/all_rar_targets.sql`
2. Update the `pn.name IN (...)` clause with desired target names
3. Re-run the query using either method above

Target names must match **exactly** as they appear in BindingDB's `poly_name` table.

## Troubleshooting

### MySQL Connection Error
```bash
# Verify MySQL is running
mysql -h 127.0.0.1 -u root -e "SELECT VERSION();"

# Check if bindingdb database exists
mysql -h 127.0.0.1 -u root -e "SHOW DATABASES LIKE 'bindingdb';"
```

### Empty Results
```bash
# Verify target names exist in database
mysql -h 127.0.0.1 -u root bindingdb -e "SELECT DISTINCT name FROM poly_name WHERE name LIKE '%retinoic%';"
```

## License

This query and tooling are provided as-is for research purposes. BindingDB data is subject to BindingDB's licensing terms.

## Citation

If you use this data, please cite:
- **BindingDB:** Gilson MK, et al. BindingDB in 2015: A public database for medicinal chemistry, computational chemistry and systems pharmacology. Nucleic Acids Res. 2016.

## Date

Analysis performed: October 22, 2025
BindingDB version: September 2024 release

