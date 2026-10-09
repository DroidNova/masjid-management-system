import 'package:flutter/material.dart';

/// One icon per meaning, used everywhere (UI_REDESIGN_PLAN.md, rule 3).
/// Screens pick icons from here, not from [Icons] directly, so the same
/// thing always looks the same.
class AppIcons {
  const AppIcons._();

  // Places and sections.
  static const IconData mosque = Icons.mosque_rounded;
  static const IconData home = Icons.home_rounded;
  static const IconData profile = Icons.person_rounded;
  static const IconData announcements = Icons.campaign_rounded;
  static const IconData moneyIn = Icons.arrow_circle_down_rounded;
  static const IconData moneyOut = Icons.arrow_circle_up_rounded;
  static const IconData money = Icons.account_balance_wallet_rounded;
  static const IconData projects = Icons.construction_rounded;
  static const IconData people = Icons.groups_rounded;
  static const IconData salary = Icons.currency_rupee_rounded;
  static const IconData myPayments = Icons.receipt_long_rounded;

  // Prayers: the sun's position through the day.
  static const IconData fajr = Icons.wb_twilight_rounded;
  static const IconData sunrise = Icons.light_mode_rounded;
  static const IconData dhuhr = Icons.wb_sunny_rounded;
  static const IconData asr = Icons.sunny_snowing;
  static const IconData maghrib = Icons.brightness_4_rounded;
  static const IconData isha = Icons.nightlight_round_rounded;
  static const IconData jumma = Icons.mosque_rounded;

  // Money categories.
  static const IconData donationBox = Icons.inventory_2_rounded;
  static const IconData zakat = Icons.volunteer_activism_rounded;

  // Status.
  static const IconData done = Icons.check_circle_rounded;
  static const IconData waiting = Icons.schedule_rounded;
  static const IconData problem = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;

  // Actions.
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData next = Icons.arrow_forward_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData calendar = Icons.event_rounded;
  static const IconData time = Icons.schedule_rounded;
  static const IconData backspace = Icons.backspace_rounded;
  static const IconData readAloud = Icons.volume_up_rounded;
  static const IconData stopReading = Icons.stop_circle_rounded;
  static const IconData leave = Icons.exit_to_app_rounded;
  static const IconData logout = Icons.power_settings_new_rounded;
  static const IconData language = Icons.translate_rounded;
  static const IconData textSize = Icons.format_size_rounded;
  static const IconData password = Icons.lock_rounded;
  static const IconData personSearch = Icons.person_search_rounded;
  static const IconData noInternet = Icons.wifi_off_rounded;
}
