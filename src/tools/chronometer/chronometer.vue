<script setup lang="ts">
import { useRafFn } from '@vueuse/core';

import { formatMs } from './chronometer.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const isRunning = ref(false);
const counter = ref(0);

let previousRafDate = Date.now();
const { pause: pauseRaf, resume: resumeRaf } = useRafFn(
  () => {
    const deltaMs = Date.now() - previousRafDate;
    previousRafDate = Date.now();
    counter.value += deltaMs;
  },
  { immediate: false },
);

function resume() {
  previousRafDate = Date.now();
  resumeRaf();
  isRunning.value = true;
}

function pause() {
  pauseRaf();
  isRunning.value = false;
}

const snippetCode = `// High-precision chronometer using requestAnimationFrame
let counter = 0;
let previousTimestamp = 0;
let rafId;

function tick(timestamp) {
  const delta = timestamp - previousTimestamp;
  counter += delta;
  previousTimestamp = timestamp;
  rafId = requestAnimationFrame(tick);
}

// Start
previousTimestamp = performance.now();
rafId = requestAnimationFrame(tick);

// Elapsed: {{elapsed}} ms

// Stop
cancelAnimationFrame(rafId);`;

const snippetVars = computed(() => ({
  elapsed: String(counter.value),
}));
</script>

<template>
  <div>
    <c-card>
      <div class="duration">
        {{ formatMs(counter) }}
      </div>
    </c-card>
    <div mt-5 flex justify-center gap-3>
      <c-button v-if="!isRunning" type="primary" @click="resume">
        Start
      </c-button>
      <c-button v-else type="warning" @click="pause">
        Stop
      </c-button>

      <c-button @click="counter = 0">
        Reset
      </c-button>
    </div>

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>

<style lang="less" scoped>
.duration {
  text-align: center;
  font-size: 40px;
  font-family: monospace;
  margin: 20px 0;
}
</style>
