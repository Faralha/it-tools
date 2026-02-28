<script setup lang="ts">
import { decodeJwt } from './jwt-parser.service';
import { useValidation } from '@/composable/validation';
import { isNotThrowing } from '@/utils/boolean';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const rawJwt = ref(
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
);

const decodedJWT = computed(() =>
  withDefaultOnError(() => decodeJwt({ jwt: rawJwt.value }), { header: [], payload: [] }),
);

const sections = [
  { key: 'header', title: 'Header' },
  { key: 'payload', title: 'Payload' },
] as const;

const validation = useValidation({
  source: rawJwt,
  rules: [
    {
      validator: value => value.length > 0 && isNotThrowing(() => decodeJwt({ jwt: rawJwt.value })),
      message: 'Invalid JWT',
    },
  ],
});

const snippetCode = `// Decode a JWT token (without verification)
function decodeJWT(token) {
  const [header, payload] = token.split('.').slice(0, 2)
    .map(part => JSON.parse(atob(part.replace(/-/g, '+').replace(/_/g, '/'))));
  return { header, payload };
}

const jwt = '{{input}}';
const { header, payload } = decodeJWT(jwt);

console.log('header:', JSON.stringify(header));
// => {{headerOutput}}
console.log('payload:', JSON.stringify(payload));
// => {{payloadOutput}}`;

const snippetVars = computed(() => {
  const decoded = decodedJWT.value;
  const headerObj = Object.fromEntries((decoded.header || []).map((c: any) => [c.claim, c.value]));
  const payloadObj = Object.fromEntries((decoded.payload || []).map((c: any) => [c.claim, c.value]));
  return {
    input: `${rawJwt.value.slice(0, 40)}...`,
    headerOutput: JSON.stringify(headerObj).slice(0, 60),
    payloadOutput: JSON.stringify(payloadObj).slice(0, 60),
  };
});
</script>

<template>
  <c-card>
    <c-input-text v-model:value="rawJwt" label="JWT to decode" :validation="validation" placeholder="Put your token here..." rows="5" multiline raw-text autofocus mb-3 />

    <n-table v-if="validation.isValid">
      <tbody>
        <template v-for="section of sections" :key="section.key">
          <th colspan="2" class="table-header">
            {{ section.title }}
          </th>
          <tr v-for="{ claim, claimDescription, friendlyValue, value } in decodedJWT[section.key]" :key="claim + value">
            <td class="claims" style="vertical-align: top;">
              <span font-bold>
                {{ claim }}
              </span>
              <span v-if="claimDescription" ml-2 op-70>
                ({{ claimDescription }})
              </span>
            </td>
            <td style="word-wrap: break-word;word-break: break-all;">
              <span>{{ value }}</span>
              <span v-if="friendlyValue" ml-2 op-70>
                ({{ friendlyValue }})
              </span>
            </td>
          </tr>
        </template>
      </tbody>
    </n-table>
  </c-card>

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>

<style lang="less" scoped>
.table-header {
  text-align: center;
}
</style>
