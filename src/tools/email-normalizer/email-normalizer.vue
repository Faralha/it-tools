<script setup lang="ts">
import { normalizeEmail } from 'email-normalizer';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const emails = ref('');
const normalizedEmails = computed(() => {
  if (!emails.value) {
    return '';
  }

  return emails.value
    .split('\n')
    .map((email) => {
      return withDefaultOnError(() => normalizeEmail({ email }), `Unable to parse email: ${email}`);
    })
    .join('\n');
});

const snippetCode = `import { normalizeEmail } from 'email-normalizer';

const email = "{{input}}";

const normalized = normalizeEmail({ email });

console.log(normalized);
// => "{{output}}"`;

const snippetVars = computed(() => {
  const firstEmail = emails.value.split('\n')[0] || '';
  return {
    input: firstEmail,
    output: withDefaultOnError(() => normalizeEmail({ email: firstEmail }), ''),
  };
});
</script>

<template>
  <div>
    <div class="mb-2">
      Raw emails to normalize:
    </div>
    <c-input-text
      v-model:value="emails" placeholder="Put your emails here (one per line)..." rows="3" multiline
      autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" autofocus monospace
    />

    <div class="mb-2 mt-4">
      Normalized emails:
    </div>
    <CodeSnippet :value="normalizedEmails" copy-message="Normalized emails copied to the clipboard" />
  </div>

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
