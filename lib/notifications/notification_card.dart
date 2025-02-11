import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/models/isar/stack_theme.dart';
import 'package:stackduo/models/notification_model.dart';
import 'package:stackduo/themes/coin_icon_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/themes/theme_providers.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/format.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/conditional_parent.dart';
import 'package:stackduo/widgets/rounded_container.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';

class NotificationCard extends ConsumerWidget {
  const NotificationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  final NotificationModel notification;

  String extractPrettyDateString(DateTime date) {
    // TODO: format this differently to better match the design
    return Format.extractDateFrom(date.millisecondsSinceEpoch ~/ 1000);
  }

  static const double mobileIconSize = 24;
  static const double desktopIconSize = 30;

  String coinIconPath(IThemeAssets assets, WidgetRef ref) {
    try {
      final coin = coinFromPrettyName(notification.coinName);
      return ref.read(coinIconProvider(coin));
    } catch (_) {
      return notification.iconAssetName;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Util.isDesktop;

    return Stack(
      children: [
        RoundedWhiteContainer(
          padding: isDesktop
              ? const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                )
              : const EdgeInsets.all(12),
          child: Row(
            children: [
              notification.changeNowId == null
                  ? SvgPicture.file(
                      File(
                        coinIconPath(
                            ref.watch(
                              themeAssetsProvider,
                            ),
                            ref),
                      ),
                      width: isDesktop ? desktopIconSize : mobileIconSize,
                      height: isDesktop ? desktopIconSize : mobileIconSize,
                    )
                  : Container(
                      width: isDesktop ? desktopIconSize : mobileIconSize,
                      height: isDesktop ? desktopIconSize : mobileIconSize,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SvgPicture.file(
                        File(
                          coinIconPath(
                              ref.watch(
                                themeAssetsProvider,
                              ),
                              ref),
                        ),
                        color: Theme.of(context)
                            .extension<StackColors>()!
                            .accentColorDark,
                        width: isDesktop ? desktopIconSize : mobileIconSize,
                        height: isDesktop ? desktopIconSize : mobileIconSize,
                      ),
                    ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConditionalParent(
                      condition: isDesktop && !notification.read,
                      builder: (child) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          child,
                          Text(
                            "New",
                            style:
                                STextStyles.desktopTextExtraExtraSmall(context)
                                    .copyWith(
                              color: Theme.of(context)
                                  .extension<StackColors>()!
                                  .accentColorGreen,
                            ),
                          )
                        ],
                      ),
                      child: Text(
                        notification.title,
                        style: isDesktop
                            ? STextStyles.desktopTextExtraExtraSmall(context)
                                .copyWith(
                                color: Theme.of(context)
                                    .extension<StackColors>()!
                                    .textDark,
                              )
                            : STextStyles.titleBold12(context),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.description,
                          style: isDesktop
                              ? STextStyles.desktopTextExtraExtraSmall(context)
                                  .copyWith(
                                  color: Theme.of(context)
                                      .extension<StackColors>()!
                                      .textSubtitle1,
                                )
                              : STextStyles.label(context),
                        ),
                        Text(
                          extractPrettyDateString(notification.date),
                          style: isDesktop
                              ? STextStyles.desktopTextExtraExtraSmall(context)
                                  .copyWith(
                                  color: Theme.of(context)
                                      .extension<StackColors>()!
                                      .textSubtitle1,
                                )
                              : STextStyles.label(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (notification.read)
          Positioned.fill(
            child: RoundedContainer(
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .background
                  .withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}
