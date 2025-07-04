// OSH.IT Website Interactive Features

document.addEventListener('DOMContentLoaded', function() {
    // ASCII Logo Animation (matching shell logo exactly)
    const logoText = `

        ██████╗ ███████╗██╗  ██╗   ██╗████████╗
       ██╔═══██╗██╔════╝██║  ██║   ██║╚══██╔══╝
       ██║   ██║███████╗███████║   ██║   ██║   
       ██║   ██║╚════██║██╔══██║   ██║   ██║   
       ╚██████╔╝███████║██║  ██║██╗██║   ██║   
        ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝   ╚═╝   

     ╔════════════════════════════════════════╗
     ║      Lightweight Zsh Framework         ║
     ║        Fast • Simple • Cool            ║
     ╚════════════════════════════════════════╝

       ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
      ▐ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ▌
       ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

    `;
    
    const logoElement = document.getElementById('logo-text');
    if (logoElement) {
        logoElement.textContent = logoText;
    }

    // Copy to Clipboard Functionality
    const copyButtons = document.querySelectorAll('.copy-btn');
    copyButtons.forEach(button => {
        button.addEventListener('click', function() {
            const textToCopy = this.getAttribute('data-copy');
            
            // Create temporary textarea
            const textarea = document.createElement('textarea');
            textarea.value = textToCopy;
            document.body.appendChild(textarea);
            textarea.select();
            
            try {
                document.execCommand('copy');
                
                // Visual feedback
                const originalText = this.textContent;
                this.textContent = 'Copied!';
                this.style.background = 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)';
                
                setTimeout(() => {
                    this.textContent = originalText;
                    this.style.background = '';
                }, 2000);
                
            } catch (err) {
                console.error('Failed to copy text: ', err);
                this.textContent = 'Failed';
                setTimeout(() => {
                    this.textContent = 'Copy';
                }, 2000);
            }
            
            document.body.removeChild(textarea);
        });
    });

    // Smooth Scrolling for Navigation Links
    const navLinks = document.querySelectorAll('.nav-link[href^="#"]');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                const offsetTop = targetElement.offsetTop - 100;
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }
        });
    });

    // Typing Animation for Command
    const commandElement = document.querySelector('.typing-animation');
    if (commandElement) {
        const originalText = commandElement.textContent;
        commandElement.textContent = '';
        
        let i = 0;
        const typeWriter = () => {
            if (i < originalText.length) {
                commandElement.textContent += originalText.charAt(i);
                i++;
                setTimeout(typeWriter, 50);
            } else {
                // Remove typing cursor after animation
                setTimeout(() => {
                    commandElement.classList.remove('typing-animation');
                }, 1000);
            }
        };
        
        // Start typing animation after a delay
        setTimeout(typeWriter, 1000);
    }

    // Performance Chart Animation
    const performanceSection = document.getElementById('performance');
    if (performanceSection) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const bars = entry.target.querySelectorAll('.bar');
                    bars.forEach((bar, index) => {
                        setTimeout(() => {
                            bar.style.animation = `fillBar 2s ease-out forwards`;
                        }, index * 500);
                    });
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });
        
        observer.observe(performanceSection);
    }

    // GitHub Stars Counter
    async function fetchGitHubStars() {
        try {
            const response = await fetch('https://api.github.com/repos/oiahoon/osh.it');
            const data = await response.json();
            const starsElement = document.getElementById('github-stars');
            if (starsElement && data.stargazers_count !== undefined) {
                starsElement.textContent = `⭐ ${data.stargazers_count}`;
            }
        } catch (error) {
            console.log('Could not fetch GitHub stars:', error);
            // Fallback to static display
            const starsElement = document.getElementById('github-stars');
            if (starsElement) {
                starsElement.textContent = '⭐ Star';
            }
        }
    }
    
    fetchGitHubStars();

    // Terminal Window Interactions
    const terminalWindows = document.querySelectorAll('.terminal-window');
    terminalWindows.forEach(window => {
        const closeBtn = window.querySelector('.btn.close');
        const minimizeBtn = window.querySelector('.btn.minimize');
        const maximizeBtn = window.querySelector('.btn.maximize');
        
        // Close button (just visual effect)
        if (closeBtn) {
            closeBtn.addEventListener('click', function(e) {
                e.preventDefault();
                window.style.opacity = '0.5';
                setTimeout(() => {
                    window.style.opacity = '1';
                }, 300);
            });
        }
        
        // Minimize button (just visual effect)
        if (minimizeBtn) {
            minimizeBtn.addEventListener('click', function(e) {
                e.preventDefault();
                const body = window.querySelector('.terminal-body');
                if (body) {
                    body.style.transform = 'scaleY(0)';
                    body.style.transformOrigin = 'top';
                    body.style.transition = 'transform 0.3s ease';
                    setTimeout(() => {
                        body.style.transform = 'scaleY(1)';
                    }, 1000);
                }
            });
        }
        
        // Maximize button (just visual effect)
        if (maximizeBtn) {
            maximizeBtn.addEventListener('click', function(e) {
                e.preventDefault();
                window.style.transform = 'scale(1.02)';
                window.style.transition = 'transform 0.2s ease';
                setTimeout(() => {
                    window.style.transform = 'scale(1)';
                }, 200);
            });
        }
    });

    // Parallax Effect for Background
    window.addEventListener('scroll', function() {
        const scrolled = window.pageYOffset;
        const rate = scrolled * -0.5;
        
        document.body.style.backgroundPosition = `center ${rate}px`;
    });

    // Feature Cards Hover Effect
    const featureCards = document.querySelectorAll('.feature-card');
    featureCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-10px) rotateX(5deg)';
            this.style.transition = 'all 0.3s ease';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) rotateX(0)';
        });
    });

    // Plugin Cards Animation
    const pluginItems = document.querySelectorAll('.plugin-item');
    const pluginObserver = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, index * 100);
                pluginObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    pluginItems.forEach(item => {
        item.style.opacity = '0';
        item.style.transform = 'translateY(20px)';
        item.style.transition = 'all 0.6s ease';
        pluginObserver.observe(item);
    });

    // Code Block Syntax Highlighting (Simple)
    const codeBlocks = document.querySelectorAll('code');
    codeBlocks.forEach(block => {
        let html = block.innerHTML;
        
        // Highlight shell commands
        html = html.replace(/(\$\s+)([^<\n]+)/g, '$1<span class="command">$2</span>');
        
        // Highlight success messages
        html = html.replace(/(✓|✅|OK|SUCCESS)/g, '<span class="success">$1</span>');
        
        // Highlight error messages
        html = html.replace(/(✗|❌|ERROR|FAILED)/g, '<span class="error">$1</span>');
        
        // Highlight info messages
        html = html.replace(/(ℹ️|INFO|→)/g, '<span class="info">$1</span>');
        
        // Highlight warnings
        html = html.replace(/(⚠️|WARNING|WARN)/g, '<span class="warning">$1</span>');
        
        block.innerHTML = html;
    });

    // Easter Egg: Konami Code
    let konamiCode = [];
    const konamiSequence = [
        'ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown',
        'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight',
        'KeyB', 'KeyA'
    ];
    
    document.addEventListener('keydown', function(e) {
        konamiCode.push(e.code);
        
        if (konamiCode.length > konamiSequence.length) {
            konamiCode.shift();
        }
        
        if (konamiCode.length === konamiSequence.length) {
            let match = true;
            for (let i = 0; i < konamiSequence.length; i++) {
                if (konamiCode[i] !== konamiSequence[i]) {
                    match = false;
                    break;
                }
            }
            
            if (match) {
                // Easter egg activated!
                document.body.style.filter = 'hue-rotate(180deg)';
                setTimeout(() => {
                    document.body.style.filter = '';
                }, 3000);
                
                // Show a fun message
                const message = document.createElement('div');
                message.textContent = '🎉 Konami Code Activated! OSH.IT Power Mode! 🚀';
                message.style.cssText = `
                    position: fixed;
                    top: 50%;
                    left: 50%;
                    transform: translate(-50%, -50%);
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 20px 40px;
                    border-radius: 10px;
                    font-family: var(--font-mono);
                    font-weight: bold;
                    z-index: 9999;
                    box-shadow: 0 20px 40px rgba(0,0,0,0.3);
                    animation: fadeInUp 0.5s ease;
                `;
                
                document.body.appendChild(message);
                setTimeout(() => {
                    document.body.removeChild(message);
                }, 3000);
                
                konamiCode = [];
            }
        }
    });

    // Performance Monitoring
    if ('performance' in window) {
        window.addEventListener('load', function() {
            setTimeout(() => {
                const perfData = performance.getEntriesByType('navigation')[0];
                const loadTime = perfData.loadEventEnd - perfData.loadEventStart;
                
                if (loadTime > 0) {
                    console.log(`🚀 OSH.IT website loaded in ${loadTime.toFixed(2)}ms`);
                    console.log('Just like our shell framework - lightning fast! ⚡');
                }
            }, 0);
        });
    }

    // Add some terminal-like console messages
    console.log('%c Welcome to OSH.IT! ', 'background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 10px; border-radius: 5px; font-weight: bold;');
    console.log('%c 🚀 Lightning Fast Zsh Framework', 'color: #22c55e; font-weight: bold;');
    console.log('%c ⚡ 92% Performance Improvement', 'color: #3b82f6; font-weight: bold;');
    console.log('%c 🔌 Smart Plugin System', 'color: #7c3aed; font-weight: bold;');
    console.log('%c Try the Konami Code for a surprise! ↑↑↓↓←→←→BA', 'color: #f59e0b; font-style: italic;');
});

// Service Worker Registration (for PWA capabilities)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
        navigator.serviceWorker.register('/sw.js')
            .then(function(registration) {
                console.log('ServiceWorker registration successful');
            })
            .catch(function(err) {
                console.log('ServiceWorker registration failed');
            });
    });
}
