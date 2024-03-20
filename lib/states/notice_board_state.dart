import 'package:flutter/material.dart';

class NoticeBoardState {
  List<String> base64ImageList;

  NoticeBoardState({required this.base64ImageList});

  void addImages(List<String> images) {
    base64ImageList.addAll(images);
  }

  void removeImage(String base64Image) {
    base64ImageList.remove(base64Image);
  }
}
