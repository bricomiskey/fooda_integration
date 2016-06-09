class PopupData < BaseData

  def create(objects)
    objects.each do |object|
      begin
        object = resolve(object)

        popup_event = exists({
          building_id: object[:building_id],
          event_end_time: object[:event_end_time],
          event_start_time: object[:event_start_time],
        })

        if popup_event.blank?
          _create_popup_event(object)
        end
      rescue => e
        log "[exception] #{e.message}"
      end
    end
  end

  def exists(key)
    log "popup check:#{key}"

    response = Fooda::PopupEventsApi.get_by({key: key})

    if response.code != 200
      log "popup check:#{key} not found"
      return nil
    end

    log "popup check:#{key} exists"

    response.popup_event
  end

  def resolve(popup_object)
    log "popup resolve:#{popup_object}"

    if (account_name = popup_object[:account_name]).present?
      log "popup account resolve:#{account_name}"

      account = _resolve_account(account_name)

      if account.present?
        popup_object[:account_id] = account.id
        log "popup account resolve:#{account_name} exists"
      end
    end

    if (building_name = popup_object[:building_name]).present?
      log "popup building resolve:#{building_name}"

      building = _resolve_building(building_name)

      if building.present?
        popup_object[:building_id] = building.try(:id)
        log "popup building resolve:#{building_name} exists"
      end
    end

    (popup_event_locations = popup_object[:popup_event_locations] || []).each do |popup_event_location|
      if (location_name = popup_event_location[:location_name]).present?
        log "popup location resolve:#{location_name}"

        location = _resolve_location(location_name)
        raise "popup location resolve:#{location_name} not found" if location.blank?

        log "popup location resolve:#{location_name} exists"

        popup_event_location[:location_id] = location.id
      end
    end

    (popup_event_vendors = popup_object[:popup_event_vendors] || []).each do |popup_event_vendor|
      if (vendor_name = popup_event_vendor[:vendor_name]).present?
        log "popup vendor resolve:#{vendor_name}"

        vendor = _resolve_vendor(vendor_name)
        raise "popup vendor resolve:#{vendor_name} not found" if vendor.blank?

        log "popup vendor resolve:#{vendor_name} exists"

        popup_event_vendor[:vendor_id] = vendor.id
      end

      if (menu_template_name = popup_event_vendor[:menu_template_name]).present?
        log "popup menu_template resolve:#{menu_template_name}"

        vendor_id = popup_event_vendor[:vendor_id]
        response = Fooda::VendorsApi.get_by({
          id: vendor_id,
          with: ['menu_templates']
        })
        vendor = response.vendor

        menu_template = vendor.menu_templates.find do |menu_template|
          menu_template.name == menu_template_name
        end
        raise "popup menu template #{menu_template_name} not found" if menu_template.blank?

        log "popup menu_template resolve:#{menu_template_name} exists"

        popup_event_vendor[:menu_template_id] = menu_template.id
      end

      if (location_name = popup_event_vendor[:popup_event_location_name]).present?
        log "popup location resolve:#{location_name}"

        location = _resolve_location(location_name)
        raise "popup location resolve:#{location_name} not found" if location.blank?

        log "popup location resolve:#{location_name} exists"

        popup_event_vendor[:popup_event_location_id] = location.id
      end
    end

    popup_object
  end

  protected

  def _create_popup_event(popup_object)
    log "popup create:#{popup_object}"

    response = Fooda::PopupEventsApi.create({
      access_token: Token.map(Token::ADMIN_USER_EMAIL),
      client_token: Token.get_client,
      popup_event: popup_object
    })

    if [200,201].include?(response.code)
      log "popup created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "popup create error:#{errors}"
    end
  end

  def _resolve_account(account_name)
    response = Fooda::AccountsApi.get_by({
      name: account_name,
    })
    response.account
  end

  def _resolve_building(building_name)
    response = Fooda::BuildingsApi.get_by({
      name: building_name,
    })
    response.building
  end

  def _resolve_location(location_name)
    response = Fooda::LocationsApi.get_by({
      name: location_name,
    })
    response.location
  end

  def _resolve_vendor(vendor_name)
    response = Fooda::VendorsApi.get_by({
      name: vendor_name,
    })
    response.vendor
  end

end
