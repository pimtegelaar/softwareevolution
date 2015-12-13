package softwareevolution.series2;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.rascalmpl.value.IString;
import org.rascalmpl.value.IValueFactory;

public class Crypto {
  
  private final IValueFactory vf;

  public Crypto(IValueFactory vf) {
    this.vf = vf;
  }
  
  public IString digest(IString input, IString algorithm) throws NoSuchAlgorithmException, UnsupportedEncodingException {
    return digest(input, vf.string("UTF-8"),algorithm);
  }
  
  public IString digest(IString input, IString encoding, IString algorithm) throws NoSuchAlgorithmException, UnsupportedEncodingException {
    return vf.string(digest(input.getValue(), encoding.getValue(), algorithm.getValue()));
  }
  
  private String digest(String input, String encoding, String algorithm) throws NoSuchAlgorithmException, UnsupportedEncodingException {
    MessageDigest md = MessageDigest.getInstance(algorithm);
    byte[] digest = md.digest(input.getBytes(encoding));
    return new String(digest);
  }
}
