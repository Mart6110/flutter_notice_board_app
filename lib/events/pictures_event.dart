// PicturesEvent is an abstract class representing events related to picture management
abstract class PicturesEvent {}

// LoginEvent represents the event of a user logging in
class LoginEvent extends PicturesEvent {}

// LogoutEvent represents the event of a user logging out
class LogoutEvent extends PicturesEvent {}

// UploadImageEvent represents the event of uploading an image with the specified index
class UploadImageEvent extends PicturesEvent {
  final int index; // Index of the image to upload

  UploadImageEvent(this.index); // Constructor for creating an UploadImageEvent
}
