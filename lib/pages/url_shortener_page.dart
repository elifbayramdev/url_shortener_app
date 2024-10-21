import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_shortener_app/database/db.dart';
import 'package:url_shortener_app/logics/url_shortener_logic.dart';
import 'package:url_shortener_app/theme/colors.dart';
import 'package:url_shortener_app/logics/toast_messages.dart';

class UrlShortenerPage extends StatefulWidget {
  @override
  _URLShortenerPageState createState() => _URLShortenerPageState();
}

class _URLShortenerPageState extends State<UrlShortenerPage> with ToastMixin {
  final urlController = TextEditingController();
  List<Map<String, dynamic>> _savedUrls = [];
  String? _shortenedUrl;
  final UrlShortenerLogic _urlShortenerLogic = UrlShortenerLogic();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Circular progress indicator for buttons
  bool isLoadingCopy = false;
  bool isLoadingPaste = false;
  bool isLoadingShorten = false;

  @override
  void initState() {
    super.initState();
    loadUrls();
  }

  Future<void> loadUrls() async {
    List<Map<String, dynamic>> urls = await _urlShortenerLogic.loadUrls();
    setState(() {
      _savedUrls = List.from(urls);
    });
  }

  Future<void> pasteUrl() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      urlController.text = data.text!;
      showToast(
          context: context,
          type: EnumToastMessage.success,
          title: 'Url is pasted.');
    } else {
      showToast(
          context: context,
          type: EnumToastMessage.warning,
          description: 'There is nothing to paste!');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'URL Shortener App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: _savedUrls.length,
                    itemBuilder: (context, index) {
                      final urlData = _savedUrls[index];
                      final urlId = urlData['id'];

                      return Dismissible(
                        key: Key(urlId.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: AlignmentDirectional.centerEnd,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) async {
                          // Remove the URL from the database
                          await _dbHelper.deleteUrl(urlId).then(
                            (value) {
                              switch (value.responseStatus) {
                                case ResponseDbEnum.error:
                                  showToast(
                                      context: context,
                                      type: EnumToastMessage.error);
                                  break;
                                case ResponseDbEnum.success:
                                  showToast(
                                      context: context,
                                      type: EnumToastMessage.success);
                                  break;
                                case ResponseDbEnum.warning:
                                  showToast(
                                      context: context,
                                      type: EnumToastMessage.warning);
                                  break;
                                default:
                              }
                              loadUrls();
                            },
                          );

                          // Remove the URL from the UI
                          setState(() {
                            _savedUrls.removeAt(index);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.grey, blurRadius: 3)
                              ],
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    final shortenedUrl =
                                        urlData['shortened_url'];
                                    if (shortenedUrl != null) {
                                      Clipboard.setData(
                                          ClipboardData(text: shortenedUrl));
                                      showToast(
                                          context: context,
                                          type: EnumToastMessage.info,
                                          title: 'Url is copied.');
                                    } else {
                                      showToast(
                                          context: context,
                                          type: EnumToastMessage.warning,
                                          title: 'No shortened URL available.');
                                    }
                                  },
                                  icon: Icon(
                                    Icons.link,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Shortened Url: ${urlData['shortened_url']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Original Url: ${urlData['original_url']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                helperText: 'Please enter the URL to shorten',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  child: Container(
                    width: 100,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Paste',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    pasteUrl();
                    print('Paste button is pressed');
                  },
                ),
                GestureDetector(
                  child: Container(
                    width: 100,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Shorten',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    final url = urlController.text;
                    if (url.isNotEmpty) {
                      _urlShortenerLogic.shortenUrl(url).then(
                        (value) {
                          switch (value.responseStatus) {
                            case ResponseEnum.error:
                              showToast(
                                  context: context,
                                  type: EnumToastMessage.error);
                              break;
                            case ResponseEnum.success:
                              showToast(
                                  context: context,
                                  type: EnumToastMessage.success);
                              break;
                            case ResponseEnum.warning:
                              showToast(
                                  context: context,
                                  type: EnumToastMessage.warning);
                              break;
                            default:
                          }
                          loadUrls();
                        },
                      );
                    }
                    urlController.clear();
                    print('Shorten button is pressed');
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
