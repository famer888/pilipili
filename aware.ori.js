function decryptImage(word) {
  try {
    const media_key = CryptoJS[String.fromCharCode(101) + String.fromCharCode(110) + String.fromCharCode(99)][String.fromCharCode(85) + String.fromCharCode(116) + String.fromCharCode(102) + String.fromCharCode(56)][`${String.fromCharCode(112)}arse`]('102_53_100_57_54_53_100_102_55_53_51_51_54_50_55_48'.split('_').map(a => String.fromCharCode(parseInt(a))).join(''));
    const media_iv = CryptoJS[String.fromCharCode(101) + String.fromCharCode(110) + String.fromCharCode(99)][String.fromCharCode(85) + String.fromCharCode(116) + String.fromCharCode(102) + String.fromCharCode(56)][`${String.fromCharCode(112)}arse`]('57_55_98_54_48_51_57_52_97_98_99_50_102_98_101_49'.split('_').map(a => String.fromCharCode(parseInt(a))).join(''));
    const decrypt = CryptoJS.AES.decrypt(word, media_key, {
      iv: media_iv,
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7
    });
    return decrypt.toString(CryptoJS.enc.Base64);
  } catch (err) {
    return '';
  }
}