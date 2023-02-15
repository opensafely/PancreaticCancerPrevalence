from cohortextractor import StudyDefinition, patients

from codelists import *

start_date = "2015-01-01"
end_date = "2022-12-31"

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
    index_date=end_date,
    population=patients.satisfying(
        """
        registered AND
        (NOT died) AND
        (age_pa_ca >=18 AND age_pa_ca <=120) AND
        (sex = "M") AND
        prostate_ca
        """,
    ),
    registered=patients.registered_as_of(
        "2015-01-01",
        return_expectations={"incidence": 0.9},
    ),
    # registered=patients.registered_with_one_practice_between(
    #     "2015-01-01", "2022-12-31"
    # ),
    died=patients.died_from_any_cause(
        on_or_before="2015-01-01",
        returning="binary_flag",
        return_expectations={"incidence": 0.1}
        ),
    # age=patients.age_as_of(
    #     "2015-01-01",
    #     return_expectations={
    #         "rate": "universal",
    #         "int": {"distribution": "population_ages"},
    #     },
    # ),
    # deregistered=patients.date_deregistered_from_all_supported_practices(
    #     date_format="YYYY-MM-DD"
    # ),
    prostate_ca=patients.with_these_clinical_events(
        prostate_cancer_codes,
        on_or_before="last_day_of_month(index_date)",
        find_first_match_in_period=True,
        include_date_of_match=True,
        include_month=True,
        include_day=True,
        returning="binary_flag",
        return_expectations={
            "date": {"earliest": "2000-01-01", "latest": "today"},
            "incidence": 1.0
        }
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.5, "F": 0.5}},
        }
    ),
    # ethnicity=patients.categorised_as(
    #     {
    #         "Missing": "DEFAULT",
    #         "White": """ ethnicity_code=1 """,
    #         "Mixed": """ ethnicity_code=2 """,
    #         "South_Asian": """ ethnicity_code=3 """,
    #         "Black": """ ethnicity_code=4 """,
    #         "Other": """ ethnicity_code=5 """,
    #     },
    #     return_expectations={
    #         "rate": "universal",
    #         "category": {
    #             "ratios": {
    #                 "Missing": 0.4,
    #                 "White": 0.2,
    #                 "Mixed": 0.1,
    #                 "South_Asian": 0.1,
    #                 "Black": 0.1,
    #                 "Other": 0.1,
    #             }
    #         },
    #     },
    #     ethnicity_code=patients.with_these_clinical_events(
    #         ethnicity_codes,
    #         returning="category",
    #         find_last_match_in_period=True,
    #         return_expectations={
    #         "category": {"ratios": {"1": 0.1, "2": 0.1, "3": 0.2, "4": 0.2,"5": 0.2, "6": 0.2}},
    #         "incidence": 1,
    #         },
    #     ),
    # ),
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
    imd_cat=patients.categorised_as(
        {
            "Unknown": "DEFAULT",
            "1 (most deprived)": "imd >= 0 AND imd < 32844*1/5",
            "2": "imd >= 32844*1/5 AND imd < 32844*2/5",
            "3": "imd >= 32844*2/5 AND imd < 32844*3/5",
            "4": "imd >= 32844*3/5 AND imd < 32844*4/5",
            "5 (least deprived)": "imd >= 32844*4/5 AND imd <= 32844",
        },
        imd=patients.address_as_of(
            "2015-01-01",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Unknown": 0.05,
                    "1 (most deprived)": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5 (least deprived)": 0.19,
                }
            },
        },
    ),
    # died=patients.died_from_any_cause(
    #     on_or_before="index_date",
    #     returning="date_of_death",
    #     date_format="YYYY-MM-DD",
    #     return_expectations={
    #         "date": {"earliest" : "2020-02-01"},
    #         "rate": "exponential_increase"
    #     },
    # ),
    # has_died=patients.died_from_any_cause(
    #     on_or_before="index_date",
    #     returning='binary_flag',
    #     return_expectations={
    #         "incidence": 0.4
    #     },
    # ),
    age_pa_ca=patients.age_as_of(
        "prostate_ca_date",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
            "incidence": 1.0
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
    incidence=patients.satisfying(
        """
        diagnosis AND
        NOT previous
        """,
        diagnosis=patients.with_these_clinical_events(
            prostate_cancer_codes,
            returning="binary_flag",
            find_first_match_in_period=True,
            between=[
                "2015-01-01",
                "last_day_of_month(index_date)",
            ],
            return_expectations={"incidence": 0.5}
        ),
        previous=patients.with_these_clinical_events(
            codelist=prostate_cancer_codes,
            returning="binary_flag",
            find_first_match_in_period=True,
            on_or_before="2014-12-31",
            return_expectations={"incidence": 0.1},
        ),
        return_expectations={"incidence": 0.4},
    ),
)
