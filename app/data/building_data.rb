class BuildingData < BaseData

  def create(objects)
    objects.each do |object|
      building = exists(object[:name])

      if building.blank?
        building = _create_building(object)
      end
    end
  end

  def exists(name)
    log "building check:#{name}"

    response = Fooda::BuildingsApi.get_by({name: name})
    building = response.building

    if response.code != 200
      log "building check:#{name} not found"
      return nil
    end

    log "building check:#{name} exists"

    building
  end

  protected

  def _create_building(building_object)
    log "building create:#{building_object}"

    if (market_name = building_object[:market_name]).present?
      log "market resolve:#{market_name}"
      response = Fooda::MarketsApi.get_by({
        name: market_name,
      })
      if response.code != 200
        log "market resolve:#{market_name} error"
        return nil
      end

      market = response.market
      building_object[:market_id] = market.id

      log "market resolve:#{market_name} ok"
    end

    response = Fooda::BuildingsApi.create({
      access_token: Token.map(Token::ADMIN_USER_EMAIL),
      client_token: Token.get_client,
      building: building_object,
    })

    if [200,201].include?(response.code)
      log "building created"

      yield response.build if block_given?
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "building create error:#{errors}"

      return nil
    end

    building = response.building

    response = Fooda::BuildingsApi.change_state(
      building.id,
      'approve',
      {
        access_token: Token.map(Token::ADMIN_USER_EMAIL),
        client_token: Token.get_client,
      },
    )

    if response.code == 200
      log "building approved"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "building approve error:#{errors}"
    end

    building
  end

end
