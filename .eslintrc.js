module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: ["airbnb-base"],
  globals: {
    $: "readonly",
    L: "readonly",
  },
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module",
  },
  rules: {
    "max-len": "off",
    "prefer-destructuring": "off",
    "no-alert": "off",
    "no-console": "off",
    "max-classes-per-file": "off",
    "no-new": "off",
  },
  settings: {
    "import/resolver": {
      node: {
        paths: ["app/javascript/"],
        extensions: [".js", ".js.erb"],
      },
    },
  },
};
