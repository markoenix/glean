/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/// The ability to convert an enum key back to its string representation.
/// This is necessary because Glean-generated enum values are camelCased,
/// so an enum's `name` property doesn't match the allowed key.
///
/// This is automatically implemented for generated enums.
public protocol EventExtraKey: Hashable {
    func keyName() throws -> String
}

/// Extra keys for events by name.
///
/// For user-defined `EventMetricType`s every event with extras
/// will get their own corresponding event extra data class.
public protocol EventExtras {
    /// Convert the event extras into 2 lists:
    ///
    /// 1. The list of extra key indices.
    ///    Unset keys will be skipped.
    /// 2. The list of extra values.
    func toExtraRecord() -> [String: String]
}

/// Default of no extra keys for events.
///
/// An enum with no values for convenient use as the default set of extra keys
/// that an `EventMetricType` can accept.
public enum NoExtraKeys: EventExtraKey {
    public func keyName() throws -> String {
        throw "can't serialize this key"
    }
}

/// Default of no extra keys for events (for the new API).
///
/// An empty class for convenient use as the default set of extra keys
/// that an `EventMetricType` can accept.
public class NoExtras: EventExtras {
    public func toExtraRecord() -> [String: String] {
        return [String: String]()
    }
}

/// Default-implement `EventExtras` for a map of ExtraKeys to Strings.
extension Dictionary: EventExtras where Key: EventExtraKey, Value == String {
    public func toExtraRecord() -> [String: String] {
        var record = [String: String]()

        for (key, value) in self {
            record[try! key.keyName()] = value
        }

        return record
    }
}

/// This implements the developer facing API for recording events.
///
/// Instances of this class type are automatically generated by the parsers at built time,
/// allowing developers to record events that were previously registered in the metrics.yaml file.
///
/// The Events API only exposes the `EventMetricType.record(extra:)` method, which takes care of validating the input
/// data and making sure that limits are enforced.
public class EventMetricType<ExtraKeysEnum: EventExtraKey, ExtraObject: EventExtras> {
    let inner: EventMetric

    /// The public constructor used by automatically generated metrics.
    public init(_ meta: CommonMetricData, _ allowedExtraKeys: [String]? = nil) {
        self.inner = EventMetric(meta, allowedExtraKeys ?? [])
    }

    /// Record an event by using the information provided by the instance of this class.
    ///
    /// - parameters:
    ///     * extra: (optional) A map of extra keys. Keys are identiifers and mapped to their registered name,
    ///              values need to be strings.
    ///              This is used for events where additional richer context is needed.
    ///              The maximum length for values is defined by `MAX_LENGTH_EXTRA_KEY_VALUE`.
    @available(*, deprecated, message: "Specify types for your event extras. See the reference for details.")
    public func record(extra: [ExtraKeysEnum: String]) {
        self.recordInternal(extras: extra.toExtraRecord())
    }

    public func record(_ properties: ExtraObject? = nil) {
        self.recordInternal(extras: properties.map { $0.toExtraRecord() } ?? [:])
    }

    func recordInternal(extras: [String: String]) {
        self.inner.record(extras)
    }

    /// Returns the stored value for testing purposes only. This function will attempt to await the
    /// last task (if any) writing to the the metric's storage engine before returning a value.
    ///
    /// - parameters:
    ///     * pingName: represents the name of the ping to retrieve the metric for.
    ///                 Defaults to the first value in `sendInPings`.
    ///
    /// - returns:  value of the stored metric or `nil` if nothing was recorded.
    public func testGetValue(_ pingName: String? = nil) -> [RecordedEvent]? {
        return self.inner.testGetValue()
    }

    /// Returns the number of errors recorded for the given metric.
    ///
    /// - parameters:
    ///     * errorType: The type of error recorded.
    ///     * pingName: represents the name of the ping to retrieve the metric for.
    ///                 Defaults to the first value in `sendInPings`.
    ///
    /// - returns: The number of errors recorded for the metric for the given error type.
    public func testGetNumRecordedErrors(_ errorType: ErrorType, pingName: String? = nil) -> Int32 {
        return self.inner.testGetNumRecordedErrors(errorType, pingName)
    }
}
