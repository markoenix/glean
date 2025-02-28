# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.


import datetime
from typing import Optional


from .._uniffi import DatetimeMetric
from .._uniffi import CommonMetricData, TimeUnit, Datetime
from ..testing import ErrorType


def tzoffset(offset):
    """
    Create a timezone from the given offset (in seconds) from UTC.
    """
    delta = datetime.timedelta(seconds=offset)
    return datetime.timezone(delta)


class DatetimeMetricType:
    """
    This implements the developer facing API for recording datetime metrics.

    Instances of this class type are automatically generated by
    `glean.load_metrics`, allowing developers to record values that were
    previously registered in the metrics.yaml file.

    The datetime API only exposes the `DatetimeMetricType.set` method.
    """

    def __init__(self, common_metric_data: CommonMetricData, time_unit: TimeUnit):
        self._inner = DatetimeMetric(common_metric_data, time_unit)

    def set(self, value: Optional[datetime.datetime] = None) -> None:
        """
        Set a datetime value, truncating it to the metric's resolution.

        Args:
            value (datetime.datetime): (default: now) The `datetime.datetime`
                value to set. If not provided, will record the current time.
        """
        if value is None:
            # now at UTC -> astimezone gives us a time with the local timezone.
            value = datetime.datetime.now(datetime.timezone.utc).astimezone()

        tzinfo = value.tzinfo
        if tzinfo is not None:
            utcoff = tzinfo.utcoffset(value)
            if utcoff is not None:
                offset = utcoff.seconds
            else:
                offset = 0
        else:
            offset = 0

        dt = Datetime(
            year=value.year,
            month=value.month,
            day=value.day,
            hour=value.hour,
            minute=value.minute,
            second=value.second,
            nanosecond=value.microsecond * 1000,
            offset_seconds=offset,
        )

        self._inner.set(dt)

    def test_get_value_as_str(self, ping_name: Optional[str] = None) -> Optional[str]:
        """
        Returns the stored value for testing purposes only, as an ISO8601 string.

        Args:
            ping_name (str): (default: first value in send_in_pings) The name
                of the ping to retrieve the metric for.

        Returns:
            value (str): value of the stored metric.
        """
        dt = self.test_get_value(ping_name)
        if not dt:
            return None

        return dt.isoformat()

    def test_get_value(
        self, ping_name: Optional[str] = None
    ) -> Optional[datetime.datetime]:
        """
        Returns the stored value for testing purposes only.

        Args:
            ping_name (str): (default: first value in send_in_pings) The name
                of the ping to retrieve the metric for.

        Returns:
            value (datetime.datetime): value of the stored metric.
        """
        dt = self._inner.test_get_value(ping_name)
        if not dt:
            return None

        tz = tzoffset(dt.offset_seconds)
        dt = datetime.datetime(
            year=dt.year,
            month=dt.month,
            day=dt.day,
            hour=dt.hour,
            minute=dt.minute,
            second=dt.second,
            microsecond=round(dt.nanosecond / 1000),
            tzinfo=tz,
        )
        return dt

    def test_get_num_recorded_errors(
        self, error_type: ErrorType, ping_name: Optional[str] = None
    ) -> int:
        return self._inner.test_get_num_recorded_errors(error_type, ping_name)


__all__ = ["DatetimeMetricType"]
