#!/bin/sh
npx create-next-app $1
cd $1
npm i normalize.css
mkdir components
mkdir components/atoms
mkdir components/molecules
mkdir components/organisms
mkdir components/templates
mkdir components/pages

cat <<EOT >styles/globals.css
@import '../node_modules/normalize.css/normalize.css';
@import url('https://fonts.googleapis.com/css2?family=Roboto&display=swap');
html,
body {
  padding: 0;
  margin: 0;
  font-family: 'Roboto', sans-serif;
}

a {
  color: inherit;
  text-decoration: none;
}

* {
  box-sizing: border-box;
}

EOT
cat <<EOT >next.config.js
module.exports = {
  future: {
    webpack5: true,
  },
}
EOT

npm i -D typescript @types/react @types/node
npm i -D @testing-library/react @types/jest babel-jest @testing-library/jest-dom @testing-library/user-event @testing-library/dom jest
npm i -D identity-obj-proxy storybook-css-modules-preset
touch tsconfig.json

cat <<EOT >.babelrc
{
  "presets": ["next/babel"]
}
EOT
cat <<EOT >jest.config.js
module.exports = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
  testPathIgnorePatterns: ['<rootDir>/.next/', '<rootDir>/node_modules/'],
  moduleNameMapper: {
    '\\.(scss|sass|css)$': 'identity-obj-proxy',
  },
}
EOT
cat <<EOT >jest.setup.ts
import '@testing-library/jest-dom'
EOT
npx sb init
npm i -D storybook-css-modules-preset
rm -fr stories
cat <<EOT >.storybook/main.js
module.exports = {
  stories: [
    '../components/**/*.stories.mdx',
    '../components/**/*.stories.@(js|jsx|ts|tsx)',
  ],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    'storybook-css-modules-preset',
  ],
}
EOT

mkdir components/atoms/SampleTemplate
touch components/atoms/SampleTemplate/styles.module.css

cat <<EOT >components/atoms/SampleTemplate/index.stories.tsx
import Component from '.'

export default {
  title: 'Atoms/Component',
  component: Component,
}
const Template = (args) => <Component {...args} />

export const standard = Template.bind({})
standard.args = {}
EOT
cat <<EOT >components/atoms/SampleTemplate/index.test.tsx
import { render } from '@testing-library/react'
import Index from '.'

test('renders', () => {
  render(<Index />)
})
EOT
cat <<EOT >components/atoms/SampleTemplate/index.tsx
import index from "./SampleTemplate";
export default index
EOT
cat <<EOT >components/atoms/SampleTemplate/SampleTemplate.tsx
import '../../../styles/globals.css'
import 'normalize.css'
import styles from './styles.module.css'
export default ({}) => {
  return <></>
}
EOT
rm README.md
touch README.md

rm -fr pages
mkdir pages
mkdir pages/api
cat <<EOT >pages/index.tsx
import Head from 'next/head'
const page = ()=> {
  return (
    <>
      <Head>
        <title>Change me</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

    </>
  )
}
export default page
EOT
cat <<EOT >pages/404.tsx
import Head from 'next/head'
const page = ()=> {
  return (
    <>
      <h1>404 - Page Not Found</h1>
    </>
  )
}
export default page
EOT
cat <<EOT >pages/_app.tsx
import '../styles/globals.css'

function App({ Component, pageProps }) {
  return <Component {...pageProps} />
}

export default App
EOT
cat <<EOT >pages/api/hello.js
// export default (req, res) => {
//   res.status(200).json({ name: 'John Doe' })
// }
EOT

rm -fr styles
mkdir styles
cat <<EOT >styles/globals.css
@import '../node_modules/normalize.css/normalize.css';
@import url('https://fonts.googleapis.com/css2?family=Roboto&display=swap');
html,
body {
  padding: 0;
  margin: 0;
  font-family: 'Roboto', sans-serif;
}

a {
  color: inherit;
  text-decoration: none;
}

* {
  box-sizing: border-box;
}
#__next {
  min-height: 100vh;
  min-width: 100vw;
}
EOT
rm public/vercel.svg
git init
npm run build
rm -fr .next

cat <<EOT >changePackageJson.js
const fs = require('fs').promises
;(async () => {
  const packageJson = await fs.readFile('./package.json', 'utf8')
  const package = JSON.parse(packageJson)
  package.scripts.export = 'next export'
  package.scripts.test = 'jest --watch'
  await fs.writeFile('./package.json', JSON.stringify(package))
})()
EOT
node changePackageJson.js
rm changePackageJson.js
git add .
git commit -m "inital boilerplate"
git branch -M main