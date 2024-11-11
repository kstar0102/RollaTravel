import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ButtonWidgetType {
  LoginText,
  ContinueText,
  CreateAccountTitle,
  EditProfileText,
  SettingText,
  FollowingText,
  startTripTitle,
  endTripTitle
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
      case ButtonWidgetType.LoginText:
        btnTitle = login_title;
        break;
      case ButtonWidgetType.ContinueText:
        btnTitle = continue_text;
        break;
      case ButtonWidgetType.CreateAccountTitle:
        btnTitle = create_account;
        break;
      case ButtonWidgetType.EditProfileText:
        btnTitle = edit_profile;
        break;
      case ButtonWidgetType.FollowingText:
        btnTitle = following;
        break;
      case ButtonWidgetType.SettingText:
        btnTitle = settings;
        break;
      case ButtonWidgetType.startTripTitle:
        btnTitle = start_trip;
        break;
      case ButtonWidgetType.endTripTitle:
        btnTitle = end_trip;
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
            height: vh(context, 5),
            child: Container(
              decoration: BoxDecoration(
                color:  widget.fullColor ,
                border: Border.all(color: widget.borderColor!),
                borderRadius: BorderRadius.circular(15)
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
                fontSize: 36.sp,
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
