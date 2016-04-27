class MarketData < BaseData

  def create(objects)
    objects.each do |object|
      market = find(object[:name])

      if market.blank?
        _create_market(object)
      end
    end
  end

  def find(name)
    log "market:#{name}"

    response = Fooda::MarketsApi.get_by({name: name})

    if response.code != 200
      log "market not found"
      return nil
    end

    log "market exists"

    response[:market]
  end

  protected

  def _create_market(market_object)
    log "market:#{market_object}"

    response = Fooda::MarketsApi.create({market: market_object})

    if [200,201].include?(response.code)
      log "market created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "market create error:#{errors}"
    end
  end

end
