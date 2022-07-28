class Encryption

  B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'.split('')

  def self.encode(secret, key_to_encode)
    cipher = OpenSSL::Cipher::AES.new(256, :CFB8)
    cipher.encrypt
    cipher.key = Digest::MD5.hexdigest(secret)
    cipher.iv = secret
    encrypted = cipher.update(key_to_encode.to_s) + cipher.final

    Base64.strict_encode64(encrypted)
  end

  def self.decode(secret, encrypted_key)
    decrypted = Base64.decode64(encrypted_key)

    decipher = OpenSSL::Cipher::AES.new(256, :CFB8)
    decipher.decrypt
    decipher.key = Digest::MD5.hexdigest(secret)
    decipher.iv = secret
    decoded = decipher.update(decrypted) + decipher.final
  end

  def self.int64(i)
    (B64[i >> 24 & 63] + B64[i >> 18 & 63] + B64[i >> 12 & 63] + B64[i >> 6 & 63] + B64[i & 63]).gsub(/^A+/, '')
  end

  def self.generate_code(prefix, id)
    prefix + int64(id) + ('AA' + int64((id + 123)**2 % 4096))[-2, 2]
  end
end