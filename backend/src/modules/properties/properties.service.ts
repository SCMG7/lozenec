import prisma from '../../config/db.js';
import { ApiError } from '../../utils/ApiError.js';

interface CreatePropertyData {
  name: string;
  address?: string | null;
  property_type?: string | null;
  default_price_per_night?: number;
  check_in_time?: string;
  check_out_time?: string;
  currency?: string;
}

interface UpdatePropertyData extends Partial<CreatePropertyData> {}

export async function listProperties(userId: string) {
  const properties = await prisma.property.findMany({
    where: { user_id: userId, is_active: true },
    orderBy: { created_at: 'asc' },
  });

  return properties.map((p) => ({
    id: p.id,
    name: p.name,
    address: p.address,
    property_type: p.property_type,
    default_price_per_night: p.default_price_per_night,
    check_in_time: p.check_in_time,
    check_out_time: p.check_out_time,
    currency: p.currency,
    is_active: p.is_active,
    created_at: p.created_at.toISOString(),
    updated_at: p.updated_at.toISOString(),
  }));
}

export async function getPropertyById(userId: string, id: string) {
  const property = await prisma.property.findFirst({
    where: { id, user_id: userId },
  });

  if (!property) {
    throw ApiError.notFound('Property not found');
  }

  return {
    id: property.id,
    name: property.name,
    address: property.address,
    property_type: property.property_type,
    default_price_per_night: property.default_price_per_night,
    check_in_time: property.check_in_time,
    check_out_time: property.check_out_time,
    currency: property.currency,
    is_active: property.is_active,
    created_at: property.created_at.toISOString(),
    updated_at: property.updated_at.toISOString(),
  };
}

export async function createProperty(userId: string, data: CreatePropertyData) {
  // Check pro status for multi-property (checks both subscription and lifetime purchase)
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { pro_expires_at: true, has_lifetime_tax_report: true },
  });

  const now = new Date();
  const isPro =
    user?.has_lifetime_tax_report ||
    (user?.pro_expires_at !== null && user?.pro_expires_at !== undefined && user.pro_expires_at > now);

  if (!isPro) {
    const activeCount = await prisma.property.count({
      where: { user_id: userId, is_active: true },
    });
    if (activeCount >= 1) {
      throw new ApiError(403, 'PRO_REQUIRED');
    }
  }

  const property = await prisma.property.create({
    data: {
      user_id: userId,
      name: data.name,
      address: data.address ?? null,
      property_type: data.property_type ?? null,
      default_price_per_night: data.default_price_per_night ?? 0,
      check_in_time: data.check_in_time ?? '14:00',
      check_out_time: data.check_out_time ?? '12:00',
      currency: data.currency ?? 'EUR',
    },
  });

  return {
    id: property.id,
    name: property.name,
    address: property.address,
    property_type: property.property_type,
    default_price_per_night: property.default_price_per_night,
    check_in_time: property.check_in_time,
    check_out_time: property.check_out_time,
    currency: property.currency,
    is_active: property.is_active,
    created_at: property.created_at.toISOString(),
    updated_at: property.updated_at.toISOString(),
  };
}

export async function updateProperty(
  userId: string,
  id: string,
  data: UpdatePropertyData,
) {
  const existing = await prisma.property.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Property not found');
  }

  const updateData: Record<string, unknown> = {};
  if (data.name !== undefined) updateData['name'] = data.name;
  if (data.address !== undefined) updateData['address'] = data.address;
  if (data.property_type !== undefined) updateData['property_type'] = data.property_type;
  if (data.default_price_per_night !== undefined) updateData['default_price_per_night'] = data.default_price_per_night;
  if (data.check_in_time !== undefined) updateData['check_in_time'] = data.check_in_time;
  if (data.check_out_time !== undefined) updateData['check_out_time'] = data.check_out_time;
  if (data.currency !== undefined) updateData['currency'] = data.currency;

  const property = await prisma.property.update({
    where: { id },
    data: updateData,
  });

  return {
    id: property.id,
    name: property.name,
    address: property.address,
    property_type: property.property_type,
    default_price_per_night: property.default_price_per_night,
    check_in_time: property.check_in_time,
    check_out_time: property.check_out_time,
    currency: property.currency,
    is_active: property.is_active,
    created_at: property.created_at.toISOString(),
    updated_at: property.updated_at.toISOString(),
  };
}

export async function deleteProperty(userId: string, id: string) {
  const existing = await prisma.property.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Property not found');
  }

  // Soft delete: set is_active = false
  await prisma.property.update({
    where: { id },
    data: { is_active: false },
  });

  return { message: 'Property deleted' };
}
