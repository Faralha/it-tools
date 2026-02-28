<script setup lang="ts">
import { getCountries, getCountryCallingCode, parsePhoneNumber } from 'libphonenumber-js/max';
import lookup from 'country-code-lookup';
import {
  formatTypeToHumanReadable,
  getDefaultCountryCode,
  getFullCountryName,
} from './phone-parser-and-formatter.models';
import { withDefaultOnError } from '@/utils/defaults';
import { booleanToHumanReadable } from '@/utils/boolean';
import { useValidation } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const rawPhone = ref('');
const defaultCountryCode = ref(getDefaultCountryCode());
const validation = useValidation({
  source: rawPhone,
  rules: [
    {
      validator: value => value === '' || /^[0-9 +\-()]+$/.test(value),
      message: 'Invalid phone number',
    },
  ],
});

const parsedDetails = computed(() => {
  if (!validation.isValid) {
    return undefined;
  }

  const parsed = withDefaultOnError(() => parsePhoneNumber(rawPhone.value, defaultCountryCode.value), undefined);

  if (!parsed) {
    return undefined;
  }

  return [
    { label: 'Country', value: parsed.country },
    { label: 'Country', value: getFullCountryName(parsed.country) },
    { label: 'Country calling code', value: parsed.countryCallingCode },
    { label: 'Is valid?', value: booleanToHumanReadable(parsed.isValid()) },
    { label: 'Is possible?', value: booleanToHumanReadable(parsed.isPossible()) },
    { label: 'Type', value: formatTypeToHumanReadable(parsed.getType()) },
    { label: 'International format', value: parsed.formatInternational() },
    { label: 'National format', value: parsed.formatNational() },
    { label: 'E.164 format', value: parsed.format('E.164') },
    { label: 'RFC3966 format', value: parsed.format('RFC3966') },
  ];
});

const countriesOptions = getCountries().map(code => ({
  label: `${lookup.byIso(code)?.country || code} (+${getCountryCallingCode(code)})`,
  value: code,
}));

const snippetCode = `import { parsePhoneNumber } from 'libphonenumber-js/max';

const phone = '{{input}}';
const parsed = parsePhoneNumber(phone, '{{countryCode}}');

console.log(parsed.formatInternational()); // {{international}}
console.log(parsed.formatNational());      // {{national}}
console.log(parsed.isValid());             // {{isValid}}`;

const snippetVars = computed(() => {
  const parsed = withDefaultOnError(() => parsePhoneNumber(rawPhone.value, defaultCountryCode.value), undefined);
  return {
    input: rawPhone.value,
    countryCode: defaultCountryCode.value,
    international: parsed?.formatInternational() ?? '',
    national: parsed?.formatNational() ?? '',
    isValid: parsed ? String(parsed.isValid()) : 'false',
  };
});
</script>

<template>
  <div>
    <c-select v-model:value="defaultCountryCode" label="Default country code:" :options="countriesOptions" searchable mb-5 />
    <c-input-text
      v-model:value="rawPhone"
      placeholder="Enter a phone number"
      label="Phone number:"
      :validation="validation"
      mb-5
    />

    <n-table v-if="parsedDetails">
      <tbody>
        <tr v-for="{ label, value } in parsedDetails" :key="label">
          <td font-bold>
            {{ label }}
          </td>
          <td>
            <span-copyable v-if="value" :value="value" />
            <span v-else op-70>
              Unknown
            </span>
          </td>
        </tr>
      </tbody>
    </n-table>

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
