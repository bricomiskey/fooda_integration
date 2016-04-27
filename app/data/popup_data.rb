class PopupData < BaseData

  def create(objects)
    objects.each do |object|
      _create_popup_event(object)
    end
  end

  protected

  def _create_popup_event(popup_object)
    account_name = popup_object[:account_name]
    building_name = popup_object[:building_name]

    popup_event_vendors = popup_object[:popup_event_vendors] || []

    log "popup:#{popup_object}"

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

      popup_object[:account_id] = account.try(:id)
    end

    if building_name.present?
      # map building_name to object
      building_data = BuildingData.new
      building = BuildingData.new.find(building_name)

      popup_object[:building_id] = building.try(:id)
    end

    popup_event_vendors.each do |popup_event_vendor|
      if popup_event_vendor[:vendor_name].present?
        # map vendor name to object
        vendor = VendorData.new.find(popup_event_vendor[:vendor_name])
        popup_event_vendor[:vendor_id] = vendor.try(:id)
      end

      if popup_event_vendor[:menu_template_name].present?
        log "vendor:#{popup_event_vendor[:vendor_name]}:menu_template:#{popup_event_vendor[:menu_template_name]}"

        vendor = VendorData.new.find(popup_event_vendor[:vendor_name], {with: ['menu_templates']})
        menu_template = vendor.menu_templates.find do |menu_template|
          menu_template.name == popup_event_vendor[:menu_template_name]
        end
        popup_event_vendor[:menu_template_id] = menu_template.try(:id)

        if menu_template.present?
          log "vendor menu template exists"
        end
      end

      if popup_event_vendor[:popup_event_location_name].present?
        # map location name to object
        location = LocationData.new.find(popup_event_vendor[:popup_event_location_name])
        popup_event_vendor[:popup_event_location_id] = location.try(:id)
      end
    end

    response = Fooda::PopupEventsApi.create({popup_event: popup_object})

    if [200,201].include?(response.code)
      log "popup created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "popup create error:#{errors}"
    end
  end

end
