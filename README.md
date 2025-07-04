# OSH.IT Website

This directory contains the source code for the OSH.IT project website, featuring a beautiful retro terminal design that reflects the project's aesthetic.

## 🎨 Design Features

- **Retro Terminal Theme**: Authentic terminal window design with classic buttons
- **Interactive Elements**: Hover effects, animations, and terminal-like interactions
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Performance Optimized**: Fast loading with lazy loading and caching
- **PWA Ready**: Service worker and manifest for offline capabilities

## 🚀 Development

### Local Development

```bash
# Serve the website locally
cd docs
python3 -m http.server 8000
# or
npm run serve

# Visit http://localhost:8000
```

### Build Process

```bash
# Generate dynamic content
node generate-content.js

# Run linting
npm run lint

# Optimize assets
npm run optimize
```

### Content Generation

The website uses dynamic content generation to stay in sync with the repository:

- **Version Information**: Automatically extracted from `VERSION` file
- **Plugin Count**: Calculated from plugin directories
- **Features**: Extracted from README.md
- **Latest Changes**: Pulled from CHANGELOG.md

## 📁 File Structure

```
docs/
├── index.html          # Main HTML file
├── styles.css          # CSS styles with retro theme
├── script.js           # JavaScript for interactions
├── favicon.svg         # SVG favicon
├── sw.js              # Service worker
├── generate-content.js # Content generator
├── package.json       # Dependencies
└── README.md          # This file
```

## 🎯 Features

### Visual Design
- **Terminal Windows**: Authentic terminal appearance with close/minimize/maximize buttons
- **ASCII Art Logo**: Animated OSH.IT logo
- **Gradient Accents**: Beautiful color gradients throughout
- **Syntax Highlighting**: Code blocks with terminal-style highlighting

### Interactive Elements
- **Copy Buttons**: One-click copying of installation commands
- **Smooth Scrolling**: Navigation with smooth scroll behavior
- **Hover Effects**: 3D transforms and animations
- **Performance Chart**: Animated comparison bars
- **Easter Eggs**: Hidden Konami code activation

### Performance
- **Lazy Loading**: Images and content loaded on demand
- **Service Worker**: Caching for offline access
- **Optimized Assets**: Compressed and minified resources
- **Fast Loading**: Sub-second load times

### SEO & Accessibility
- **Meta Tags**: Complete Open Graph and Twitter Card support
- **Structured Data**: JSON-LD for search engines
- **Semantic HTML**: Proper heading structure and landmarks
- **ARIA Labels**: Accessibility attributes where needed

## 🔧 Customization

### Colors
The color scheme is defined in CSS custom properties:

```css
:root {
  --terminal-bg: #0d1117;
  --terminal-fg: #c9d1d9;
  --accent-purple: #7c3aed;
  --success: #22c55e;
  /* ... */
}
```

### Typography
Uses JetBrains Mono for authentic terminal feel:

```css
--font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
```

### Animations
Smooth animations with CSS transitions and keyframes:

```css
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}
```

## 🚀 Deployment

The website is automatically deployed using GitHub Actions:

1. **Build**: Generate dynamic content and optimize assets
2. **Deploy**: Deploy to GitHub Pages
3. **Test**: Run Lighthouse CI for performance monitoring
4. **Monitor**: Check accessibility and SEO

### GitHub Pages Setup

1. Enable GitHub Pages in repository settings
2. Set source to "GitHub Actions"
3. The workflow will automatically deploy on push to main

### Custom Domain (Optional)

To use a custom domain:

1. Add `CNAME` file with your domain
2. Configure DNS settings
3. Enable HTTPS in GitHub Pages settings

## 📊 Performance Monitoring

The website includes comprehensive performance monitoring:

- **Lighthouse CI**: Automated performance, accessibility, and SEO audits
- **Load Time Monitoring**: Automatic checks for page load speed
- **Accessibility Testing**: PA11Y integration for accessibility compliance
- **SEO Validation**: Sitemap generation and meta tag validation

## 🤝 Contributing

To contribute to the website:

1. **Fork the repository**
2. **Make changes** in the `docs/` directory
3. **Test locally** using the development server
4. **Submit a pull request**

### Guidelines

- Follow the existing design patterns
- Maintain the retro terminal aesthetic
- Ensure responsive design works on all devices
- Test performance impact of changes
- Update documentation as needed

## 📄 License

The website code is licensed under the MIT License, same as the main project.

---

**Made with ❤️ for the OSH.IT community**
