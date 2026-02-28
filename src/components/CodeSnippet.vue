<script setup lang="ts">
import { Copy } from '@vicons/tabler';
import { useElementSize } from '@vueuse/core';
import hljs from 'highlight.js/lib/core';
import jsonHljs from 'highlight.js/lib/languages/json';
import sqlHljs from 'highlight.js/lib/languages/sql';
import xmlHljs from 'highlight.js/lib/languages/xml';
import yamlHljs from 'highlight.js/lib/languages/yaml';
import iniHljs from 'highlight.js/lib/languages/ini';
import markdownHljs from 'highlight.js/lib/languages/markdown';
import { useCopy } from '@/composable/copy';

const props = withDefaults(
  defineProps<{
    /** New API: template string with {{varName}} placeholders */
    code?: string
    /** New API: map of variable names to values */
    variables?: Record<string, string>
    /** New API: title displayed in the header */
    title?: string
    /** Legacy API: plain code string to display */
    value?: string
    /** Legacy API: label rendered above the card */
    label?: string
    /** Legacy API: element whose height the code block should follow */
    followHeightOf?: HTMLElement | null
    /** Legacy API: placement of the floating copy button */
    copyPlacement?: 'top-right' | 'bottom-right' | 'outside' | 'none'
    /** Copy button tooltip / label */
    copyMessage?: string
    language?: string
  }>(),
  {
    code: undefined,
    variables: () => ({}),
    title: undefined,
    value: undefined,
    label: undefined,
    followHeightOf: null,
    copyPlacement: 'top-right',
    copyMessage: 'Copy to clipboard',
    language: 'txt',
  },
);

hljs.registerLanguage('sql', sqlHljs);
hljs.registerLanguage('json', jsonHljs);
hljs.registerLanguage('html', xmlHljs);
hljs.registerLanguage('xml', xmlHljs);
hljs.registerLanguage('yaml', yamlHljs);
hljs.registerLanguage('toml', iniHljs);
hljs.registerLanguage('markdown', markdownHljs);

const { followHeightOf } = toRefs(props);
const { height } = followHeightOf.value ? useElementSize(followHeightOf) : { height: ref(null) };

// Determine which API is in use
const useNewApi = computed(() => props.code !== undefined);

// --- New API: variable-interpolation segments ---
type Segment = { type: 'text'; value: string } | { type: 'variable'; name: string; value: string };

const segments = computed<Segment[]>(() => {
  const source = props.code ?? '';
  const vars = props.variables ?? {};
  const parts: Segment[] = [];
  const regex = /\{\{(\w+)\}\}/g;
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  // eslint-disable-next-line no-cond-assign
  while ((match = regex.exec(source)) !== null) {
    if (match.index > lastIndex) {
      parts.push({ type: 'text', value: source.slice(lastIndex, match.index) });
    }
    const varName = match[1];
    parts.push({ type: 'variable', name: varName, value: vars[varName] ?? '' });
    lastIndex = regex.lastIndex;
  }

  if (lastIndex < source.length) {
    parts.push({ type: 'text', value: source.slice(lastIndex) });
  }

  return parts;
});

const renderedCode = computed(() =>
  segments.value.map(s => s.value).join(''),
);

// New API copies rendered code; legacy API copies the raw value.
const legacyValue = computed(() => props.value ?? '');
const copySource = computed(() => useNewApi.value ? renderedCode.value : legacyValue.value);

const { copy, isJustCopied } = useCopy({ source: copySource, createToast: false });
const tooltipText = computed(() => isJustCopied.value ? 'Copied!' : props.copyMessage);
</script>

<template>
  <!-- New API: header + variable-interpolation display -->
  <div v-if="useNewApi" class="code-snippet">
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
    >{{ segment.type === 'variable' ? segment.value || `<${segment.name}>` : segment.value }}</span></code></pre>
  </div>

  <!-- Legacy API: n-code with syntax highlighting -->
  <div v-else style="overflow-x: hidden; width: 100%">
    <div v-if="label" mb-1 text-sm op-60>
      {{ label }}
    </div>
    <c-card relative>
      <n-scrollbar
        x-scrollable
        trigger="none"
        :style="height ? `min-height: ${height - 40 /* card padding */ + 10 /* negative margin compensation */}px` : ''"
      >
        <n-config-provider :hljs="hljs">
          <n-code :code="legacyValue" :language="language" :trim="false" data-test-id="area-content" />
        </n-config-provider>
      </n-scrollbar>
      <div v-if="copyPlacement !== 'none'" absolute right-10px top-10px>
        <c-tooltip v-if="legacyValue" :tooltip="tooltipText" position="left">
          <c-button circle important:h-10 important:w-10 @click="copy()">
            <n-icon size="22" :component="Copy" />
          </c-button>
        </c-tooltip>
      </div>
    </c-card>
    <div v-if="copyPlacement === 'outside'" mt-4 flex justify-center>
      <c-button @click="copy()">
        {{ tooltipText }}
      </c-button>
    </div>
  </div>
</template>

<style lang="less" scoped>
/* Legacy scrollbar compensation */
::v-deep(.n-scrollbar) {
  padding-bottom: 10px;
  margin-bottom: -10px;
}

/* New API styles */
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
