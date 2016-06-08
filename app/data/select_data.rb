class SelectData < BaseData

  def create(objects)
    objects.each do |object|
      begin
        object = resolve(object)

        # todo: find object

        if true#object.blank?
          _create_select_event(object)
        end
      rescue => e
        log "[exception] #{e.message}"
      end
    end
  end

  def resolve(select_object)
    select_event_locations = select_object[:select_event_locations] || []
    select_event_vendors = select_object[:select_event_vendors] || []

    log "delivery resolve:#{select_object}"

    if (account_name = select_object[:account_name]).present?
      log "delivery account resolve:#{account_name}"

      account = _resolve_account(account_name)

      if account.present?
        select_object[:account_id] = account.id
        log "delivery account resolve:#{account_name} exists"
      end
    end

    select_event_locations.each do |select_event_location|
      if (location_name = select_event_location[:location_name]).present?
        log "delivery location resolve:#{location_name}"

        location = _resolve_location(location_name)
        raise "delivery location resolve:#{location_name} not found" if location.blank?

        log "delivery location resolve:#{location_name} exists"

        select_event_location[:location_id] = location.id
      end
    end

    select_event_vendors.each do |select_event_vendor|
      if (vendor_name = select_event_vendor[:vendor_name]).present?
        log "delivery vendor resolve:#{vendor_name}"

        vendor = _resolve_vendor(vendor_name)
        raise "delivery vendor resolve:#{vendor_name} not found" if vendor.blank?

        log "delivery vendor resolve:#{vendor_name} exists"

        select_event_vendor[:vendor_id] = vendor.id
      end

      if (menu_template_name = select_event_vendor[:menu_template_name]).present?
        log "delivery menu_template resolve:#{menu_template_name}"

        vendor_id = select_event_vendor[:vendor_id]
        response = Fooda::VendorsApi.get_by({
          id: vendor_id,
          with: ['menu_templates']
        })
        vendor = response.vendor

        menu_template = vendor.menu_templates.find do |menu_template|
          menu_template.name == menu_template_name
        end
        raise "delivery menu template #{menu_template_name} not found" if menu_template.blank?

        log "delivery menu_template resolve:#{menu_template_name} exists"

        select_event_vendor[:menu_template_id] = menu_template.id
      end
    end

    select_object
  end

  protected

  def _create_select_event(select_object)
    log "delivery create:#{select_object}"

    response = Fooda::SelectEventsApi.create({
      access_token: Token.map(Token::ADMIN_USER_EMAIL),
      client_token: Token.get_client,
      select_event: select_object,
    })

    if [200,201].include?(response.code)
      log "delivery created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "delivery create error:#{errors}"
    end

    response.select_event
  end

  def _resolve_account(account_name)
    response = Fooda::AccountsApi.get_by({
      name: account_name,
    })
    response.account
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
