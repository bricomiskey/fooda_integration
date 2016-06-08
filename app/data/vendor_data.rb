class VendorData < BaseData

  def create(objects)
    objects.each do |object|
      vendor = exists(object[:name])

      if vendor.blank?
        _create_vendor(object)
      end
    end
  end

  def exists(vendor_name, options={})
    log "vendor check:#{vendor_name}"

    response = Fooda::VendorsApi.get_by({name: vendor_name}.merge(options))
    vendor = response.vendor

    if response.code == 200
      log "vendor check:#{vendor_name} exists"
    else
      log "vendor check:#{vendor_name} not found"
    end

    vendor
  end

  protected

  def _create_vendor(vendor_object)
    log "vendor create:#{vendor_object}"

    response = Fooda::VendorsApi.create({
      access_token: Token.map(Token::ADMIN_USER_EMAIL),
      client_token: Token.get_client,
      vendor: vendor_object
    })

    if [200,201].include?(response.code)
      log "vendor created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "vendor create error:#{errors}"
    end

    response.vendor
  end

end
