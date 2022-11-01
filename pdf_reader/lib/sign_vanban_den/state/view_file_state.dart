import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_reader/sign_vanban_den/model/mau_chu_ky_so_model.dart'; 
import 'package:pdf_reader/sign_vanban_den/utils/bloc_builder_status.dart';

class ViewFileState {
  BlocBuilderStatusCase? status;
  BlocBuilderStatusCase? statusLoadSign;
  String? imageUrl;
  String? imageLoai1;
  String? imageLoai2;
  String? imageLoai3;
  List<MauChuKySoModel>? danhSachChuKy;
  Widget? mauChuKy;
  MauChuKySoModel? chuKyMacDinh;
  int? vitriChuKy;
  int? vTriTrangKySo;
  bool? isUseDefaultConfig;
  File? fileImageWidget;
  int? countPage;
  int? currentPage;
  bool? isFirst;
  bool? isShowWarning;
  bool? isContinue;

  ViewFileState(
      {this.status,
      this.statusLoadSign,
      this.imageUrl,
      this.imageLoai1,
      this.imageLoai2,
      this.imageLoai3,
      this.danhSachChuKy,
      this.mauChuKy,
      this.chuKyMacDinh,
      this.vitriChuKy,
      this.vTriTrangKySo,
      this.isUseDefaultConfig,
      this.fileImageWidget,
      this.countPage,
      this.currentPage,
      this.isFirst,
      this.isShowWarning,
      this.isContinue = false});
  ViewFileState copyWith(
      {BlocBuilderStatusCase? status,
      BlocBuilderStatusCase? statusLoadSign,
      String? imageUrl,
      String? imageLoai1,
      String? imageLoai2,
      String? imageLoai3,
      List<MauChuKySoModel>? danhSachChuKy,
      Widget? mauChuKy,
      MauChuKySoModel? chuKyMacDinh,
      int? vitriChuKy,
      int? vTriTrangKySo,
      bool? isUseDefaultConfig,
      File? fileImageWidget,
      int? countPage,
      int? currentPage,
      bool? isFirst,
      bool? isShowWarning,
      bool? isContinue}) {
    return ViewFileState(
        status: status ?? this.status,
        statusLoadSign: statusLoadSign ?? this.statusLoadSign,
        imageUrl: imageUrl ?? this.imageUrl,
        imageLoai1: imageLoai1 ?? this.imageLoai1,
        imageLoai2: imageLoai2 ?? this.imageLoai2,
        imageLoai3: imageLoai3 ?? this.imageLoai3,
        danhSachChuKy: danhSachChuKy ?? this.danhSachChuKy,
        mauChuKy: mauChuKy ?? this.mauChuKy,
        chuKyMacDinh: chuKyMacDinh ?? this.chuKyMacDinh,
        vitriChuKy: vitriChuKy ?? this.vitriChuKy,
        vTriTrangKySo: vTriTrangKySo ?? this.vTriTrangKySo,
        isUseDefaultConfig: isUseDefaultConfig ?? this.isUseDefaultConfig,
        fileImageWidget: fileImageWidget ?? this.fileImageWidget,
        countPage: countPage ?? this.countPage,
        currentPage: currentPage ?? this.currentPage,
        isFirst: isFirst ?? this.isFirst,
        isShowWarning: isShowWarning ?? this.isShowWarning,
        isContinue: isContinue ?? this.isContinue);
  }
}