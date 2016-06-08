class LocationData < BaseData

  def create(objects)
    objects.each do |object|
      location = exists(object[:name])

      if location.blank?
        _create_location(object)
      end
    end
  end

  def exists(name)
    log "location check:#{name}"

    response = Fooda::LocationsApi.get_by({name: name})
    location = response.location

    if response.code != 200
      log "location check:#{name} not found"
      return nil
    end

    log "location check:#{name} exists"

    location
  end

  protected

  def _create_location(location_object)
    location_name = location_object[:name]

    log "location create:#{location_object}"

    if (account_name = location_object[:account_name]).present?
      log "account resolve:#{account_name}"

      response = Fooda::AccountsApi.get_by({
        name: account_name
      })
      account = response.account

      if response.code == 200
        log "account resolve:#{account_name} ok"
      else
        log "account resolve:#{account_name} not found"
      end

      location_object[:account_id] = account.try(:id)
    end

    if (building_name = location_object[:building_name]).present?
      log "building resolve:#{building_name}"

      # map building_name to object
      response = Fooda::BuildingsApi.get_by({
        name: building_name
      })
      building = response.building

      if response.code == 200
        log "building resolve:#{building_name} ok"
      else
        log "building resolve:#{building_name} not found"
      end

      location_object[:building_id] = building.try(:id)
    end

    response = Fooda::LocationsApi.create({
      access_token: Token.map(Token::ADMIN_USER_EMAIL),
      client_token: Token.get_client,
      location: location_object,
    })

    if [200,201].include?(response.code)
      log "location created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "location create error:#{errors}"
    end
  end

end
