<script setup lang="ts">
// Duplicate issue with sub directory

import { addMilliseconds, formatRelative } from 'date-fns';

import { enGB } from 'date-fns/locale';

import { formatMsDuration } from './eta-calculator.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const unitCount = ref(3 * 62);
const unitPerTimeSpan = ref(3);
const timeSpan = ref(5);
const timeSpanUnitMultiplier = ref(60000);
const startedAt = ref(Date.now());

const durationMs = computed(() => {
  const timeSpanMs = timeSpan.value * timeSpanUnitMultiplier.value;

  return unitCount.value / (unitPerTimeSpan.value / timeSpanMs);
});
const endAt = computed(() =>
  formatRelative(addMilliseconds(startedAt.value, durationMs.value), Date.now(), { locale: enGB }),
);

const snippetCode = `import { addMilliseconds, formatRelative } from 'date-fns';

// Calculate ETA for a task
const totalUnits = {{unitCount}};
const unitsPerMs = {{unitPerTimeSpan}} / ({{timeSpan}} * {{multiplier}});
const durationMs = totalUnits / unitsPerMs;

const startedAt = new Date({{startedAt}});
const endAt = addMilliseconds(startedAt, durationMs);

console.log('Duration:', durationMs, 'ms'); // => {{durationMs}} ms
console.log('ETA:', endAt.toISOString());`;

const snippetVars = computed(() => ({
  unitCount: String(unitCount.value),
  unitPerTimeSpan: String(unitPerTimeSpan.value),
  timeSpan: String(timeSpan.value),
  multiplier: String(timeSpanUnitMultiplier.value),
  startedAt: String(startedAt.value),
  durationMs: String(Math.round(durationMs.value)),
}));
</script>

<template>
  <div>
    <div text-justify op-70>
      With a concrete example, if you wash 5 plates in 3 minutes and you have 500 plates to wash, it will take you 5
      hours to wash them all.
    </div>
    <n-divider />
    <div flex gap-2>
      <n-form-item label="Amount of element to consume" flex-1>
        <n-input-number v-model:value="unitCount" :min="1" />
      </n-form-item>
      <n-form-item label="The consumption started at" flex-1>
        <n-date-picker v-model:value="startedAt" type="datetime" />
      </n-form-item>
    </div>

    <p>Amount of unit consumed by time span</p>
    <div flex flex-col items-baseline gap-y-2 md:flex-row>
      <n-input-number v-model:value="unitPerTimeSpan" :min="1" />
      <div flex items-baseline gap-2>
        <span ml-2>in</span>
        <n-input-number v-model:value="timeSpan" min-w-130px :min="1" />
        <c-select
          v-model:value="timeSpanUnitMultiplier"
          min-w-130px
          :options="[
            { label: 'milliseconds', value: 1 },
            { label: 'seconds', value: 1000 },
            { label: 'minutes', value: 1000 * 60 },
            { label: 'hours', value: 1000 * 60 * 60 },
            { label: 'days', value: 1000 * 60 * 60 * 24 },
          ]"
        />
      </div>
    </div>

    <n-divider />
    <c-card mb-2>
      <n-statistic label="Total duration">
        {{ formatMsDuration(durationMs) }}
      </n-statistic>
    </c-card>
    <c-card>
      <n-statistic label="It will end ">
        {{ endAt }}
      </n-statistic>
    </c-card>

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>

<style lang="less" scoped>
.n-input-number,
.n-date-picker {
  width: 100%;
}
</style>
