class MarketData < BaseData

  def create(objects)
    objects.each do |object|
      market = exists(object[:name])

      if market.blank?
        market = _create_market(object)
      end
    end
  end

  def exists(name)
    log "market check:#{name}"

    response = Fooda::MarketsApi.get_by({name: name})

    if response.code != 200
      log "market check:#{name} not found"
      return nil
    end

    log "market check:#{name} exists"

    response.market
  end

  protected

  def _create_market(market_object)
    log "market create:#{market_object}"

    response = Fooda::MarketsApi.create({
      access_token: Token.map(Token::ADMIN_USER_EMAIL),
      client_token: Token.get_client,
      market: market_object
    })
    market = response.market

    if [200,201].include?(response.code)
      log "market created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "market create error:#{errors}"
    end

    market
  end

end
