from file_util import *
from FontFormat import FontFormat
from parser import *
from collection_util import *
from scipy.stats import trim_mean

URL = "http://192.168.178.43"



def extract_font_loading_times(thread):
    result = []
    for font in font_paths:
        font_load = get_resource_load_time(thread, key_conditions=[
            {"k": "URI", "v": font},
            {"k": "type", "v": "Network"},
            {"k": "requestMethod", "v": "GET"},
        ])
        result.append(font_load)
    return result


def extract_cpu_load(thread, start, end):
    cpu_cycles_raw = thread["samples"]["threadCPUDelta"]
    times = thread["samples"]["time"]

    #cpu_cycles_per_ms, times = map_to_per_ms(cpu_cycles_raw, times)
    # cpu_usages = relative_to_max_value(cpu_cycles_per_ms)
    cpu_cycles = filter_by_time(cpu_cycles_raw, times, start, end)

    return cpu_cycles


def extract_memory_load(data, start, end):
    pid = get_web_thread(data, URL)["pid"]
    mem_loads_raw_data = get_counter(data, start, end, key_conditions=[
        {"k": "category", "v": "Memory"},
        {"k": "pid", "v": pid}
    ])
    mem_loads_raw = mem_loads_raw_data["count"]
    times = mem_loads_raw_data["time"]
    mem_loads_per_ms, times = map_to_per_ms(mem_loads_raw, times)
    mem_loads_in_time = filter_by_time(mem_loads_per_ms, times, start, end)
    return mem_loads_in_time


def extract_power_consumption(data, start, end):
    consumptions = get_counter(data, start, end, key_conditions=[
        {"k": "description", "v": "RAPL_Package0_PKG"},
    ])
    times = consumptions["time"]
    wattage = map_to_wattage(consumptions["count"], times)
    wattage_in_time = filter_by_time(wattage, times, start, end)
    return sum(wattage_in_time) * 1e-12


def extract_performance_scores(data):
    web_thread = get_web_thread(data, URL)

    dom_content_loaded_index = get_marker_index(web_thread, key_conditions=[
        {"k": "type", "v": "DOMEvent"},
        {"k": "eventType", "v": "DOMContentLoaded"},
        {"k": "target", "v": "document"},
    ])
    start_time = web_thread["markers"]["startTime"][dom_content_loaded_index]

    load_index = get_marker_index(web_thread, key_conditions=[
        {"k": "type", "v": "DOMEvent"},
        {"k": "eventType", "v": "load"},
        {"k": "target", "v": "document"},
    ])
    end_time = web_thread["markers"]["startTime"][load_index]

    cpu = extract_cpu_load(web_thread, start_time, end_time)
    mem = extract_memory_load(data, start_time, end_time)
    power = extract_power_consumption(data, start_time, end_time)
    font_loading_times = extract_font_loading_times(web_thread)
    obs_period_length = round(end_time - start_time, 3)

    result = [sum(cpu), trim_mean(mem, 0.1), power, obs_period_length] + font_loading_times
    return result


if __name__ == '__main__':

    for font_format in FontFormat.__members__.values():
        font_paths = [
            URL + "/fonts/RalewayExtrabold/Raleway-ExtraBold." + font_format.name.lower(),
            URL + "/fonts/MontserratSemibold/Montserrat-SemiBold." + font_format.name.lower(),
            URL + "/fonts/SourceSansPro/SourceSans-Regular." + font_format.name.lower(),
        ]

        files = get_input_files(font_format.name)

        errors = []
        for index, file in enumerate(files):
            print(f"\rProcessing file {index+1}/{len(files)}:\t\t{file}", end='', flush=True)
            try:
                profiler_data = load_json(file)
                results = extract_performance_scores(profiler_data)
                results.insert(0, index)
                results.insert(1, file)
                append_result(results)
            except TypeError as e:
                print(e)
                errors.append(file)
        if errors:
            print(f"\n\nNoneType Errors:\n{errors}")
