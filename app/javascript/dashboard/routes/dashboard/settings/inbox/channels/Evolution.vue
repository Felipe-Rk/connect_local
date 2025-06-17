<template>
  <div class="border border-n-weak bg-n-solid-1 rounded-t-lg border-b-0 h-full w-full p-6 col-span-6 overflow-auto">
    <PageHeader
      :header-title="$t('INBOX_MGMT.ADD.EVOLUTION.TITLE')"
      :header-content="$t('INBOX_MGMT.ADD.EVOLUTION.DESC')"
    />
    <form class="flex flex-wrap flex-col mx-0" @submit.prevent="createChannel()">
      <!-- Instance Name -->
      <div class="flex-shrink-0 flex-grow-0 mb-4">
        <label :class="{ error: v$.instanceName.$error }">
          {{ $t('INBOX_MGMT.ADD.EVOLUTION.INSTANCE_NAME.LABEL') }}
          <input
            v-model="instanceName"
            type="text"
            @blur="v$.instanceName.$touch"
            :placeholder="$t('INBOX_MGMT.ADD.EVOLUTION.INSTANCE_NAME.PLACEHOLDER')"
          />
          <span v-if="v$.instanceName.$error" class="message">
            {{ $t('INBOX_MGMT.ADD.EVOLUTION.INSTANCE_NAME.ERROR') }}
          </span>
        </label>
      </div>
      <!-- Number -->
      <div class="flex-shrink-0 flex-grow-0 mb-4">
        <label :class="{ error: v$.number.$error }">
          {{ $t('INBOX_MGMT.ADD.EVOLUTION.NUMBER.LABEL') }}
          <input
            v-model="number"
            type="text"
            @blur="v$.number.$touch"
            :placeholder="$t('INBOX_MGMT.ADD.EVOLUTION.NUMBER.PLACEHOLDER')"
          />
          <span v-if="v$.number.$error" class="message">
            {{ $t('INBOX_MGMT.ADD.EVOLUTION.NUMBER.ERROR') }}
          </span>
        </label>
      </div>
      <!-- API Key -->
      <div class="flex-shrink-0 flex-grow-0 mb-4">
        <label :class="{ error: v$.apikey.$error }">
          {{ $t('INBOX_MGMT.ADD.EVOLUTION.APIKEY.LABEL') }}
          <input
            v-model="apikey"
            type="text"
            @blur="v$.apikey.$touch"
            :placeholder="$t('INBOX_MGMT.ADD.EVOLUTION.APIKEY.PLACEHOLDER')"
          />
          <span v-if="v$.apikey.$error" class="message">
            {{ $t('INBOX_MGMT.ADD.EVOLUTION.APIKEY.ERROR') }}
          </span>
        </label>
      </div>
      <div class="w-full mt-4">
        <NextButton
          :is-loading="uiFlags.isCreating"
          type="submit"
          solid
          blue
          :label="$t('INBOX_MGMT.ADD.EVOLUTION.SUBMIT_BUTTON')"
        />
      </div>
    </form>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import router from '../../../../index';
import PageHeader from '../../SettingsSubPageHeader.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  name: 'EvolutionConfig',
  components: {
    PageHeader,
    NextButton,
  },
  setup() {
    return { v$: useVuelidate() };
  },
  data() {
    return {
      instanceName: '',
      number: '',
      apikey: '',
    };
  },
  computed: {
    ...mapGetters({
      uiFlags: 'inboxes/getUIFlags',
    }),
  },
  validations: {
    instanceName: { required },
    number:        { required },
    apikey:        { required },
  },
  methods: {
    async createChannel() {
      this.v$.$touch();
      if (this.v$.$invalid) {
        return;
      }

      try {
        const evoChannel = await this.$store.dispatch('inboxes/createChannel', {
          name: this.instanceName,
          channel: {
            type:   'evolution',
            config: { number: this.number, apikey: this.apikey },
          },
        });

        router.replace({
          name:   'settings_inboxes_add_agents',
          params: { page: 'new', inbox_id: evoChannel.id },
        });
      } catch (error) {
        useAlert(this.$t('INBOX_MGMT.ADD.EVOLUTION.ERROR_MESSAGE'));
      }
    },
  },
};
</script>

<style scoped>
/* Adicione estilos específicos de EvolutionConfig aqui, se necessário */
</style>
