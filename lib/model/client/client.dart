class ClientData {
  String? encryptedKey; //密钥的加密数据
  String? iV; //加密原始报文用到的向量数据
  String? ciphertext; //原始报文的加密数据
  String? authTag; //数字认证标签
  String? appId; //唯一识别码
  String? nonceStr; //随机字符串
  String? timeSign; //时间摘要
  int? timeStamp; //客户端时间

  ClientData({this.encryptedKey, this.iV, this.ciphertext, this.authTag, this.appId, this.nonceStr, this.timeSign, this.timeStamp});

  ClientData.fromJson(Map<String, dynamic> json) {
    encryptedKey = json['encryptedKey'];
    iV = json['iV'];
    ciphertext = json['ciphertext'];
    authTag = json['authTag'];
    appId = json['appId'];
    nonceStr = json['nonceStr'];
    timeSign = json['timeSign'];
    timeStamp = json['timeStamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['encryptedKey'] = encryptedKey;
    data['iV'] = iV;
    data['ciphertext'] = ciphertext;
    data['authTag'] = authTag;
    data['appId'] = appId;
    data['nonceStr'] = nonceStr;
    data['timeSign'] = timeSign;
    data['timeStamp'] = timeStamp;
    return data;
  }
}
