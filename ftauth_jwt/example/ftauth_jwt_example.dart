import 'dart:convert';

import 'package:ftauth_jwt/ftauth_jwt.dart';

void main() async {
  const jwk = '''
  {
    "use": "sig",
    "kty": "RSA",
    "kid": "geEO_TcF2Xan1OZbw5rRfz3pxt4uYCKYxfg_-SO7TTI",
    "alg": "RS256",
    "n": "1IZKp_toN7BxKiKaBDU7KhrF6Vmb1PAiHOxV1rPm8yzmyktPko4hjjvPDxtbEKb6hFDeWY7hp1d1f7GNGw7TvLTghOTOCn5dbXFlSZM8drPYXK41ooPHn10mJ5pfe7o9dOJSmvteAe4fmybR0bN-FzX_tj53bURXyb0I9By8jvoYMuVX3iG1DAo9r-S4ln8xHxl2FxXDbmYWmnUr-ROL6SppZD556t_DWkfdONcRu0nzB9zpS7xhQEvzk1INdjjtCsuCyOd18qWuFZRtQW6Beu2rmvNsUlN1ls1STRgwb6eMcsJq2FC9mWP7ArBWOT4pJkTJ0fObYYFG7w9mLdEJ_w",
    "e": "AQAB",
    "d": "nUomxtyS7WRw3LZvNt4Ow8K850-ivZ5cIPvpK9ZJ_4Aj72R9qAH5Y8NwI8YjR9fNYVBYv_-3kppwI-nMfVIj824LHVAaDjon-3AJfsKx5UiFwVJN79GIVLIkIvtl37Se93rpmDqiANu0GKhKceFeWN9mOgNRcFU8g9qcXc9G3qlwgWYa8GAteRaRI1GGUIgAKJFpUXraytUNs9XuxdYEGFCgYuEzkRB8f30LdNMIqN_iFJCr1nuYD1WccC4ayVYBo5Qk4IfP4dijz5wWE2zinWhizlhAiWs2lZT-jDJTs4W4tbUhKdOc42U6ivEbkR4MxwhwKuLua_LxWErDcDMrwQ",
    "p": "2zbFZ_yBTBqTl-9kYkWM6yCX_2VTFykjJuzyouFFWGJ1Pubfj6uHNtrOi-mTm_OxC8my0A5_ZGoc1Uca_WPay-157EkW_2Uua778ioLINy4wAZehqJWRWrMe1qfkObUJQTk2_GFIubM-WGpZKYgoMCvoXQPYm5PemAjJYK-hQxM",
    "q": "-DAmtkv4f8eDrscdx4GN56oNAHQtQ6dDOp6V_Jiagn4chmQygRlzPy_qwZJSdm9DYq4rHB1npBFZ6bL5JdHYpU6wgOYDIP_YmKQzR55q5HHsfRgTvpPIJJi3XszuNh4WxuD4th-alEQKXqgnrmPZ0MEpwuGDB9TkBFep5vMnDuU",
    "dp": "sAZWE78F0CeTFrCrSeIRWwjsJK-nPfTRfkNMPpBnj6ZYAW-AWyxgQiMHMgAYgGT5aL7IsBrEHsy6ZGRZftj86z3A5oR2TBRiZzCQN2T3AqA6-jxZGjcn5c3pWHKuZ8xAJzibN6Ois0MEMBkNibUEmFHZnz8kYyEk365GjjXZZzM",
    "dq": "i8sDYxbzh3WnlGCPQ3qTpXNBE4pcnIiv82qz7K1AClRiWMhDMjhVk7e3sQRr8k3FVOXpXlKpt94WGO44K7dBIgtqm4_zHzk8lO2X_LUcXERXAjb3mBbBWuuyDXG8kzrrdWXucRboCK8ycBKjFzUi0NScYyqGlXiyXkfKaU14KIk",
    "qi": "qTOVlaJ8y95MU6igPhvH3cMEkJ9yFc2_SCT56d2hs5Q5oYa8pCqzPneDgxV_n0ogDZFf_M7MZs8mMicQUngTj57dm3E8AyH0E-Mm4u-Cr7LobbR4xZy6Bl28Db6yupq8SQ1JWMV4OZMDMvnD3UVmhI43a8amslBqpcannqYGAUI"
  }
  ''';
  final key = JsonWebKey.fromJson(jsonDecode(jwk));

  final jwt = JsonWebToken(
    header: JsonWebHeader(
      algorithm: Algorithm.rsaSha256,
      keyId: key.keyId,
    ),
    claims: JsonWebClaims(
      issuer: 'my_app',
      subject: 'test_user',
      audience: 'my_app',
    ),
  );

  // Prints: eyJhbGciOiJSUzI1NiIsImtpZCI6ImdlRU9fVGNGMlhhbjFPWmJ3NXJSZnozcHh0NHVZQ0tZeGZnXy1TTzdUVEkifQ.eyJhdWQiOiJteV9hcHAiLCJpc3MiOiJteV9hcHAiLCJzdWIiOiJ0ZXN0X3VzZXIifQ.02-XhXgZv1GZ5Qxk0OXRk7mZmuJa1ScwSRBfYR1OR7Tl4qNVMThY-I_jRenX42XwdCKVK6Fua0tYrHWAmwxxb8ZlYgvKNt66pBBA-rl5LWWPmRaZM2IYYcijccNueq32lGpnLdQQvThpHc6rmnJJdQpnj2hCEjVrK5KBVOr6wpZaU-sSWb9hOsfGSMPV1BWrYRjXMinxBB5SOtWwqOb1V0kxsJFbGabsmpSk3FiC4LkePfA5NlGyz2M0iaYqajlg2GLGNQNZ6Whg1PTk3JHHfRdKTW3GrEwz0zeFvsi2hKNa5f7sZ7VkMpdodyN-uC0y80FtZPf9qvq6CzNdyvYYtg
  print(await jwt.encodeBase64(key.signer));

  // Prints: Token verified
  try {
    await jwt.verify(key.publicKey);
    print('Token verified');
  } on VerificationException {
    print('Unable to verify token');
  }
}
