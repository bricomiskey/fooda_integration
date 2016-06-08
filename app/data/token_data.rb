class TokenData < BaseData

  # def initialize(options={})
  #   super(options)
  #
  #   path = options[:path] || "#{Dir.pwd}/app/data/tokens/tokens.yml"
  #   objects = FileParser.load_file(path)
  #   parse(objects['tokens'])
  # end

  def create(tokens)
    tokens.each do |object|
      token = exists(object[:token])

      if token.blank?
        # default to client token
        response = Fooda::TokensApi.create_client({token: object})
        puts response
      end
    end
  end

  def exists(s)
    log "token check:#{s}"

    response = Fooda::TokensApi.get_client({token: s})
    token = response.token

    if response.code != 200
      log "token check:#{s} not found"
      return nil
    end

    log "token check:#{s} exists"

    token
  end

end
