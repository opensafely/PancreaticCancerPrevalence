from cohortextractor import StudyDefinition, patients

from codelists import *

start_date = "2015-01-01"
end_date = "2022-10-01"#"today" is not working here? 

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.8,
    },
    index_date=end_date,
    population=patients.all(),

    ethnicity=patients.categorised_as(
        {
            "White": """ ethnicity_code=1 """,
            "Mixed": """ ethnicity_code=2 """,
            "Asian": """ ethnicity_code=3 """,
            "Black": """ ethnicity_code=4 """,
            "Chinese": """ ethnicity_code=5 """,
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "White": 0.2,
                    "Mixed": 0.2,
                    "Asian": 0.2,
                    "Black": 0.2,
                    "Chinese": 0.2,
                }
            },
        },
        ethnicity_code=patients.with_these_clinical_events(
            ethnicity_codes,
            returning="category",
            find_last_match_in_period=True,
            include_date_of_match=False,
            return_expectations={
            "category": {"ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}},
            "incidence": 0.75,
            },
        ),
    ),
)

# 1 - White
# 2 - Mixed
# 3 - Asian or Asian British
# 4 - Black or Black British
# 5 - Chinese or Other Ethnic Groups