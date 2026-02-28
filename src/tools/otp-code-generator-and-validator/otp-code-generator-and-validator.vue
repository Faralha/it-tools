<script setup lang="ts">
import { useTimestamp } from '@vueuse/core';
import { useThemeVars } from 'naive-ui';
import { useQRCode } from '../qr-code-generator/useQRCode';
import { base32toHex, buildKeyUri, generateSecret, generateTOTP, getCounterFromTime } from './otp.service';
import TokenDisplay from './token-display.vue';
import { useStyleStore } from '@/stores/style.store';
import CodeSnippet from '@/components/CodeSnippet.vue';
import { computedRefreshable } from '@/composable/computedRefreshable';

const now = useTimestamp();
const interval = computed(() => (now.value / 1000) % 30);
const theme = useThemeVars();
const styleStore = useStyleStore();

const secret = ref(generateSecret());

function refreshSecret() {
  secret.value = generateSecret();
}

const [tokens] = computedRefreshable(
  () => ({
    previous: generateTOTP({ key: secret.value, now: now.value - 30000 }),
    current: generateTOTP({ key: secret.value, now: now.value }),
    next: generateTOTP({ key: secret.value, now: now.value + 30000 }),
  }),
  { throttle: 500 },
);

const keyUri = computed(() => buildKeyUri({ secret: secret.value }));

const { qrcode } = useQRCode({
  text: keyUri,
  color: {
    background: computed(() => (styleStore.isDarkTheme ? '#ffffff' : '#00000000')),
    foreground: '#000000',
  },
  options: { width: 210 },
});

const secretValidationRules = [
  {
    message: 'Secret should be a base32 string',
    validator: (value: string) => value.toUpperCase().match(/^[A-Z234567]+$/),
  },
  {
    message: 'Please set a secret',
    validator: (value: string) => value !== '',
  },
];

const snippetCode = `import { generateTOTP, getCounterFromTime } from './otp.service';

// Generate a TOTP code using a shared secret
const secret = '{{secret}}';
const now = Date.now(); // current timestamp in ms

const token = generateTOTP({ key: secret, now });
console.log('TOTP token:', token); // => {{token}}

// Check the current time step
const counter = getCounterFromTime({ now, timeStep: 30 });
console.log('Counter:', counter); // => {{counter}}`;

const snippetVars = computed(() => ({
  secret: secret.value,
  token: tokens.value?.current ?? '',
  counter: String(getCounterFromTime({ now: now.value, timeStep: 30 })),
}));
</script>

<template>
  <div style="max-width: 350px">
    <c-input-text
      v-model:value="secret"
      label="Secret"
      placeholder="Paste your TOTP secret..."
      mb-5
      :validation-rules="secretValidationRules"
    >
      <template #suffix>
        <c-tooltip tooltip="Generate a new random secret">
          <c-button circle variant="text" size="small" @click="refreshSecret">
            <icon-mdi-refresh />
          </c-button>
        </c-tooltip>
      </template>
    </c-input-text>

    <div>
      <TokenDisplay :tokens="tokens" />

      <n-progress :percentage="(100 * interval) / 30" :color="theme.primaryColor" :show-indicator="false" />
      <div style="text-align: center">
        Next in {{ String(Math.floor(30 - interval)).padStart(2, '0') }}s
      </div>
    </div>
    <div mt-4 flex flex-col items-center justify-center gap-3>
      <n-image :src="qrcode" />
      <c-button :href="keyUri" target="_blank">
        Open Key URI in new tab
      </c-button>
    </div>
  </div>
  <div style="max-width: 350px">
    <CodeSnippet
      label="Secret in hexadecimal"
      :value="base32toHex(secret)"
      mb-5
    />

    <CodeSnippet
      label="Epoch"
      :value="Math.floor(now / 1000).toString()"
      mb-5
    />

    <p>Iteration</p>

    <CodeSnippet
      :value="String(getCounterFromTime({ now, timeStep: 30 }))"
      label="Count:"
    />

    <CodeSnippet
      :value="getCounterFromTime({ now, timeStep: 30 }).toString(16).padStart(16, '0')"
      label="Padded hex:"
    />

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>

<style lang="less" scoped>
.n-progress {
  margin-top: 10px;
  ::v-deep(.n-progress-graph-line-fill) {
    transition-duration: 0.05s !important;
  }
}

.token {
  text-align: center;
  &.token-current {
    font-size: 20px;
  }
}
</style>
