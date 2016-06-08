class CreditCard
  include LoggerConcern
  include TokenConcern

  def initialize(options={})
    tokens(options)

    @user_id = options[:user_id]
  end

  def create(options={})
    cc_params = {
      credit_card: {
        billing_address: _default_billing_address,
        cvv: _default_cvv,
        expiration_date: _default_expiration_date,
        number: _default_cc_number,
      }
    }
    params = cc_params.merge({
      access_token: access_token,
      client_token: client_token,
    })
    response = Fooda::UsersApi.create_credit_card(params)

    if response.code == 201
      card = response.data.card
      logger.info "user:#{@user_id} credit card created"
    end

    response
  end

  def find(min_cards=1)
    response = get
    raise "credit card get error" if response.code != 200

    cur_cards = response.data.credit_cards

    logger.info "user:#{@user_id} credit card exists" if cur_cards.present?

    if cur_cards.size < min_cards
      new_cards_count = min_cards - cur_cards.size

      logger.info "user:#{@user_id} credit card not found ... creating #{new_cards_count} new credit card(s)"

      1.upto(new_cards_count) do |i|
        response = create
      end

      response = get
      cur_cards = response.data.credit_cards
    end

    cur_cards
  end

  def get
    response = Fooda::UsersApi.get_credit_cards({
      access_token: access_token,
      client_token: client_token
    })
  end

  protected

  def _default_billing_address
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      company: Faker::Company.name,
      street_address: Faker::Address.street_address,
      postal_code: Faker::Address.zip_code,
      country_code_alpha2: "us"
    }
  end

  def _default_cvv
    Faker::Number.number(3)
  end

  def _default_cc_number
    '4111111111111111'
  end

  def _default_expiration_date
    "#{rand(10..12)}/#{rand(17..20)}"
  end

end
