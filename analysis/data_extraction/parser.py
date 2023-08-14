from collection_util import *


def get_web_thread(data, url):
    for thread in data['threads']:
        if "eTLD+1" in thread and thread["eTLD+1"] == url:
            return thread


def get_marker_index(thread, key_conditions):
    marker_data = thread["markers"]["data"]
    for i, event in enumerate(marker_data):
        if event and has_keys_with_values(event, key_conditions):
            return i


def get_counter(data, start, end, key_conditions):
    for counter in data['counters']:
        if has_keys_with_values(counter, key_conditions):
            return counter["sampleGroups"][0]["samples"]


def get_resource_load_time(thread, key_conditions):
    key_conditions_start = key_conditions.copy()
    key_conditions_start.append({"k": "status", "v": "STATUS_START"})
    start_time_index = get_marker_index(thread, key_conditions_start)
    start_time = thread["markers"]["data"][start_time_index]["startTime"]

    key_conditions_end = key_conditions.copy()
    key_conditions_end.append({"k": "status", "v": "STATUS_STOP"})
    end_time_index = get_marker_index(thread, key_conditions_end)
    end_time = thread["markers"]["data"][end_time_index]["endTime"]

    return round(end_time - start_time, 3)

