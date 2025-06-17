<script>
import { mapGetters } from 'vuex';
import { shouldBeUrl } from 'shared/helpers/Validators';
import { useAlert } from 'dashboard/composables';
import { useVuelidate } from '@vuelidate/core';
import SettingIntroBanner from 'dashboard/components/widgets/SettingIntroBanner.vue';
import SettingsSection from '../../../../components/SettingsSection.vue';
import inboxMixin from 'shared/mixins/inboxMixin';
import FacebookReauthorize from './facebook/Reauthorize.vue';
import MicrosoftReauthorize from './channels/microsoft/Reauthorize.vue';
import GoogleReauthorize from './channels/google/Reauthorize.vue';
import PreChatFormSettings from './PreChatForm/Settings.vue';
import WeeklyAvailability from './components/WeeklyAvailability.vue';
import GreetingsEditor from 'shared/components/GreetingsEditor.vue';
import ConfigurationPage from './settingsPage/ConfigurationPage.vue';
import CollaboratorsPage from './settingsPage/CollaboratorsPage.vue';
import WidgetBuilder from './WidgetBuilder.vue';
import BotConfiguration from './components/BotConfiguration.vue';
import { FEATURE_FLAGS } from '../../../../featureFlags';
import SenderNameExamplePreview from './components/SenderNameExamplePreview.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    BotConfiguration,
    CollaboratorsPage,
    ConfigurationPage,
    FacebookReauthorize,
    GreetingsEditor,
    PreChatFormSettings,
    SettingIntroBanner,
    SettingsSection,
    WeeklyAvailability,
    WidgetBuilder,
    SenderNameExamplePreview,
    MicrosoftReauthorize,
    GoogleReauthorize,
    NextButton,
  },
  mixins: [inboxMixin],
  setup() {
    return { v$: useVuelidate() };
  },
  data() {
    return {
      avatarFile: null,
      avatarUrl: '',
      greetingEnabled: true,
      greetingMessage: '',
      emailCollectEnabled: false,
      csatSurveyEnabled: false,
      senderNameType: 'friendly',
      businessName: '',
      locktoSingleConversation: false,
      allowMessagesAfterResolved: true,
      continuityViaEmail: true,
      selectedInboxName: '',
      channelWebsiteUrl: '',
      webhookUrl: '',
      channelWelcomeTitle: '',
      channelWelcomeTagline: '',
      selectedFeatureFlags: [],
      replyTime: '',
      selectedTabIndex: 0,
      selectedPortalSlug: '',
      showBusinessNameInput: false,
    };
  },
  computed: {
    ...mapGetters({
      accountId: 'getCurrentAccountId',
      isFeatureEnabledonAccount: 'accounts/isFeatureEnabledonAccount',
      uiFlags: 'inboxes/getUIFlags',
      portals: 'portals/allPortals',
    }),

    // adicionado: detecta canal Evolution
    isEvolutionChannel() {
      return this.inbox.channel_type === 'Channel::Evolution';
    },

    selectedTabKey() {
      return this.tabs[this.selectedTabIndex]?.key;
    },
    whatsAppAPIProviderName() {
      if (this.isAWhatsAppCloudChannel) {
        return this.$t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.WHATSAPP_CLOUD');
      }
      if (this.is360DialogWhatsAppChannel) {
        return this.$t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.360_DIALOG');
      }
      if (this.isATwilioWhatsAppChannel) {
        return this.$t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.TWILIO');
      }
      return '';
    },
    tabs() {
      let visibleToAllChannelTabs = [
        { key: 'inbox_settings', name: this.$t('INBOX_MGMT.TABS.SETTINGS') },
        { key: 'collaborators',  name: this.$t('INBOX_MGMT.TABS.COLLABORATORS') },
        { key: 'businesshours',  name: this.$t('INBOX_MGMT.TABS.BUSINESS_HOURS') },
      ];

      if (this.isAWebWidgetInbox) {
        visibleToAllChannelTabs = [
          ...visibleToAllChannelTabs,
          { key: 'preChatForm',    name: this.$t('INBOX_MGMT.TABS.PRE_CHAT_FORM') },
          { key: 'widgetBuilder',  name: this.$t('INBOX_MGMT.TABS.WIDGET_BUILDER') },
        ];
      }

      // incluído isEvolutionChannel para mostrar aba Configuration
      if (
        this.isATwilioChannel ||
        this.isALineChannel   ||
        this.isAPIInbox       ||
        this.isEvolutionChannel ||
        (this.isAnEmailChannel && !this.inbox.provider) ||
        this.isAWhatsAppChannel ||
        this.isAWebWidgetInbox
      ) {
        visibleToAllChannelTabs = [
          ...visibleToAllChannelTabs,
          { key: 'configuration', name: this.$t('INBOX_MGMT.TABS.CONFIGURATION') },
        ];
      }

      if (
        this.isFeatureEnabledonAccount(this.accountId, FEATURE_FLAGS.AGENT_BOTS) &&
        !(this.isAnEmailChannel || this.isATwitterInbox)
      ) {
        visibleToAllChannelTabs = [
          ...visibleToAllChannelTabs,
          { key: 'botConfiguration', name: this.$t('INBOX_MGMT.TABS.BOT_CONFIGURATION') },
        ];
      }
      return visibleToAllChannelTabs;
    },
    currentInboxId() {
      return this.$route.params.inboxId;
    },
    inbox() {
      return this.$store.getters['inboxes/getInbox'](this.currentInboxId);
    },

    inboxName() {
      // adicionado: exibe número para Evolution
      if (this.isEvolutionChannel) {
        return `${this.inbox.name} (${this.inbox.provider_config.number})`;
      }
      if (this.isATwilioSMSChannel || this.isATwilioWhatsAppChannel) {
        return `${this.inbox.name} (${this.inbox.messaging_service_sid || this.inbox.phone_number})`;
      }
      if (this.isAWhatsAppChannel) {
        return `${this.inbox.name} (${this.inbox.phone_number})`;
      }
      if (this.isAnEmailChannel) {
        return `${this.inbox.name} (${this.inbox.email})`;
      }
      return this.inbox.name;
    },
    canLocktoSingleConversation() {
      // adicionado: permite lock para Evolution
      return (
        this.isASmsInbox       ||
        this.isAWhatsAppChannel||
        this.isAFacebookInbox  ||
        this.isAPIInbox        ||
        this.isEvolutionChannel
      );
    },
    inboxNameLabel() {
      if (this.isAWebWidgetInbox) {
        return this.$t('INBOX_MGMT.ADD.WEBSITE_NAME.LABEL');
      }
      return this.$t('INBOX_MGMT.ADD.CHANNEL_NAME.LABEL');
    },
    inboxNamePlaceHolder() {
      if (this.isAWebWidgetInbox) {
        return this.$t('INBOX_MGMT.ADD.WEBSITE_NAME.PLACEHOLDER');
      }
      return this.$t('INBOX_MGMT.ADD.CHANNEL_NAME.PLACEHOLDER');
    },
    textAreaChannels() {
      if (this.isATwilioChannel || this.isATwitterInbox || this.isAFacebookInbox)
        return true;
      return false;
    },
    microsoftUnauthorized() {
      return this.isAMicrosoftInbox && this.inbox.reauthorization_required;
    },
    facebookUnauthorized() {
      return this.isAFacebookInbox && this.inbox.reauthorization_required;
    },
    googleUnauthorized() {
      const isLegacyInbox = ['imap.gmail.com', 'imap.google.com'].includes(
        this.inbox.imap_address
      );

      return (
        (this.isAGoogleInbox || isLegacyInbox) &&
        this.inbox.reauthorization_required
      );
    },
  },
  watch: {
    $route(to) {
      if (to.name === 'settings_inbox_show') {
        this.fetchInboxSettings();
      }
    },
  },
  mounted() {
    this.fetchInboxSettings();
    this.fetchPortals();
  },
  methods: {
    fetchPortals() {
      this.$store.dispatch('portals/index');
    },
    handleFeatureFlag(e) {
      this.selectedFeatureFlags = this.toggleInput(
        this.selectedFeatureFlags,
        e.target.value
      );
    },
    toggleInput(selected, current) {
      if (selected.includes(current)) {
        const newSelectedFlags = selected.filter(flag => flag !== current);
        return newSelectedFlags;
      }
      return [...selected, current];
    },
    onTabChange(selectedTabIndex) {
      this.selectedTabIndex = selectedTabIndex;
    },
    fetchInboxSettings() {
      this.selectedTabIndex = 0;
      this.selectedAgents = [];
      this.$store.dispatch('agents/get');
      this.$store.dispatch('teams/get');
      this.$store.dispatch('labels/get');
      this.$store.dispatch('inboxes/get').then(() => {
        this.avatarUrl = this.inbox.avatar_url;
        this.selectedInboxName = this.inbox.name;
        this.webhookUrl = this.inbox.webhook_url;
        this.greetingEnabled = this.inbox.greeting_enabled || false;
        this.greetingMessage = this.inbox.greeting_message || '';
        this.emailCollectEnabled = this.inbox.enable_email_collect;
        this.csatSurveyEnabled = this.inbox.csat_survey_enabled;
        this.senderNameType = this.inbox.sender_name_type;
        this.businessName = this.inbox.business_name;
        this.allowMessagesAfterResolved = this.inbox.allow_messages_after_resolved;
        this.continuityViaEmail = this.inbox.continuity_via_email;
        this.channelWebsiteUrl = this.inbox.website_url;
        this.channelWelcomeTitle = this.inbox.welcome_title;
        this.channelWelcomeTagline = this.inbox.welcome_tagline;
        this.selectedFeatureFlags = this.inbox.selected_feature_flags || [];
        this.replyTime = this.inbox.reply_time;
        this.locktoSingleConversation = this.inbox.lock_to_single_conversation;
        this.selectedPortalSlug = this.inbox.help_center ? this.inbox.help_center.slug : '';
      });
    },
    async updateInbox() {
      try {
        const payload = {
          id: this.currentInboxId,
          name: this.selectedInboxName,
          enable_email_collect: this.emailCollectEnabled,
          csat_survey_enabled: this.csatSurveyEnabled,
          allow_messages_after_resolved: this.allowMessagesAfterResolved,
          greeting_enabled: this.greetingEnabled,
          greeting_message: this.greetingMessage || '',
          portal_id: this.selectedPortalSlug
            ? this.portals.find(portal => portal.slug === this.selectedPortalSlug).id
            : null,
          lock_to_single_conversation: this.locktoSingleConversation,
          sender_name_type: this.senderNameType,
          business_name: this.businessName || null,
          channel: {
            widget_color: this.inbox.widget_color,
            website_url: this.channelWebsiteUrl,
            webhook_url: this.webhookUrl,
            welcome_title: this.channelWelcomeTitle || '',
            welcome_tagline: this.channelWelcomeTagline || '',
            selectedFeatureFlags: this.selectedFeatureFlags,
            reply_time: this.replyTime || 'in_a_few_minutes',
            continuity_via_email: this.continuityViaEmail,
          },
        };
        if (this.avatarFile) payload.avatar = this.avatarFile;
        await this.$store.dispatch('inboxes/updateInbox', payload);
        useAlert(this.$t('INBOX_MGMT.EDIT.API.SUCCESS_MESSAGE'));
      } catch (error) {
        useAlert(error.message || this.$t('INBOX_MGMT.EDIT.API.ERROR_MESSAGE'));
      }
    },
    handleImageUpload({ file, url }) {
      this.avatarFile = file;
      this.avatarUrl = url;
    },
    async handleAvatarDelete() {
      try {
        await this.$store.dispatch('inboxes/deleteInboxAvatar', this.currentInboxId);
        this.avatarFile = null;
        this.avatarUrl = '';
        useAlert(this.$t('INBOX_MGMT.DELETE.API.AVATAR_SUCCESS_MESSAGE'));
      } catch (error) {
        useAlert(error.message ? error.message : this.$t('INBOX_MGMT.DELETE.API.AVATAR_ERROR_MESSAGE'));
      }
    },
    toggleSenderNameType(key) {
      this.senderNameType = key;
    },
    onClickShowBusinessNameInput() {
      this.showBusinessNameInput = !this.showBusinessNameInput;
      if (this.showBusinessNameInput) this.$nextTick(() => this.$refs.businessNameInput.focus());
    },
  },
  validations: {
    webhookUrl: { shouldBeUrl },
    selectedInboxName: {},
  },
};
</script>

