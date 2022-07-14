import 'dart:io';
import 'package:mime/mime.dart';

class MimeHelper {
  MimeHelper._();

  static String? getFileMimeFromName(String path){
    return lookupMimeType(path);
  }

  static Future<String?> getFileMimeFromMagic(String path) async {
    return getMimeByFileHeader(await readFileBytes(path, defaultMagicNumbersMaxLength));
  }

  static String? getMimeByFileHeader(List<int> headerBytes){
    return lookupMimeType('', headerBytes: headerBytes);
  }

  static String? getMimeByFileHeaderOrName(String path, List<int> headerBytes){
    return lookupMimeType(path, headerBytes: headerBytes);
  }

  static String getExtensionFromMime(String mime){
    return extensionFromMime(mime);
  }

  static String? getExtensionFromContentType(String? type){
    if(type == null) {
      return null;
    }

    return extensionFromMime(type.split(';')[0]);
  }

  static bool isVideoHttpHeader(String mime) {
    if(mime.toLowerCase().startsWith('video/')) {
      return true;
    }

    return false;
  }

  static bool isAudioHttpHeader(String mime) {
    if(mime.toLowerCase().startsWith('audio/')) {
      return true;
    }

    return false;
  }

  static bool isImageHttpHeader(String mime) {
    if(mime.toLowerCase().startsWith('image/')) {
      return true;
    }

    return false;
  }

  static bool isPdfHttpHeader(String mime) {
    if(mime.toLowerCase().contains('/pdf')) {
      return true;
    }

    return false;
  }

  static bool isVideoByMime(String? mime){
    if(mime == null) {
      return false;
    }

    // || mime.contains('flv')

    if(mime.startsWith('video')){
      if(mime.contains('mp4') || mime.contains('3gp') || mime.contains('webm')
          || mime.contains('mov') || mime.contains('mkv') || mime.contains('matroska')
          ) {
        return true;
      }
    }

    return false;
  }

  static bool isAudioByMime(String? mime){
    if(mime == null) {
      return false;
    }

    // || mime.contains('wma') || mime.contains('midi')

    if(mime.startsWith('audio')){
      if(mime.contains('mp2') || mime.contains('mp3') || mime.contains('mpeg')
          || mime.contains('ogg') || mime.contains('aac') || mime.contains('amr')
          || mime.contains('wav') || mime.contains('3gp') || mime.contains('flac')
          ) {
        return true;
      }
    }

    return false;
  }

  static bool isImageByMime(String? mime){
    if(mime == null) {
      return false;
    }

    if(mime.startsWith('image')){
      if(mime.contains('png') || mime.contains('jpg') || mime.contains('jpeg')
          || mime.contains('webp') || mime.contains('gif') || mime.contains('tif')) {
        return true;
      }
    }

    return false;
  }

  static bool isPdfByMime(String? mime){
    if(mime == null) {
      return false;
    }

    if(mime.contains('/pdf')){
      return true;
    }

    return false;
  }

  static Future<List<int>> readFileBytes(String path, int len) async {
    final file = File(path);
    var fileOpen = await file.open(mode: FileMode.read);

    var count = 0;
    var bytes = <int>[];
    var byte = 0;

    while (byte != -1 && count < len) {
      byte = fileOpen.readByteSync();
      bytes.add(byte);
      count++;
    }

    await fileOpen.close();
    return bytes;
  }
}