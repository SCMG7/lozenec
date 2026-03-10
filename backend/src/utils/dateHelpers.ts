import {
  startOfMonth,
  endOfMonth,
  parse,
  differenceInCalendarDays,
  max as dateMax,
  min as dateMin,
} from 'date-fns';

/**
 * Get the start and end dates of a month from a "YYYY-MM" string.
 */
export function getMonthRange(yearMonth: string): { start: Date; end: Date } {
  const parsed = parse(yearMonth + '-01', 'yyyy-MM-dd', new Date());
  return {
    start: startOfMonth(parsed),
    end: endOfMonth(parsed),
  };
}

/**
 * Check if two date ranges overlap.
 * Overlap means: a_start < b_end AND a_end > b_start
 */
export function datesOverlap(
  aStart: Date,
  aEnd: Date,
  bStart: Date,
  bEnd: Date,
): boolean {
  return aStart < bEnd && aEnd > bStart;
}

/**
 * Count the number of nights that a reservation (checkIn..checkOut)
 * spends within a given range (rangeStart..rangeEnd).
 *
 * A "night" is counted for each date d where checkIn <= d < checkOut
 * and rangeStart <= d < rangeEnd+1day.
 */
export function countNightsInRange(
  checkIn: Date,
  checkOut: Date,
  rangeStart: Date,
  rangeEnd: Date,
): number {
  const effectiveStart = dateMax([checkIn, rangeStart]);
  const effectiveEnd = dateMin([checkOut, new Date(rangeEnd.getTime() + 86400000)]);
  const nights = differenceInCalendarDays(effectiveEnd, effectiveStart);
  return Math.max(0, nights);
}
