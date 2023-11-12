module.exports = function(api) {
  api.cache(true);
  return {
    presets: [
      // ... other presets you may have
    ],
    plugins: [
      "@babel/plugin-proposal-private-property-in-object"
      // ... other plugins you may have
    ],
  };
};