<template>
  <div class="flex-grow flex-shrink w-full min-w-0 pl-0 pr-0 overflow-auto settings">
    <SettingIntroBanner :header-image="inbox.avatarUrl" :header-title="inboxName">
      <woot-tabs class="settings--tabs" :index="selectedTabIndex" :border="false" @change="onTabChange">
        <woot-tabs-item v-for="(tab, index) in tabs" :key="tab.key" :index="index" :name="tab.name" :show-badge="false" />
      </woot-tabs>
    </SettingIntroBanner>
    <section class="max-w-6xl mx-auto w-full">
      <MicrosoftReauthorize v-if="microsoftUnauthorized" :inbox="inbox" />
      <FacebookReauthorize  v-if="facebookUnauthorized"  :inbox="inbox" />
      <GoogleReauthorize    v-if="googleUnauthorized"    :inbox="inbox" />
      <div v-if="selectedTabKey==='inbox_settings'" class="mx-8">
        <!-- resto sem alterações -->
      </div>
      <div v-if="selectedTabKey==='collaborators'" class="mx-8">
        <CollaboratorsPage :inbox="inbox" />
      </div>
      <div v-if="selectedTabKey==='configuration'">
        <ConfigurationPage :inbox="inbox" />
      </div>
      <div v-if="selectedTabKey==='preChatForm'">
        <PreChatFormSettings :inbox="inbox" />
      </div>
      <div v-if="selectedTabKey==='businesshours'">
        <WeeklyAvailability :inbox="inbox" />
      </div>
      <div v-if="selectedTabKey==='widgetBuilder'">
        <WidgetBuilder :inbox="inbox" />
      </div>
      <div v-if="selectedTabKey==='botConfiguration'">
        <BotConfiguration :inbox="inbox" />
      </div>
    </section>
  </div>
</template>

<style scoped lang="scss">
.settings--tabs {
  ::v-deep .tabs { @apply p-0; }
}
</style>
