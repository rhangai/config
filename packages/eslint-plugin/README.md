# Instalação

Typescript:

```sh
yarn add --dev @honestdev/eslint-config \
	eslint-config-airbnb-typescript \
	eslint-config-prettier \
	eslint-plugin-import \
	eslint-plugin-prettier \
	@typescript-eslint/parser \
	@typescript-eslint/eslint-plugin
```

### `vue-typescript`

```sh
yarn add --dev @honestdev/eslint-config \
	eslint-config-airbnb-typescript \
	eslint-config-prettier \
	eslint-plugin-import \
	eslint-plugin-prettier \
	eslint-plugin-vue \
	@typescript-eslint/parser \
	@typescript-eslint/eslint-plugin
```

```js
module.export = {
	root: true,
	extends: ['@honestdev/eslint-config/vue-typescript'],
	parserOptions: {
		project: 'tsconfig.json'
	}
};
```
