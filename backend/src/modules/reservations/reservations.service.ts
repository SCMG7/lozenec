import { type Prisma } from '@prisma/client';
import prisma from '../../config/db.js';
import { ApiError } from '../../utils/ApiError.js';
import { getMonthRange } from '../../utils/dateHelpers.js';
import type { PaymentMethod, PaymentStatus, ReservationStatus } from '@prisma/client';

interface CreateReservationData {
  guest_id: string;
  check_in: string;
  check_out: string;
  num_guests: number;
  price_per_night: number;
  total_price: number;
  amount_paid?: number;
  payment_status?: PaymentStatus;
  payment_method?: PaymentMethod | null;
  status?: ReservationStatus;
  source?: string | null;
  notes?: string | null;
}

interface UpdateReservationData extends Partial<CreateReservationData> {}

async function checkOverlap(
  userId: string,
  checkIn: Date,
  checkOut: Date,
  excludeId?: string,
) {
  const where: Record<string, unknown> = {
    user_id: userId,
    status: { not: 'cancelled' as const },
    check_in: { lt: checkOut },
    check_out: { gt: checkIn },
  };
  if (excludeId) {
    where['NOT'] = { id: excludeId };
  }
  const conflicts = await prisma.reservation.findMany({
    where,
    include: { guest: { select: { full_name: true } } },
  });
  return conflicts;
}

export async function getCalendar(userId: string, month: string) {
  const { start, end } = getMonthRange(month);
  // Extend range to catch reservations that overlap the month
  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: end },
      check_out: { gte: start },
    },
    include: {
      guest: { select: { id: true, full_name: true } },
    },
    orderBy: { check_in: 'asc' },
  });

  // Monthly summary
  const confirmed = reservations.filter((r) => r.status === 'confirmed');
  const totalRevenue = confirmed.reduce((sum, r) => sum + r.total_price, 0);
  const totalPaid = confirmed.reduce((sum, r) => sum + r.amount_paid, 0);

  return {
    reservations: reservations.map((r) => ({
      id: r.id,
      guest_id: r.guest_id,
      guest_name: r.guest.full_name,
      check_in: r.check_in.toISOString(),
      check_out: r.check_out.toISOString(),
      num_guests: r.num_guests,
      total_price: r.total_price,
      amount_paid: r.amount_paid,
      payment_status: r.payment_status,
      status: r.status,
      source: r.source,
    })),
    summary: {
      total_reservations: reservations.length,
      confirmed: confirmed.length,
      cancelled: reservations.filter((r) => r.status === 'cancelled').length,
      pending: reservations.filter((r) => r.status === 'pending').length,
      total_revenue: totalRevenue,
      total_paid: totalPaid,
      total_unpaid: totalRevenue - totalPaid,
    },
  };
}

export async function checkConflict(
  userId: string,
  checkIn: string,
  checkOut: string,
  excludeId?: string,
) {
  const conflicts = await checkOverlap(
    userId,
    new Date(checkIn),
    new Date(checkOut),
    excludeId,
  );
  return {
    has_conflict: conflicts.length > 0,
    conflicts: conflicts.map((c) => ({
      id: c.id,
      guest_name: c.guest.full_name,
      check_in: c.check_in.toISOString(),
      check_out: c.check_out.toISOString(),
    })),
  };
}

export async function getReservationsByDate(userId: string, date: string) {
  const d = new Date(date);
  const nextDay = new Date(d);
  nextDay.setDate(nextDay.getDate() + 1);

  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lt: nextDay },
      check_out: { gt: d },
    },
    include: {
      guest: { select: { id: true, full_name: true, phone: true } },
    },
    orderBy: { check_in: 'asc' },
  });

  return reservations.map((r) => ({
    id: r.id,
    guest_id: r.guest_id,
    guest_name: r.guest.full_name,
    guest_phone: r.guest.phone,
    check_in: r.check_in.toISOString(),
    check_out: r.check_out.toISOString(),
    num_guests: r.num_guests,
    total_price: r.total_price,
    amount_paid: r.amount_paid,
    payment_status: r.payment_status,
    status: r.status,
  }));
}

