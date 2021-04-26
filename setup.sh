#!/bin/sh
set -e
npx create-next-app $1
cd $1
mkdir scr
mkdir scr/atoms
mkdir scr/molecules
mkdir scr/organisms
mkdir scr/templates
mkdir scr/pages
mkdir scr/functions
mkdir scr/functions/getters
mkdir scr/functions/setters
mkdir scr/hooks

cat <<EOT >styles/globals.css
@import url('https://fonts.googleapis.com/css2?family=Roboto&display=swap');
* {
  box-sizing: border-box;
  margin: 0;
  font-family: 'Roboto', sans-serif;
}

a {
  color: inherit;
  text-decoration: none;
}

#__next {
  min-height: 100vh;
  min-width: 100vw;
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
npm i -D storybook-css-modules-preset @storybook/addon-storyshots
rm -fr stories
cat <<EOT >.storybook/main.js
module.exports = {
  stories: [
    '../scr/**/*.stories.mdx',
    '../scr/**/*.stories.@(js|jsx|ts|tsx)',
  ],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    'storybook-css-modules-preset',
  ],
}
EOT
cat <<EOT >.storybook/preview.js
import '../styles/globals.css'
export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
}
EOT
cat <<EOT >.storybook/storybook.test.js
import initStoryshots from '@storybook/addon-storyshots'
initStoryshots()
EOT

rm README.md
touch README.md

rm -fr pages
mkdir pages
mkdir pages/api
cat <<EOT >pages/index.tsx
import Head from 'next/head'
const page = () => {
  return (
    <>
      <Head>
        <title>Change me</title>
        <link rel='icon' href='/favicon.ico' />
        <meta name='description' content='' />
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
@tailwind base;
@tailwind components;
@tailwind utilities;
@import url('https://fonts.googleapis.com/css2?family=Roboto&display=swap');
html,
body {
  padding: 0;
  margin: 0;
  font-family: 'Roboto', sans-serif;
  overflow: hidden;
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
  display: grid;
  place-items: center;
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
  package.scripts.export = 'next build && next export'
  package.scripts.deploy = 'npm run export && mkdir firebaseBuild && cp server.js firebaseBuild/index.js && cp server.js firebaseBuild/index.js && cp package*.json firebaseBuild && cp -r .next firebaseBuild && cp -r public firebaseBuild && cross-env NODE_ENV=production firebase deploy --only functions,hosting ; rm -fr firebaseBuild'
  package.scripts.test = 'jest --watch'
  console.log(package)
  await fs.writeFile('./package.json', JSON.stringify(package))
})()
EOT
node changePackageJson.js
rm changePackageJson.js

echo .firebase >> .gitignore
npm i firebase-functions
npm i -D firebase-admin cross-env 
cat <<EOT >.firebaserc
{
  "projects": {
    "default": "Replace-me"
  }
}
EOT
cat <<EOT >firebase.json
{
  "hosting": {
    "public": "out",
    "rewrites": [
      {
        "source": "**",
        "function": "nextServer"
      }
    ]
  },
  "functions": {
    "source": "firebaseBuild",
    "runtime": "nodejs12"
  }
}
EOT
cat <<EOT >server.js
const functions = require('firebase-functions')
const { default: next } = require('next')

const isDev = process.env.NODE_ENV !== 'production'

const server = next({
  dev: isDev,
  conf: { distDir: '.next' },
})

const nextjsHandle = server.getRequestHandler()

exports.nextServer = functions
  .runWith({
    timeoutSeconds: 15,
    memory: '128MB',
  })
  .https.onRequest((req, res) => {
    return server.prepare().then(() => nextjsHandle(req, res))
  })
EOT
npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
cat <<EOT >tailwind.config.js
module.exports = {
  purge: ['./pages/**/*.{js,ts,jsx,tsx}', './components/**/*.{js,ts,jsx,tsx}'],
  darkMode: false,
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
EOT
cat <<EOT >postcss.config.js
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOT



npx prettier --write .
git add .
git commit -m "Inital boilerplate"
git branch -M main
