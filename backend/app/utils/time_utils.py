def datetime_to_datenum(dt):
    frac = (
        dt.hour / 24
        + dt.minute / 1440
        + dt.second / 86400
        + dt.microsecond / 86400e6
    )

    return dt.toordinal() + frac