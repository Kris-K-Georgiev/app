import '../widgets/icon_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons, Icon, Color; // alias layer needs material icons

/// Central registry for SVG icons to keep usage consistent and ease swaps.
/// Add new icons in assets/icons and register here.
class AppIcons {
  static String _path(String name) => 'assets/icons/$name.svg';

  // Core navigation / sections
  static Widget news({Color? color, double size=24}) => IconSvg(_path('news'), color: color, size: size);
  static Widget events({Color? color, double size=24}) => IconSvg(_path('events'), color: color, size: size);
  static Widget settings({Color? color, double size=24}) => IconSvg(_path('settings'), color: color, size: size);
  static Widget logout({Color? color, double size=24}) => IconSvg(_path('logout'), color: color, size: size);
  static Widget layers({Color? color, double size=120}) => IconSvg(_path('layers'), color: color, size: size);
  static Widget update({Color? color, double size=24}) => IconSvg(_path('update'), color: color, size: size);
  static Widget close({Color? color, double size=20}) => IconSvg(_path('close'), color: color, size: size);
  static Widget photo({Color? color, double size=20}) => IconSvg(_path('photo'), color: color, size: size);

  // Alias layer for common Material icons so usage can be centralized
  static Icon share({Color? color, double size=24}) => Icon(Icons.share_outlined, color: color, size: size);
  static Icon calendarAdd({Color? color, double size=24}) => Icon(Icons.event_outlined, color: color, size: size);
  static Icon edit({Color? color, double size=20}) => Icon(Icons.edit_outlined, color: color, size: size);
  static Icon person({Color? color, double size=24}) => Icon(Icons.person_outline, color: color, size: size);
  static Icon statusWaitlist({Color? color, double size=18}) => Icon(Icons.hourglass_bottom, color: color, size: size);
  static Icon statusConfirmed({Color? color, double size=18}) => Icon(Icons.check_circle_outline, color: color, size: size);
  static Icon history({Color? color, double size=18}) => Icon(Icons.history, color: color, size: size);
  static Icon schedule({Color? color, double size=16}) => Icon(Icons.schedule, color: color, size: size);
  static Icon location({Color? color, double size=16}) => Icon(Icons.location_on_outlined, color: color, size: size);
  static Icon city({Color? color, double size=16}) => Icon(Icons.apartment_outlined, color: color, size: size);
  static Icon audience({Color? color, double size=16}) => Icon(Icons.lock_open_outlined, color: color, size: size);
  static Icon people({Color? color, double size=16}) => Icon(Icons.people_outline, color: color, size: size);
  static Icon hourglass({Color? color, double size=16}) => Icon(Icons.hourglass_bottom, color: color, size: size);
  static Icon seat({Color? color, double size=14}) => Icon(Icons.event_seat, color: color, size: size);
  static Icon warning({Color? color, double size=20}) => Icon(Icons.warning_amber, color: color, size: size);
  static Icon shield({Color? color, double size=16}) => Icon(Icons.shield_outlined, color: color, size: size);
  static Icon brokenImage({Color? color, double size=20}) => Icon(Icons.broken_image, color: color, size: size);
  static Icon closeIcon({Color? color, double size=20}) => Icon(Icons.close, color: color, size: size);
  static Icon check({Color? color, double size=20}) => Icon(Icons.check_circle_outline, color: color, size: size);
  static Icon bookmark({Color? color, double size=22}) => Icon(Icons.bookmark_border, color: color, size: size);
}
