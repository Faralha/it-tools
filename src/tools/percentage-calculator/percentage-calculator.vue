<script setup lang="ts">
import CodeSnippet from '@/components/CodeSnippet.vue';

const percentageX = ref<number | undefined>();
const percentageY = ref<number | undefined>();
const percentageResult = computed(() => {
  if (percentageX.value === undefined || percentageY.value === undefined) {
    return '';
  }
  return (percentageX.value / 100 * percentageY.value).toString();
});

const numberX = ref<number | undefined>();
const numberY = ref<number | undefined>();
const numberResult = computed(() => {
  if (numberX.value === undefined || numberY.value === undefined) {
    return '';
  }
  const result = 100 * numberX.value / numberY.value;
  return (!Number.isFinite(result) || Number.isNaN(result)) ? '' : result.toString();
});

const numberFrom = ref<number | undefined>();
const numberTo = ref<number | undefined>();
const percentageIncreaseDecrease = computed(() => {
  if (numberFrom.value === undefined || numberTo.value === undefined) {
    return '';
  }
  const result = (numberTo.value - numberFrom.value) / numberFrom.value * 100;
  return (!Number.isFinite(result) || Number.isNaN(result)) ? '' : result.toString();
});

const snippetCode = `// Percentage calculations in JavaScript

// X% of Y
function percentageOf(x, y) {
  return x / 100 * y;
}
console.log('{{x}}% of {{y}} =', percentageOf({{x}}, {{y}})); // => {{result1}}

// X is what percent of Y?
function whatPercent(x, y) {
  return 100 * x / y;
}
console.log('{{numX}} is what % of {{numY}}?', whatPercent({{numX}}, {{numY}})); // => {{result2}}

// Percentage increase/decrease from X to Y
function percentChange(from, to) {
  return (to - from) / from * 100;
}`;

const snippetVars = computed(() => ({
  x: String(percentageX.value ?? 25),
  y: String(percentageY.value ?? 200),
  result1: percentageResult.value || '50',
  numX: String(numberX.value ?? 50),
  numY: String(numberY.value ?? 200),
  result2: numberResult.value || '25',
}));
</script>

<template>
  <div style="flex: 0 0 100%">
    <div style="margin: 0 auto; max-width: 600px">
      <c-card mb-3>
        <div mb-3 sm:hidden>
          What is
        </div>
        <div flex gap-2>
          <div hidden pt-1 sm:block style="min-width: 48px;">
            What is
          </div>
          <n-input-number v-model:value="percentageX" data-test-id="percentageX" placeholder="X" />
          <div min-w-fit pt-1>
            % of
          </div>
          <n-input-number v-model:value="percentageY" data-test-id="percentageY" placeholder="Y" />
          <input-copyable v-model:value="percentageResult" data-test-id="percentageResult" readonly placeholder="Result" style="max-width: 150px;" />
        </div>
      </c-card>

      <c-card mb-3>
        <div mb-3 sm:hidden>
          X is what percent of Y
        </div>
        <div flex gap-2>
          <n-input-number v-model:value="numberX" data-test-id="numberX" placeholder="X" />
          <div hidden min-w-fit pt-1 sm:block>
            is what percent of
          </div>
          <n-input-number v-model:value="numberY" data-test-id="numberY" placeholder="Y" />
          <input-copyable v-model:value="numberResult" data-test-id="numberResult" readonly placeholder="Result" style="max-width: 150px;" />
        </div>
      </c-card>

      <c-card mb-3>
        <div mb-3>
          What is the percentage increase/decrease
        </div>
        <div flex gap-2>
          <n-input-number v-model:value="numberFrom" data-test-id="numberFrom" placeholder="From" />
          <n-input-number v-model:value="numberTo" data-test-id="numberTo" placeholder="To" />
          <input-copyable v-model:value="percentageIncreaseDecrease" data-test-id="percentageIncreaseDecrease" readonly placeholder="Result" style="max-width: 150px;" />
        </div>
      </c-card>

      <c-card title="Code snippet">
        <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
      </c-card>
    </div>
  </div>
</template>
