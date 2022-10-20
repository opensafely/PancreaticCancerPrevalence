from cohortextractor import (
    codelist_from_csv,
    codelist,
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
ethnicity_codes_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_16",
)
prostate_cancer_codes = codelist_from_csv(
    "codelists/user-agleman-prostate_cancer_snomed.csv",
    system="snomed",
    column="code",
)

