 
import 'package:pdf_reader/sign_vanban_den/model/media_model.dart';

class MediaState {
  final List<MediaModel>? medias;
  final bool? isSelectedMedia;

  const MediaState({this.medias, this.isSelectedMedia});

  MediaState initMedia() {
    List<MediaModel> medias = [];
    return MediaState(medias: medias);
  }

  MediaState cloneWith({mediaPhanAnhs, isSelectedMedia}) => MediaState(
        medias: mediaPhanAnhs ?? this.medias,
        isSelectedMedia: isSelectedMedia ?? this.isSelectedMedia,
      );
}
