<script setup lang="ts">
import slugify from '@sindresorhus/slugify';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const input = ref('');
const slug = computed(() => withDefaultOnError(() => slugify(input.value), ''));
</script>

<template>
  <div>
    <c-input-text v-model:value="input" multiline placeholder="Put your string here (ex: My file path)" label="Your string to slugify" autofocus raw-text mb-5 />

    <CodeSnippet :value="slug" label="Your slug" copy-message="Slug copied to clipboard" />
  </div>
</template>
