module softwareevolution::series2::CryptoTest

import softwareevolution::series2::Crypto;

test bool test_md5_sameInpuHasSameHash(str message) = md5(message) == md5(message);

test bool test_md5_differentInpuHasDifferentHash(str message) = md5(message) != md5(message+"a");

test bool test_md5_utf16_sameInpuHasSameHash(str message) = md5(message,"UTF-16") == md5(message,"UTF-16");

test bool test_md5_utf16_differentInpuHasDifferentHash(str message) = md5(message,"UTF-16") != md5(message+"a","UTF-16");

test bool test_md5_utf16_utf8_sameInpuHasDifferentHash(str message) {
  if(message=="") {
    return true;
  }
  return md5(message,"UTF-16") != md5(message,"UTF-8");
}

test bool test_sha1_sameInpuHasSameHash(str message) = sha1(message) == sha1(message);

test bool test_md5_sha1_sameInpuHasDifferentHash(str message) = md5(message) != sha1(message);

test bool test_sha1_differentInpuHasDifferentHash(str message) = sha1(message) != sha1(message+"a");
