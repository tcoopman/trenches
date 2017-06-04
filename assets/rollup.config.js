import node_resolve from 'rollup-plugin-node-resolve';

export default {
    entry: './lib/es6/bs/main.js',
    format: 'cjs',
    dest: './js/main-bundled.js',
    plugins: [node_resolve({module: true, browser: true})],
    moduleName: 'trenches'
}