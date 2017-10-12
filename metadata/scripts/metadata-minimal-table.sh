#!/bin/bash

#This script outputs a table of the metadata that are useful that are reasonably minimal

sIODir=$1
sJavaDir=$2

cd $sIODir

#outputting metadata for all samples
sqlite3 formatted_metadata/metadata_formatted.db "select * from tbl1 where variable in ('blank_or_control', 'enrichment', 'domain', 'dna_region', 'latitude', 'longitude', 'env_biome', 'env_feature', 'env_material');" | tail -n+2 > formatted_metadata/metadata_minimal_table.csv
java -cp $sJavaDir/Utilities.jar edu.ucsf.FlatFileToPivotTable.FlatFileToPivotTableLauncher \
	--sValueHeader=VALUE \
	--rgsExpandHeaders=VARIABLE \
	--sDataPath=$sIODir/formatted_metadata/metadata_minimal_table.csv \
	--sOutputPath=$sIODir/formatted_metadata/metadata_minimal_table.csv
sed -i -e "s|unknown|null|g" -e "s|undefined|null|g" -e "s|VARIABLE=||g" -e "s|\,\,|\,null\,|g" -e "s|None|null|g" formatted_metadata/metadata_minimal_table.csv

#outputting metadata for samples with complete metadata
rm -f temp.0.db
sqlite3 temp.0.db ".import $sIODir/formatted_metadata/metadata_minimal_table.csv tbl1"
sqlite3 temp.0.db "select * from tbl1 where not(blank_or_control='TRUE') and enrichment='FALSE'" | tail -n+2 > temp.1.csv
grep -v '\,null' temp.1.csv > formatted_metadata/metadata_minimal_complete_no_blank_no_control_no_enrichment_table.csv

#cleaning up
rm temp.*

