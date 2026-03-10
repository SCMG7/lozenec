import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.userId,
    required super.guestId,
    super.guestName,
    super.guestPhone,
    super.guestEmail,
    required super.checkInDate,
    required super.checkOutDate,
    required super.numNights,
    required super.pricePerNight,
    required super.totalPrice,
    super.depositAmount,
    super.depositReceived,
    super.status,
    super.paymentStatus,
    super.amountPaid,
    super.notes,
    super.activityLog,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final reservation = Reservation.fromJson(json);
    return ReservationModel(
      id: reservation.id,
      userId: reservation.userId,
      guestId: reservation.guestId,
      guestName: reservation.guestName,
      guestPhone: reservation.guestPhone,
      guestEmail: reservation.guestEmail,
      checkInDate: reservation.checkInDate,
      checkOutDate: reservation.checkOutDate,
      numNights: reservation.numNights,
      pricePerNight: reservation.pricePerNight,
      totalPrice: reservation.totalPrice,
      depositAmount: reservation.depositAmount,
      depositReceived: reservation.depositReceived,
      status: reservation.status,
      paymentStatus: reservation.paymentStatus,
      amountPaid: reservation.amountPaid,
      notes: reservation.notes,
      activityLog: reservation.activityLog,
      createdAt: reservation.createdAt,
      updatedAt: reservation.updatedAt,
    );
  }

  factory ReservationModel.fromEntity(Reservation reservation) {
    return ReservationModel(
      id: reservation.id,
      userId: reservation.userId,
      guestId: reservation.guestId,
      guestName: reservation.guestName,
      guestPhone: reservation.guestPhone,
      guestEmail: reservation.guestEmail,
      checkInDate: reservation.checkInDate,
      checkOutDate: reservation.checkOutDate,
      numNights: reservation.numNights,
      pricePerNight: reservation.pricePerNight,
      totalPrice: reservation.totalPrice,
      depositAmount: reservation.depositAmount,
      depositReceived: reservation.depositReceived,
      status: reservation.status,
      paymentStatus: reservation.paymentStatus,
      amountPaid: reservation.amountPaid,
      notes: reservation.notes,
      activityLog: reservation.activityLog,
      createdAt: reservation.createdAt,
      updatedAt: reservation.updatedAt,
    );
  }
}
