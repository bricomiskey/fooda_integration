class LocationData < BaseData

  def create(objects)
    objects.each do |object|
      location = find(object[:name])

      if location.blank?
        _create_location(object)
      end
    end
  end

  def find(name)
    log "location:#{name}"

    response = Fooda::LocationsApi.get_by({name: name})

    if response.code != 200
      log "location not found"
      return nil
    end

    log "location exists"

    response[:location]
  end

  protected

  def _create_location(location_object)
    location_name = location_object[:name]

    log "location:#{location_object}"

    account_name = location_object[:account_name]
    building_name = location_object[:building_name]

    if account_name.present?
      # map account_name to object
      account_data = AccountData.new
      account = account_data.find_or_create(
        account_name,
        Hashie::Mash.new({
          name: account_name,
          account_type: 'enterprise',
        })
      )

      location_object[:account_id] = account.try(:id)
    end

    if building_name.present?
      # map building_name to object
      building_data = BuildingData.new
      building = BuildingData.new.find(building_name)

      location_object[:building_id] = building.try(:id)
    end

    response = Fooda::LocationsApi.create({location: location_object})

    if [200,201].include?(response.code)
      log "location created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "location create error:#{errors}"
    end
  end

end
