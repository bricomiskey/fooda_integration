class VendorData < BaseData

  def create(objects)
    objects.each do |object|
      vendor = find(object[:name])

      if vendor.blank?
        _create_vendor(object)
      end
    end
  end

  def find(vendor_name, options={})
    log "vendor:#{vendor_name}"

    response = Fooda::VendorsApi.get_by({name: vendor_name}.merge(options))

    if response.code == 200
      log "vendor exists"
      vendor = response[:vendor]
    else
      vendor = nil
    end
  end

  protected

  def _create_vendor(vendor_object)
    log "vendor:#{vendor_object}"

    response = Fooda::VendorsApi.create({vendor: vendor_object})
    if [200,201].include?(response.code)
      log "vendor created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "vendor create error:#{errors}"
    end

  end

end
