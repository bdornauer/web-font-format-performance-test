
def has_keys_with_values(element, key_conditions):
    for cond in key_conditions:
        if not cond["k"] in element:
            return False
        elif element[cond["k"]] != cond["v"]:
            return False
    return True


def filter_by_time(values, times, start, end):
    result = []
    for i, el in enumerate(values[:-1]):
        if start <= times[i+1] <= end:
            result.append(el)
    return result


def relative_to_max_value(values):
    max_value = max(values)
    for i in range(len(values)):
        if values[i]:
            values[i] = round(values[i] * 100 / max_value, 2)
    return values


def map_to_wattage(values, times):
    if len(values) != len(times):
        raise "Illegal Argument: "
    wh = []
    for i in range(1, len(values)):
        sample_time_delta_ms = times[i] - times[i - 1]
        pico_wh = values[i]
        # watts = pico_wh / (sample_time_delta_ms / 3.6) * pow(10, 6)
        wh.append(pico_wh)
    return wh


def map_to_per_ms(values, times):
    if len(values) != len(times):
        raise "Illegal Argument: List lengths not equal."
    values_per_ms = []
    for i in range(1, len(values)):
        delta_ms = times[i] - times[i - 1]
        value_per_ms = values[i] / delta_ms
        values_per_ms.append(value_per_ms)
    return values_per_ms, times[1:]
