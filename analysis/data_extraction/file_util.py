import json
import os
import csv

columns = [
    "Index",
    "Filename",
    "AVG CPU Cycles / ms",
    "AVG MEM Changes / ms",
    "AVG Wattage",
    "Length of observation period",
    "AVG Raleway Load Time",
    "AVG Montserrat Load Time",
    "AVG SourceSans Load Time"
]
writer = None
output_csv_file = None


def load_json(json_file):
    with open(json_file, 'r', encoding="utf8") as file:
        return json.load(file)


def get_input_files(font_format):
    global output_csv_file
    output_csv_file = f'output/{font_format}.csv'

    init_csv()

    file_paths = []
    for filename in os.listdir(f"input/{font_format}"):
        if filename.endswith('.json'):
            file_paths.append(os.path.join(f"input/{font_format}", filename))
    return file_paths


def init_csv():
    global writer
    if os.path.exists(output_csv_file):
        os.remove(output_csv_file)
        print("delete prior file")
    csv_file = open(output_csv_file, 'a', newline='')
    writer = csv.writer(csv_file)
    writer.writerow(columns)


def append_result(result):
    global writer
    writer.writerow(result)