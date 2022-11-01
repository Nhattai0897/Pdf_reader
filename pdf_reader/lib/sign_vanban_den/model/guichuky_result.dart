class GuiChuKyResult {
  late String _urlFileSigned;
  late String _messageError;
  late String _urlAlfresco;

  GuiChuKyResult(this._urlFileSigned, this._urlAlfresco, this._messageError);

  String get messageError => _messageError;

  set messageError(String value) {
    _messageError = value;
  }

  String get urlFileSigned => _urlFileSigned;

  set urlFileSigned(String value) {
    _urlFileSigned = value;
  }

  String get urlAlfresco => _urlAlfresco;

  set urlAlfresco(String value) {
    _urlAlfresco = value;
  }

  GuiChuKyResult.fromJson(Map<String, dynamic> json) {
    messageError = json['messageError'];
    urlFileSigned = json['urlFileSigned'];
    urlAlfresco = json['urlAlfresco'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageError'] = this.messageError;
    data['urlFileSigned'] = this.urlFileSigned;
    data['urlAlfresco'] = this.urlAlfresco;
    return data;
  }
}
