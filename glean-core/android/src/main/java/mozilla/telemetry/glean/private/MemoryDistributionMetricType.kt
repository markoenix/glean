/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package mozilla.telemetry.glean.private

import androidx.annotation.VisibleForTesting
import mozilla.telemetry.glean.internal.MemoryDistributionMetric
import mozilla.telemetry.glean.testing.ErrorType

/**
 * This implements the developer facing API for recording memory distribution metrics.
 *
 * Instances of this class type are automatically generated by the parsers at build time,
 * allowing developers to record values that were previously registered in the metrics.yaml file.
 */
class MemoryDistributionMetricType(meta: CommonMetricData, memoryUnit: MemoryUnit) : HistogramBase {
    val inner = MemoryDistributionMetric(meta, memoryUnit)

    /**
     * Delegate common methods to the underlying type directly.
     */

    fun accumulate(sample: Long) = inner.accumulate(sample)

    override fun accumulateSamples(samples: List<Long>) = inner.accumulateSamples(samples)

    /**
     * Testing-only methods get an annotation
     */

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    @JvmOverloads
    fun testGetValue(pingName: String? = null) = inner.testGetValue(pingName)

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    @JvmOverloads
    fun testGetNumRecordedErrors(error: ErrorType) = inner.testGetNumRecordedErrors(error)

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    @JvmOverloads
    fun testHasValue(pingName: String? = null): Boolean {
        return this.testGetValue(pingName) != null
    }
}
