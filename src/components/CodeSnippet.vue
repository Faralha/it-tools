<script setup lang="ts">
import { useCopy } from '@/composable/copy';

const props = defineProps<{
  code: string
  variables: Record<string, string>
  language?: string
  title?: string
}>();

type Segment = { type: 'text'; value: string } | { type: 'variable'; name: string; value: string };

const segments = computed<Segment[]>(() => {
  const parts: Segment[] = [];
  const regex = /\{\{(\w+)\}\}/g;
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  // eslint-disable-next-line no-cond-assign
  while ((match = regex.exec(props.code)) !== null) {
    if (match.index > lastIndex) {
      parts.push({ type: 'text', value: props.code.slice(lastIndex, match.index) });
    }
    const varName = match[1];
    parts.push({ type: 'variable', name: varName, value: props.variables[varName] ?? '' });
    lastIndex = regex.lastIndex;
  }

  if (lastIndex < props.code.length) {
    parts.push({ type: 'text', value: props.code.slice(lastIndex) });
  }

  return parts;
});

const renderedCode = computed(() =>
  segments.value.map(s => (s.type === 'text' ? s.value : s.value)).join(''),
);

const { copy, isJustCopied } = useCopy({ source: renderedCode, text: 'Code copied to clipboard' });
</script>

<template>
  <div class="code-snippet">
    <div class="code-snippet-header">
      <span class="code-snippet-lang">{{ language ?? 'javascript' }}</span>
      <span v-if="title" class="code-snippet-title">{{ title }}</span>
      <c-button size="small" variant="text" class="code-snippet-copy-btn" @click="copy()">
        <template #icon>
          <n-icon v-if="!isJustCopied">
            <svg
              xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
            >
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
            </svg>
          </n-icon>
          <n-icon v-else>
            <svg
              xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
            >
              <polyline points="20 6 9 17 4 12" />
            </svg>
          </n-icon>
        </template>
        {{ isJustCopied ? 'Copied!' : 'Copy' }}
      </c-button>
    </div>
    <pre class="code-snippet-body"><code><span
      v-for="(segment, i) in segments" :key="i"
      :class="segment.type === 'variable' ? `code-var code-var--${segment.name}` : 'code-text'"
    >{{ segment.type
      === 'variable' ? segment.value || `<${segment.name}>` : segment.value }}</span></code></pre>
  </div>
</template>

<style lang="less" scoped>
.code-snippet {
  border-radius: 6px;
  overflow: hidden;
  border: 1px solid rgba(128, 128, 128, 0.25);
  font-size: 13px;

  &-header {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 6px 14px;
    background-color: rgba(128, 128, 128, 0.12);
    border-bottom: 1px solid rgba(128, 128, 128, 0.2);
  }

  &-lang {
    font-family: monospace;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    opacity: 0.55;
  }

  &-title {
    font-size: 12px;
    opacity: 0.65;
    flex: 1;
  }

  &-copy-btn {
    margin-left: auto;
    font-size: 12px !important;
    height: 24px !important;
    padding: 0 8px !important;
  }

  &-body {
    margin: 0;
    padding: 14px 16px;
    overflow-x: auto;
    background-color: rgba(0, 0, 0, 0.18);
    line-height: 1.65;

    code {
      font-family: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', Consolas, monospace;
      font-size: 13px;
      white-space: pre;
    }
  }
}

.code-text {
  color: #abb2bf;
}

.code-var {
  font-weight: 600;
  border-radius: 3px;
  padding: 0 2px;
}

.code-var--input {
  color: #e5c07b;
  background-color: rgba(229, 192, 123, 0.1);
}

.code-var--output {
  color: #98c379;
  background-color: rgba(152, 195, 121, 0.1);
}

.code-var--urlSafe {
  color: #61afef;
  background-color: rgba(97, 175, 239, 0.1);
}
</style>
