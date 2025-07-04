module.exports = {
  ci: {
    collect: {
      url: ['https://oiahoon.github.io/osh.it/'],
      startServerCommand: 'cd docs && python3 -m http.server 8000',
      startServerReadyPattern: 'Serving HTTP',
      startServerReadyTimeout: 10000,
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', {minScore: 0.9}],
        'categories:accessibility': ['error', {minScore: 0.9}],
        'categories:best-practices': ['warn', {minScore: 0.9}],
        'categories:seo': ['warn', {minScore: 0.9}],
        'categories:pwa': ['warn', {minScore: 0.7}],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
