<script setup lang="ts">
import _ from 'lodash';
import { generateRandomMacAddress } from './mac-adress-generator.models';
import { computedRefreshable } from '@/composable/computedRefreshable';
import { useCopy } from '@/composable/copy';
import { usePartialMacAddressValidation } from '@/utils/macAddress';
import CodeSnippet from '@/components/CodeSnippet.vue';

const amount = useStorage('mac-address-generator-amount', 1);
const macAddressPrefix = useStorage('mac-address-generator-prefix', '64:16:7F');

const prefixValidation = usePartialMacAddressValidation(macAddressPrefix);

const casesTransformers = [
  { label: 'Uppercase', value: (value: string) => value.toUpperCase() },
  { label: 'Lowercase', value: (value: string) => value.toLowerCase() },
];
const caseTransformer = ref(casesTransformers[0].value);

const separators = [
  { label: ':', value: ':' },
  { label: '-', value: '-' },
  { label: '.', value: '.' },
  { label: 'None', value: '' },
];
const separator = useStorage('mac-address-generator-separator', separators[0].value);

const [macAddresses, refreshMacAddresses] = computedRefreshable(() => {
  if (!prefixValidation.isValid) {
    return '';
  }

  const ids = _.times(amount.value, () => caseTransformer.value(generateRandomMacAddress({
    prefix: macAddressPrefix.value,
    separator: separator.value,
  })));
  return ids.join('\n');
});

const { copy } = useCopy({ source: macAddresses, text: 'MAC addresses copied to the clipboard' });

const snippetCode = `// Generate a random MAC address
function randomHex() {
  return Math.floor(Math.random() * 256).toString(16).padStart(2, '0').toUpperCase();
}

function generateMacAddress(prefix = '', sep = ':') {
  const parts = prefix ? prefix.split(':') : [];
  while (parts.length < 6) parts.push(randomHex());
  return parts.join(sep);
}

const mac = generateMacAddress('{{prefix}}', ':');
console.log(mac);
// => {{output}}`;

const snippetVars = computed(() => ({
  prefix: macAddressPrefix.value,
  output: macAddresses.value.split('\n')[0] || '',
}));
</script>

<template>
  <div flex flex-col justify-center gap-2>
    <div flex items-center>
      <label w-150px pr-12px text-right> Quantity:</label>
      <n-input-number v-model:value="amount" min="1" max="100" flex-1 />
    </div>

    <c-input-text
      v-model:value="macAddressPrefix"
      label="MAC address prefix:"
      placeholder="Set a prefix, e.g. 64:16:7F"
      clearable
      label-position="left"
      spellcheck="false"
      :validation="prefixValidation"
      raw-text
      label-width="150px"
      label-align="right"
    />

    <c-buttons-select
      v-model:value="caseTransformer"
      :options="casesTransformers"
      label="Case:"
      label-width="150px"
      label-align="right"
    />

    <c-buttons-select
      v-model:value="separator"
      :options="separators"
      label="Separator:"
      label-width="150px"
      label-align="right"
    />

    <c-card mt-5 flex data-test-id="ulids">
      <pre m-0 m-x-auto>{{ macAddresses }}</pre>
    </c-card>

    <div flex justify-center gap-2>
      <c-button data-test-id="refresh" @click="refreshMacAddresses()">
        Refresh
      </c-button>
      <c-button @click="copy()">
        Copy
      </c-button>
    </div>

    <c-card title="Code snippet">
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
