import React, { useEffect, useState } from 'react';
import { ArrowRight, Github, Shield, Copy, Lock, Zap, Users, Cpu } from 'lucide-react';

export function WorldIDHero() {
  const [windowWidth, setWindowWidth] = useState(1200); // Default desktop width
  const [isDarkMode, setIsDarkMode] = useState(false);

  useEffect(() => {
    // Update width on mount and window resize
    const updateWidth = () => setWindowWidth(window.innerWidth);
    updateWidth();
    window.addEventListener('resize', updateWidth);
    return () => window.removeEventListener('resize', updateWidth);
  }, []);

  // Theme detection
  useEffect(() => {
    // Check for theme preference
    const checkTheme = () => {
      const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches ||
                     document.documentElement.classList.contains('dark');
      setIsDarkMode(isDark);
    };
    
    checkTheme();
    
    // Listen for theme changes
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQuery.addEventListener('change', checkTheme);
    
    // Also listen for manual theme toggles
    const observer = new MutationObserver(checkTheme);
    observer.observe(document.documentElement, { 
      attributes: true, 
      attributeFilter: ['class'] 
    });
    
    return () => {
      mediaQuery.removeEventListener('change', checkTheme);
      observer.disconnect();
    };
  }, []);

  // Force full screen and remove scroll
  useEffect(() => {
    // Hide body scroll
    document.body.style.overflow = 'hidden';
    document.body.style.height = '100vh';
    document.documentElement.style.overflow = 'hidden';
    document.documentElement.style.height = '100vh';
    
    // Find and modify parent containers
    const containers = [
      document.querySelector('[data-layout="landing"]'),
      document.querySelector('main'),
      document.querySelector('article'),
      document.querySelector('.vocs_Content'),
      document.querySelector('.vocs_ContentWrapper'),
    ];
    
    containers.forEach(container => {
      if (container) {
        (container as HTMLElement).style.height = '100vh';
        (container as HTMLElement).style.overflow = 'hidden';
        (container as HTMLElement).style.padding = '0';
        (container as HTMLElement).style.margin = '0';
      }
    });

    return () => {
      // Cleanup
      document.body.style.overflow = '';
      document.body.style.height = '';
      document.documentElement.style.overflow = '';
      document.documentElement.style.height = '';
    };
  }, []);

  return (
    <div 
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        height: '100vh',
        backgroundColor: '#03022b',
        zIndex: 9999,
        overflow: 'hidden'
      }}
    >
      {/* Background Animation */}
      <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 1 }}>
        {/* Floating particles with movement */}
        <div style={{ 
          position: 'absolute', 
          top: '20%', 
          left: '10%', 
          width: '8px', 
          height: '8px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 73, 1, 0.7)', 
          animation: 'float1 8s ease-in-out infinite' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          top: '40%', 
          right: '15%', 
          width: '6px', 
          height: '6px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 73, 1, 0.8)', 
          animation: 'float2 6s ease-in-out infinite 1s' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          bottom: '30%', 
          left: '25%', 
          width: '10px', 
          height: '10px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 73, 1, 0.6)', 
          animation: 'float3 10s ease-in-out infinite 2s' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          top: '60%', 
          right: '25%', 
          width: '6px', 
          height: '6px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 73, 1, 0.7)', 
          animation: 'float4 7s ease-in-out infinite 3s' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          top: '15%', 
          left: '60%', 
          width: '8px', 
          height: '8px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 107, 53, 0.6)', 
          animation: 'float5 9s ease-in-out infinite 0.5s' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          bottom: '15%', 
          right: '40%', 
          width: '7px', 
          height: '7px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 73, 1, 0.8)', 
          animation: 'float6 8.5s ease-in-out infinite 1.5s' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          top: '35%', 
          left: '35%', 
          width: '5px', 
          height: '5px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 107, 53, 0.7)', 
          animation: 'float7 11s ease-in-out infinite 2.5s' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          bottom: '45%', 
          right: '10%', 
          width: '9px', 
          height: '9px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 73, 1, 0.6)', 
          animation: 'float8 7.5s ease-in-out infinite 3.5s' 
        }}></div>

        {/* Add more floating particles */}
        <div style={{ 
          position: 'absolute', 
          top: '80%', 
          left: '75%', 
          width: '7px', 
          height: '7px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 73, 1, 0.65)', 
          animation: 'float9 9s ease-in-out infinite 1s' 
        }}></div>
        <div style={{ 
          position: 'absolute', 
          top: '25%', 
          left: '85%', 
          width: '5px', 
          height: '5px', 
          borderRadius: '50%', 
          backgroundColor: 'rgba(255, 107, 53, 0.55)', 
          animation: 'float10 7s ease-in-out infinite 0.5s' 
        }}></div>

        {/* Animated connecting lines */}
        <svg style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.4 }}>
          <line x1="10%" y1="20%" x2="25%" y2="30%" stroke="#ff4901" strokeWidth="1.5">
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="4s" repeatCount="indefinite" />
            <animateTransform attributeName="transform" type="translate" values="0,0; 5,-3; 0,0" dur="8s" repeatCount="indefinite" />
          </line>
          <line x1="75%" y1="30%" x2="90%" y2="50%" stroke="#ff6b35" strokeWidth="1.5">
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="3s" repeatCount="indefinite" begin="1s" />
            <animateTransform attributeName="transform" type="translate" values="0,0; -3,5; 0,0" dur="6s" repeatCount="indefinite" begin="1s" />
          </line>
          <line x1="20%" y1="70%" x2="40%" y2="85%" stroke="#ff4901" strokeWidth="1.5">
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="3.5s" repeatCount="indefinite" begin="2s" />
            <animateTransform attributeName="transform" type="translate" values="0,0; 4,2; 0,0" dur="7s" repeatCount="indefinite" begin="2s" />
          </line>
          <line x1="60%" y1="15%" x2="75%" y2="35%" stroke="#ff6b35" strokeWidth="1.5">
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="4.5s" repeatCount="indefinite" begin="0.5s" />
            <animateTransform attributeName="transform" type="translate" values="0,0; -2,-4; 0,0" dur="9s" repeatCount="indefinite" begin="0.5s" />
          </line>
          <line x1="35%" y1="35%" x2="45%" y2="60%" stroke="#ff4901" strokeWidth="1">
            <animate attributeName="opacity" values="0.1;0.6;0.1" dur="5s" repeatCount="indefinite" begin="3s" />
            <animateTransform attributeName="transform" type="translate" values="0,0; 3,-2; 0,0" dur="10s" repeatCount="indefinite" begin="3s" />
          </line>
          <line x1="80%" y1="25%" x2="65%" y2="45%" stroke="#ff6b35" strokeWidth="1">
            <animate attributeName="opacity" values="0.1;0.5;0.1" dur="6s" repeatCount="indefinite" begin="1.5s" />
            <animateTransform attributeName="transform" type="translate" values="0,0; -4,3; 0,0" dur="12s" repeatCount="indefinite" begin="1.5s" />
          </line>
          <line x1="15%" y1="85%" x2="35%" y2="70%" stroke="#ff4901" strokeWidth="1">
            <animate attributeName="opacity" values="0.2;0.6;0.2" dur="5.5s" repeatCount="indefinite" begin="0.7s" />
            <animateTransform attributeName="transform" type="translate" values="0,0; 5,-4; 0,0" dur="11s" repeatCount="indefinite" begin="0.7s" />
          </line>
        </svg>
        
        {/* CSS Keyframes for floating animation */}
        <style>{`
          @keyframes float1 { 0%, 100% { transform: translate(0, 0) scale(1); } 25% { transform: translate(10px, -15px) scale(1.1); } 50% { transform: translate(-8px, -25px) scale(0.9); } 75% { transform: translate(12px, -10px) scale(1.05); } }
          @keyframes float2 { 0%, 100% { transform: translate(0, 0) rotate(0deg); } 33% { transform: translate(-15px, 20px) rotate(120deg); } 66% { transform: translate(20px, 10px) rotate(240deg); } }
          @keyframes float3 { 0%, 100% { transform: translate(0, 0) scale(1); } 20% { transform: translate(8px, -12px) scale(1.2); } 40% { transform: translate(-12px, -8px) scale(0.8); } 60% { transform: translate(15px, 5px) scale(1.1); } 80% { transform: translate(-5px, 15px) scale(0.9); } }
          @keyframes float4 { 0%, 100% { transform: translate(0, 0); } 50% { transform: translate(-20px, 15px); } }
          @keyframes float5 { 0%, 100% { transform: translate(0, 0) scale(1); } 25% { transform: translate(-10px, 20px) scale(1.15); } 75% { transform: translate(15px, -18px) scale(0.85); } }
          @keyframes float6 { 0%, 100% { transform: translate(0, 0) rotate(0deg); } 50% { transform: translate(18px, -25px) rotate(180deg); } }
          @keyframes float7 { 0%, 100% { transform: translate(0, 0); } 30% { transform: translate(12px, -8px); } 70% { transform: translate(-8px, 12px); } }
          @keyframes float8 { 0%, 100% { transform: translate(0, 0) scale(1); } 40% { transform: translate(-15px, -20px) scale(1.3); } 80% { transform: translate(10px, 25px) scale(0.7); } }
          @keyframes float9 { 0%, 100% { transform: translate(0, 0) rotate(0deg) scale(1); } 50% { transform: translate(-12px, 15px) rotate(180deg) scale(0.9); } }
          @keyframes float10 { 0%, 100% { transform: translate(0, 0) scale(1); } 33% { transform: translate(10px, -10px) scale(1.1); } 66% { transform: translate(-8px, -12px) scale(0.95); } }
          @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(0.8); }
          }
        `}</style>
      </div>

      {/* Navigation Bar */}
      <nav style={{
        position: 'relative',
        zIndex: 20,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: windowWidth < 640 ? '0.5rem 1rem' : '0.75rem 2rem',
        backgroundColor: 'rgba(255, 255, 255, 0.9)',
        backdropFilter: 'blur(12px)',
        borderBottom: '1px solid rgba(255, 255, 255, 0.2)'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <img
            src={isDarkMode ? "/LogoLightContext.svg" : "/LogoDarkContext.svg"}
            alt="Logo"
            style={{
              width: '32px',
              height: '32px',
              objectFit: 'contain'
            }}
          />
          <span style={{ 
            fontSize: '15px', 
            fontWeight: '500', 
            color: '#374151',
            display: windowWidth < 480 ? 'none' : 'block' // Hide text on very small screens
          }}>
            Starknet World ID Bridge
          </span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '2rem' }}>
          <a 
            href="/overview" 
            style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '0.5rem', 
              color: 'white',
              backgroundColor: '#03022b',
              textDecoration: 'none', 
              fontSize: '14px', 
              fontWeight: '500',
              padding: '0.5rem 1rem',
              borderRadius: '8px',
              border: '1px solid rgba(255, 255, 255, 0.2)'
            }}
          >
            <span>Docs</span>
          </a>
          <a 
            href="https://x.com/nethermindstark?lang=en" 
            target="_blank"
            rel="noopener noreferrer"
            style={{ color: '#6b7280', textDecoration: 'none', fontSize: '18px', fontWeight: '500' }}
          >
            𝕏
          </a>
          <a 
            href="https://github.com/NethermindEth/starknet-worldcoin-bridge"
            target="_blank"
            rel="noopener noreferrer" 
            style={{ color: '#6b7280', textDecoration: 'none' }}
          >
            <Github style={{ width: '24px', height: '24px' }} />
          </a>
        </div>
      </nav>

      {/* Main Content */}
      <div style={{
        position: 'relative',
        zIndex: 10,
        height: 'calc(100vh - 64px)',
        display: 'flex',
        alignItems: 'flex-start', // Change from center to flex-start
        justifyContent: 'center',
        padding: windowWidth < 640 ? '1rem' : '2rem',
        paddingTop: windowWidth < 640 ? '2rem' : '4rem'
      }}>
        <div style={{
          textAlign: 'center',
          maxWidth: windowWidth < 640 ? '100%' : '1200px',
          width: '100%',
          height: '100%',
          position: 'relative', 
          display: 'flex', 
          flexDirection: 'column', 
          justifyContent: 'space-between' 
        }}>
          <div> {/* Wrap main content in a div */}
            {/* Centered Logo */}
            <div style={{ 
              marginBottom: '2rem', 
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center'
            }}>
              <img
                src={isDarkMode ? "/LogoDarkContext.svg" : "/LogoLightContext.svg"}
                alt="Starknet World ID Bridge Logo"
                style={{
                  width: '120px',
                  height: '120px',
                  objectFit: 'contain'
                }}
              />
            </div>

            {/* Status Badge */}
            <div style={{ marginBottom: '1.5rem' }}> {/* Reduced from 2rem */}
              <a
                href="https://github.com/NethermindEth/starknet-worldcoin-bridge/releases"
                target="_blank"
                rel="noopener noreferrer"
                style={{ textDecoration: 'none' }}
              >
                <div style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '0.75rem',
                  borderRadius: '9999px',
                  backgroundColor: 'rgba(255, 255, 255, 0.08)',
                  backdropFilter: 'blur(10px)',
                  padding: '0.125rem 0.75rem 0.125rem 0.125rem',
                  fontSize: '14px',
                  fontWeight: '500',
                  color: 'rgba(255, 255, 255, 0.9)',
                  border: '1px solid rgba(255, 255, 255, 0.15)',
                  boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1), inset 0 1px 0 rgba(255, 255, 255, 0.1)',
                  transition: 'all 0.3s ease',
                  cursor: 'pointer',
                  userSelect: 'none'
                }}
                onMouseEnter={(e) => {
                  (e.target as HTMLElement).style.backgroundColor = 'rgba(255, 255, 255, 0.12)';
                  (e.target as HTMLElement).style.transform = 'translateY(-1px)';
                  (e.target as HTMLElement).style.boxShadow = '0 12px 40px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.15)';
                }}
                onMouseLeave={(e) => {
                  (e.target as HTMLElement).style.backgroundColor = 'rgba(255, 255, 255, 0.08)';
                  (e.target as HTMLElement).style.transform = 'translateY(0px)';
                  (e.target as HTMLElement).style.boxShadow = '0 8px 32px rgba(0, 0, 0, 0.1), inset 0 1px 0 rgba(255, 255, 255, 0.1)';
                }}
              >
                <span style={{
                  borderRadius: '9999px',
                  background: 'linear-gradient(135deg, #f97316, #ea580c)',
                  padding: '0.25rem 0.625rem',
                  fontSize: '12px',
                  color: 'white',
                  fontWeight: '600',
                  textShadow: '0 1px 2px rgba(0, 0, 0, 0.1)'
                }}>
                  Early Access
                </span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', userSelect: 'none', WebkitUserSelect: 'none', MozUserSelect: 'none', msUserSelect: 'none' }}>
                  {/* Green blinking dot */}
                  <div style={{
                    width: '8px',
                    height: '8px',
                    borderRadius: '50%',
                    backgroundColor: '#10b981',
                    animation: 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                    boxShadow: '0 0 8px rgba(16, 185, 129, 0.6)'
                  }}></div>
                  <span style={{ userSelect: 'none' }}>Live on Sepolia Testnet</span>
                  <ArrowRight style={{ width: '16px', height: '16px', color: 'rgba(255, 255, 255, 0.7)' }} />
                </span>
              </div>
              </a>
            </div>

            {/* Main Heading */}
            <h1 style={{
              fontSize: 'clamp(1.8rem, 5vw, 4rem)', // Reduced from 2rem and 4.5rem
              lineHeight: '0.9',
              fontWeight: '800',
              color: 'white',
              marginBottom: '0.8rem', // Reduced from 1rem
              letterSpacing: '-0.025em'
            }}>
              <div>Connecting</div>
              <div style={{ marginTop: '0.5rem' }}>
                <span style={{
                  background: 'linear-gradient(135deg, #ff4901 0%, #ff6b35 100%)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  backgroundClip: 'text'
                }}>
                  World ID
                </span>
                <span style={{ margin: '0 0.5rem' }}>to</span>
                <span style={{
                  background: 'linear-gradient(135deg, #ff4901 0%, #ff6b35 100%)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  backgroundClip: 'text'
                }}>
                  Starknet
                </span>
              </div>
            </h1>

            {/* Subtitle */}
            <p style={{
              fontSize: 'clamp(0.8rem, 1.5vw, 1rem)', // Reduced from 0.9rem and 1.1rem
              lineHeight: '1.4',
              color: 'rgba(255, 255, 255, 0.8)',
              marginBottom: '1.5rem', // Reduced from 1.8rem
              maxWidth: '600px',
              margin: '0 auto 1.5rem auto'
            }}>
              Enable human verification in your Starknet DApps while preserving user privacy through zero-knowledge proofs.
            </p>

            {/* Feature Pills */}
            <div style={{
              display: 'flex',
              flexWrap: 'wrap',
              justifyContent: 'center',
              gap: windowWidth < 480 ? '0.5rem' : '0.75rem',
              padding: windowWidth < 480 ? '0 0.5rem' : 0,
              marginBottom: '1.2rem', // Reduced from 1.5rem
            }}>
              {[
                { icon: Lock, text: 'Privacy-First' },
                { icon: Zap, text: 'Zero-Knowledge' },
                { icon: Users, text: 'Sybil-Resistant' },
                { icon: Cpu, text: 'Cairo Integration' }
              ].map(({ icon: Icon, text }) => (
                <div 
                  key={text} 
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.4rem',
                    backgroundColor: 'rgba(255, 255, 255, 0.05)',
                    backdropFilter: 'blur(4px)',
                    border: '1px solid rgba(255, 255, 255, 0.2)',
                    borderRadius: '9999px',
                    padding: '0.5rem 1rem',
                    transition: 'all 0.3s ease',
                    cursor: 'pointer',
                    userSelect: 'none',
                    WebkitUserSelect: 'none',
                    MozUserSelect: 'none',
                    msUserSelect: 'none'
                  }}
                  onMouseEnter={(e) => {
                    const target = e.currentTarget as HTMLElement;
                    target.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
                    target.style.transform = 'translateY(-2px)';
                    target.style.boxShadow = '0 8px 25px rgba(0, 0, 0, 0.15)';
                  }}
                  onMouseLeave={(e) => {
                    const target = e.currentTarget as HTMLElement;
                    target.style.backgroundColor = 'rgba(255, 255, 255, 0.05)';
                    target.style.transform = 'translateY(0px)';
                    target.style.boxShadow = 'none';
                  }}
                >
                  <Icon style={{ width: '16px', height: '16px', color: '#fb923c' }} />
                  <span style={{ color: 'rgba(255, 255, 255, 0.9)', fontSize: '13px', fontWeight: '500' }}>{text}</span>
                </div>
              ))}
            </div>

            {/* Code Snippet */}
            <div style={{
              maxWidth: windowWidth < 768 ? '95%' : '500px', // Reduced from 800px
              margin: '0 auto 1.5rem auto', // Reduced from 2rem
              fontSize: windowWidth < 480 ? '10px' : '11px'
            }}>
              <div style={{
                backgroundColor: 'rgba(0, 0, 0, 0.4)',
                backdropFilter: 'blur(8px)',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                borderRadius: '12px',
                padding: '1.2rem',
                fontFamily: 'ui-monospace, SFMono-Regular, "SF Mono", Monaco, Inconsolata, "Roboto Mono", monospace',
                position: 'relative',
                boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)',
                textAlign: 'left',
                fontSize: '11px' // Reduced from 12px to help fit content
              }}>
                {/* Code header */}
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  marginBottom: '0.8rem',
                  paddingBottom: '0.6rem',
                  borderBottom: '1px solid rgba(255, 255, 255, 0.1)'
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
                    <div style={{ width: '10px', height: '10px', borderRadius: '50%', backgroundColor: '#ef4444' }}></div>
                    <div style={{ width: '10px', height: '10px', borderRadius: '50%', backgroundColor: '#f59e0b' }}></div>
                    <div style={{ width: '10px', height: '10px', borderRadius: '50%', backgroundColor: '#10b981' }}></div>
                  </div>
                  <span style={{ fontSize: '11px', color: 'rgba(255, 255, 255, 0.5)' }}>IStarkWorldID.cairo</span>
                  <button
                    onClick={() => navigator.clipboard.writeText(`use starknet::EthAddress;

#[starknet::interface]
pub trait IStarkWorldID<TContractState> {
    fn receive_root(ref self: TContractState, from_address: felt252, new_root: u256);
    fn set_root_history_expiry(ref self: TContractState, from_address: felt252, expiry_time: felt252);
    fn transfer_ownership(ref self: TContractState, from_address: felt252, new_owner: EthAddress);
}`)}
                    style={{
                      padding: '0.4rem',
                      backgroundColor: 'transparent',
                      border: 'none',
                      borderRadius: '6px',
                      cursor: 'pointer',
                      transition: 'all 0.2s'
                    }}
                    onMouseEnter={(e) => (e.target as HTMLElement).style.backgroundColor = 'rgba(255, 255, 255, 0.1)'}
                    onMouseLeave={(e) => (e.target as HTMLElement).style.backgroundColor = 'transparent'}
                  >
                    <Copy style={{ width: '14px', height: '14px', color: 'rgba(255, 255, 255, 0.6)' }} />
                  </button>
                </div>
                
                {/* Code content - simplified */}
                <div style={{ lineHeight: '1.7', color: 'rgba(255, 255, 255, 0.9)' }}>
                  <div style={{ marginBottom: '0.3rem' }}>
                    <span style={{ color: '#34d399' }}>#[starknet::interface]</span>
                  </div>
                  <div style={{ marginBottom: '0.3rem' }}>
                    <span style={{ color: '#c084fc' }}>pub trait</span> <span style={{ color: '#fbbf24' }}>IStarkWorldID</span><span style={{ color: '#e5e7eb' }}>{'<'}TContractState{'>'}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* CTA Button */}
            <div style={{ marginBottom: '1.2rem' }}> {/* Reduced from 1.5rem */}
              <a
                href="/getting-started"
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  borderRadius: '10px',
                  background: 'linear-gradient(to bottom, #f97316, #ea580c)',
                  border: '2px solid #ea580c',
                  padding: '0.75rem 1.5rem',
                  fontSize: '15px',
                  fontWeight: '600',
                  color: 'white',
                  textDecoration: 'none',
                  boxShadow: '0 0 0 2px rgba(0,0,0,0.04), 0 0 20px 0 rgba(249,115,22,0.4)',
                  transition: 'all 0.2s',
                  cursor: 'pointer'
                }}
                onMouseEnter={(e) => {
                  (e.target as HTMLElement).style.transform = 'scale(1.05)';
                  (e.target as HTMLElement).style.boxShadow = '0 0 0 2px rgba(0,0,0,0.04), 0 0 28px 0 rgba(249,115,22,0.6)';
                }}
                onMouseLeave={(e) => {
                  (e.target as HTMLElement).style.transform = 'scale(1)';
                  (e.target as HTMLElement).style.boxShadow = '0 0 0 2px rgba(0,0,0,0.04), 0 0 20px 0 rgba(249,115,22,0.4)';
                }}
              >
                Get Started
                <ArrowRight style={{ width: '16px', height: '16px' }} />
              </a>
            </div>
          </div>

          {/* Partners section */}
          <div style={{
            padding: windowWidth < 480 ? '0.4rem 0.5rem 0.8rem 0.5rem' : '0.5rem 1rem 1rem 1rem', // Reduced all padding
            borderTop: '1px solid rgba(255, 255, 255, 0.1)',
          }}>
            <p style={{ 
              color: 'rgba(255, 255, 255, 0.4)', 
              marginBottom: '0.4rem', // Reduced from 0.5rem
              fontSize: '8px', // Reduced from 9px
              textTransform: 'uppercase', 
              letterSpacing: '0.05em', 
              fontWeight: '500' 
            }}>
              Supported by
            </p>
            <div style={{ 
              display: 'flex', 
              flexWrap: 'wrap', 
              justifyContent: 'center', 
              alignItems: 'center', 
              gap: windowWidth < 480 ? '0.4rem' : '0.6rem' 
            }}>
              {[
                { name: 'World', href: 'https://worldcoin.org' },
                { name: 'Nethermind', href: 'https://nethermind.io' },
                { name: 'Starknet', href: 'https://starknet.io' },
                { name: 'Garaga', href: 'https://github.com/keep-starknet-strange/garaga' }
              ].map(({ name, href }) => (
                <a 
                  key={name}
                  href={href}
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{ 
                    color: 'rgba(255, 255, 255, 0.6)', 
                    fontSize: '11px', 
                    fontWeight: '500',
                    textDecoration: 'none',
                    transition: 'color 0.2s'
                  }}
                  onMouseEnter={(e) => (e.target as HTMLElement).style.color = 'rgba(255, 255, 255, 1)'}
                  onMouseLeave={(e) => (e.target as HTMLElement).style.color = 'rgba(255, 255, 255, 0.6)'}
                >
                  {name}
                </a>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Add responsive styles */}
      <style>{`
        @media (max-width: 640px) {
          h1 { font-size: clamp(1.5rem, 4vw, 2.5rem) !important; }
          p { font-size: clamp(0.875rem, 1.5vw, 1rem) !important; }
        }
        @media (max-width: 480px) {
          .feature-pill { padding: 0.35rem 0.75rem !important; }
        }
      `}</style>
    </div>
  );
}