export async function getReservationById(userId: string, id: string) {
  const reservation = await prisma.reservation.findFirst({
    where: { id, user_id: userId },
    include: {
      guest: true,
      activity_logs: {
        orderBy: { created_at: 'desc' },
      },
    },
  });

  if (!reservation) {
    throw ApiError.notFound('Reservation not found');
  }

  return {
    ...reservation,
    check_in: reservation.check_in.toISOString(),
    check_out: reservation.check_out.toISOString(),
    created_at: reservation.created_at.toISOString(),
    updated_at: reservation.updated_at.toISOString(),
    guest: {
      ...reservation.guest,
      created_at: reservation.guest.created_at.toISOString(),
      updated_at: reservation.guest.updated_at.toISOString(),
    },
    activity_logs: reservation.activity_logs.map((log) => ({
      ...log,
      created_at: log.created_at.toISOString(),
    })),
  };
}

export async function getReservationSummary(userId: string, id: string) {
  const reservation = await prisma.reservation.findFirst({
    where: { id, user_id: userId },
    include: {
      guest: { select: { id: true, full_name: true, phone: true } },
    },
  });

  if (!reservation) {
    throw ApiError.notFound('Reservation not found');
  }

  return {
    id: reservation.id,
    guest_id: reservation.guest_id,
    guest_name: reservation.guest.full_name,
    guest_phone: reservation.guest.phone,
    check_in: reservation.check_in.toISOString(),
    check_out: reservation.check_out.toISOString(),
    num_guests: reservation.num_guests,
    total_price: reservation.total_price,
    amount_paid: reservation.amount_paid,
    payment_status: reservation.payment_status,
    status: reservation.status,
    notes: reservation.notes,
  };
}

export async function createReservation(
  userId: string,
  data: CreateReservationData,
) {
  const checkIn = new Date(data.check_in);
  const checkOut = new Date(data.check_out);

  if (checkIn >= checkOut) {
    throw ApiError.badRequest('Check-out must be after check-in');
  }

  // Verify guest belongs to user
  const guest = await prisma.guest.findFirst({
    where: { id: data.guest_id, user_id: userId },
  });
  if (!guest) {
    throw ApiError.notFound('Guest not found');
  }

  // Check overlap
  const conflicts = await checkOverlap(userId, checkIn, checkOut);
  if (conflicts.length > 0) {
    throw ApiError.conflict(
      `Dates overlap with existing reservation for ${conflicts[0]!.guest.full_name}`,
    );
  }

  const reservation = await prisma.reservation.create({
    data: {
      user_id: userId,
      guest_id: data.guest_id,
      check_in: checkIn,
      check_out: checkOut,
      num_guests: data.num_guests,
      price_per_night: data.price_per_night,
      total_price: data.total_price,
      amount_paid: data.amount_paid ?? 0,
      payment_status: data.payment_status ?? 'unpaid',
      payment_method: data.payment_method ?? null,
      status: data.status ?? 'confirmed',
      source: data.source ?? null,
      notes: data.notes ?? null,
    },
    include: { guest: { select: { full_name: true } } },
  });

  // Log creation
  await prisma.reservationActivityLog.create({
    data: {
      reservation_id: reservation.id,
      user_id: userId,
      action: 'created',
      changes: { status: reservation.status },
    },
  });

  return {
    ...reservation,
    check_in: reservation.check_in.toISOString(),
    check_out: reservation.check_out.toISOString(),
    created_at: reservation.created_at.toISOString(),
    updated_at: reservation.updated_at.toISOString(),
  };
}

