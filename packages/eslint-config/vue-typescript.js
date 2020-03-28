const rules = require('./src/rules');

module.exports = {
	plugins: ['prettier', 'vue'],
	extends: [
		'eslint-config-airbnb-typescript/base',
		'prettier',
		'prettier/vue',
		'prettier/@typescript-eslint',
		'plugin:vue/recommended',
	],
	parserOptions: {
		parser: '@typescript-eslint/parser',
		extraFileExtensions: ['.vue'],
	},
	env: {
		node: true,
		browser: true,
		jest: true,
	},
	rules: {
		...rules.base,
		...rules.typescript,
		...rules.vue,
	},
	overrides: [
		{
			files: ['*.stories.{js,ts}'],
			rules: {
				'vue/require-prop-types': 'off',
			},
		},
	],
};
