import 'package:flutter/cupertino.dart';

class PopupCustom {
  static void showPopup(BuildContext context, {
    String? textContent,
    String? title,
    Widget? content,
    Function? thenFunction,
    required List<Function(BuildContext context)> listOnPress,
    required List<Widget> listAction
  }) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? "Message"),
        content: content ?? Text(textContent ?? ''),
        actions: List.generate((listAction).length, (index) {
          return CupertinoDialogAction(
            onPressed: () => listOnPress[index](context),
            child: listAction[index],
          );
        }),
      ),
    ).then((_) => (thenFunction ?? (){})());
  }
}
