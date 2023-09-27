import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final List<CustomAppBarAction> actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.showBackButton = true,
    this.onBackButtonPressed,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  onBackButtonPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions.map((action) {
        return IconButton(
          icon: Icon(action.icon),
          onPressed: action.callback,
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class CustomAppBarAction {
  final IconData icon;
  final VoidCallback callback;

  CustomAppBarAction({
    required this.icon,
    required this.callback,
  });
}