export async function updateReservation(
  userId: string,
  id: string,
  data: UpdateReservationData,
) {
  const existing = await prisma.reservation.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Reservation not found');
  }

  const checkIn = data.check_in ? new Date(data.check_in) : existing.check_in;
  const checkOut = data.check_out
    ? new Date(data.check_out)
    : existing.check_out;

  if (checkIn >= checkOut) {
    throw ApiError.badRequest('Check-out must be after check-in');
  }

  // Check overlap if dates changed
  if (data.check_in || data.check_out) {
    const conflicts = await checkOverlap(userId, checkIn, checkOut, id);
    if (conflicts.length > 0) {
      throw ApiError.conflict(
        `Dates overlap with existing reservation for ${conflicts[0]!.guest.full_name}`,
      );
    }
  }

  // Track changes for activity log
  const changes: Record<string, { from: unknown; to: unknown }> = {};
  const updateData: Record<string, unknown> = {};

  if (data.guest_id !== undefined && data.guest_id !== existing.guest_id) {
    changes['guest_id'] = { from: existing.guest_id, to: data.guest_id };
    updateData['guest_id'] = data.guest_id;
  }
  if (data.check_in !== undefined) {
    changes['check_in'] = {
      from: existing.check_in.toISOString(),
      to: data.check_in,
    };
    updateData['check_in'] = new Date(data.check_in);
  }
  if (data.check_out !== undefined) {
    changes['check_out'] = {
      from: existing.check_out.toISOString(),
      to: data.check_out,
    };
    updateData['check_out'] = new Date(data.check_out);
  }
  if (
    data.num_guests !== undefined &&
    data.num_guests !== existing.num_guests
  ) {
    changes['num_guests'] = { from: existing.num_guests, to: data.num_guests };
    updateData['num_guests'] = data.num_guests;
  }
  if (
    data.price_per_night !== undefined &&
    data.price_per_night !== existing.price_per_night
  ) {
    changes['price_per_night'] = {
      from: existing.price_per_night,
      to: data.price_per_night,
    };
    updateData['price_per_night'] = data.price_per_night;
  }
  if (
    data.total_price !== undefined &&
    data.total_price !== existing.total_price
  ) {
    changes['total_price'] = {
      from: existing.total_price,
      to: data.total_price,
    };
    updateData['total_price'] = data.total_price;
  }
  if (
    data.amount_paid !== undefined &&
    data.amount_paid !== existing.amount_paid
  ) {
    changes['amount_paid'] = {
      from: existing.amount_paid,
      to: data.amount_paid,
    };
    updateData['amount_paid'] = data.amount_paid;
  }
  if (
    data.payment_status !== undefined &&
    data.payment_status !== existing.payment_status
  ) {
    changes['payment_status'] = {
      from: existing.payment_status,
      to: data.payment_status,
    };
    updateData['payment_status'] = data.payment_status;
  }
  if (data.payment_method !== undefined) {
    changes['payment_method'] = {
      from: existing.payment_method,
      to: data.payment_method,
    };
    updateData['payment_method'] = data.payment_method;
  }
  if (data.status !== undefined && data.status !== existing.status) {
    changes['status'] = { from: existing.status, to: data.status };
    updateData['status'] = data.status;
  }
  if (data.source !== undefined) {
    changes['source'] = { from: existing.source, to: data.source };
    updateData['source'] = data.source;
  }
  if (data.notes !== undefined) {
    changes['notes'] = { from: existing.notes, to: data.notes };
    updateData['notes'] = data.notes;
  }

  const reservation = await prisma.reservation.update({
    where: { id },
    data: updateData,
    include: { guest: { select: { full_name: true } } },
  });

  // Log changes
  if (Object.keys(changes).length > 0) {
    await prisma.reservationActivityLog.create({
      data: {
        reservation_id: id,
        user_id: userId,
        action: 'updated',
        changes: changes as Prisma.InputJsonValue,
      },
    });
  }

  return {
    ...reservation,
    check_in: reservation.check_in.toISOString(),
    check_out: reservation.check_out.toISOString(),
    created_at: reservation.created_at.toISOString(),
    updated_at: reservation.updated_at.toISOString(),
  };
}

export async function markAsPaid(userId: string, id: string) {
  const existing = await prisma.reservation.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Reservation not found');
  }

  const reservation = await prisma.reservation.update({
    where: { id },
    data: {
      payment_status: 'paid',
      amount_paid: existing.total_price,
    },
    include: { guest: { select: { full_name: true } } },
  });

  await prisma.reservationActivityLog.create({
    data: {
      reservation_id: id,
      user_id: userId,
      action: 'marked_paid',
      changes: {
        payment_status: { from: existing.payment_status, to: 'paid' },
        amount_paid: { from: existing.amount_paid, to: existing.total_price },
      },
    },
  });

  return {
    ...reservation,
    check_in: reservation.check_in.toISOString(),
    check_out: reservation.check_out.toISOString(),
    created_at: reservation.created_at.toISOString(),
    updated_at: reservation.updated_at.toISOString(),
  };
}

export async function deleteReservation(userId: string, id: string) {
  const existing = await prisma.reservation.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Reservation not found');
  }

  await prisma.reservation.delete({ where: { id } });
  return { message: 'Reservation deleted' };
}
