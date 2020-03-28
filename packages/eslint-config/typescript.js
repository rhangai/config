const rules = require('./src/rules');

module.exports = {
	plugins: ['prettier'],
	extends: [
		'eslint-config-airbnb-typescript/base',
		'prettier',
		'prettier/@typescript-eslint',
	],
	env: {
		node: true,
		jest: true,
	},
	rules: {
		...rules.base,
		...rules.typescript,
	},
};
