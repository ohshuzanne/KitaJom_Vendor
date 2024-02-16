class Accommodation {
  final String accommodationID;
  final String size;
  final String imgUrl;
  bool isFavorated;
  final String description;

  Accommodation({
    required this.accommodationID,
    required this.size,
    required this.imgUrl,
    required this.isFavorated,
    required this.description,
  });

  static List<Accommodation> accommodationList = [
    Accommodation(
      accommodationID: "1",
      size: "3 rooms",
      imgUrl: "images/16.png",
      isFavorated: true,
      description: "big room big house big rings",
    )
  ];
}
