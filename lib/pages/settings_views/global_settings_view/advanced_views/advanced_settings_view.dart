import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/pages/settings_views/global_settings_view/advanced_views/debug_view.dart';
import 'package:stackduo/pages/settings_views/global_settings_view/advanced_views/manage_coin_units/manage_coin_units_view.dart';
import 'package:stackduo/pages/settings_views/global_settings_view/advanced_views/manage_explorer_view.dart';
import 'package:stackduo/pages/stack_privacy_calls.dart';
import 'package:stackduo/providers/global/prefs_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/widgets/background.dart';
import 'package:stackduo/widgets/choose_coin_view.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/custom_buttons/draggable_switch_button.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';
import 'package:tuple/tuple.dart';

class AdvancedSettingsView extends StatelessWidget {
  const AdvancedSettingsView({
    Key? key,
  }) : super(key: key);

  static const String routeName = "/advancedSettings";

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");

    return Background(
      child: Scaffold(
        backgroundColor: Theme.of(context).extension<StackColors>()!.background,
        appBar: AppBar(
          leading: AppBarBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Advanced",
            style: STextStyles.navBarTitle(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoundedWhiteContainer(
                padding: const EdgeInsets.all(0),
                child: RawMaterialButton(
                  // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Constants.size.circularBorderRadius,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(DebugView.routeName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Debug info",
                          style: STextStyles.titleBold12(context),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              RoundedWhiteContainer(
                child: Consumer(
                  builder: (_, ref, __) {
                    return RawMaterialButton(
                      // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Constants.size.circularBorderRadius,
                        ),
                      ),
                      onPressed: null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Toggle testnet coins",
                              style: STextStyles.titleBold12(context),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 20,
                              width: 40,
                              child: DraggableSwitchButton(
                                isOn: ref.watch(
                                  prefsChangeNotifierProvider.select(
                                      (value) => value.showTestNetCoins),
                                ),
                                onValueChanged: (newValue) {
                                  ref
                                      .read(prefsChangeNotifierProvider)
                                      .showTestNetCoins = newValue;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              RoundedWhiteContainer(
                child: Consumer(
                  builder: (_, ref, __) {
                    return RawMaterialButton(
                      // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Constants.size.circularBorderRadius,
                        ),
                      ),
                      onPressed: null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Enable coin control",
                              style: STextStyles.titleBold12(context),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 20,
                              width: 40,
                              child: DraggableSwitchButton(
                                isOn: ref.watch(
                                  prefsChangeNotifierProvider.select(
                                      (value) => value.enableCoinControl),
                                ),
                                onValueChanged: (newValue) {
                                  ref
                                      .read(prefsChangeNotifierProvider)
                                      .enableCoinControl = newValue;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              RoundedWhiteContainer(
                padding: const EdgeInsets.all(0),
                child: Consumer(
                  builder: (_, ref, __) {
                    final externalCalls = ref.watch(
                      prefsChangeNotifierProvider
                          .select((value) => value.externalCalls),
                    );
                    return RawMaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Constants.size.circularBorderRadius,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          StackPrivacyCalls.routeName,
                          arguments: true,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Stack Experience",
                                    style: STextStyles.titleBold12(context),
                                  ),
                                  TextSpan(
                                    text: externalCalls
                                        ? "\nEasy crypto"
                                        : "\nIncognito",
                                    style: STextStyles.label(context)
                                        .copyWith(fontSize: 15.0),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              RoundedWhiteContainer(
                padding: const EdgeInsets.all(0),
                child: RawMaterialButton(
                  // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Constants.size.circularBorderRadius,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(ChooseCoinView.routeName,
                        arguments: const Tuple3<String, String, String>(
                            "Manage block explorers",
                            "block explorer",
                            ManageExplorerView.routeName));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Change block explorer",
                          style: STextStyles.titleBold12(context),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              RoundedWhiteContainer(
                padding: const EdgeInsets.all(0),
                child: RawMaterialButton(
                  // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Constants.size.circularBorderRadius,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ManageCoinUnitsView.routeName,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Units",
                          style: STextStyles.titleBold12(context),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
