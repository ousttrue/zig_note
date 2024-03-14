import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  sidebar: [
    'index',
    {
      type: 'category',
      label: 'ことはじめ',
      items: [
        'getstarted/index',
      ],
    },
    {
      type: 'category',
      label: 'zig tools',
      items: [
        'tools/nvim',
        'tools/zls',
        'tools/zls_source',
      ]
    },
    {
      type: 'category',
      label: 'zig version',
      items: [
        'zig_version/zigup',
        'zig_version/breaking_changes',
      ]
    },
    {
      type: 'category',
      label: 'build',
      items: [
        'build/index',
        'build/zon',
        'build/gyro',
        'build/zigmod',
        'build/zpm',
      ]
    },
    {
      type: 'category',
      label: 'use zig',
      link: { type: 'doc', id: 'dev/index' },
      items: [
        'dev/basic',
        'dev/block',
        'dev/loop',
        'dev/pointer',
        'dev/string',
        'dev/import',
        'dev/async',
      ],
    },
    'std/index',
    'ast/index',
    'zig_building',
    'articles/index',
  ],
};

export default sidebars;
