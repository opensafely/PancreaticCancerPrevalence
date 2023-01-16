from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
)

from codelists import *

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "2015-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
        },
    index_date="2015-01-01",
    population=patients.satisfying(
        """
        registered
        AND NOT has_died
        AND (age >=18 AND age <= 110)
        AND (sex = "M")
        """
    ),
    registered=patients.registered_as_of(
        "last_day_of_month(index_date)",
        return_expectations={"incidence":0.95}
    ),
    has_died=patients.died_from_any_cause(
        on_or_before="first_day_of_month(index_date) - 1 day",# has not died in the previous month and so no clash with the *died_prostate* variable 
        returning="binary_flag",
    ),
    age=patients.age_as_of(
        "first_day_of_month(index_date)",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.5, "F": 0.5}},
        }
    ),
### prevalence that month: diagnosed any time up to the date, registered, alive and an adult in a given month
    prevalence=patients.with_these_clinical_events(
        prostate_cancer_codes,
        on_or_before="last_day_of_month(index_date)",
        find_first_match_in_period=True,
        include_date_of_match=True,
        include_month=True,
        include_day=True,
        returning="binary_flag",
        return_expectations={
            "date": {"earliest": "2015-01-01", "latest": "today"},
            "incidence": 0.6
        }
    ),

### age at diagnosis
    age_pa_ca=patients.age_as_of(
        "prevalence_date",
        return_expectations={
            "rate": "exponential_increase",
            "int": {"distribution": "population_ages"},
        },
    ),
### incidence, NEW diagnosed that month
    # incid=patients.with_these_clinical_events(
    #     prostate_cancer_codes,
    #     between=[
    #         "first_day_of_month(index_date)", #diagnosed this month, will this work for measures?
    #         "last_day_of_month(index_date)",
    #     ],
    #     find_first_match_in_period=True,
    #     include_date_of_match=True,
    #     include_month=True,
    #     include_day=True,
    #     returning="binary_flag",
    #     return_expectations={
    #         "date": {"earliest": "2015-01-01", "latest": "today"},
    #         "incidence": 0.4
    #     }
    # ),
    # incidence=patients.satisfying(
    #     """
    #     incid
    #     AND incid_date = prevalence_date
    #     """
    # ),## this would work
### or otherwise this
# https://github.com/opensafely/antidepressant-prescribing-lda/blob/e50bd7479bf87c10947b0a1aec9b30b2f7518924/analysis/study_definition.py#L111-L122    
    incidence=patients.satisfying(
        """
        diagnosis AND
        NOT previous
        """,
        diagnosis=patients.with_these_clinical_events(
            prostate_cancer_codes,
            returning="binary_flag",
            find_last_match_in_period=True,
            between=[
                "first_day_of_month(index_date)",
                "last_day_of_month(index_date)",
            ],
            return_expectations={"incidence": 0.5}
        ),
        previous=patients.with_these_clinical_events(
            codelist=prostate_cancer_codes,
            returning="binary_flag",
            find_last_match_in_period=True,
            on_or_before="first_day_of_month(index_date) - 1 day",
            return_expectations={"incidence": 0.1},
        ),
        return_expectations={"incidence": 0.4},
    ),
    died_prostate=patients.with_these_codes_on_death_certificate(
        prostate_cancer_ICD10,
        between=[
            "first_day_of_month(index_date)",
            "last_day_of_month(index_date)",
            ],
        match_only_underlying_cause=False,
        return_expectations={"incidence": 0.20},
    ),
### demographics: sex, ethnicity, IMD, and region
    age_group=patients.categorised_as(
        {
            "<65": "DEFAULT",
            "65-74": """ age >= 65 AND age < 75""",
            "75-84": """ age >= 75 AND age < 85""",
            "85+": """ age >=  85 AND age < 120""",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "<65": 0.25,
                    "65-74": 0.25,
                    "75-84": 0.25,
                    "85+": 0.25,
                }
            },
        },
    ),
    region=patients.registered_practice_as_of(
        "last_day_of_month(index_date)",
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
    imd_cat=patients.categorised_as(
        {
            "IMD_0": "DEFAULT",
            "IMD_1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "IMD_2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "IMD_3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "IMD_4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "IMD_5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "last_day_of_month(index_date)",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "IMD_0": 0.05,
                    "IMD_1": 0.19,
                    "IMD_2": 0.19,
                    "IMD_3": 0.19,
                    "IMD_4": 0.19,
                    "IMD_5": 0.19,
                }
            },
        },
    ),
)

measures = [
    Measure(
        id="prevalence_rate",
        numerator="prevalence",
        denominator="population",
        group_by="population",
        small_number_suppression=True,
    ),
    Measure(
        id="prevalencebyRegion_rate",
        numerator="prevalence",
        denominator="population",
        group_by="region",
        small_number_suppression=True,
    ),
    Measure(
        id="prevalencebyIMD_rate",
        numerator="prevalence",
        denominator="population",
        group_by="imd_cat",
        small_number_suppression=True,
    ),
    Measure(
        id="prevalencebyEthnicity_rate",
        numerator="prevalence",
        denominator="population",
        group_by="ethnicity",
        small_number_suppression=True,
    ),
    Measure(
        id="prevalencebyAge_rate",
        numerator="prevalence",
        denominator="population",
        group_by="age_group",
        small_number_suppression=True,
    ),
    Measure(
        id="incidence_rate",
        numerator="incidence",
        denominator="population",
        group_by="population",
        small_number_suppression=True,
    ),
    Measure(
        id="incidencebyRegion_rate",
        numerator="incidence",
        denominator="population",
        group_by="region",
        small_number_suppression=True,
    ),
    Measure(
        id="incidencebyIMD_rate",
        numerator="incidence",
        denominator="population",
        group_by="imd_cat",
        small_number_suppression=True,
    ),
    Measure(
        id="incidencebyEthnicity_rate",
        numerator="incidence",
        denominator="population",
        group_by="ethnicity",
        small_number_suppression=True,
    ),
    Measure(
        id="incidencebyAge_rate",
        numerator="incidence",
        denominator="population",
        group_by="age_group",
        small_number_suppression=True,
    ),
    Measure(
        id="mortality_rate",
        numerator="died_prostate",
        denominator="population",
        group_by="population",
        small_number_suppression=True,
    ),
]
