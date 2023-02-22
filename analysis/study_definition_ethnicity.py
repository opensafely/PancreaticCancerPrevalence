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
            "Missing": "DEFAULT",
            "White": """ ethnicity_code=1 """,
            "Chinese&Mixed": """ ethnicity_code=2 OR ethnicity_code=5 """,
            "Asian": """ ethnicity_code=3 """,
            "Black": """ ethnicity_code=4 """,
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Missing": 0.4,
                    "White": 0.1,
                    "Asian": 0.1,
                    "Black": 0.2,
                    "Chinese&Mixed": 0.2,
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