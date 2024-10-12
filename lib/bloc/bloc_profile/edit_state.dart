part of 'edit_bloc.dart';

class EditState {
  List<File>? imageUpload;
  int? indexPurpose;
  String? purposeValue;
  int? indexLevel;
  ModelInfoUser? modelInfoUser;
  bool? isLoading;

  EditState({
    this.imageUpload,
    this.indexPurpose,
    this.purposeValue,
    this.indexLevel,
    this.modelInfoUser,
    this.isLoading
  });
}
