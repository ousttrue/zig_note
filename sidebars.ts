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
    'zig_version',
    {
      type: 'category',
      label: 'ことはじめ',
      items: [
        'getstarted/index',
        'getstarted/nvim',
      ],
    },
    'build/index',
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
    'zls/index',
    'zig_building',
    'articles/index',
  ],
};

export default sidebars;
