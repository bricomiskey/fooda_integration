require 'test_helper'

class PopupCreateTest < ActionDispatch::IntegrationTest

  let!(:ping) { ping! }
  let!(:check) { check!(:vendor, vendor_name) }

  let(:logger) { Logger.new(STDOUT) }

  let(:admin_email) { Token::ADMIN_USER_EMAIL }
  let(:admin_token) { Token.map(admin_email) }

  let(:client_token) { Token.get_client }

  let(:account_name) { 'Chicago Account' }
  let(:building_name) { 'Chicago Building 1' }
  let(:location_name) { 'Chicago Building 1 Spot' }

  let(:vendor_name) { 'Leghorn Chicken' }
  let(:menu_template_name) { 'Leghorn Chicken Popup Menu Template' }

  let(:popup_email_list_id) { '18277' }
  let(:popup_initial_status) { 'proposed' }

  let(:time_now) { Time.now }
  let(:time_now_utc) { Time.now.utc }

  let(:popup_event_data) {
    Hashie::Mash.new(
      account_name: account_name,
      building_name: building_name,
      email_list_id: popup_email_list_id,
      event_end_time: (time_now_utc.end_of_day + 12.hours + 2.hours).to_s(:ical_datetime_utc),
      event_start_time:(time_now_utc.end_of_day + 12.hours).to_s(:ical_datetime_utc),
      ignore_final_email: false,
      ignore_introduction_email: true,
      meal_period: 'Lunch',
      status: popup_initial_status,
      popup_event_locations: [
        location_name: location_name,
      ],
      popup_event_vendors: [
        {
          menu_template_name: menu_template_name,
          popup_event_location_name: location_name,
          prep_for: rand(30..45),
          site_fee_cents: rand(100..500),
          tokens: ['meals_sold_reminder_token', 'site_directions_token'],
          vendor_name: vendor_name,
        }
      ],
    )
  }

  test "admin should create popup event" do
    # get popup event account, building, location objects
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

    # create popup event

    response = Fooda::PopupEventsApi.create({
      access_token: admin_token,
      client_token: client_token,
      popup_event: PopupData.new.resolve(popup_event_data),
    })
    response.code.must_equal 201

    popup_event = response.popup_event

    logger.info "popup_event:#{popup_event.id} created"

    popup_event.status.must_equal popup_initial_status
    popup_event.vendors.map{ |o| o.id }.must_equal [vendor.id]

    # schedule, then activate popup event

    events = [
      {event: 'schedule', params: {ssl_verify_off: 1, sync_workers: 1}},
      {event: 'activate', params: {}}
    ]
    events.each do |hash|
      event = hash[:event]
      options = hash[:params].merge({
        access_token: admin_token,
        client_token: client_token,
      })
      response = Fooda::PopupEventsApi.change_state(popup_event.id, event, options)
      puts response # xxx
      # response.code.must_equal 200
    end

    options = {
      id: popup_event.id,
      access_token: admin_token,
      client_token: client_token,
      with: ['event_campaigns'],
    }
    response = Fooda::PopupEventsApi.get_by(options)
    response.code.must_equal 200

    puts response

    popup_event = response.popup_event
    popup_event.status.must_equal 'active'

    campaign = popup_event.event_campaigns.find do |campaign|
      campaign.campaignable_type.match(/Popup/) && campaign.campaignable_id == popup_event.id
    end
    campaign.state.must_equal 'scheduled'
    campaign.campaign_id.must_match(/^\d+$/)

    response = ExpressPigeon::CampaignsApi._get(campaign.campaign_id)
    response.code.must_equal 200
  end

end
