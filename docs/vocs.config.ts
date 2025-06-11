import { defineConfig } from 'vocs'

export default defineConfig({
  banner:{
    dismissable:true,
    backgroundColor:'black',
    textColor:'white',
    height: '30px',
    content: '🚧 Docs are a work in progress. Thanks for your patience as we improve them!',
  },
  title: 'Docs',
  sidebar: [
    {
      text: 'Introduction',
      items: [
        { text: 'Overview', link: '/overview' },
        { text: 'Why It Matters', link: '/why-it-matters' },
        { text: 'Getting Started', link: '/getting-started' },
      ]
    },
    {
      text: 'Guides',
      items: [
        { text: 'Pre Requisites', link: '/prerequisites' },
        { text: 'Bridge Setup', link: '/setup' },
        { text: 'Verification', link: '/verification' },
      ]
    },
    {
      text: 'Architecture',
      items: [
        { text: 'System Overview', link: '/system-overview' },
        { text: 'L1 Components', link: '/l1-components' },
        { text: 'L2 Components', link: '/l2-components' },
      ]
    },
  ],
})

