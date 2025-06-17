# loading installation configs
GlobalConfig.clear_cache
ConfigLoader.new.process

## Seeds productions
# if Rails.env.production?
#   # Setup Onboarding flow
#   Redis::Alfred.set(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING, true)
# end

## Seeds productions
if Rails.env.production?


  Redis::Alfred.set(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING, true)

  # Carrega dados do .env
  account_name = ENV.fetch('CW_ACCOUNT_NAME', 'Empresa Default')
  user_email = ENV.fetch('CW_ADMIN_EMAIL', 'admin@empresa.com')
  user_password = ENV.fetch('CW_ADMIN_PASSWORD', '123456')

  account = Account.find_or_create_by!(name: account_name)

  user = User.find_or_initialize_by(email: user_email)
  unless user.persisted?
    user.name = 'Admin'
    user.password = user_password
    user.type = 'SuperAdmin'
    user.skip_confirmation!
    user.save!
    puts "✅ Usuário criado: #{user_email}"
  else
    puts "ℹ️ Usuário #{user_email} já existe."
  end
  
  AccountUser.find_or_create_by!(account: account, user: user, role: :administrator)
  
  # 🔥 agora está fora do bloco — será sempre executado
  unless Inbox.exists?(name: 'Canal Evolution', account: account)
    channel = Channel::Evolution.create!
    inbox = Inbox.create!(name: 'Canal Evolution', account: account, channel: channel)
    InboxMember.create!(user: user, inbox: inbox)
    puts "✅ Canal e Inbox 'Evolution' criados."
  else
    puts "ℹ️ Inbox 'Canal Evolution' já existe."
  end
end
## Seeds for Local Development
unless Rails.env.production?

  # Enables creating additional accounts from dashboard
  installation_config = InstallationConfig.find_by(name: 'CREATE_NEW_ACCOUNT_FROM_DASHBOARD')
  installation_config.value = true
  installation_config.save!
  GlobalConfig.clear_cache

  account = Account.create!(
    name: 'Acme Inc'
  )

  secondary_account = Account.create!(
    name: 'Acme Org'
  )

  user = User.new(name: 'John', email: 'john@acme.inc', password: 'Password1!', type: 'SuperAdmin')
  user.skip_confirmation!
  user.save!

  AccountUser.create!(
    account_id: account.id,
    user_id: user.id,
    role: :administrator
  )

  AccountUser.create!(
    account_id: secondary_account.id,
    user_id: user.id,
    role: :administrator
  )

  web_widget = Channel::WebWidget.create!(account: account, website_url: 'https://acme.inc')

  inbox = Inbox.create!(channel: web_widget, account: account, name: 'Acme Support')
  InboxMember.create!(user: user, inbox: inbox)

  contact_inbox = ContactInboxWithContactBuilder.new(
    source_id: user.id,
    inbox: inbox,
    hmac_verified: true,
    contact_attributes: { name: 'jane', email: 'jane@example.com', phone_number: '+2320000' }
  ).perform

  conversation = Conversation.create!(
    account: account,
    inbox: inbox,
    status: :open,
    assignee: user,
    contact: contact_inbox.contact,
    contact_inbox: contact_inbox,
    additional_attributes: {}
  )


  Channel::Evolution.find_or_create_by!
  Inbox.find_or_create_by!(name: 'Canal Evolution', account_id: 1) do |inbox|
    inbox.channel = Channel::Evolution.first
  end
  # sample email collect
  Seeders::MessageSeeder.create_sample_email_collect_message conversation

  Message.create!(content: 'Hello', account: account, inbox: inbox, conversation: conversation, sender: contact_inbox.contact,
                  message_type: :incoming)

  # sample location message
  #
  location_message = Message.new(content: 'location', account: account, inbox: inbox, sender: contact_inbox.contact, conversation: conversation,
                                 message_type: :incoming)
  location_message.attachments.new(
    account_id: account.id,
    file_type: 'location',
    coordinates_lat: 37.7893768,
    coordinates_long: -122.3895553,
    fallback_title: 'Bay Bridge, San Francisco, CA, USA'
  )
  location_message.save!

  # sample card
  Seeders::MessageSeeder.create_sample_cards_message conversation
  # input select
  Seeders::MessageSeeder.create_sample_input_select_message conversation
  # form
  Seeders::MessageSeeder.create_sample_form_message conversation
  # articles
  Seeders::MessageSeeder.create_sample_articles_message conversation
  # csat
  Seeders::MessageSeeder.create_sample_csat_collect_message conversation

  CannedResponse.create!(account: account, short_code: 'start', content: 'Hello welcome to chatwoot.')
end
