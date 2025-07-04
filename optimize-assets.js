#!/usr/bin/env node
// OSH.IT Asset Optimization Script

const fs = require('fs');
const path = require('path');

console.log('🔧 Optimizing OSH.IT website assets...');

// Minify CSS (simple minification)
const minifyCSS = (css) => {
  return css
    .replace(/\/\*[\s\S]*?\*\//g, '') // Remove comments
    .replace(/\s+/g, ' ') // Collapse whitespace
    .replace(/;\s*}/g, '}') // Remove unnecessary semicolons
    .replace(/\s*{\s*/g, '{') // Clean up braces
    .replace(/\s*}\s*/g, '}')
    .replace(/\s*;\s*/g, ';') // Clean up semicolons
    .replace(/\s*,\s*/g, ',') // Clean up commas
    .replace(/\s*:\s*/g, ':') // Clean up colons
    .trim();
};

// Minify JavaScript (simple minification)
const minifyJS = (js) => {
  return js
    .replace(/\/\*[\s\S]*?\*\//g, '') // Remove block comments
    .replace(/\/\/.*$/gm, '') // Remove line comments
    .replace(/\s+/g, ' ') // Collapse whitespace
    .replace(/;\s*}/g, '}') // Clean up
    .replace(/\s*{\s*/g, '{')
    .replace(/\s*}\s*/g, '}')
    .replace(/\s*;\s*/g, ';')
    .replace(/\s*,\s*/g, ',')
    .trim();
};

// Optimize HTML (remove unnecessary whitespace)
const optimizeHTML = (html) => {
  return html
    .replace(/>\s+</g, '><') // Remove whitespace between tags
    .replace(/\s+/g, ' ') // Collapse whitespace
    .trim();
};

// Create optimized versions
try {
  // Optimize CSS
  const cssPath = path.join(__dirname, 'styles.css');
  if (fs.existsSync(cssPath)) {
    const css = fs.readFileSync(cssPath, 'utf8');
    const minifiedCSS = minifyCSS(css);
    const savings = ((css.length - minifiedCSS.length) / css.length * 100).toFixed(1);
    
    // Create minified version
    fs.writeFileSync(path.join(__dirname, 'styles.min.css'), minifiedCSS);
    console.log(`✅ CSS optimized: ${css.length} → ${minifiedCSS.length} bytes (${savings}% reduction)`);
  }

  // Optimize JavaScript
  const jsPath = path.join(__dirname, 'script.js');
  if (fs.existsSync(jsPath)) {
    const js = fs.readFileSync(jsPath, 'utf8');
    const minifiedJS = minifyJS(js);
    const savings = ((js.length - minifiedJS.length) / js.length * 100).toFixed(1);
    
    // Create minified version
    fs.writeFileSync(path.join(__dirname, 'script.min.js'), minifiedJS);
    console.log(`✅ JavaScript optimized: ${js.length} → ${minifiedJS.length} bytes (${savings}% reduction)`);
  }

  // Create production HTML with minified assets
  const htmlPath = path.join(__dirname, 'index.html');
  if (fs.existsSync(htmlPath)) {
    let html = fs.readFileSync(htmlPath, 'utf8');
    
    // Replace with minified versions in production
    if (process.env.NODE_ENV === 'production') {
      html = html.replace('styles.css', 'styles.min.css');
      html = html.replace('script.js', 'script.min.js');
    }
    
    const optimizedHTML = optimizeHTML(html);
    const savings = ((html.length - optimizedHTML.length) / html.length * 100).toFixed(1);
    
    if (process.env.NODE_ENV === 'production') {
      fs.writeFileSync(path.join(__dirname, 'index.html'), optimizedHTML);
      console.log(`✅ HTML optimized: ${html.length} → ${optimizedHTML.length} bytes (${savings}% reduction)`);
    } else {
      console.log(`ℹ️  HTML would be optimized: ${html.length} → ${optimizedHTML.length} bytes (${savings}% reduction)`);
    }
  }

  // Generate performance report
  const generatePerformanceReport = () => {
    const stats = {
      timestamp: new Date().toISOString(),
      files: {},
      total_original: 0,
      total_optimized: 0
    };

    // Check all files
    const files = ['index.html', 'styles.css', 'script.js'];
    files.forEach(file => {
      const filePath = path.join(__dirname, file);
      if (fs.existsSync(filePath)) {
        const size = fs.statSync(filePath).size;
        stats.files[file] = { size };
        stats.total_original += size;
      }
    });

    // Check minified files
    const minFiles = ['styles.min.css', 'script.min.js'];
    minFiles.forEach(file => {
      const filePath = path.join(__dirname, file);
      if (fs.existsSync(filePath)) {
        const size = fs.statSync(filePath).size;
        const originalFile = file.replace('.min', '');
        if (stats.files[originalFile]) {
          stats.files[originalFile].minified_size = size;
          stats.total_optimized += size;
        }
      }
    });

    // Calculate total savings
    stats.total_savings = stats.total_original - stats.total_optimized;
    stats.savings_percentage = ((stats.total_savings / stats.total_original) * 100).toFixed(1);

    fs.writeFileSync(
      path.join(__dirname, 'optimization-report.json'),
      JSON.stringify(stats, null, 2)
    );

    console.log(`📊 Optimization Report:`);
    console.log(`   Original size: ${stats.total_original} bytes`);
    console.log(`   Optimized size: ${stats.total_optimized} bytes`);
    console.log(`   Total savings: ${stats.total_savings} bytes (${stats.savings_percentage}%)`);
  };

  generatePerformanceReport();

  console.log('🎉 Asset optimization completed!');

} catch (error) {
  console.error('❌ Error during optimization:', error.message);
  process.exit(1);
}
