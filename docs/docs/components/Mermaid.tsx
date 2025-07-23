// Alternative simple approach - docs/components/Mermaid.tsx

import React, { useEffect, useState } from 'react';

interface MermaidProps {
  chart: string;
  className?: string;
}

export function Mermaid({ chart, className = '' }: MermaidProps) {
  const [svgContent, setSvgContent] = useState<string>('');
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const renderMermaid = async () => {
      try {
        setIsLoading(true);
        setError(null);

        // Load mermaid if needed
        if (typeof window !== 'undefined' && !window.mermaid) {
          await new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js';
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
          });
        }

        if (!isMounted) return;

        if (window.mermaid) {
          window.mermaid.initialize({ 
            startOnLoad: false,
            theme: document.documentElement.classList.contains('dark') ? 'dark' : 'default',
            securityLevel: 'loose'
          });
          
          const id = `mermaid-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
          const { svg } = await window.mermaid.render(id, chart);
          
          if (isMounted) {
            setSvgContent(svg);
            setIsLoading(false);
          }
        }
      } catch (err) {
        console.error('Mermaid error:', err);
        if (isMounted) {
          setError('Failed to render diagram');
          setIsLoading(false);
        }
      }
    };

    renderMermaid();

    return () => {
      isMounted = false;
    };
  }, [chart]);

  if (error) {
    return (
      <div className={`mermaid-error ${className}`} style={{
        padding: '1rem',
        border: '1px solid #ef4444',
        borderRadius: '0.5rem',
        backgroundColor: '#fef2f2',
        color: '#dc2626',
        margin: '1rem 0'
      }}>
        <p>Error: {error}</p>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className={`mermaid-loading ${className}`} style={{
        padding: '2rem',
        textAlign: 'center',
        color: '#6b7280',
        margin: '1rem 0'
      }}>
        Loading diagram...
      </div>
    );
  }

  return (
    <div 
      className={`mermaid-diagram ${className}`}
      style={{
        display: 'flex',
        justifyContent: 'center',
        margin: '1rem 0'
      }}
      dangerouslySetInnerHTML={{ __html: svgContent }}
    />
  );
}

declare global {
  interface Window {
    mermaid: any;
  }
}