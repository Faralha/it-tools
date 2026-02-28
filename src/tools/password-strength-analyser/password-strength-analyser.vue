<script setup lang="ts">
import { getPasswordCrackTimeEstimation } from './password-strength-analyser.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const password = ref('');
const crackTimeEstimation = computed(() => getPasswordCrackTimeEstimation({ password: password.value }));

const details = computed(() => [
  {
    label: 'Password length:',
    value: crackTimeEstimation.value.passwordLength,
  },
  {
    label: 'Entropy:',
    value: Math.round(crackTimeEstimation.value.entropy * 100) / 100,
  },
  {
    label: 'Character set size:',
    value: crackTimeEstimation.value.charsetLength,
  },
  {
    label: 'Score:',
    value: `${Math.round(crackTimeEstimation.value.score * 100)} / 100`,
  },
]);

const snippetCode = `import { getPasswordCrackTimeEstimation } from './password-strength-analyser.service';

const result = getPasswordCrackTimeEstimation({ password: '{{password}}' });

// Entropy:  {{entropy}} bits
// Charset:  {{charsetLength}}
// Score:    {{score}} / 100
// Crack in: {{crackDuration}}`;

const snippetVars = computed(() => ({
  password: password.value.slice(0, 30) || 'P@ssw0rd!',
  entropy: String(Math.round(crackTimeEstimation.value.entropy * 100) / 100),
  charsetLength: String(crackTimeEstimation.value.charsetLength),
  score: String(Math.round(crackTimeEstimation.value.score * 100)),
  crackDuration: crackTimeEstimation.value.crackDurationFormatted,
}));
</script>

<template>
  <div flex flex-col gap-3>
    <c-input-text
      v-model:value="password"
      type="password"
      placeholder="Enter a password..."
      clearable
      autofocus
      raw-text
      test-id="password-input"
    />

    <c-card text-center>
      <div op-60>
        Duration to crack this password with brute force
      </div>
      <div text-2xl data-test-id="crack-duration">
        {{ crackTimeEstimation.crackDurationFormatted }}
      </div>
    </c-card>
    <c-card>
      <div v-for="({ label, value }) of details" :key="label" flex gap-3>
        <div flex-1 text-right op-60>
          {{ label }}
        </div>
        <div flex-1 text-left>
          {{ value }}
        </div>
      </div>
    </c-card>
    <div op-70>
      <span font-bold>Note: </span>
      The computed strength is based on the time it would take to crack the password using a brute force approach, it does not take into account the possibility of a dictionary attack.
    </div>

    <c-card title="Code snippet">
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
