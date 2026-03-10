import prisma from '../../config/db.js';
import { ApiError } from '../../utils/ApiError.js';

interface ListGuestsParams {
  userId: string;
  search?: string;
  filter?: 'all' | 'upcoming' | 'past' | 'cancelled';
  sort?: 'name_asc' | 'name_desc' | 'recent' | 'oldest';
  page?: number;
  limit?: number;
}

export async function listGuests(params: ListGuestsParams) {
  const {
    userId,
    search,
    filter = 'all',
    sort = 'name_asc',
    page = 1,
    limit = 20,
  } = params;

  const skip = (page - 1) * limit;
  const now = new Date();

  // Base where clause
  const where: Record<string, unknown> = { user_id: userId };

  // Search filter
  if (search) {
    where['full_name'] = { contains: search, mode: 'insensitive' };
  }

  // Reservation-based filter
  let guestIds: string[] | undefined;
  if (filter !== 'all') {
    let reservationWhere: Record<string, unknown> = { user_id: userId };
    if (filter === 'upcoming') {
      reservationWhere = { ...reservationWhere, check_in: { gte: now }, status: { not: 'cancelled' as const } };
    } else if (filter === 'past') {
      reservationWhere = { ...reservationWhere, check_out: { lt: now }, status: { not: 'cancelled' as const } };
    } else if (filter === 'cancelled') {
      reservationWhere = { ...reservationWhere, status: 'cancelled' as const };
    }
    const reservations = await prisma.reservation.findMany({
      where: reservationWhere,
      select: { guest_id: true },
      distinct: ['guest_id'],
    });
    guestIds = reservations.map((r) => r.guest_id);
    where['id'] = { in: guestIds };
  }

  // Sort
  let orderBy: Record<string, string>;
  switch (sort) {
    case 'name_desc':
      orderBy = { full_name: 'desc' };
      break;
    case 'recent':
      orderBy = { created_at: 'desc' };
      break;
    case 'oldest':
      orderBy = { created_at: 'asc' };
      break;
    default:
      orderBy = { full_name: 'asc' };
  }

  const [guests, total] = await Promise.all([
    prisma.guest.findMany({
      where,
      orderBy,
      skip,
      take: limit,
      include: {
        reservations: {
          select: { id: true, check_in: true, check_out: true, status: true, total_price: true },
          orderBy: { check_in: 'desc' },
        },
      },
    }),
    prisma.guest.count({ where }),
  ]);

  return {
    guests: guests.map((g) => {
      const totalReservations = g.reservations.length;
      const totalSpent = g.reservations
        .filter((r) => r.status !== 'cancelled')
        .reduce((sum, r) => sum + r.total_price, 0);
      const lastStay = g.reservations.find(
        (r) => r.status !== 'cancelled' && r.check_out <= now,
      );
      const upcomingStay = g.reservations.find(
        (r) => r.status !== 'cancelled' && r.check_in >= now,
      );

      return {
        id: g.id,
        full_name: g.full_name,
        email: g.email,
        phone: g.phone,
        country: g.country,
        notes: g.notes,
        total_reservations: totalReservations,
        total_spent: totalSpent,
        last_stay: lastStay
          ? lastStay.check_out.toISOString()
          : null,
        upcoming_stay: upcomingStay
          ? upcomingStay.check_in.toISOString()
          : null,
        created_at: g.created_at.toISOString(),
      };
    }),
    pagination: {
      page,
      limit,
      total,
      total_pages: Math.ceil(total / limit),
    },
  };
}

export async function searchGuests(userId: string, query: string) {
  const guests = await prisma.guest.findMany({
    where: {
      user_id: userId,
      full_name: { contains: query, mode: 'insensitive' },
    },
    select: { id: true, full_name: true, phone: true },
    take: 10,
    orderBy: { full_name: 'asc' },
  });
  return guests;
}

export async function getGuestById(userId: string, id: string) {
  const guest = await prisma.guest.findFirst({
    where: { id, user_id: userId },
    include: {
      reservations: {
        include: { guest: { select: { full_name: true } } },
        orderBy: { check_in: 'desc' },
      },
    },
  });

  if (!guest) {
    throw ApiError.notFound('Guest not found');
  }

  const now = new Date();
  const confirmedReservations = guest.reservations.filter(
    (r) => r.status !== 'cancelled',
  );
  const totalSpent = confirmedReservations.reduce(
    (sum, r) => sum + r.total_price,
    0,
  );
  const totalNights = confirmedReservations.reduce((sum, r) => {
    const nights = Math.ceil(
      (r.check_out.getTime() - r.check_in.getTime()) / 86400000,
    );
    return sum + nights;
  }, 0);

  return {
    id: guest.id,
    full_name: guest.full_name,
    email: guest.email,
    phone: guest.phone,
    notes: guest.notes,
    country: guest.country,
    id_number: guest.id_number,
    created_at: guest.created_at.toISOString(),
    updated_at: guest.updated_at.toISOString(),
    stats: {
      total_reservations: guest.reservations.length,
      total_spent: totalSpent,
      total_nights: totalNights,
      cancelled: guest.reservations.filter((r) => r.status === 'cancelled')
        .length,
    },
    reservations: guest.reservations.map((r) => ({
      id: r.id,
      check_in: r.check_in.toISOString(),
      check_out: r.check_out.toISOString(),
      num_guests: r.num_guests,
      total_price: r.total_price,
      amount_paid: r.amount_paid,
      payment_status: r.payment_status,
      status: r.status,
      is_upcoming: r.check_in > now,
    })),
  };
}

export async function createGuest(
  userId: string,
  data: {
    full_name: string;
    email?: string | null;
    phone?: string | null;
    notes?: string | null;
    country?: string | null;
    id_number?: string | null;
  },
) {
  const guest = await prisma.guest.create({
    data: {
      user_id: userId,
      full_name: data.full_name,
      email: data.email ?? null,
      phone: data.phone ?? null,
      notes: data.notes ?? null,
      country: data.country ?? null,
      id_number: data.id_number ?? null,
    },
  });

  return {
    ...guest,
    created_at: guest.created_at.toISOString(),
    updated_at: guest.updated_at.toISOString(),
  };
}

export async function updateGuest(
  userId: string,
  id: string,
  data: {
    full_name?: string;
    email?: string | null;
    phone?: string | null;
    notes?: string | null;
    country?: string | null;
    id_number?: string | null;
  },
) {
  const existing = await prisma.guest.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Guest not found');
  }

  const guest = await prisma.guest.update({
    where: { id },
    data,
  });

  return {
    ...guest,
    created_at: guest.created_at.toISOString(),
    updated_at: guest.updated_at.toISOString(),
  };
}

export async function deleteGuest(userId: string, id: string) {
  const guest = await prisma.guest.findFirst({
    where: { id, user_id: userId },
    include: {
      reservations: {
        where: {
          check_in: { gte: new Date() },
          status: { not: 'cancelled' },
        },
      },
    },
  });

  if (!guest) {
    throw ApiError.notFound('Guest not found');
  }

  if (guest.reservations.length > 0) {
    throw ApiError.conflict(
      'Cannot delete guest with upcoming reservations. Cancel or delete the reservations first.',
    );
  }

  await prisma.guest.delete({ where: { id } });
  return { message: 'Guest deleted' };
}
