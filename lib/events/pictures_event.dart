abstract class PicturesEvent {}

class LoginEvent extends PicturesEvent {}

class LogoutEvent extends PicturesEvent {}

class UploadImageEvent extends PicturesEvent {
  final int index;

  UploadImageEvent(this.index);
}
