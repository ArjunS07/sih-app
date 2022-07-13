import pathlib
from csv import reader
import os

base_path = pathlib.Path().resolve()

LANGUAGE_MEDIUM_CHOICES = []
language_path = os.path.join(base_path, 'api', 'resources', 'languages.csv')

with open(language_path, 'r') as f:
    csv_reader = reader(f)
    LANGUAGE_MEDIUM_CHOICES = tuple(csv_reader)

CITY_CHOICES = []
city_path = os.path.join(base_path, 'api', 'resources', 'cities.csv')

with open(city_path, 'r') as f:
    csv_reader = reader(f)
    CITY_CHOICES = list(map(tuple, csv_reader))

def all_choices(choice_set):
    ids = [choice[0] for choice in choice_set]
    return ids

GRADE_CHOICES = [
    ('NS', 'Nursery'),
    ('KG', 'Kindergarten'),
    ('1G', 'First grade'),
    ('2G', 'Second grade'),
    ('3G', 'Third grade'),
    ('4G', 'Fourth grade'),
    ('5G', 'Fifth grade'),
    ('6G', 'SIXTH grade'),
    ('7G', 'Seventh grade'),
    ('8G', 'Eighth grade'),
    ('9G', 'Ninth grade'),
    ('10G', 'Tenth grade'),
    ('11G', 'Eleventh grade'),
    ('12G', 'Twelfth grade'),
]


BOARD_CHOICES = [
    ('CBSE', 'CBSE'),
    ('STATE', 'State board'),
    ('ICSE', 'ICSE'),
    ('ISC', 'ISC'),
    ('IGCSE', 'IGCSE'),
    ('IB', 'IB'),
    ('OTHER', 'Other'),
]

SUBJECT_CHOICES = [
    ('MATH', 'Mathematics'),

    ('ENGLISH', 'English'),
    ('HIN', 'Hindi'),
    ('SANSK', 'Sanskrit'),
    ('SP', 'Spanish'),
    ('FR', 'French'),
    ('GR', 'German'),

    ('EVS', 'Environmental science (EVS)'),
    ('SCIENCE', 'Science'),
    ('BIO', 'Biology'),
    ('PHY', 'Physics'),
    ('CHEM', 'Chemistry'),
    ('CS', 'Computer science'),
    ('PSYCH', 'PSYCHOLOGY'),

    ('SST', 'Social studies / Social science'),
    ('HIST', 'History'),
    ('CIV', 'Civics'),
    ('GEO', 'Geography'),
    ('ECO', 'Economics'),
    ('COM', 'Commerce'),
    ('ACC', 'Accounting'),
    ('SOC', 'Sociology'),

    ('HOM', 'Home science'),
    ('ART', 'Art'),
]
