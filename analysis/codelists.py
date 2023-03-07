from cohortextractor import (
    codelist_from_csv,
    codelist,
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity-snomed-0removed.csv",
    system="snomed",
    column="snomedcode",
    category_column="Grouping_6",
)
prostate_cancer_codes = codelist_from_csv(
    "codelists/user-agleman-prostate_cancer_snomed.csv",
    system="snomed",
    column="code",
)

# prostate_cancer_ICD10
# C61 C68.0 C79.8 D40.0 #other not good 
prostate_cancer_ICD10 = codelist(["C61"], 
system ="icd10")

