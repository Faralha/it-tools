<script setup lang="ts">
import { convertBase } from '../integer-base-converter/integer-base-converter.model';
import { ipv4ToInt, ipv4ToIpv6, isValidIpv4 } from './ipv4-address-converter.service';
import { useValidation } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const rawIpAddress = useStorage('ipv4-converter:ip', '192.168.1.1');

const convertedSections = computed(() => {
  const ipInDecimal = ipv4ToInt({ ip: rawIpAddress.value });

  return [
    { label: 'Decimal: ', value: String(ipInDecimal) },
    { label: 'Hexadecimal: ', value: convertBase({ fromBase: 10, toBase: 16, value: String(ipInDecimal) }).toUpperCase() },
    { label: 'Binary: ', value: convertBase({ fromBase: 10, toBase: 2, value: String(ipInDecimal) }) },
    { label: 'Ipv6: ', value: ipv4ToIpv6({ ip: rawIpAddress.value }) },
    { label: 'Ipv6 (short): ', value: ipv4ToIpv6({ ip: rawIpAddress.value, prefix: '::ffff:' }) },
  ];
});

const { attrs: validationAttrs } = useValidation({
  source: rawIpAddress,
  rules: [{ message: 'Invalid ipv4 address', validator: ip => isValidIpv4({ ip }) }],
});

const decimalOutput = computed(() => {
  try {
    return String(ipv4ToInt({ ip: rawIpAddress.value }));
  }
  catch { return ''; }
});

const binaryOutput = computed(() => {
  try {
    return convertBase({ fromBase: 10, toBase: 2, value: decimalOutput.value });
  }
  catch { return ''; }
});

const ipv6Output = computed(() => {
  try {
    return ipv4ToIpv6({ ip: rawIpAddress.value });
  }
  catch { return ''; }
});

const snippetCode = `import { ipv4ToInt, ipv4ToIpv6 } from './ipv4-address-converter.service';
import { convertBase } from '../integer-base-converter/integer-base-converter.model';

const ip = '{{input}}';

// Convert to decimal integer
const decimal = ipv4ToInt({ ip });
console.log('Decimal:', decimal); // => {{decimal}}

// Convert to binary
const binary = convertBase({ fromBase: 10, toBase: 2, value: String(decimal) });
console.log('Binary:', binary); // => {{binary}}

// Convert to IPv6
const ipv6 = ipv4ToIpv6({ ip });
console.log('IPv6:', ipv6); // => {{ipv6}}`;

const snippetVars = computed(() => ({
  input: rawIpAddress.value,
  decimal: decimalOutput.value,
  binary: binaryOutput.value.slice(0, 32),
  ipv6: ipv6Output.value,
}));
</script>

<template>
  <div>
    <c-input-text v-model:value="rawIpAddress" label="The ipv4 address:" placeholder="The ipv4 address..." />

    <n-divider />

    <input-copyable
      v-for="{ label, value } of convertedSections"
      :key="label"
      :label="label"
      label-position="left"
      label-width="100px"
      label-align="right"
      mb-2
      :value="validationAttrs.validationStatus === 'error' ? '' : value"
      placeholder="Set a correct ipv4 address"
    />

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
