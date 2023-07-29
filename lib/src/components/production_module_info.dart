import 'package:flutter/material.dart';

class ProductionModuleInfo {
  final String? svgSrc, title, totalStorage, linkScreen;
  final int? numOfFiles, percentage;
  final Color? color;

  ProductionModuleInfo({
    this.svgSrc,
    this.title,
    this.totalStorage,
    this.numOfFiles,
    this.linkScreen,
    this.percentage,
    this.color,
  });
}

List listProductionModules = [
  ProductionModuleInfo(
    title: "Porcicultura",
    numOfFiles: 1328,
    svgSrc: "assets/icons/pig.svg",
    totalStorage: "1.9GB",
    linkScreen: "/porcicultura_home",
    color: Colors.green,
    percentage: 35,
  ),
  ProductionModuleInfo(
    title: "Acuicultura",
    numOfFiles: 1328,
    svgSrc: "assets/icons/fish.svg",
    totalStorage: "2.9GB",
    color: const Color(0xFFFFA113),
    percentage: 35,
  ),
  ProductionModuleInfo(
    title: "Agricultura",
    numOfFiles: 1328,
    svgSrc: "assets/icons/peppers.svg",
    totalStorage: "1GB",
    color: const Color(0xFFA4CDFF),
    percentage: 10,
  ),
  ProductionModuleInfo(
    title: "Ganadería Bovina",
    numOfFiles: 5328,
    svgSrc: "assets/icons/cow.svg",
    totalStorage: "7.3GB",
    color: const Color(0xFF007EE5),
    percentage: 78,
  ),
  ProductionModuleInfo(
    title: "Ganadería Caprina",
    numOfFiles: 5328,
    svgSrc: "assets/icons/goat.svg",
    totalStorage: "7.3GB",
    color: const Color(0xFF007EE5),
    percentage: 78,
  ),
];
