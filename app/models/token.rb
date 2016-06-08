class Token

  @@singleton = Hashie::Mash.new

  ADMIN_USER_EMAIL = 'admin@fooda.com'

  def self.initialize
    TokenData.new if @@singleton.blank?
  end

  def self.get(key)
    initialize

    @@singleton[key]
  end

  def self.get_client
    return @@singleton[:client] if @@singleton[:client].present?

    response = Fooda::TokensApi.get_client

    if response.code != 200
      return nil
    end

    response.token.token
  end

  # map email to token
  def self.map(email)
    return @@singleton[email] if @@singleton[email].present?

    response = Fooda::TokensApi.map({
      email: email
    })

    if response.code != 200
      return nil
    end

    response.token.token
  end

  def self.set(key, value)
    @@singleton[key] = value
  end

end
