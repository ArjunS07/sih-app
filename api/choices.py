import pathlib
from csv import reader
import os

base_path = pathlib.Path().resolve()
def all_choices(choice_set):
    ids = [choice[0] for choice in choice_set]
    return ids

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

GRADE_CHOICES = []
grade_path = os.path.join(base_path, 'api', 'resources', 'grades.csv')
with open(grade_path, 'r') as f:
    csv_reader = reader(f)
    GRADE_CHOICES = list(map(tuple, csv_reader))

BOARD_CHOICES = []
board_path = os.path.join(base_path, 'api', 'resources', 'boards.csv')
with open(board_path, 'r') as f:
    csv_reader = reader(f)
    BOARD_CHOICES = list(map(tuple, csv_reader))

SUBJECT_CHOICES = []
subject_path = os.path.join(base_path, 'api', 'resources', 'subjects.csv')
with open(subject_path, 'r') as f:
    csv_reader = reader(f)
    SUBJECT_CHOICES = list(map(tuple, csv_reader))

EDUCATIONAL_LEVEL_CHOICES = []
subject_path = os.path.join(base_path, 'api', 'resources', 'educational_level.csv')
with open(subject_path, 'r') as f:
    csv_reader = reader(f)
    EDUCATIONAL_LEVEL_CHOICES = list(map(tuple, csv_reader))

def decode_choice(choice_set, choice_id):
    for choice in choice_set:
        if choice[0] == choice_id:
            return choice[1]
    return None