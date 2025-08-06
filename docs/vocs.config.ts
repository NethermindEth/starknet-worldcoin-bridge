import { defineConfig } from 'vocs'

export default defineConfig({
  banner:{
    dismissable:true,
    backgroundColor:'black',
    textColor:'white',
    height: '30px',
    content: '🚧 Docs are a work in progress. Thanks for your patience as we improve them!',
  },
  title: 'Starknet Worldcoin ID Bridge ',
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
        { text: 'Prerequisites', link: '/prerequisites' },
        {
          text: 'Verification',
          collapsed: true,
          items: [
            // { text: 'Overview', link: '/verification/' },
            { text: 'Strategy', link: '/verification/strategy' },
            { text: 'Integration Testing', link: '/verification/integration-testing' },
            { text: 'Nullifier Tracking', link: '/verification/nullifier-tracking' },
            { text: 'Error Handling', link: '/verification/error-handling' },
          ]
        }, 
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