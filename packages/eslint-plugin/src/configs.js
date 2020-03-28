const rules = require('./rules');

module.exports = {
	javascript: {
		plugins: ['prettier'],
		extends: ['eslint-config-airbnb-base', 'prettier'],
		env: {
			node: true,
			jest: true
		},
		rules: {
			...rules.base,
			...rules.javascript
		}
	},
	typescript: {
		plugins: ['prettier'],
		extends: [
			'eslint-config-airbnb-typescript/base',
			'prettier',
			'prettier/@typescript-eslint'
		],
		env: {
			node: true,
			jest: true
		},
		rules: {
			...rules.base,
			...rules.typescript
		}
	},
	vue: {
		plugins: ['prettier', 'vue'],
		extends: [
			'eslint-config-airbnb-base',
			'prettier',
			'prettier/vue',
			'plugin:vue/recommended'
		],
		env: {
			node: true,
			browser: true,
			jest: true
		},
		rules: {
			...rules.base,
			...rules.vue
		},
		overrides: [
			{
				files: ['*.stories.{js,ts}'],
				rules: {
					'vue/require-prop-types': 'off'
				}
			}
		]
	},
	'vue-typescript': {
		plugins: ['prettier', 'vue'],
		extends: [
			'eslint-config-airbnb-typescript/base',
			'prettier',
			'prettier/vue',
			'prettier/@typescript-eslint',
			'plugin:vue/recommended'
		],
		parserOptions: {
			parser: '@typescript-eslint/parser',
			extraFileExtensions: ['.vue']
		},
		env: {
			node: true,
			browser: true,
			jest: true
		},
		rules: {
			...rules.base,
			...rules.typescript,
			...rules.vue
		},
		overrides: [
			{
				files: ['*.stories.{js,ts}'],
				rules: {
					'vue/require-prop-types': 'off'
				}
			}
		]
	}
};
