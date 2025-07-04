#!/usr/bin/env node
// OSH.IT Website Content Generator
// Generates dynamic content from repository data

const fs = require('fs');
const path = require('path');

console.log('🚀 Generating OSH.IT website content...');

// Read package.json for version info
let version = '1.3.0';
try {
  const packagePath = path.join(__dirname, '..', 'package.json');
  if (fs.existsSync(packagePath)) {
    const packageData = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
    version = packageData.version || version;
  }
} catch (error) {
  console.log('Could not read package.json, using default version');
}

// Read VERSION file
try {
  const versionPath = path.join(__dirname, '..', 'VERSION');
  if (fs.existsSync(versionPath)) {
    const versionData = fs.readFileSync(versionPath, 'utf8').trim();
    if (versionData) {
      version = versionData;
    }
  }
} catch (error) {
  console.log('Could not read VERSION file');
}

// Read README for plugin information
let pluginCount = 6;
let features = [];
try {
  const readmePath = path.join(__dirname, '..', 'README.md');
  if (fs.existsSync(readmePath)) {
    const readmeContent = fs.readFileSync(readmePath, 'utf8');
    
    // Extract plugin count
    const pluginMatches = readmeContent.match(/plugins\/(\w+)/g);
    if (pluginMatches) {
      pluginCount = [...new Set(pluginMatches)].length;
    }
    
    // Extract features
    const featureSection = readmeContent.match(/## ✨ Features([\s\S]*?)##/);
    if (featureSection) {
      const featureLines = featureSection[1].match(/- .+/g);
      if (featureLines) {
        features = featureLines.map(line => line.replace(/^- /, '').trim());
      }
    }
  }
} catch (error) {
  console.log('Could not read README.md');
}

// Read CHANGELOG for latest changes
let latestChanges = [];
try {
  const changelogPath = path.join(__dirname, '..', 'CHANGELOG.md');
  if (fs.existsSync(changelogPath)) {
    const changelogContent = fs.readFileSync(changelogPath, 'utf8');
    
    // Extract latest changes
    const unreleasedSection = changelogContent.match(/## \[Unreleased\]([\s\S]*?)##/);
    if (unreleasedSection) {
      const changes = unreleasedSection[1].match(/- .+/g);
      if (changes) {
        latestChanges = changes.slice(0, 5).map(line => line.replace(/^- /, '').trim());
      }
    }
  }
} catch (error) {
  console.log('Could not read CHANGELOG.md');
}

// Generate meta tags and structured data
const generateMetaTags = () => {
  return `
  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://osh.it.miaowu.org/">
  <meta property="og:title" content="OSH.IT - A Lightweight Zsh Plugin Framework">
  <meta property="og:description" content="Lightning fast Zsh framework with 92% performance improvement through advanced lazy loading. Smart plugin system for developers.">
  <meta property="og:image" content="https://osh.it.miaowu.org/og-image.png">

  <!-- Twitter -->
  <meta property="twitter:card" content="summary_large_image">
  <meta property="twitter:url" content="https://osh.it.miaowu.org/">
  <meta property="twitter:title" content="OSH.IT - A Lightweight Zsh Plugin Framework">
  <meta property="twitter:description" content="Lightning fast Zsh framework with 92% performance improvement through advanced lazy loading. Smart plugin system for developers.">
  <meta property="twitter:image" content="https://osh.it.miaowu.org/og-image.png">

  <!-- Structured Data -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": "OSH.IT",
    "description": "A lightweight Zsh plugin framework with advanced lazy loading and 92% performance improvement",
    "url": "https://osh.it.miaowu.org/",
    "downloadUrl": "https://github.com/oiahoon/osh.it",
    "version": "${version}",
    "operatingSystem": "Linux, macOS",
    "applicationCategory": "DeveloperApplication",
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "USD"
    },
    "author": {
      "@type": "Person",
      "name": "oiahoon",
      "url": "https://github.com/oiahoon"
    }
  }
  </script>`;
};

// Update HTML file with dynamic content
try {
  const htmlPath = path.join(__dirname, 'index.html');
  let htmlContent = fs.readFileSync(htmlPath, 'utf8');
  
  // Update version in footer
  htmlContent = htmlContent.replace(
    /<div class="terminal-title">OSH\.IT v[\d.]+<\/div>/,
    `<div class="terminal-title">OSH.IT v${version}</div>`
  );
  
  // Update plugin count in footer stats
  htmlContent = htmlContent.replace(
    /<span class="stat-value">\d+<\/span>\s*<span class="stat-label">Built-in Plugins<\/span>/,
    `<span class="stat-value">${pluginCount}</span>\n                <span class="stat-label">Built-in Plugins</span>`
  );
  
  // Add meta tags if not present
  if (!htmlContent.includes('property="og:type"')) {
    htmlContent = htmlContent.replace(
      /<link rel="icon"[^>]*>/,
      `<link rel="icon" type="image/svg+xml" href="favicon.svg">${generateMetaTags()}`
    );
  }
  
  fs.writeFileSync(htmlPath, htmlContent);
  console.log('✅ Updated index.html with dynamic content');
} catch (error) {
  console.error('❌ Error updating HTML:', error.message);
}

// Generate sitemap.xml
const generateSitemap = () => {
  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://osh.it.miaowu.org/</loc>
    <lastmod>${new Date().toISOString().split('T')[0]}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://github.com/oiahoon/osh.it</loc>
    <lastmod>${new Date().toISOString().split('T')[0]}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>`;
  
  fs.writeFileSync(path.join(__dirname, 'sitemap.xml'), sitemap);
  console.log('✅ Generated sitemap.xml');
};

// Generate robots.txt
const generateRobots = () => {
  const robots = `User-agent: *
Allow: /

Sitemap: https://oiahoon.github.io/osh.it/sitemap.xml`;
  
  fs.writeFileSync(path.join(__dirname, 'robots.txt'), robots);
  console.log('✅ Generated robots.txt');
};

// Generate manifest.json for PWA
const generateManifest = () => {
  const manifest = {
    name: "OSH.IT - Zsh Plugin Framework",
    short_name: "OSH.IT",
    description: "A lightweight Zsh plugin framework with advanced lazy loading",
    start_url: "/",
    display: "standalone",
    background_color: "#0d1117",
    theme_color: "#667eea",
    icons: [
      {
        src: "favicon.svg",
        sizes: "any",
        type: "image/svg+xml"
      }
    ]
  };
  
  fs.writeFileSync(path.join(__dirname, 'manifest.json'), JSON.stringify(manifest, null, 2));
  console.log('✅ Generated manifest.json');
};

// Generate performance report
const generatePerformanceReport = () => {
  const report = {
    generated: new Date().toISOString(),
    version: version,
    metrics: {
      lazy_loading_improvement: "92%",
      startup_time_traditional: "138ms",
      startup_time_oshit: "11ms",
      plugin_count: pluginCount,
      features_count: features.length
    },
    features: features,
    latest_changes: latestChanges
  };
  
  fs.writeFileSync(path.join(__dirname, 'performance-report.json'), JSON.stringify(report, null, 2));
  console.log('✅ Generated performance-report.json');
};

// Run all generators
try {
  generateSitemap();
  generateRobots();
  generateManifest();
  generatePerformanceReport();
  
  console.log('🎉 Content generation completed successfully!');
  console.log(`📊 Version: ${version}`);
  console.log(`🔌 Plugins: ${pluginCount}`);
  console.log(`✨ Features: ${features.length}`);
  console.log(`📝 Latest changes: ${latestChanges.length}`);
} catch (error) {
  console.error('❌ Error during content generation:', error.message);
  process.exit(1);
}
