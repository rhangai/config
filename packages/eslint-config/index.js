const rules = require('./src/rules');

module.exports = {
	plugins: ['prettier'],
	extends: ['eslint-config-airbnb-base', 'prettier'],
	env: {
		node: true,
		jest: true,
	},
	rules: {
		...rules.base,
		...rules.javascript,
	},
};
