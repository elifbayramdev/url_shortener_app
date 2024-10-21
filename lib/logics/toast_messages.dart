import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_shortener_app/theme/toast_colors.dart';
import 'package:flutter/services.dart';

mixin ToastMixin<T extends StatefulWidget> on State<T> {
  void showToast({
    String? description,
    String? title,
    required BuildContext context,
    required EnumToastMessage type,
    bool hasBorder = false,
  }) {
    final overlay = Overlay.of(context);
    // Declare overlayEntry as late to ensure it's initialized before usage
    late OverlayEntry overlayEntry;
    bool isOverlayVisible = true;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 70.0,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 0) {
                if (isOverlayVisible) {
                  overlayEntry.remove();
                  isOverlayVisible = false;
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: getToastColor(type),
                borderRadius: BorderRadius.circular(16),
                border: hasBorder ? getToastBorder(type) : null,
              ),
              child: Row(
                children: [
                  getSvgAsset(type),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title == null ? getTitle(type) : title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          description == null
                              ? getDescription(type)
                              : description,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    child: SvgPicture.asset(
                      'assets/vectors/close.svg',
                    ),
                    onTap: () {
                      if (isOverlayVisible) {
                        overlayEntry.remove();
                        isOverlayVisible = false;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);

    // Remove the toast after a delay, only if it's still visible
    Future.delayed(Duration(seconds: 3), () {
      if (isOverlayVisible && mounted) {
        overlayEntry.remove();
        isOverlayVisible = false;
      }
    });
  }

  // Toast messages' titles if it is not given
  String getTitle(EnumToastMessage type) {
    switch (type) {
      case EnumToastMessage.info:
        return 'Info';
      case EnumToastMessage.success:
        return 'Success';
      case EnumToastMessage.warning:
        return 'Warning';
      case EnumToastMessage.error:
        return 'Error';
      default:
        return 'Default';
    }
  }

  // Toast messages' titles if it is not given
  String getDescription(EnumToastMessage type) {
    switch (type) {
      case EnumToastMessage.info:
        return 'Info';
      case EnumToastMessage.success:
        return 'Success';
      case EnumToastMessage.warning:
        return 'Warning';
      case EnumToastMessage.error:
        return 'Error';
      default:
        return 'Default';
    }
  }

  // Get toast messages' icons
  SvgPicture getSvgAsset(EnumToastMessage type) {
    switch (type) {
      case EnumToastMessage.info:
        return SvgPicture.asset('assets/vectors/info.svg');
      case EnumToastMessage.success:
        return SvgPicture.asset('assets/vectors/success.svg');
      case EnumToastMessage.warning:
        return SvgPicture.asset('assets/vectors/warning.svg');
      case EnumToastMessage.error:
        return SvgPicture.asset('assets/vectors/error.svg');
    }
  }

  // Get toast messages' background colors
  Color getToastColor(EnumToastMessage type) {
    switch (type) {
      case EnumToastMessage.info:
        return ToastColors.infoColor;
      case EnumToastMessage.success:
        return ToastColors.successColor;
      case EnumToastMessage.warning:
        return ToastColors.warningColor;
      case EnumToastMessage.error:
        return ToastColors.errorColor;
    }
  }

  // Get toast messages' borders
  Border getToastBorder(EnumToastMessage type) {
    switch (type) {
      case EnumToastMessage.info:
        return Border.all(
          color: ToastColors.infoBorderColor,
        );
      case EnumToastMessage.success:
        return Border.all(
          color: ToastColors.successBorderColor,
        );
      case EnumToastMessage.warning:
        return Border.all(
          color: ToastColors.warningBorderColor,
        );
      case EnumToastMessage.error:
        return Border.all(
          color: ToastColors.errorBorderColor,
        );
    }
  }
}

enum EnumToastMessage { info, success, warning, error }
