const rules = require('./src/rules');

module.exports = {
	plugins: ['prettier', 'vue'],
	extends: [
		'eslint-config-airbnb-base',
		'prettier',
		'prettier/vue',
		'plugin:vue/recommended',
	],
	env: {
		node: true,
		browser: true,
		jest: true,
	},
	rules: {
		...rules.base,
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
