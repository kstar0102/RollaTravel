import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ButtonWidgetType {
  ContinueText,
  ResendCodeTitle,
  SaveTitle,
  StartConversationTitle,
  UpgradeTitle,
  ContactsalesTitle,
  AddCardTitle,
  CloseTitle,
}

class ButtonWidget extends StatefulWidget {
  final ButtonWidgetType btnType;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final Color? fullColor;

  const ButtonWidget({
    Key? key,
    required this.btnType,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
    required this.fullColor
  }) : super(key: key);

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    String btnTitle;
    switch (widget.btnType) {
      case ButtonWidgetType.ContinueText:
        btnTitle = "Continue";
        break;
      case ButtonWidgetType.ResendCodeTitle:
        btnTitle = "Resend the code";
        break;
      case ButtonWidgetType.SaveTitle:
        btnTitle = "Save";
        break;
      case ButtonWidgetType.StartConversationTitle:
        btnTitle = "Save & Start Conversation";
        break;
      case ButtonWidgetType.UpgradeTitle:
        btnTitle = "Upgrade";
        break;
      case ButtonWidgetType.ContactsalesTitle:
        btnTitle = "Contact Sales";
        break;
      default:
        btnTitle = "unknow";
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: SizedBox(
            width: vw(context, 100),
            height: vh(context, 6),
            child: Container(
              decoration: BoxDecoration(
                color:  widget.fullColor ,
                border: Border.all(color: widget.borderColor!),
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0XFF000000),
              textStyle: TextStyle(
                fontFamily: 'LeyendoDEMO',
                fontWeight: FontWeight.w500,
                fontSize: 50.sp,
              ),
            ),
            onPressed: widget.onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(btnTitle, style: TextStyle(color:  widget.textColor!),),
              ],
            ) 
          ),
        ),
      ],
    );
  }
}
