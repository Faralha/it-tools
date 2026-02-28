<script setup lang="ts">
import { extractIBAN, friendlyFormatIBAN, isQRIBAN, validateIBAN } from 'ibantools';
import { getFriendlyErrors } from './iban-validator-and-parser.service';
import type { CKeyValueListItems } from '@/ui/c-key-value-list/c-key-value-list.types';
import CodeSnippet from '@/components/CodeSnippet.vue';

const rawIban = ref('');

const ibanInfo = computed<CKeyValueListItems>(() => {
  const iban = rawIban.value.toUpperCase().replace(/\s/g, '').replace(/-/g, '');

  if (iban === '') {
    return [];
  }

  const { valid: isIbanValid, errorCodes } = validateIBAN(iban);
  const { countryCode, bban } = extractIBAN(iban);
  const errors = getFriendlyErrors(errorCodes);

  return [
    { label: 'Is IBAN valid ?', value: isIbanValid, showCopyButton: false },
    { label: 'IBAN errors', value: errors.length === 0 ? undefined : errors, hideOnNil: true, showCopyButton: false },
    { label: 'Is IBAN a QR-IBAN ?', value: isQRIBAN(iban), showCopyButton: false },
    { label: 'Country code', value: countryCode },
    { label: 'BBAN', value: bban },
    { label: 'IBAN friendly format', value: friendlyFormatIBAN(iban) },
  ];
});

const ibanExamples = [
  'FR7630006000011234567890189',
  'DE89370400440532013000',
  'GB29NWBK60161331926819',
];

const snippetCode = `import { validateIBAN, extractIBAN, friendlyFormatIBAN } from 'ibantools';

const iban = '{{input}}';

const { valid } = validateIBAN(iban);
const { countryCode, bban } = extractIBAN(iban);
const friendly = friendlyFormatIBAN(iban);

console.log('Valid:', valid);       // {{isValid}}
console.log('Country:', countryCode); // {{country}}
console.log('Friendly:', friendly); // {{friendly}}`;

const snippetVars = computed(() => {
  const iban = rawIban.value.toUpperCase().replace(/\s/g, '').replace(/-/g, '');
  if (!iban) {
    return { input: 'GB29NWBK60161331926819', isValid: 'true', country: 'GB', friendly: 'GB29 NWBK 6016 1331 9268 19' };
  }
  const { valid } = validateIBAN(iban);
  const { countryCode } = extractIBAN(iban);
  return {
    input: iban,
    isValid: String(valid),
    country: countryCode ?? '',
    friendly: friendlyFormatIBAN(iban) ?? iban,
  };
});
</script>

<template>
  <div>
    <c-input-text v-model:value="rawIban" placeholder="Enter an IBAN to check for validity..." test-id="iban-input" />

    <c-card v-if="ibanInfo.length > 0" mt-5>
      <c-key-value-list :items="ibanInfo" data-test-id="iban-info" />
    </c-card>

    <c-card title="Valid IBAN examples" mt-5>
      <div v-for="iban in ibanExamples" :key="iban">
        <c-text-copyable :value="iban" font-mono :displayed-value="friendlyFormatIBAN(iban)" />
      </div>
    </c-card>

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
