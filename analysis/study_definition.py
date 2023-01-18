from cohortextractor import StudyDefinition, patients

from codelists import *

start_date = "2015-01-01"
end_date = "2022-12-01"

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
    index_date=end_date,
    population=patients.all(),

    ethnicity=patients.categorised_as(
        {
            "Missing": "DEFAULT",
            "White": """ ethnicity_code=1 """,
            "Mixed": """ ethnicity_code=2 """,
            "South_Asian": """ ethnicity_code=3 """,
            "Black": """ ethnicity_code=4 """,
            "Other": """ ethnicity_code=5 """,
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Missing": 0.4,
                    "White": 0.2,
                    "Mixed": 0.1,
                    "South_Asian": 0.1,
                    "Black": 0.1,
                    "Other": 0.1,
                }
            },
        },
        ethnicity_code=patients.with_these_clinical_events(
            ethnicity_codes,
            returning="category",
            find_last_match_in_period=True,
            on_or_before="index_date",
            return_expectations={
            "category": {"ratios": {"1": 0.1, "2": 0.1, "3": 0.2, "4": 0.2,"5": 0.2, "6": 0.2}},
            "incidence": 1,
            },
        ),
    ),
    died=patients.died_from_any_cause(
        on_or_before="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "2020-02-01"},
            "rate": "exponential_increase"
        },
    ),
    has_died=patients.died_from_any_cause(
        on_or_before="index_date",
        returning='binary_flag',
        return_expectations={
            "incidence": 0.4
        },
    ),
    prostate_ca=patients.with_these_clinical_events(
        prostate_cancer_codes,
        on_or_before="index_date",
        find_first_match_in_period=True,
        include_date_of_match=True,
        include_month=True,
        include_day=True,
        returning="binary_flag",
        return_expectations={
            "date": {"earliest": "2000-01-01", "latest": "today"},
            "incidence": 0.8
        }
    ),
    age_pa_ca=patients.age_as_of(
        "prostate_ca_date",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
        },
    ),
    age_group=patients.categorised_as(
        {
            "Missing": "DEFAULT",
            "<65": """ age_pa_ca < 65""",
            "65-74": """ age_pa_ca >= 65 AND age_pa_ca < 75""",
            "75-84": """ age_pa_ca >= 75 AND age_pa_ca < 85""",
            "85+": """ age_pa_ca >= 85""",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Missing": 0.2,
                    "<65": 0.2,
                    "65-74": 0.2,
                    "75-84": 0.2,
                    "85+": 0.2,
                }
            },
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.99, "F": 0.01}},
        }
    ),
    region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and the Humber": 0.2,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East of England": 0.1,
                    "London": 0.1,
                    "South East": 0.2,
                },
            },
        },
    ),
    imd_Q=patients.address_as_of(
        "index_date",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
    imd_cat=patients.categorised_as(
        {
            "Missing": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Missing": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
    ),
)
