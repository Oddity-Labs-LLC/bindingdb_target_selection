-- Query for FASN (Fatty Acid Synthase) targets
SELECT 
    k.reactant_set_id as 'Reactant_Set_ID',
    pn.name as 'Target',
    p.source_organism as 'Target_Organism',
    m.smiles_string as 'SMILES',
    m.inchi as 'InChI',
    m.inchi_key as 'InChI_Key',
    m.monomerid as 'Compound_Monomer_ID',
    m.display_name as 'Compound_Name',
    m.chembl_id as 'ChEMBL_ID',
    ers.enzyme_polymerid as 'Target_Polymer_ID',
    k.ki as 'Ki_nM',
    k.kd as 'Kd_nM',
    k.ic50 as 'IC50_nM',
    k.ec50 as 'EC50_nM',
    k.kon as 'kon_M1s1',
    k.koff as 'koff_s1',
    k.ph as 'pH',
    k.temp as 'Temp_C',
    a.doi as 'Article_DOI',
    a.pmid as 'Article_PMID',
    a.title as 'Article_Title',
    a.year as 'Publication_Year',
    m.het_pdb as 'Ligand_HET_ID',
    p.unpid1 as 'UniProt_ID',
    p.pdb_ids as 'PDB_IDs',
    p.sequence as 'Target_Sequence'
FROM ki_result k
INNER JOIN enzyme_reactant_set ers ON k.reactant_set_id = ers.reactant_set_id
INNER JOIN poly_name pn ON ers.enzyme_polymerid = pn.polymerid
    AND pn.name IN (
        'fasn',
        'fasn/her2',
        'fatty acid synthase (fasn)',
        'fatty acid synthase',
        'fatty acid synthase [2202-2509]'
    )
LEFT JOIN polymer p ON ers.enzyme_polymerid = p.polymerid
LEFT JOIN monomer m ON ers.inhibitor_monomerid = m.monomerid
LEFT JOIN entry e ON k.entryid = e.entryid
LEFT JOIN entry_citation ec ON e.entryid = ec.entryid
LEFT JOIN article a ON ec.articleid = a.articleid
WHERE (k.ki IS NOT NULL OR k.kd IS NOT NULL OR k.ic50 IS NOT NULL OR k.ec50 IS NOT NULL)
ORDER BY pn.name, k.reactant_set_id;

