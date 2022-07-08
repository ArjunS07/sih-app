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


GRADE_CHOICES = [
    ('NS', 'Nursey'),
    ('KG', 'Kindergarten'),
    ('1', 'First grade'),
    ('2', 'Second grade'),
    ('3', 'Third grade'),
    ('4', 'Fourth grade'),
    ('5', 'Fifth grade'),
    ('6', 'SIXTH grade'),
    ('7', 'Seventh grade'),
    ('8', 'Eighth grade'),
    ('9', 'Ninth grade'),
    ('10', 'Tenth grade'),
    ('11', 'Eleventh grade'),
    ('12', 'Twelfth grade'),
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
