#!/usr/bin/env node
// OSH.IT Enhanced Content Generator
// Automatically detects and updates website content based on repository changes

const fs = require('fs');
const path = require('path');

console.log('🚀 OSH.IT Enhanced Content Generator');
console.log('=====================================');

// Enhanced plugin detection
const detectPlugins = () => {
  const pluginsDir = path.join(__dirname, '..', 'plugins');
  const plugins = {
    stable: [],
    beta: [],
    experimental: []
  };
  
  if (!fs.existsSync(pluginsDir)) {
    console.log('⚠️  Plugins directory not found');
    return plugins;
  }
  
  const pluginDirs = fs.readdirSync(pluginsDir, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);
  
  pluginDirs.forEach(pluginName => {
    const pluginPath = path.join(pluginsDir, pluginName);
    const pluginFile = path.join(pluginPath, `${pluginName}.plugin.zsh`);
    
    let category = 'experimental'; // default
    let description = 'Plugin description not available';
    let version = '1.0.0';
    
    // Try to read plugin metadata
    if (fs.existsSync(pluginFile)) {
      try {
        const content = fs.readFileSync(pluginFile, 'utf8');
        
        // Extract metadata from comments
        const descMatch = content.match(/# Description:\s*(.+)/i);
        if (descMatch) description = descMatch[1].trim();
        
        const versionMatch = content.match(/# Version:\s*(.+)/i);
        if (versionMatch) version = versionMatch[1].trim();
        
        const categoryMatch = content.match(/# Category:\s*(.+)/i);
        if (categoryMatch) category = categoryMatch[1].trim().toLowerCase();
      } catch (error) {
        console.log(`⚠️  Could not read plugin file: ${pluginName}`);
      }
    }
    
    // Check README for additional info
    const readmePath = path.join(pluginPath, 'README.md');
    if (fs.existsSync(readmePath)) {
      try {
        const readmeContent = fs.readFileSync(readmePath, 'utf8');
        const descMatch = readmeContent.match(/^#\s+(.+)/m);
        if (descMatch && description === 'Plugin description not available') {
          description = descMatch[1].trim();
        }
      } catch (error) {
        console.log(`⚠️  Could not read README for: ${pluginName}`);
      }
    }
    
    plugins[category].push({
      name: pluginName,
      description,
      version,
      path: pluginPath
    });
  });
  
  return plugins;
};

// Enhanced feature detection
const detectFeatures = () => {
  const features = [];
  
  try {
    const readmePath = path.join(__dirname, '..', 'README.md');
    if (fs.existsSync(readmePath)) {
      const content = fs.readFileSync(readmePath, 'utf8');
      
      // Extract features from multiple sections
      const sections = [
        /## ✨ Features([\s\S]*?)##/,
        /## 🚀 Features([\s\S]*?)##/,
        /## Features([\s\S]*?)##/
      ];
      
      sections.forEach(regex => {
        const match = content.match(regex);
        if (match) {
          const featureLines = match[1].match(/- .+/g);
          if (featureLines) {
            featureLines.forEach(line => {
              const feature = line.replace(/^- /, '').trim();
              if (!features.includes(feature)) {
                features.push(feature);
              }
            });
          }
        }
      });
    }
  } catch (error) {
    console.log('⚠️  Could not extract features from README');
  }
  
  return features;
};

// Detect version information
const detectVersion = () => {
  // Try multiple sources for version
  const sources = [
    path.join(__dirname, '..', 'VERSION'),
    path.join(__dirname, '..', 'package.json'),
    path.join(__dirname, 'package.json')
  ];
  
  for (const source of sources) {
    try {
      if (fs.existsSync(source)) {
        if (source.endsWith('.json')) {
          const data = JSON.parse(fs.readFileSync(source, 'utf8'));
          if (data.version) return data.version;
        } else {
          const version = fs.readFileSync(source, 'utf8').trim();
          if (version) return version;
        }
      }
    } catch (error) {
      continue;
    }
  }
  
  return '1.4.0'; // fallback
};

// Detect latest changes
const detectChanges = () => {
  const changes = [];
  
  try {
    const changelogPath = path.join(__dirname, '..', 'CHANGELOG.md');
    if (fs.existsSync(changelogPath)) {
      const content = fs.readFileSync(changelogPath, 'utf8');
      
      // Extract unreleased changes
      const unreleasedMatch = content.match(/## \[Unreleased\]([\s\S]*?)##/);
      if (unreleasedMatch) {
        const changeLines = unreleasedMatch[1].match(/- .+/g);
        if (changeLines) {
          changeLines.slice(0, 5).forEach(line => {
            changes.push(line.replace(/^- /, '').trim());
          });
        }
      }
    }
  } catch (error) {
    console.log('⚠️  Could not extract changes from CHANGELOG');
  }
  
  return changes;
};

// Generate enhanced website content
const generateEnhancedContent = () => {
  const plugins = detectPlugins();
  const features = detectFeatures();
  const version = detectVersion();
  const changes = detectChanges();
  
  const totalPlugins = Object.values(plugins).reduce((sum, arr) => sum + arr.length, 0);
  
  console.log('📊 Detected Content:');
  console.log(`   Version: ${version}`);
  console.log(`   Total Plugins: ${totalPlugins}`);
  console.log(`   - Stable: ${plugins.stable.length}`);
  console.log(`   - Beta: ${plugins.beta.length}`);
  console.log(`   - Experimental: ${plugins.experimental.length}`);
  console.log(`   Features: ${features.length}`);
  console.log(`   Recent Changes: ${changes.length}`);
  
  // Update HTML content
  try {
    const htmlPath = path.join(__dirname, 'index.html');
    let htmlContent = fs.readFileSync(htmlPath, 'utf8');
    
    // Update version
    htmlContent = htmlContent.replace(
      /<div class="terminal-title">OSH\.IT v[\d.]+<\/div>/g,
      `<div class="terminal-title">OSH.IT v${version}</div>`
    );
    
    // Update plugin count
    htmlContent = htmlContent.replace(
      /<span class="stat-value">\d+<\/span>\s*<span class="stat-label">Built-in Plugins<\/span>/,
      `<span class="stat-value">${totalPlugins}</span>\n                <span class="stat-label">Built-in Plugins</span>`
    );
    
    fs.writeFileSync(htmlPath, htmlContent);
    console.log('✅ Updated index.html with enhanced content');
  } catch (error) {
    console.error('❌ Error updating HTML:', error.message);
  }
  
  // Generate enhanced report
  const report = {
    generated: new Date().toISOString(),
    version,
    plugins: {
      total: totalPlugins,
      by_category: {
        stable: plugins.stable.length,
        beta: plugins.beta.length,
        experimental: plugins.experimental.length
      },
      details: plugins
    },
    features: {
      count: features.length,
      list: features
    },
    changes: {
      count: changes.length,
      list: changes
    }
  };
  
  fs.writeFileSync(
    path.join(__dirname, 'enhanced-report.json'),
    JSON.stringify(report, null, 2)
  );
  
  console.log('✅ Generated enhanced-report.json');
  return report;
};

// Main execution
if (require.main === module) {
  try {
    const report = generateEnhancedContent();
    console.log('🎉 Enhanced content generation completed!');
  } catch (error) {
    console.error('❌ Error during enhanced content generation:', error.message);
    process.exit(1);
  }
}

module.exports = { detectPlugins, detectFeatures, detectVersion, detectChanges };
