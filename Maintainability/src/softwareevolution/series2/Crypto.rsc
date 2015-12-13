module softwareevolution::series2::Crypto

public str md5(str input) =  md5(input,"UTF-8");
public str md5(str input, str encoding) = digest(input,encoding,"MD5");

public str sha1(str input) =  sha1(input,"UTF-8");
public str sha1(str input, str encoding) = digest(input,encoding,"SHA1");

@javaClass{softwareevolution.series2.Crypto}
public java str digest(str input, str algorithm);

@javaClass{softwareevolution.series2.Crypto}
public java str digest(str input, str encoding, str algorithm);