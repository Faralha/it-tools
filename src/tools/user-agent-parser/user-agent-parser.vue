<script setup lang="ts">
import { UAParser } from 'ua-parser-js';
import { Adjustments, Browser, Cpu, Devices, Engine } from '@vicons/tabler';
import UserAgentResultCards from './user-agent-result-cards.vue';
import type { UserAgentResultSection } from './user-agent-parser.types';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const ua = ref(navigator.userAgent as string);

function getUserAgentInfo(userAgent: string) {
  return userAgent.trim().length > 0
    ? UAParser(userAgent.trim())
    : ({ ua: '', browser: {}, cpu: {}, device: {}, engine: {}, os: {} } as UAParser.IResult);
}
const userAgentInfo = computed(() => withDefaultOnError(() => getUserAgentInfo(ua.value), undefined));

const sections: UserAgentResultSection[] = [
  {
    heading: 'Browser',
    icon: Browser,
    content: [
      { label: 'Name', getValue: block => block?.browser.name, undefinedFallback: 'No browser name available' },
      { label: 'Version', getValue: block => block?.browser.version, undefinedFallback: 'No browser version available' },
    ],
  },
  {
    heading: 'Engine',
    icon: Engine,
    content: [
      { label: 'Name', getValue: block => block?.engine.name, undefinedFallback: 'No engine name available' },
      { label: 'Version', getValue: block => block?.engine.version, undefinedFallback: 'No engine version available' },
    ],
  },
  {
    heading: 'OS',
    icon: Adjustments,
    content: [
      { label: 'Name', getValue: block => block?.os.name, undefinedFallback: 'No OS name available' },
      { label: 'Version', getValue: block => block?.os.version, undefinedFallback: 'No OS version available' },
    ],
  },
  {
    heading: 'Device',
    icon: Devices,
    content: [
      { label: 'Model', getValue: block => block?.device.model, undefinedFallback: 'No device model available' },
      { label: 'Type', getValue: block => block?.device.type, undefinedFallback: 'No device type available' },
      { label: 'Vendor', getValue: block => block?.device.vendor, undefinedFallback: 'No device vendor available' },
    ],
  },
  {
    heading: 'CPU',
    icon: Cpu,
    content: [
      { label: 'Architecture', getValue: block => block?.cpu.architecture, undefinedFallback: 'No CPU architecture available' },
    ],
  },
];

const snippetCode = `import { UAParser } from 'ua-parser-js';

const ua = '{{input}}';
const result = UAParser(ua);

console.log(result.browser.name);  // {{browser}}
console.log(result.os.name);       // {{os}}
console.log(result.device.type);   // {{device}}`;

const snippetVars = computed(() => ({
  input: ua.value.slice(0, 60),
  browser: userAgentInfo.value?.browser?.name ?? '',
  os: userAgentInfo.value?.os?.name ?? '',
  device: userAgentInfo.value?.device?.type ?? 'desktop',
}));
</script>

<template>
  <div>
    <c-input-text
      v-model:value="ua"
      label="User agent string"
      multiline
      placeholder="Put your user-agent here..."
      clearable
      raw-text
      rows="2"
      autosize
      monospace
      mb-3
    />

    <UserAgentResultCards :user-agent-info="userAgentInfo" :sections="sections" />

    <c-card title="Code snippet" mt-3>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
