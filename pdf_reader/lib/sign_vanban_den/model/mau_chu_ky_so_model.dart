// /// isHoTenNguoiKy => isNhanThangTin
// class MauChuKySoModel {
//   int? idMauChuKy;
//   String? tenMauChuKy;
//   String? sdtKySo;
//   String? hoTenNguoiThucHien;
//   String? hoTenNguoiKy;
//   String? emailNguoiKy;
//   String? tenPhongBanNguoiKy;
//   String? urlHinhAnh;
//   bool? isHinhAnh;
//   bool? isHoTenNguoiKy;
//   bool? isEmailNguoiKy;
//   bool? isPhongBanNguoiKy;
//   bool? isThoiGianKy;
//   int? intLoaiHienThi;
//   int? intViTriTrang;
//   int? intViTriChuKyMacDinh;
//   bool? isMauChuKyMacDinh;
//   bool? isDaXoa;
//   int? donViID;
//   int? createdUserID;
//   String? createdDate;
//   String? tenNguoiKyThamQuyen;
//   bool? isOpen;
//   int? intLoaiChuKySo;

//   MauChuKySoModel(
//       {this.idMauChuKy,
//       this.tenMauChuKy,
//       this.sdtKySo,
//       this.hoTenNguoiThucHien,
//       this.hoTenNguoiKy,
//       this.emailNguoiKy,
//       this.tenPhongBanNguoiKy,
//       this.urlHinhAnh,
//       this.isHinhAnh,
//       this.isHoTenNguoiKy,
//       this.isEmailNguoiKy,
//       this.isPhongBanNguoiKy,
//       this.isThoiGianKy,
//       this.intLoaiHienThi,
//       this.intViTriTrang,
//       this.intViTriChuKyMacDinh,
//       this.isMauChuKyMacDinh,
//       this.isDaXoa,
//       this.donViID,
//       this.createdUserID,
//       this.createdDate,
//       this.tenNguoiKyThamQuyen,
//       this.isOpen,
//       this.intLoaiChuKySo});

//   MauChuKySoModel.fromJson(Map<String, dynamic> json) {
//     idMauChuKy = json['idMauChuKy'];
//     tenMauChuKy = json['tenMauChuKy'];
//     sdtKySo = json['sdtKySo'];
//     hoTenNguoiThucHien = json['hoTenNguoiThucHien'];
//     hoTenNguoiKy = json['hoTenNguoiKy'];
//     emailNguoiKy = json['emailNguoiKy'];
//     tenPhongBanNguoiKy = json['tenPhongBanNguoiKy'];
//     urlHinhAnh = json['urlHinhAnh'];
//     isHinhAnh = json['isHinhAnh'];
//     isHoTenNguoiKy = json['isHoTenNguoiKy'];
//     isEmailNguoiKy = json['isEmailNguoiKy'];
//     isPhongBanNguoiKy = json['isPhongBanNguoiKy'];
//     isThoiGianKy = json['isThoiGianKy'];
//     intLoaiHienThi = json['intLoaiHienThi'];
//     tenNguoiKyThamQuyen = json['tenNguoiKyThamQuyen'];
//     intViTriTrang = json['intViTriTrang'];
//     intViTriChuKyMacDinh = json['intViTriChuKyMacDinh'];
//     isMauChuKyMacDinh = json['isMauChuKyMacDinh'];
//     isDaXoa = json['isDaXoa'];
//     donViID = json['donViID'];
//     createdUserID = json['createdUserID'];
//     createdDate = json['createdDate'];
//     isOpen = false;
//     intLoaiChuKySo = json['intLoaiChuKySo'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['idMauChuKy'] = this.idMauChuKy;
//     data['tenMauChuKy'] = this.tenMauChuKy;
//     data['sdtKySo'] = this.sdtKySo;
//     data['hoTenNguoiThucHien'] = this.hoTenNguoiThucHien;
//     data['hoTenNguoiKy'] = this.hoTenNguoiKy;
//     data['emailNguoiKy'] = this.emailNguoiKy;
//     data['tenPhongBanNguoiKy'] = this.tenPhongBanNguoiKy;
//     data['urlHinhAnh'] = this.urlHinhAnh;
//     data['isHinhAnh'] = this.isHinhAnh;
//     data['tenNguoiKyThamQuyen'] = this.tenNguoiKyThamQuyen;
//     data['isHoTenNguoiKy'] = this.isHoTenNguoiKy;
//     data['isEmailNguoiKy'] = this.isEmailNguoiKy;
//     data['isPhongBanNguoiKy'] = this.isPhongBanNguoiKy;
//     data['isThoiGianKy'] = this.isThoiGianKy;
//     data['intLoaiHienThi'] = this.intLoaiHienThi;
//     data['intViTriTrang'] = this.intViTriTrang;
//     data['intViTriChuKyMacDinh'] = this.intViTriChuKyMacDinh;
//     data['isMauChuKyMacDinh'] = this.isMauChuKyMacDinh;
//     data['isDaXoa'] = this.isDaXoa;
//     data['donViID'] = this.donViID;
//     data['createdUserID'] = this.createdUserID;
//     data['intLoaiChuKySo'] = this.intLoaiChuKySo;
//     return data;
//   }
// }
