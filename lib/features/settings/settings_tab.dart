import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/utils/app_colors.dart';
import 'package:todo_app/core/utils/app_images.dart';
import 'package:todo_app/core/utils/styles.dart';
import 'package:todo_app/features/login/login_screen.dart';
import 'package:todo_app/features/settings/settings_widget.dart';
import 'package:todo_app/firebase/firebase_functions.dart';
import 'package:todo_app/providers/my_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyProvider>(context);
    var local = AppLocalizations.of(context)!;
    List<String> langList = [local.english, local.arabic];
    List<String> themeList = [local.dark, local.light];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 75.h),
          Text(
            'Settings',
            textAlign: TextAlign.center,
            style: AppStyles.bodyL.copyWith(color: AppColor.primaryColor),
          ),
          SizedBox(height: 5.h),
          Image.asset(
            AppImages.settingsTab,
            width: 135.w,
            height: 135.h,
          ),
          SizedBox(height: 5.h),
          SettingsWidget(
            iconPath: AppImages.user,
            isHint: true,
            hint: 'name, age, ...etc',
            title: 'Account info',
            onTap: () {},
          ),
          SettingsWidget(
            iconPath: AppImages.privacy,
            isHint: true,
            hint: 'email, password, mobile',
            title: 'Privacy',
            onTap: () {},
          ),
          SettingsWidget(
            iconPath: AppImages.theme,
            title: 'Theme Mode',
            isDropMenu: true,
            dropDownItems: themeList,
            onDropDownChanged: (String? value) {
              if (value == local.dark) {
                provider.changeThemeMode(ThemeMode.dark);
              } else if (value == local.light) {
                provider.changeThemeMode(ThemeMode.light);
              }
            },
          ),
          SettingsWidget(
            iconPath: AppImages.notification,
            title: 'Notification',
            onTap: () {},
          ),
          SettingsWidget(
            iconPath: AppImages.language,
            title: 'Language',
            isDropMenu: true,
            dropDownItems: langList,
            onDropDownChanged: (String? value) {
              if (value == local.arabic) {
                provider.changeLanguageCode('ar');
              } else if (value == local.english) {
                provider.changeLanguageCode('en');
              }
            },
          ),
          SettingsWidget(
            iconPath: AppImages.aboutUs,
            title: 'About Us',
            onTap: () {},
          ),
          SettingsWidget(
            iconPath: AppImages.logout,
            title: 'Logout',
            onTap: () async {
              await FirebaseFunctions.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            },
          ),
          SizedBox(height: 75.h),
        ],
      ),
    );
  }
}
