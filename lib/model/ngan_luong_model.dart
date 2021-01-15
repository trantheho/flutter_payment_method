
class NganLuongModel {
  String code;
  String tokenCode;
  String checkoutUrl;


  NganLuongModel(Map<String, dynamic> json){
    this.code = json["response_code"];
    this.tokenCode = json["token_code"];
    this.checkoutUrl = json["checkout_url"];
  }

}


class SendDeposit {
  String mFunc;
  String mVersion;
  String mMerchantID;
  String mMerchantAccount;
  String mOrderCode;
  int mTotalAmount;
  String mCurrency;
  String mLanguage;
  String mReturnUrl;
  String mCancelUrl;
  String mNotifyUrl;
  String mBuyerFullName;
  String mBuyerEmail;
  String mBuyerMobile;
  String mBuyerAddress;
  String mChecksum;

  SendDeposit({
    this.mFunc,
    this.mVersion,
    this.mMerchantID,
    this.mMerchantAccount,
    this.mOrderCode,
    this.mTotalAmount,
    this.mCurrency,
    this.mLanguage,
    this.mReturnUrl,
    this.mCancelUrl,
    this.mNotifyUrl,
    this.mBuyerFullName,
    this.mBuyerEmail,
    this.mBuyerMobile,
    this.mBuyerAddress,
    this.mChecksum,
  });
}