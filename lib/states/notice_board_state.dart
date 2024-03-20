// NoticeBoardState class represents the state of the notice board.
class NoticeBoardState {
  List<String> base64ImageList; // List to store base64 encoded images

  // Constructor to initialize the NoticeBoardState with a list of base64 encoded images.
  NoticeBoardState({required this.base64ImageList});

  // Method to add a list of images to the notice board state.
  void addImages(List<String> images) {
    base64ImageList.addAll(images);
  }

  // Method to remove a specific image from the notice board state.
  void removeImage(String base64Image) {
    base64ImageList.remove(base64Image);
  }
}
