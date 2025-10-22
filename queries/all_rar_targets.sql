-- Query for all RAR-related targets (9661 rows)
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
        'Retinoic acid receptor alpha',
        'Retinoic acid receptor beta',
        'Retinoic acid receptor gamma',
        'Retinoic acid receptor, gamma',
        'Retinoic acid receptor RXR-alpha',
        'Retinoic acid receptor RXR-gamma',
        'Retinoic acid receptor alpha [200-419]',
        'Retinoic acid receptor beta [200-419]',
        'Retinoic acid receptor gamma [183-417]',
        'Retinoic acid receptor RXR-alpha/alpha',
        'Retinoic acid receptor RXR-alpha/gamma',
        'Retinoic acid receptor, alpha, isoform CRA_b',
        'Retinoic acid receptor alpha/Retinoid X receptor alpha',
        'Retinoic acid receptor RXR-alpha/Vitamin D3 receptor',
        'Retinoid X receptor gamma/retinoic acid receptor alpha',
        'Oxysterols receptor LXR-alpha/Retinoic acid receptor RXR-alpha',
        'Retinoic acid receptor RXR-alpha/Oxysterols receptor LXR-beta',
        'Retinoic acid receptor RXR-alpha/Thyroid hormone receptor alpha',
        'Retinoic acid receptor RXR-alpha/Thyroid hormone receptor beta',
        'Peroxisome proliferator-activated receptor gamma/Retinoic acid receptor RXR-alpha',
        'Retinoic acid-related nuclear receptor gamma t (RORgammat)',
        'Retinoic acid-related nuclear receptor gamma t (ROR t)',
        'Nuclear receptor subfamily 4 group A member 2/Retinoic acid receptor RXR-alpha',
        'Retinoic acid receptor RXR-alpha [225-462]/Thyroid hormone receptor beta [148-410]',
        'Retinoic acid receptors gamma / alpha',
        'Cellular retinoic acid-binding protein 1',
        'Cellular retinoic acid-binding protein 2'
    )
LEFT JOIN polymer p ON ers.enzyme_polymerid = p.polymerid
LEFT JOIN monomer m ON ers.inhibitor_monomerid = m.monomerid
LEFT JOIN entry e ON k.entryid = e.entryid
LEFT JOIN entry_citation ec ON e.entryid = ec.entryid
LEFT JOIN article a ON ec.articleid = a.articleid
WHERE (k.ki IS NOT NULL OR k.kd IS NOT NULL OR k.ic50 IS NOT NULL OR k.ec50 IS NOT NULL)
ORDER BY pn.name, k.reactant_set_id;

