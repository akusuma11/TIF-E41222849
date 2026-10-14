class CreateCollectionArgs {
  final bool isEdit;
  final String type;
  final String collectionId;
  final String? title;
  final String? desc;
  final int? bgColor;

  const CreateCollectionArgs.edit({
    required this.type,
    required this.collectionId,
    this.title,
    this.desc,
    this.bgColor,
  }) : isEdit = true;
}
