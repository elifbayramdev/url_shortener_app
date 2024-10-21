import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_shortener_app/database/db.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_shortener_app/pages/url_shortener_page.dart';

class UrlShortenerLogic {
  final String apiKey = '8943b7fd64cd8b1770ff5affa9a9437b'; // API Key
  final String baseUrl = 'https://www.shareaholic.com/v2/share/shorten_link';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<bool> urlExists(String url) async {
    return await _dbHelper.checkUrlExists(url);
  }

  Future<List<Map<String, dynamic>>> loadUrls() async {
    List<Map<String, dynamic>> urls = await _dbHelper.getUrls();
    return urls;
  }

  Future<UrlResponse> shortenUrl(String url) async {
    Uri apiUrl = Uri.parse('$baseUrl?apikey=$apiKey&url=$url');
    bool urlExists = await _dbHelper.checkUrlExists(url);

    if (urlExists) {
      print('URL exists');
      return UrlResponse('', ResponseEnum.warning);
    } else {
      try {
        final response = await http.get(
          apiUrl,
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data);
          await saveUrl(url, data['data']);
          loadUrls();
          return UrlResponse(data['data'], ResponseEnum.success);
        } else {
          print('API error: ${response.statusCode}');
          return UrlResponse('', ResponseEnum.error);
        }
      } catch (e) {
        print('Error during the request: $e');
        return UrlResponse('', ResponseEnum.error);
      }
    }
    return UrlResponse('', ResponseEnum.error);
  }

  Future<void> saveUrl(String originalUrl, String shortenedUrl) async {
    await _dbHelper.insertUrl(originalUrl, shortenedUrl);
  }

  Future<String?> pasteUrl() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      return data.text;
    }
    return null;
  }

  Future<void> copyShortenedUrl(String shortenedUrl) async {
    await Clipboard.setData(ClipboardData(text: shortenedUrl));
  }
}

class UrlResponse {
  UrlResponse(this.url, this.responseStatus);
  String? url;
  ResponseEnum? responseStatus;
}

enum ResponseEnum { error, success, warning }
