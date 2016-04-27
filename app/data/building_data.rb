class BuildingData < BaseData

  def create(objects)
    objects.each do |object|
      building = find(object[:name])

      if building.blank?
        _create_building(object)
      end
    end
  end

  def find(name)
    log "building:#{name}"

    response = Fooda::BuildingsApi.get_by({name: name})

    if response.code != 200
      log "building not found"
      return nil
    end

    log "building exists"

    response[:building]
  end

  protected

  def _create_building(building_object)
    log "building:#{building_object}"

    response = Fooda::BuildingsApi.create({building: building_object})

    if [200,201].include?(response.code)
      log "building created"

      yield response.build if block_given?
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "building create error:#{errors}"

      return
    end

    building = response.building

    response = Fooda::BuildingsApi.change_state(building.id, 'approve')

    if response.code == 200
      log "building approved"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "building approve error:#{errors}"
    end
  end

end
