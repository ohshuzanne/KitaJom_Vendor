class BookingDetail {
  final String listingName;
  final dynamic totalAmount;
  final String listingType;
  final String checkIn;
  final String checkOut;
  final String night;
  final List<dynamic> ticketType;
  final String confirmationNumber;
  final String userId;

  BookingDetail({
    required this.listingName,
    required this.totalAmount,
    required this.listingType,
    required this.checkIn,
    required this.checkOut,
    required this.night,
    required this.ticketType,
    required this.confirmationNumber,
    required this.userId,
  });
}
