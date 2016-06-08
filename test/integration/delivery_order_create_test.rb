require 'test_helper'

class DeliveryOrderCreateTest < ActionDispatch::IntegrationTest

  let!(:ping) { ping! }
  let!(:check) { check!(:vendor, vendor_name) }

  let(:logger) { Logger.new(STDOUT) }

  let(:admin_email) { Token::ADMIN_USER_EMAIL }
  let(:admin_token) { Token.map(admin_email) }

  let(:client_token) { Token.get_client }

  let(:customer_email) { random_delivery_customer_email }
  let(:customer_token) { Token.map(customer_email) }

  let(:customer_data) {
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      password: 'password',
    }.merge(email: customer_email)
  }

  let(:account_name) { 'Chicago Account' }
  let(:building_name) { 'Chicago Building 1' }
  let(:location_name) { 'Chicago Building 1 Delivery' }

  let(:vendor_name) { 'Leghorn Chicken' }
  let(:menu_template_name) { 'Leghorn Chicken Delivery Menu Template' }

  let(:time_now) { Time.now }
  let(:time_now_utc) { Time.now.utc }

  let(:select_event_data) {
    Hashie::Mash.new(
      account_name: account_name,
      default_gratuity: rand(5..10).to_f,
      delivery_time: (time_now + 6.hours + 1.hours).to_s(:ical_datetime_local),
      delivery_time_utc: (time_now_utc + 6.hours + 1.hours).to_s(:ical_datetime_utc),
      meal_period: 'lunch',
      ordering_window_end_time: (time_now + 6.hours).to_s(:ical_datetime_local),
      ordering_window_end_time_utc: (time_now_utc + 6.hours).to_s(:ical_datetime_utc),
      ordering_window_start_time: (time_now - 1.minute).to_s(:ical_datetime_local),
      ordering_window_start_time_utc: (time_now_utc - 1.minute).to_s(:ical_datetime_utc),
      ready_and_bagged: rand(30..59),
      select_event_locations: [
        location_name: location_name,
      ],
      select_event_vendors: [
        menu_template_name: menu_template_name,
        vendor_name: vendor_name,
      ],
      status: 'active',
    )
  }

  test "user should create delivery order" do
    # get select event account, building, location objects

    response = Fooda::AccountsApi.get_by({name: account_name})
    response.code.must_equal 200
    account = response.account

    response = Fooda::BuildingsApi.get_by({name: building_name})
    response.code.must_equal 200
    building = response.building

    response = Fooda::LocationsApi.get_by({name: location_name})
    response.code.must_equal 200
    location = response.location

    response = Fooda::VendorsApi.get_by({name: vendor_name})
    response.code.must_equal 200
    vendor = response.vendor

    if vendor.state != 'active'
      options = {
        access_token: admin_token,
        client_token: client_token,
      }
      response = Fooda::VendorsApi.change_state(vendor.id, 'activate', options)
      response.code.must_equal 200

      response = Fooda::VendorsApi.get_by({name: vendor_name})
      vendor = response.vendor
    end

    # create select event
    response = Fooda::SelectEventsApi.create({
      access_token: admin_token,
      client_token: client_token,
      select_event: SelectData.new.resolve(select_event_data),
    })
    response.code.must_equal 201

    select_event = response.select_event

    logger.info "select_event:#{select_event.id} created"

    # get user
    response = Fooda::UsersApi.get_by({email: customer_email})
    user = response.user

    if response.code == 404
      response = Fooda::UsersApi.create({user: customer_data})
      response.code.must_equal 201

      user = response.user
    end

    user.email.must_equal customer_email

    logger.info "user:#{user.id} email:#{user.email}"

    account_name = select_event.account_name
    building_name = select_event.locations.map{ |o| o.delivery_building_name }.first
    location_name = select_event.locations.map{ |o| o.delivery_location_name }.first

    # link user to account and building

    params = {
      access_token: admin_token,
      user: {
        uuid: user.uuid
      }
    }
    response = Fooda::AccountsApi.add_user(account.id, params)
    response.code.must_equal 201
    account_role = response.account_role

    params = {
      access_token: admin_token,
      account_role_id: account_role.id,
      user: {
        uuid: user.uuid
      }
    }
    response = Fooda::BuildingsApi.add_user(building.id, params)
    response.code.must_equal 201

    # start order process
    # step 1: get select schedule
    # step 2: get select event vendor menu(s)
    # step 3: add item(s) to cart
    # step 4: create order

    logger.info "user:#{user.id} select_event:#{select_event.id} order starting ..."

    # delivery date is in local time
    delivery_date = Time.parse(select_event_data.delivery_time).to_date

    response = Fooda::SelectScheduleApi.get_schedule({
      access_token: customer_token,
      client_token: client_token,
      end_date: (delivery_date+1.day).to_s,
      start_date: delivery_date.to_s,
    })
    response.code.must_equal 200

    # puts response

    dates = response.data.dates
    dates.size.must_be :>=, 1

    select_events = dates.find{ |hash| hash.date == delivery_date.to_s }.meal_periods.first.select_events
    select_events.map{ |o| o.id }.include?(select_event.id).must_equal true

    vendor_id = select_event.vendors.map{ |o| o.id }.first

    params = {
      access_token: customer_token,
      client_token: client_token,
    }
    response = Fooda::SelectMenusApi.get_menu(select_event.id, vendor_id, params)
    response.code.must_equal 200

    # puts response

    menus = response.data.menu
    menus.size.must_be :>=, 1

    menu_items = menus.first.menu_items
    menu_items.size.must_be :>=, 1

    menu_item = menu_items.sample

    params = {
      access_token: customer_token,
      client_token: client_token,
    }
    response = Fooda::CartApi.get_items(params)
    response.code.must_equal 200

    if response.data.items.size == 0
      params = {
        access_token: customer_token,
        client_token: client_token,
        item_id: menu_item.id,
        select_event_id: select_event.id,
      }
      response = Fooda::CartApi.add_item(params)
      response.code.must_equal 201
    end

    logger.info "user:#{user.id} credit card check ..."

    credit_cards = CreditCard.new({user_id: user.id, user_email: customer_email}).find
    credit_cards.size.must_be :>=, 1

    credit_card = credit_cards.first

    params = {
      access_token: customer_token,
      client_token: client_token,
      card_id: credit_card.id,
      locations: [
        {
          location_id: location.id,
          select_event_id: select_event.id,
        }
      ]
    }
    response = Fooda::OrdersApi.create(params)
    # puts response
    response.code.must_equal 201

    orders = response.data.orders
    orders.size.must_equal 1

    logger.info "user:#{user.id} select_event:#{select_event.id} order completed"

    timestamp_end = select_event_data.ordering_window_end_time_utc
    timestamp_start = select_event_data.ordering_window_start_time_utc

    params = {
      access_token: admin_token,
      client_token: client_token,
      select_event_id: select_event.id,
      timestamp_start: timestamp_start,
      timestamp_end: timestamp_end,
      vendor_id: vendor.id,
    }
    response = Fooda::SelectManifestsApi.create(params)
    response.code.must_equal 201

    response.select_events.size.must_equal 1

    logger.info "user:#{user.id} select_event:#{select_event.id} manifest created"

    response.select_manifest.present?.must_equal true
    select_manifest = response.select_manifest

    params = {
      access_token: admin_token,
      client_token: client_token,
      with: ['select_events'],
    }
    response = Fooda::SelectManifestsApi._get(select_manifest.id, params)
    response.code.must_equal 200

    response.select_manifest.select_events.map{ |o| o.id }.must_equal [select_event.id]

    params = {
      access_token: admin_token,
      client_token: client_token,
    }
    response = Fooda::SelectManifestsApi._send(select_manifest.id, params)
    # puts response
    response.code.must_equal 200

    response.email.subject.must_match "Fooda Select Manifest #{select_manifest.id}"

    logger.info "user:#{user.id} select_event:#{select_event.id} manifest sent"
  end

end
