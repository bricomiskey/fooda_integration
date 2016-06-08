module TokenConcern

  extend ActiveSupport::Concern

  def tokens(hash)
    @_tokens = hash
  end

  def access_token
    @access_token ||= (@_tokens[:user_token] || @_tokens[:access_token] || Token.map(@_tokens[:user_email]))
  end

  def client_token
    @client_token ||= Token.get_client
  end

end
