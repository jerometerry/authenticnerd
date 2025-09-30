// frontend/rtk-codegen.config.cts
const { ConfigFile } = require('@rtk-query/codegen-openapi');

const config: typeof ConfigFile = {
  schemaFile: 'http://127.0.0.1:8000/openapi.json',
  apiFile: './src/state/api.ts',
  outputFile: './src/state/generatedApi.ts',
  hooks: true,
  tag: true, 
};

module.exports = config;