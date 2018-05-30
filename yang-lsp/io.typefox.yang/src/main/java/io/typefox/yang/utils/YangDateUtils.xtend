package io.typefox.yang.utils

import io.typefox.yang.yang.Revision
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Comparator

/**
 * Utilities for dates in YANG.
 * 
 * @author akos.kitta
 */
abstract class YangDateUtils {

	/**
	 * The YANG revision format.
	 * <br>
	 * From RFC-7950: {@code YYYY-MM-DD}.
	 * <br>
	 * Corresponding JAVA representation: {@code yyyy-MM-dd}.
	 * <p>
	 * See: https://tools.ietf.org/html/rfc7950#section-7.1.9
	 */
	public static val REVISION_FORMAT = "yyyy-MM-dd";

	/**
	 * The thread safe date format for the revision date.
	 */
	static val REVISION_DATE_FORMAT = new DateFormatThreadLocal(REVISION_FORMAT);

	/**
	 * Null-safe revision comparator that does not compare the revisions at all if 
	 * the dates cannot be interpreted and/or parsed.
	 */
	static val REVISION_DATE_COMPARATOR = new Comparator<Revision> {

		override compare(Revision left, Revision right) {
			val leftTime = left.timeSafe;
			val rightTime = right.timeSafe;
			if (leftTime === -1L || rightTime === -1L) {
				return 0;
			}
			return Long.compare(leftTime, rightTime);
		}

		private def getTimeSafe(Revision it) {
			if (it === null || revision.nullOrEmpty) {
				return -1L;
			}
			try {
				return revisionDateFormat.parse(revision).time;
			} catch (ParseException e) {
				return -1L;
			}
		}

	}
	
	/**
	 * Returns with {@code true} if the first revision argument is 
	 * chronological strictly greater than the second argument.
	 * If any of the arguments is {@code null}, or the date information is 
	 * not available (or invalid) for any of the arguments, this method returns {@code false}.  
	 */
	static def isGreaterThan(Revision left, Revision right) {
		return REVISION_DATE_COMPARATOR.compare(left, right) > 0;
	}

	/**
	 * Returns with the date format for YANG revisions.
	 */
	static def getRevisionDateFormat() {
		return REVISION_DATE_FORMAT.get;
	}

	private new() {
	}

	private static final class DateFormatThreadLocal extends ThreadLocal<SimpleDateFormat> {

		val SimpleDateFormat delegate;

		new(String pattern) {
			delegate = new SimpleDateFormat(pattern);
			delegate.lenient = false;
		}

		override get() {
			return delegate;
		}

		override set(SimpleDateFormat value) {
			// NOOP
		}

	}

}
