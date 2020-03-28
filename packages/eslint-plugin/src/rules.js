module.exports = {
	base: {
		camelcase: ['error'],
		'class-methods-use-this': 'off',
		'lines-between-class-members': [
			'error',
			'always',
			{ exceptAfterSingleLine: true }
		],
		'max-classes-per-file': 'off',
		'no-await-in-loop': 'off',
		'no-continue': 'off',
		'no-else-return': ['error', { allowElseIf: true }],
		'no-plusplus': ['error', { allowForLoopAfterthoughts: true }],
		'no-restricted-syntax': 'off',
		'import/prefer-default-export': 'off',
		'import/extensions': 'off',
		'import/no-unresolved': 'off',
		'import/no-cycle': 'off',
		'import/order': [
			'error',
			{
				pathGroups: [
					{
						pattern: '~/**',
						group: 'parent'
					}
				]
			}
		],
		'import/no-extraneous-dependencies': [
			'error',
			{
				devDependencies: [
					'**/rollup.config.{ts,js}',
					'**/webpack.config.{ts,js}',
					'**/nuxt.config.{ts,js}',
					'**/*.test.{js,ts}',
					'**/*.spec.{js,ts}',
					'**/*.stories.{js,ts}',
					'**/test/**/*.{js,ts}'
				]
			}
		],
		'prettier/prettier': 'error'
	},
	javascript: {
		'no-unused-expressions': ['error', { allowTernary: true }],
		'interface-name-prefix': 'off',
		'explicit-function-return-type': 'off',
		'no-explicit-any': 'off',
		'no-use-before-define': 'off',
		'no-unused-vars': [
			'warn',
			{
				argsIgnorePattern: '^_'
			}
		]
	},
	typescript: {
		'@typescript-eslint/no-unused-expressions': [
			'error',
			{ allowTernary: true }
		],
		'@typescript-eslint/interface-name-prefix': 'off',
		'@typescript-eslint/explicit-function-return-type': 'off',
		'@typescript-eslint/no-explicit-any': 'off',
		'@typescript-eslint/no-use-before-define': 'off',
		'@typescript-eslint/no-unused-vars': [
			'warn',
			{
				argsIgnorePattern: '^_'
			}
		]
	},
	vue: {}
};
