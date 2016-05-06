class PartnerData < BaseData

  def create(objects)
    objects.each do |object|
      partner = find(object[:name])

      if partner.blank?
        _create_partner(object)
      end
    end
  end

  def find(partner_name, options={})
    log "partner:#{partner_name}"

    response = Fooda::PartnersApi.get_by({name: partner_name}.merge(options))

    case response.code
    when 200
      log 'partner exists'
      response[:partner]
    end
  end

  protected

  def _create_partner(partner_object)
    log "partner:#{partner_object}"

    response = Fooda::PartnersApi.create({partner: partner_object})

    case response.code
    when 200, 201
      log 'partner created'
    else
      errors = response.errors.map{ |o| [o.code, o.message] }
      log "partner create error:#{errors}"
    end
  end
end
