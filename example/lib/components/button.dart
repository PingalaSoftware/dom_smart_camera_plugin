import 'package:flutter/material.dart';

class OptionsButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? iconSize;
  final double? borderRadios;

  const OptionsButton(
      {Key? key,
      this.text,
      this.icon,
      required this.size,
      this.backgroundColor,
      this.textColor,
      this.height,
      this.iconSize,
      this.borderRadios})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: height ?? 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadios ?? 8),
        color:
            backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.8),
      ),
      child: Center(
        child: (icon != null && text != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: textColor ?? Theme.of(context).secondaryHeaderColor,
                    size: iconSize ?? 24,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    text ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          textColor ?? Theme.of(context).secondaryHeaderColor,
                    ),
                  )
                ],
              )
            : icon != null
                ? Icon(
                    icon,
                    color: textColor ?? Theme.of(context).secondaryHeaderColor,
                    size: iconSize ?? 24,
                  )
                : Text(
                    text ?? "",
                    style: TextStyle(
                      color:
                          textColor ?? Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
      ),
    );
  }
}
