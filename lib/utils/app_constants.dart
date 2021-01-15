class AppConstant{
  // ngan luong
  static final String nganLuongUrl = "https://sandbox.nganluong.vn:8088/nl35/mobile_checkout_api_post.php";
  static final String nlSuccessUrl = "https://sandbox.nganluong.vn:8088/nl35/checkout/version27/success/token_code";
  static final String nlFailedUrl = "https://sandbox.nganluong.vn:8088/nl35/checkout/version27/verify/token_code";
  static final String nlErrorUrl = "https://sandbox.nganluong.vn:8088/nl35/checkout/error.html?message=TOG7l2kgaOG7hyB0aOG7kW5n&return_url=";

  static final String RETURN_URL = "https://account.nganluong.vn/nganluong/homeDeveloper/DeveloperBank.html";
  static final String CANCEL_URL = "https://www.nganluong.vn/nganluong/homeDeveloper/DeveloperBank.html";

  static final String mMerchantID = ''; //your merchant ID
  static final String mMerchantPassword = 'your merchant password';
  static final String mMerchantAccount = 'your merchant account';
  static final String mBuyerEmail = '';
  static final String mBuyerAddress = '';
  static final String mBuyerFullName = '';
  static final String mBuyerMobile = '';
  static final String mCurrency = 'vnd';
  static final String mLanguage = 'vi';
  static final String mFunc = 'sendOrder';
  static final String mVersion = '1.0';

  // stripe
  static final String stripeSecretKey = ""; // your stripeSecretKey
  static final String stripePublishableKey = ""; // your stripePublishableKey

  // One Pay
  static String onePayMerchant = 'TESTONEPAY';
  static String onePayAccessCode = '6BEB2546';
  static String onePaySecret = '6D0870CDE5F24F34F3915FB0045120DB';
  static String onePayReturnUrl = 'https://localhost/returnurl';
  static String onePayUrl = 'https://mtf.onepay.vn/paygate/vpcpay.op?';
}